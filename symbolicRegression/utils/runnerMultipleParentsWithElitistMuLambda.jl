module runnerCrossoverMuLambda

    using Random
    using StatsBase
    using IterTools

    include("../globalParams.jl")
    include("utilityFuncs.jl")
    #todo:
    #import CrossoverAlgos
    include("crossover/crossoverAlgos.jl")
    include("../standardCGP/chromosome.jl")

    mutable struct Runner
        params::CgpParameters
        data::Vector{Vector{Float32}}
        label::Vector{Float32}
        eval_data::Vector{Vector{Float32}}
        eval_label::Vector{Float32}
        population::Vector{Chromosome}
        fitness_vals_sorted::Vector{Float32}
        fitness_vals::Vector{Float32}
        rng::MersenneTwister
        elitist_ids::Vector{Int}
        child_ids::Vector{Int}
        selected_parents_ids::Vector{Int}
    end

    function Base.show(io::IO, runner::Runner)
        println(io, "Fitnesses: $(runner.fitness_vals)")
    end

    function Runner(params::CgpParameters,
                    data::Vector{Vector{Float32}},
                    label::Vector{Float32},
                    eval_data::Vector{Vector{Float32}},
                    eval_label::Vector{Float32})
        rng = MersenneTwister()

        data = utilityFuncs.transpose_vec(data)
        eval_data = utilityFuncs.transpose_vec(eval_data)

        population = Vector{Chromosome}(undef, params.population_size + params.elitism_number)
        fitness_vals = Vector{Float32}(undef, params.population_size + params.elitism_number)

        for i in 1:(params.population_size + params.elitism_number)
            chromosome = Chromosome(params)
            fitness = evaluate(chromosome, data, label)

            if isnan(fitness)
                fitness = typemax(Float32)
            end

            fitness_vals[i] = fitness
            population[i] = chromosome
        end

        fitness_vals_sorted = sort(fitness_vals)

        temp_fitness_vals_sorted = reverse(copy(fitness_vals_sorted))
        unique!(temp_fitness_vals_sorted)

        elitist_ids = Int[]

        while length(elitist_ids) < params.elitism_number
            current_best_fitness_val = pop!(temp_fitness_vals_sorted)
            utilityFuncs.get_argmins_of_value!(fitness_vals, elitist_ids, current_best_fitness_val)
        end

        resize!(elitist_ids, params.elitism_number)

        child_ids = setdiff(1:(params.population_size + params.elitism_number), elitist_ids)

        Runner(
            params,
            data,
            label,
            eval_data,
            eval_label,
            population,
            fitness_vals,
            fitness_vals_sorted,
            rng,
            elitist_ids,
            Int[],
            child_ids
        )
    end

    function learn_step!(runner::Runner, i::Int)
        get_child_ids!(runner)
        reorder!(runner)
        crossover!(runner)
        mutate_chromosomes!(runner)
        eval_chromosomes!(runner)
        get_elitists!(runner)
    end

    function get_child_ids!(runner::Runner)
        runner.child_ids = setdiff(1:(runner.params.population_size + runner.params.elitism_number), runner.elitist_ids)
    end

    function reorder!(runner::Runner)
        reorder_set = setdiff(1:(runner.params.population_size + runner.params.elitism_number), runner.elitist_ids)
        for id in reorder_set
            reorder!(runner.population[id])
        end
    end

    function mutate_chromosomes!(runner::Runner)
        for id in runner.child_ids
            mutate_single!(runner.population[id])
        end
    end

    function eval_chromosomes!(runner::Runner)
        for id in runner.child_ids
            fitness = evaluate(runner.population[id], runner.data, runner.label)

            if isnan(fitness) || isinf(fitness)
                fitness = typemax(Float32)
            end

            runner.fitness_vals[id] = fitness
        end
        best_fitnesses_sorted = copy(self.fitness_vals)
        sort!(best_fitnesses_sorted)
        self.fitness_vals_sorted = best_fitnesses_sorted
    end


    function get_elitists!(self)
        # Get mu - many best fitness vals
        sorted_fitness_vals = copy(self.fitness_vals_sorted)
        # remove duplicates
        unique!(sorted_fitness_vals)

        new_parent_ids = Vector{Int}(undef, 0)
        sizehint!(new_parent_ids, self.params.elitism_number)

        for current_best_fitness_val in sorted_fitness_vals
            parent_candidate_ids = Vector{Int}(undef, 0)
            sizehint!(parent_candidate_ids, self.params.population_size)

            get_argmins_of_value!(self.fitness_vals, parent_candidate_ids, current_best_fitness_val)

            remaining_new_parent_spaces = self.params.elitism_number - length(new_parent_ids)
            if length(parent_candidate_ids) <= remaining_new_parent_spaces
                # if enough space left, extend all parent candidates
                append!(new_parent_ids, parent_candidate_ids)
            else
                # case: more candidates than parent spaces left
                # remove parents from the previous generation until either all parents removed
                # or parent_candidates.len can fill remaining spaces

                # remove parent ids until either no parent ids are left or the candidate list fits
                # into the remaining new parent set
                for old_parent_id in self.elitist_ids
                    # if the old parent id is in candidate list
                    if old_parent_id in parent_candidate_ids
                        # get index of parent in the candidate list
                        index = findfirst(isequal(old_parent_id), parent_candidate_ids)
                        # remove in O(1)
                        deleteat!(parent_candidate_ids, index)
                        # if enough parents are removed, break
                        if length(parent_candidate_ids) <= remaining_new_parent_spaces
                            break
                        end
                    end
                end

                resize!(parent_candidate_ids, min(length(parent_candidate_ids), self.params.elitism_number - length(new_parent_ids)))
                append!(new_parent_ids, parent_candidate_ids)

                if length(new_parent_ids) == self.params.elitism_number
                    break
                end
            end
        end
        @assert length(self.elitist_ids) == length(new_parent_ids)
        self.elitist_ids = new_parent_ids
    end

    function get_best_fitness(self)
        return self.fitness_vals_sorted[1]
    end

    function get_test_fitness!(self)
        best_fitness = Inf32

        for individual in self.population
            fitness = evaluate(individual, self.eval_data, self.eval_label)

            if !isnan(fitness) && fitness < best_fitness
                best_fitness = fitness
            end
        end
        return best_fitness
    end

    function get_elitism_fitness(self)
        results = Vector{Float32}(undef, self.params.elitism_number)
        for (i, id) in enumerate(self.elitist_ids)
            results[i] = self.fitness_vals[id]
        end
        return results
    end

    function get_parent(self)
        idx = argmin(self.fitness_vals)
        return deepcopy(self.population[idx])
    end

    function crossover!(self)
        # get all new children ids; i.e. the ID's of chromosomes in the population that
        # can be replaced.
        # It must exclude the elitists, otherwise they may be replaced too
        children_set = setdiff(1:(self.params.population_size + self.params.elitism_number), self.elitist_ids)

        # create new population
        new_population = deepcopy(self.population)

        for child_ids in IterTools.partition(children_set, 2)
            crossover_prob = rand()

            parent_ids = sample(self.elitist_ids, 2, replace=false)

            if crossover_prob <= self.params.crossover_rate
                if self.params.crossover_type == 0
                    single_point_crossover!(self, new_population, child_ids[1], child_ids[2], parent_ids[1], parent_ids[2])
                elseif self.params.crossover_type == 1
                    multi_point_crossover!(self, new_population, child_ids[1], child_ids[2], parent_ids[1], parent_ids[2])
                elseif self.params.crossover_type == 2
                    uniform_crossover!(self, new_population, child_ids[1], child_ids[2], parent_ids[1], parent_ids[2])
                elseif self.params.crossover_type == 3
                    no_crossover!(self, new_population, child_ids[1], child_ids[2], parent_ids[1], parent_ids[2])
                else
                    error("not implemented crossover type")
                end
            else
                # no crossover, just copy parents
                new_population[child_ids[1]] = deepcopy(self.population[parent_ids[1]])
                new_population[child_ids[2]] = deepcopy(self.population[parent_ids[2]])
            end
        end
        self.population = new_population
    end
end

#This Julia code translates the Rust `Runner` struct and its associated methods. Note that some functions like `crossover!` and `get_elitists!` are not fully implemented as they were not provided in the original Rust code. Also, I've assumed that `Chromosome`, `GlobalParams`, `utilityFuncs`, and `CrossoverAlgos` are defined elsewhere, as they were imported in the Rust code.

#The Julia version uses similar data structures and follows the same logic as the Rust code. Some Rust-specific constructs have been adapted to Julia equivalents. For example:

#1. `Vec` is replaced with `Vector`.
#2. `usize` is replaced with `Int`.
#3. `f32` is replaced with `Float32`.
#4. The `Display` trait implementation is replaced with a `Base.show` method.
#5. Rust's `thread_rng()` is replaced with Julia's `MersenneTwister()`.

#Remember to implement or import the missing functions and types (like `Chromosome`, `evaluate`, etc.) to make this code fully functional in Julia.

