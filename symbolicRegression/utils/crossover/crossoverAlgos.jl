using Random


#für richtige Einstellungen andere Runner verwenden


include("../runner_multiple_parents_with_elitist_mulambda.jl")
include("../runner.jl")

include("../../standardCGP/chromosome.jl")

#single_point_crossover für mu lambda ohne elitisten
function single_point_crossover!(runner::RunnerMuLambda,
                                 new_population::Vector{Chromosome},
                                 child1_id::Int,
                                 child2_id::Int,
                                 parent1_id::Int,
                                 parent2_id::Int)
    # Generate range between computational nodes
    crossover_point = rand(runner.rng, runner.params.nbr_inputs:(runner.params.nbr_inputs + runner.params.nbr_computational_nodes - 1))

    cross_chromo_1 = deepcopy(runner.population[parent1_id])
    cross_chromo_2 = deepcopy(runner.population[parent2_id])

    cross_chromo_1.nodes_grid[1:crossover_point], cross_chromo_2.nodes_grid[1:crossover_point] = 
        cross_chromo_2.nodes_grid[1:crossover_point], cross_chromo_1.nodes_grid[1:crossover_point]

    get_active_nodes_id!(cross_chromo_1)
    get_active_nodes_id!(cross_chromo_2)

    new_population[child1_id] = cross_chromo_1
    new_population[child2_id] = cross_chromo_2
end

# two point crossover für mu lambda ohne elitisten
function two_point_crossover!(runner::RunnerMuLambda,
                                new_population::Vector{Chromosome},
                                child1_id::Int,
                                child2_id::Int,
                                parent1_id::Int,
                                parent2_id::Int)
    cross_chromo_1 = deepcopy(runner.population[parent1_id])
    cross_chromo_2 = deepcopy(runner.population[parent2_id])

    crossover_points = sample(runner.params.nbr_inputs:(runner.params.nbr_inputs + runner.params.nbr_computational_nodes - 1), 
                              2, replace=false)

    for point in crossover_points
        cross_chromo_1.nodes_grid[point:end], cross_chromo_2.nodes_grid[point:end] = 
            cross_chromo_2.nodes_grid[point:end], cross_chromo_1.nodes_grid[point:end]
    end

    get_active_nodes_id!(cross_chromo_1)
    get_active_nodes_id!(cross_chromo_2)

    new_population[child1_id] = cross_chromo_1
    new_population[child2_id] = cross_chromo_2
end


#uniform crossover mu lambda ohne elitisten
function uniform_crossover!(runner::RunnerMuLambda,
                            new_population::Vector{Chromosome},
                            child1_id::Int,
                            child2_id::Int,
                            parent1_id::Int,
                            parent2_id::Int)
    cross_chromo_1 = deepcopy(runner.population[parent1_id])
    cross_chromo_2 = deepcopy(runner.population[parent2_id])

    for node_id in runner.params.nbr_inputs:(runner.params.nbr_inputs + runner.params.nbr_computational_nodes - 1)
        if rand(Bool)
            cross_chromo_1.nodes_grid[node_id], cross_chromo_2.nodes_grid[node_id] = 
                cross_chromo_2.nodes_grid[node_id], cross_chromo_1.nodes_grid[node_id]
        end
    end

    get_active_nodes_id!(cross_chromo_1)
    get_active_nodes_id!(cross_chromo_2)

    new_population[child1_id] = cross_chromo_1
    new_population[child2_id] = cross_chromo_2
end

#kein crossover mu lambda ohne elitisten
function no_crossover!(runner::RunnerMuLambda,
                       new_population::Vector{Chromosome},
                       child1_id::Int,
                       child2_id::Int,
                       parent1_id::Int,
                       parent2_id::Int)
    new_population[child1_id] = deepcopy(runner.population[parent1_id])
    new_population[child2_id] = deepcopy(runner.population[parent2_id])
end

