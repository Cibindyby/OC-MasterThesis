using Random
using Printf
using IterTools

include("../globalParams.jl")
include("../utils/utilityFuncs.jl")
include("../standardCGP/chromosome.jl")
include("../utils/crossover/crossoverAlgos.jl")

# ID's: Begin with population, afterwards elitists.
# Total number of population: population.len + elitists.len
# Andere Idee:
# größere Population: Population <- population + elitisten
# speichere elitist id

mutable struct RunnerElitistMuLambda
    params::CgpParameters
    data::Adjoint{Bool, Matrix{Bool}}
    label::Adjoint{Bool, Matrix{Bool}}
    eval_data::Adjoint{Bool, Matrix{Bool}}
    eval_label::Adjoint{Bool, Matrix{Bool}}
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
    oneFifthPositive::Bool
end

function Base.show(io::IO, runner::RunnerElitistMuLambda)
    println(io, "Fitnesses: ", runner.fitness_vals)
end

function RunnerElitistMuLambda(params::CgpParameters,
    data::Adjoint{Bool, Matrix{Bool}},
    label::Adjoint{Bool, Matrix{Bool}},
    eval_data::Adjoint{Bool, Matrix{Bool}},
    eval_label::Adjoint{Bool, Matrix{Bool}})

    rng = MersenneTwister()
    iteration = 0

    oneFifthPositive = false
    
    last_crossover_rate = NaN
    if params.crossover_rate_type == 1
        last_crossover_rate = params.crossover_rate
    else
        last_crossover_rate = params.crossover_start
    end

    #data = transpose_vec(data)
    #eval_data = transpose_vec(eval_data)

    population = Vector{Chromosome}(undef, params.population_size + params.elitism_number)
    fitness_vals = Vector{Float32}(undef, params.population_size + params.elitism_number)

    for i in 1:(params.population_size + params.elitism_number)
        chromosome = Chromosome(params)
        fitness = evaluate!(chromosome, data, label)

        if isnan(fitness)
            fitness = typemax(Float32)
        end

        fitness_vals[i] = fitness
        population[i] = chromosome
    end

    # Get sorted fitness vals
    fitness_vals_sorted = deepcopy(fitness_vals)
    sort!(fitness_vals_sorted)

    # Reverse fitness_vals_sorted to pop the best fitness first
    temp_fitness_vals_sorted = deepcopy(fitness_vals_sorted)
    reverse!(temp_fitness_vals_sorted)
    unique!(temp_fitness_vals_sorted)

    elitist_ids = Int[]
    
    while length(elitist_ids) < params.elitism_number
        current_best_fitness_val = pop!(temp_fitness_vals_sorted)

        get_argmins_of_value!(fitness_vals, elitist_ids, current_best_fitness_val)
    end

    elitist_ids = elitist_ids .-1
    resize!(elitist_ids, params.elitism_number)

    child_ids = collect(0:(params.population_size + params.elitism_number - 1))
    child_ids = vect_difference(child_ids, elitist_ids)

    return RunnerElitistMuLambda(params, data, label, eval_data, eval_label, population, fitness_vals, fitness_vals_sorted, rng, elitist_ids, child_ids, Int[], iteration, last_crossover_rate, oneFifthPositive)
end

function learn_step!(runner::RunnerElitistMuLambda)
    get_child_ids(runner)
    crossover(runner)
    mutate_chromosomes!(runner)
    eval_chromosomes!(runner)
    get_elitists(runner)
end

function get_child_ids(runner::RunnerElitistMuLambda)
    child_ids = collect(0:(runner.params.population_size + runner.params.elitism_number - 1))
    runner.child_ids = vect_difference(child_ids, runner.elitist_ids)
end

function mutate_chromosomes!(runner::RunnerElitistMuLambda)
    # mutate new chromosomes; do not mutate elitists
    for id in runner.child_ids
        mutate_single!(runner.population[id+1])
    end
end

function eval_chromosomes!(runner::RunnerElitistMuLambda)
    for id in 0:length(runner.population)-1
        fitness = evaluate!(runner.population[id+1], runner.data, runner.label)

        if isnan(fitness) || isinf(fitness)
            fitness = typemax(Float32)
        end

        runner.fitness_vals[id+1] = fitness
    end

    best_fitnesses_sorted = deepcopy(runner.fitness_vals)
    sort!(best_fitnesses_sorted)

    runner.fitness_vals_sorted = best_fitnesses_sorted
end

function get_elitists(runner::RunnerElitistMuLambda)
    # Get mu - many best fitness vals
    sorted_fitness_vals = unique(deepcopy(runner.fitness_vals_sorted))

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
                        deleteat!(parent_candidate_ids, index)
                    end
                    if length(parent_candidate_ids) <= remaining_new_parent_spaces
                        break
                    end
                end
            end

            resize!(parent_candidate_ids, runner.params.elitism_number - length(new_parent_ids))
            append!(new_parent_ids, parent_candidate_ids)

            if length(new_parent_ids) == runner.params.elitism_number
                break
            end
        end
    end
    @assert length(runner.elitist_ids) == length(new_parent_ids)
    runner.elitist_ids = new_parent_ids .-1
end

function get_best_fitness(runner::RunnerElitistMuLambda)
    return runner.fitness_vals_sorted[1]
end

function get_test_fitness(runner::RunnerElitistMuLambda)
    best_fitn = typemax(Float32)

    for individual in runner.population
        fitness = evaluate!(individual, runner.eval_data, runner.eval_label)

        if !isnan(fitness) && fitness < best_fitn
            best_fitn = fitness
        end
    end

    return best_fitn
end

function get_elitism_fitness(runner::RunnerElitistMuLambda)
    results = Vector{Float32}(undef, runner.params.elitism_number)
    for id in runner.elitist_ids
        push!(results, runner.fitness_vals[id+1])
    end
    return results
end


function crossover(runner::RunnerElitistMuLambda)
    # get all new children ids; i.e. the ID's of chromosomes in the population that
    # can be replaced.
    # It must exclude the elitists, otherwise they may be replaced too

    children_set = collect(0:(runner.params.population_size + runner.params.elitism_number - 1))
    children_set = vect_difference(children_set, runner.elitist_ids)

    # create new population
    new_population = deepcopy(runner.population)

    crossover_for_this_iteration = get_crossover_rate!(runner)

    for child_ids in Iterators.partition(children_set, 2)
        crossover_prob = rand(Float32)

        parent_ids = rand(runner.elitist_ids, 2)

        if crossover_prob <= crossover_for_this_iteration
            if runner.params.crossover_type == 0
                new_population = single_point_crossover!(runner.rng, runner.params.nbr_inputs, runner.params.nbr_computational_nodes, runner.population, new_population, child_ids[1], child_ids[2], parent_ids[1], parent_ids[2])
            elseif runner.params.crossover_type == 1
                new_population = two_point_crossover!(runner.params.nbr_inputs, runner.params.nbr_computational_nodes, runner.population, new_population, child_ids[1], child_ids[2], parent_ids[1], parent_ids[2])
            elseif runner.params.crossover_type == 2
                new_population = uniform_crossover!(runner.params.nbr_inputs, runner.params.nbr_computational_nodes, runner.population, new_population, child_ids[1], child_ids[2], parent_ids[1], parent_ids[2])
            elseif runner.params.crossover_type == 3
                new_population = no_crossover!(runner.population, new_population, child_ids[1], child_ids[2], parent_ids[1], parent_ids[2])
            else
                error("not implemented crossover type")
            end
        else
            # no crossover, just copy parents
            
            chrom1 = deepcopy(runner.population[parent_ids[1]+1])
            chrom2 = deepcopy(runner.population[parent_ids[2]+1])
            new_population[child_ids[1]+1] = chrom1
            new_population[child_ids[2]+1] = chrom2
        end
        runner.population = new_population
    end
    

    if runner.params.crossover_rate_type == 3
        twentyPercentChildren = ceil(Int64, length(runner.child_ids)) #20% der Kinder (aufgerundet)
        betterThenAllParents = 0;

        for id in runner.child_ids
            fitn = evaluate!(runner.population[id+1], runner.data, runner.label)
    
            if isnan(fitn) || isinf(fitn)
                fitn = typemax(Float32)
            end
    
            betterThanParents = true;
            for elit in runner.elitist_ids
                if fitn >= evaluate!(runner.population[elit + 1], runner.data, runner.label)
                    betterThanParents = false;
                    break
                end
            end

            if(betterThanParents)
                betterThenAllParents = betterThenAllParents + 1
            end
        end

        if betterThenAllParents >= twentyPercentChildren
            runner.oneFifthPositive = true
        else
            runner.oneFifthPositive = false
        end

    end
        
end

function get_crossover_rate!(runner::RunnerElitistMuLambda)
    crossover_rate_now = runner.last_crossover_rate
    offset_is_active = runner.params.crossover_offset > runner.iteration

    if runner.params.crossover_rate_type == 1 #konstant
        
        if offset_is_active
            crossover_rate_now = 0.0f0
        end

    elseif runner.params.crossover_rate_type == 2 #Clegg

        if offset_is_active
            crossover_rate_now = 0.0f0
        else
            crossover_rate_now = runner.last_crossover_rate - runner.params.crossover_delta
            if crossover_rate_now < 0.0f0
                crossover_rate_now = 0.0f0
            end
            runner.last_crossover_rate = crossover_rate_now
        end

    elseif runner.params.crossover_rate_type == 3 #oneFifth

        if offset_is_active
            crossover_rate_now = 0.0f0
        else
            
            if runner.oneFifthPositive
                crossover_rate_now = runner.last_crossover_rate * 1.1
            else
                crossover_rate_now = runner.last_crossover_rate * 0.9
            end

            if crossover_rate_now > 1.0f0
                crossover_rate_now = 1.0f0
            end
            runner.last_crossover_rate = crossover_rate_now
        end

    end

    return crossover_rate_now
end
