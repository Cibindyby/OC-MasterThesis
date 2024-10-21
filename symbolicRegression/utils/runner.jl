using Random
using Printf

include("../globalParams.jl")
include("../utils/utilityFuncs.jl")
include("../standardCGP/chromosome.jl")

mutable struct Runner
    params::CgpParameters
    data::Vector{Vector{Float32}}
    label::Vector{Float32}
    eval_data::Vector{Vector{Float32}}
    eval_label::Vector{Float32}
    population::Vector{Chromosome}
    best_fitness::Float32
    fitness_vals::Vector{Float32}
    parent_id::Int
end

function Base.show(io::IO, runner::Runner)
    print(io, "Parent: ", runner.population[runner.parent_id])
    println(io, "Fitness: ", runner.best_fitness)
end

function Runner(params::CgpParameters,
                data::Vector{Vector{Float32}},
                label::Vector{Float32},
                eval_data::Vector{Vector{Float32}},
                eval_label::Vector{Float32})
    chromosomes = Vector{Chromosome}(undef, params.mu + params.lambda)
    fitness_vals = Vector{Float32}(undef, params.mu + params.lambda)

    # transpose so a whole row of the dataset can be used as an array for calculation
    data = transpose(data)
    eval_data = transpose(eval_data)

    for i in 1:(params.mu + params.lambda)
        chromosome = Chromosome(params)
        fitness = evaluate(chromosome, data, label)
        if isnan(fitness)
            fitness = typemax(Float32)
        end
        fitness_vals[i] = fitness
        chromosomes[i] = chromosome
    end

    best_fitness = get_min(fitness_vals)
    parent_id = get_argmin(fitness_vals)

    Runner(params, data, label, eval_data, eval_label, chromosomes, best_fitness, fitness_vals, parent_id)
end

function learn_step!(runner::Runner, i::Int)
    mutate_chromosomes!(runner)
    eval_chromosomes!(runner)
    new_parent_by_neutral_search!(runner)
end


function new_parent_by_neutral_search!(runner::Runner)
    min_keys = Int[]
    get_argmins_of_value(runner.fitness_vals, min_keys, runner.best_fitness)

    if length(min_keys) == 1
        runner.parent_id = min_keys[1]
    else
        if runner.parent_id in min_keys
            deleteat!(min_keys, findfirst(==(runner.parent_id), min_keys))
        end
        runner.parent_id = rand(min_keys)
    end
end

function mutate_chromosomes!(runner::Runner)
    for i in 1:(runner.params.mu + runner.params.lambda)
        if i == runner.parent_id
            continue
        end
        runner.population[i] = deepcopy(runner.population[runner.parent_id])
        mutate_single!(runner.population[i])
    end
end

function eval_chromosomes!(runner::Runner)
    for i in 1:(runner.params.mu + runner.params.lambda)
        if i != runner.parent_id
            fitness = evaluate(runner.population[i], runner.data, runner.label)
            if isnan(fitness) || isinf(fitness)
                fitness = typemax(Float32)
            end
            runner.fitness_vals[i] = fitness
        end
    end

    runner.best_fitness = get_min(runner.fitness_vals)
end

function get_test_fitness(runner::Runner)
    best_fitness = typemax(Float32)

    for individual in runner.population
        fitness = evaluate(individual, runner.eval_data, runner.eval_label)
        if !isnan(fitness) && fitness < best_fitness
            best_fitness = fitness
        end
    end
    return best_fitness
end

get_best_fitness(runner::Runner) = runner.best_fitness

get_parent(runner::Runner) = deepcopy(runner.population[runner.parent_id])

