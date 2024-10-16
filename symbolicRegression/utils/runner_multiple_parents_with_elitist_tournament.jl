using Random
using Printf
using IterTools

include("../globalParams.jl")
include("utilityFuncs.jl")
include("crossover/crossoverAlgos.jl")

# ID's: Begin with population, afterwards elitists.
# Total number of population: population.len + elitists.len
# Andere Idee:
# größere Population: Population <- population + elitisten
# speichere elitist id

struct RunnerMultipleParentsTournament
    params::CgpParameters
    data::Vector{Vector{Float32}}
    label::Vector{Float32}
    eval_data::Vector{Vector{Float32}}
    eval_label::Vector{Float32}
    population::Vector{Chromosome}
    fitness_vals_sorted::Vector{Float32}
    # check for correctness, must include elitists too
    fitness_vals::Vector{Float32}
    # check for correctness, must include elitists too
    tournament_selected::Vector{Int}
    rng::MersenneTwister

    elitist_ids::Vector{Int}
    child_ids::Vector{Int}
end

function Base.show(io::IO, runner::RunnerMultipleParentsTournament)
    println(io, "Fitnesses: ", runner.fitness_vals)
end

function RunnerMultipleParentsTournament(params::CgpParameters, data::Vector{Vector{Float32}}, label::Vector{Float32}, eval_data::Vector{Vector{Float32}}, eval_label::Vector{Float32})
    rng = MersenneTwister()

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

        get_argmins_of_value(fitness_vals, elitist_ids, current_best_fitness_val)
    end

    truncate!(elitist_ids, params.elitism_number)

    child_ids = collect(0:(params.population_size + params.elitism_number - 1))
    child_ids = vect_difference(child_ids, elitist_ids)

    return RunnerMultipleParentsTournament(params, data, label, eval_data, eval_label, population, fitness_vals, fitness_vals_sorted, rng, elitist_ids, child_ids)
end

function learn_step(runner::RunnerMultipleParentsTournament, i::Int)
    get_child_ids(runner)

    tournament_selection(runner)

    reorder(runner)

    crossover(runner)

    mutate_chromosomes(runner)

    eval_chromosomes(runner)

    get_elitists(runner)
end

function get_child_ids(runner::RunnerMultipleParentsTournament)
    # elitists should not be reordered as they did not change
    child_ids = collect(0:(runner.params.population_size + runner.params.elitism_number - 1))
    child_ids = vect_difference(child_ids, runner.elitist_ids)

    runner.child_ids = child_ids
end

function reorder(runner::RunnerMultipleParentsTournament)
    # elitists should not be reordered as they did not change
    reorder_set = collect(0:(runner.params.population_size + runner.params.elitism_number - 1))
    reorder_set = vect_difference(reorder_set, runner.elitist_ids)

    for id in reorder_set
        runner.population[id].reorder()
    end
end

function tournament_selection(runner::RunnerMultipleParentsTournament)
    selection = Int[]

    for _ in 1:runner.params.population_size
        winner_id = argmin(rand(runner.fitness_vals, runner.params.tournament_size))
        push!(selection, winner_id)
    end

    runner.tournament_selected = selection
end

function mutate_chromosomes(runner::RunnerMultipleParentsTournament)
    for id in runner.child_ids
        runner.population[id].mutate_single()
    end
end

function eval_chromosomes(runner::RunnerMultipleParentsTournament)
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

function get_elitists(runner::RunnerMultipleParentsTournament)
    temp_fitness_vals_sorted = copy(runner.fitness_vals_sorted)
    unique!(temp_fitness_vals_sorted)
    reverse!(temp_fitness_vals_sorted)

    elitist_ids = Int[]

    while length(elitist_ids) < runner.params.elitism_number
        current_best_fitness_val = pop!(temp_fitness_vals_sorted)

        get_argmins_of_value(runner.fitness_vals, elitist_ids, current_best_fitness_val)
    end

    truncate!(elitist_ids, runner.params.elitism_number)
    runner.elitist_ids = elitist_ids
end

function get_best_fitness(runner::RunnerMultipleParentsTournament)
    return runner.fitness_vals_sorted[1]
end

function get_test_fitness(runner::RunnerMultipleParentsTournament)
    best_fitness = typemax(Float32)

    for individual in runner.population
        fitness = individual.evaluate(runner.eval_data, runner.eval_label)

        if !isnan(fitness) && fitness < best_fitness
            best_fitness = fitness
        end
    end
    return best_fitness
end

function get_elitism_fitness(runner::RunnerMultipleParentsTournament)
    results = Vector{Float32}(undef, runner.params.elitism_number)
    for id in runner.elitist_ids
        push!(results, runner.fitness_vals[id])
    end
    return results
end

function get_parent(runner::RunnerMultipleParentsTournament)
    idx = get_argmin(runner.fitness_vals)
    return copy(runner.population[idx])
end

function crossover(runner::RunnerMultipleParentsTournament)
    children_set = collect(0:(runner.params.population_size + runner.params.elitism_number - 1))
    children_set = vect_difference(children_set, runner.elitist_ids)

    new_population = copy(runner.population)

    for (i, child_ids) in Iterators.partition(children_set, 2)
        crossover_prob = rand(Float32)
        if crossover_prob <= runner.params.crossover_rate
            if runner.params.crossover_type == 0
                crossover_algos.single_point_crossover(runner, new_population, child_ids[1], child_ids[2], runner.tournament_selected[2 * i], runner.tournament_selected[2 * i + 1])
            elseif runner.params.crossover_type == 1
                crossover_algos.multi_point_crossover(runner, new_population, child_ids[1], child_ids[2], runner.tournament_selected[2 * i], runner.tournament_selected[2 * i + 1])
            elseif runner.params.crossover_type == 2
                crossover_algos.uniform_crossover(runner, new_population, child_ids[1], child_ids[2], runner.tournament_selected[2 * i], runner.tournament_selected[2 * i + 1])
            elseif runner.params.crossover_type == 3
                crossover_algos.no_crossover(runner, new_population, child_ids[1], child_ids[2], runner.tournament_selected[2 * i], runner.tournament_selected[2 * i + 1])
            else
                error("not implemented crossover type")
            end
        else
            # no crossover, just copy parents
            new_population[child_ids[1]] = copy(runner.population[runner.tournament_selected[2 * i]])
            new_population[child_ids[2]] = copy(runner.population[runner.tournament_selected[2 * i + 1]])
        end
    end
    runner.population = new_population
end

function _deprecated_and_buggy_crossover(runner::RunnerMultipleParentsTournament)
    children_set = collect(0:(runner.params.population_size + runner.params.elitism_number - 1))
    children_set = vect_difference(children_set, runner.elitist_ids)

    new_population = copy(runner.population)

    for child_ids in Iterators.partition(children_set, 2)
        parent_ids = rand(1:length(runner.tournament_selected), 2)

        crossover_prob = rand(Float32)
        if crossover_prob <= runner.params.crossover_rate
            if runner.params.crossover_type == 0
                crossover_algos.single_point_crossover(runner, new_population, child_ids[1], child_ids[2], parent_ids[1], parent_ids[2])
            elseif runner.params.crossover_type == 1
                crossover_algos.multi_point_crossover(runner, new_population, child_ids[1], child_ids[2], parent_ids[1], parent_ids[2])
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

