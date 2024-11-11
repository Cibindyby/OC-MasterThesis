using Random


#für richtige Einstellungen andere Runner verwenden

include("../../standardCGP/chromosome.jl")

#single_point_crossover für mu lambda ohne elitisten
function single_point_crossover!(rng, nbr_inputs, nbr_computational_nodes, population,
                                 new_population::Vector{Chromosome},
                                 child1_id::Int,
                                 child2_id::Int,
                                 parent1_id::Int,
                                 parent2_id::Int)
    # Generate range between computational nodes
    crossover_point = rand(rng, nbr_inputs:(nbr_inputs + nbr_computational_nodes - 1))

    cross_chromo_1 = deepcopy(population[parent1_id + 1])
    cross_chromo_2 = deepcopy(population[parent2_id + 1])

    cross_chromo_1.nodes_grid[1:crossover_point], cross_chromo_2.nodes_grid[1:crossover_point] = 
        cross_chromo_2.nodes_grid[1:crossover_point], cross_chromo_1.nodes_grid[1:crossover_point]

    get_active_nodes_id!(cross_chromo_1)
    get_active_nodes_id!(cross_chromo_2)

    new_population[child1_id + 1] = cross_chromo_1
    new_population[child2_id + 1] = cross_chromo_2

    return new_population
end

# two point crossover für mu lambda ohne elitisten
function two_point_crossover!(nbr_inputs, nbr_computational_nodes, population,
                                new_population::Vector{Chromosome},
                                child1_id::Int,
                                child2_id::Int,
                                parent1_id::Int,
                                parent2_id::Int)
    cross_chromo_1 = deepcopy(population[parent1_id + 1])
    cross_chromo_2 = deepcopy(population[parent2_id + 1])

    crossover_points = rand(nbr_inputs:(nbr_inputs + nbr_computational_nodes - 1), 2)

    for point in crossover_points
        cross_chromo_1.nodes_grid[point:end], cross_chromo_2.nodes_grid[point:end] = 
            cross_chromo_2.nodes_grid[point:end], cross_chromo_1.nodes_grid[point:end]
    end

    get_active_nodes_id!(cross_chromo_1)
    get_active_nodes_id!(cross_chromo_2)

    new_population[child1_id + 1] = cross_chromo_1
    new_population[child2_id + 1] = cross_chromo_2

    return new_population
end


#uniform crossover mu lambda ohne elitisten
function uniform_crossover!(nbr_inputs, nbr_computational_nodes, population,
                            new_population::Vector{Chromosome},
                            child1_id::Int,
                            child2_id::Int,
                            parent1_id::Int,
                            parent2_id::Int)
    cross_chromo_1 = deepcopy(population[parent1_id + 1])
    cross_chromo_2 = deepcopy(population[parent2_id + 1])

    for node_id in nbr_inputs:(nbr_inputs + nbr_computational_nodes - 1)
        if rand(Bool)
            cross_chromo_1.nodes_grid[node_id], cross_chromo_2.nodes_grid[node_id] = 
                cross_chromo_2.nodes_grid[node_id], cross_chromo_1.nodes_grid[node_id]
        end
    end

    get_active_nodes_id!(cross_chromo_1)
    get_active_nodes_id!(cross_chromo_2)

    new_population[child1_id + 1] = cross_chromo_1
    new_population[child2_id + 1] = cross_chromo_2

    return new_population
end

#kein crossover mu lambda ohne elitisten
function no_crossover!(population,
                       new_population::Vector{Chromosome},
                       child1_id::Int,
                       child2_id::Int,
                       parent1_id::Int,
                       parent2_id::Int)
    new_population[child1_id + 1] = deepcopy(population[parent1_id + 1])
    new_population[child2_id + 1] = deepcopy(population[parent2_id + 1])

    return new_population
end

