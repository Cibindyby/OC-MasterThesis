using Random
using Printf
using IterTools

include("../globalParams.jl")
include("../utils/utilityFuncs.jl")
include("../standardCGP/chromosome.jl")

# ID's: Begin with population, afterwards elitists.
# Total number of population: population.len + elitists.len
# Andere Idee:
# größere Population: Population <- population + elitisten
# speichere elitist id

mutable struct RunnerElitistMuLambda
    params::CgpParameters
    data::Vector{Vector{Bool}}
    label::Vector{Bool}
    eval_data::Vector{Vector{Bool}}
    eval_label::Vector{Bool}
    population::Vector{Chromosome}
    fitness_vals_sorted::Vector{Float32}
    # check for correctness, must include elitists too
    fitness_vals::Vector{Float32}
    rng::MersenneTwister
    elitist_ids::Vector{Int}
    child_ids::Vector{Int}
    # check for correctness, must include elitists too
    selected_parents_ids::Vector{Int}
    iteration::Int
    last_crossover_rate::Float32
end

function Base.show(io::IO, runner::RunnerElitistMuLambda)
    println(io, "Fitnesses: ", runner.fitness_vals)
end

function RunnerElitistMuLambda(params::CgpParameters, data::Vector{Vector{Bool}}, label::Vector{Bool}, eval_data::Vector{Vector{Bool}}, eval_label::Vector{Bool})
    rng = MersenneTwister()
    iteration = 0
    
    if params.crossover_rate_type == 1
        last_crossover_rate = params.crossover_rate
    else
        last_crossover_rate = params.crossover_start
    end

    data = utility_funcs.transpose(data)
    eval_data = utility_funcs.transpose(eval_data)

    population = Vector{Chromosome}(undef, params.population_size + params.elitism_number)
    fitness_vals = Vector{Float32}(undef, params.population_size + params.elitism_number)

    for i in 1:(params.population_size + params.elitism_number)
        chromosome = Chromosome(params)
        fitness = chromosome.evaluate(data, label)

        if isnan(fitness)
            fitness = typemax(Float32)
        end

        fitness_vals[i] = fitness
        population[i] = chromosome
    end

    # Get sorted fitness vals
    fitness_vals_sorted = copy(fitness_vals)
    sort!(fitness_vals_sorted)

    # Reverse fitness_vals_sorted to pop the best fitness first
    temp_fitness_vals_sorted = copy(fitness_vals_sorted)
    reverse!(temp_fitness_vals_sorted)
    unique!(temp_fitness_vals_sorted)

    elitist_ids = Int[]
    
    while length(elitist_ids) < params.elitism_number
        current_best_fitness_val = pop!(temp_fitness_vals_sorted)

        get_argmins_of_value!(fitness_vals, elitist_ids, current_best_fitness_val)
    end

    truncate!(elitist_ids, params.elitism_number)

    child_ids = collect(0:(params.population_size + params.elitism_number - 1))
    child_ids = vect_difference(child_ids, elitist_ids)

    return RunnerElitistMuLambda(params, data, label, eval_data, eval_label, population, fitness_vals, fitness_vals_sorted, rng, elitist_ids, child_ids, Int[], iteration, last_crossover_rate)
end

function learn_step(runner::RunnerElitistMuLambda, i::Int)
    get_child_ids(runner)
    crossover(runner)
    mutate_chromosomes(runner)
    eval_chromosomes(runner)
    get_elitists(runner)
end

function get_child_ids(runner::RunnerElitistMuLambda)
    child_ids = collect(0:(runner.params.population_size + runner.params.elitism_number - 1))
    runner.child_ids = vect_difference(child_ids, runner.elitist_ids)
end

function mutate_chromosomes(runner::RunnerElitistMuLambda)
    # mutate new chromosomes; do not mutate elitists
    for id in runner.child_ids
        runner.population[id].mutate_single()
    end
end

function eval_chromosomes(runner::RunnerElitistMuLambda)
    for id in runner.child_ids
        fitness = runner.population[id].evaluate(runner.data, runner.label)

        if isnan(fitness) || isinf(fitness)
            fitness = typemax(Float32)
        end

        runner.fitness_vals[id] = fitness
    end

    best_fitnesses_sorted = copy(runner.fitness_vals)
    sort!(best_fitnesses_sorted)

    runner.fitness_vals_sorted = best_fitnesses_sorted
end

function get_elitists(runner::RunnerElitistMuLambda)
    # Get mu - many best fitness vals
    sorted_fitness_vals = unique(copy(runner.fitness_vals_sorted))

    new_parent_ids = Int[]
    for current_best_fitness_val in sorted_fitness_vals
        parent_candidate_ids = Int[]

        get_argmins_of_value!(runner.fitness_vals, parent_candidate_ids, current_best_fitness_val)

        remaining_new_parent_spaces = runner.params.elitism_number - length(new_parent_ids)
        if length(parent_candidate_ids) <= remaining_new_parent_spaces
            append!(new_parent_ids, parent_candidate_ids)
        else
            for old_parent_id in runner.elitist_ids
                if old_parent_id in parent_candidate_ids
                    index = findfirst(==(old_parent_id), parent_candidate_ids)
                    if index !== nothing
                        pop!(parent_candidate_ids, index)
                    end
                    if length(parent_candidate_ids) <= remaining_new_parent_spaces
                        break
                    end
                end
            end

            truncate!(parent_candidate_ids, runner.params.elitism_number - length(new_parent_ids))
            append!(new_parent_ids, parent_candidate_ids)

            if length(new_parent_ids) == runner.params.elitism_number
                break
            end
        end
    end
    @assert length(runner.elitist_ids) == length(new_parent_ids)
    runner.elitist_ids = new_parent_ids
end

function get_best_fitness(runner::RunnerElitistMuLambda)
    return runner.fitness_vals_sorted[1]
end

function get_test_fitness(runner::RunnerElitistMuLambda)
    best_fitness = typemax(Float32)

    for individual in runner.population
        fitness = individual.evaluate(runner.eval_data, runner.eval_label)

        if !isnan(fitness) && fitness < best_fitness
            best_fitness = fitness
        end
    end

    iteration += 1

    return best_fitness
end

function get_elitism_fitness(runner::RunnerElitistMuLambda)
    results = Vector{Float32}(undef, runner.params.elitism_number)
    for id in runner.elitist_ids
        push!(results, runner.fitness_vals[id])
    end
    return results
end

function get_parent(runner::RunnerElitistMuLambda)
    idx = get_argmin(runner.fitness_vals)
    return copy(runner.population[idx])
end

function crossover(runner::RunnerElitistMuLambda)
    # get all new children ids; i.e. the ID's of chromosomes in the population that
    # can be replaced.
    # It must exclude the elitists, otherwise they may be replaced too

    children_set = collect(0:(runner.params.population_size + runner.params.elitism_number - 1))
    children_set = vect_difference(children_set, runner.elitist_ids)

    # create new population
    new_population = copy(runner.population)

    crossover_for_this_iteration = get_crossover_rate()

    for (i, child_ids) in Iterators.partition(children_set, 2)
        crossover_prob = rand(Float32)

        parent_ids = rand(runner.elitist_ids, 2)

        if crossover_prob <= crossover_for_this_iteration
            if runner.params.crossover_type == 0
                crossover_algos.single_point_crossover(runner, new_population, child_ids[1], child_ids[2], parent_ids[1], parent_ids[2])
            elseif runner.params.crossover_type == 1
                crossover_algos.two_point_crossover(runner, new_population, child_ids[1], child_ids[2], parent_ids[1], parent_ids[2])
            elseif runner.params.crossover_type == 2
                crossover_algos.uniform_crossover(runner, new_population, child_ids[1], child_ids[2], parent_ids[1], parent_ids[2])
            elseif runner.params.crossover_type == 3
                crossover_algos.no_crossover(runner, new_population, child_ids[1], child_ids[2], parent_ids[1], parent_ids[2])
            else
                error("not implemented crossover type")
            end
        else
            # no crossover, just copy parents
            new_population[child_ids[1]] = copy(runner.population[parent_ids[1]])
            new_population[child_ids[2]] = copy(runner.population[parent_ids[2]])
        end
    end
    runner.population = new_population
end

function get_crossover_rate()
    crossover_rate_now = last_crossover_rate
    offset_is_active = params.crossover_offset > iteration

    if params.crossover_rate_type == 1 #konstant
        
        if offset_is_active
            crossover_rate_now = 0.0f0
        end

    elseif params.crossover_rate_type == 2 #Clegg

        if offset_is_active
            crossover_rate_now = 0.0f0
        else
            crossover_rate_now = last_crossover_rate - params.crossover_delta
            last_crossover_rate = crossover_rate_now
        end

    elseif params.crossover_rate_type == 3 #oneFifth

        if offset_is_active
            crossover_rate_now = 0.0f0
        else
            #TODO: crossover rate berechnen für one fifth
            crossover_rate_now = last_crossover_rate + params.crossover_delta
            last_crossover_rate = crossover_rate_now
        end

    end

    return crossover_rate_now
end
