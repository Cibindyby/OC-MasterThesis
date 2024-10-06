# Aufbau der Population der CGP
# hier finden Selektion, Rekombination und Mutation statt

# Globale Variablen für die Hyperparameter
global NODE_ARITY = 2  # Anzahl der Eingaben pro Knoten
global MAX_NODES = 50  # Maximale Anzahl an Knoten in der CGP

# Struktur für ein Individuum in der CGP
struct CGPIndividual
    genes::Vector{Float64}
    fitness::Float64
end

# Initialisiere die Population
function initialize_population(population_size::Int)
    population = [CGPIndividual(rand(MAX_NODES), Inf) for _ in 1:population_size]
    return population
end

# Evaluierung der Fitness eines Individuums
function evaluate_fitness(individual::CGPIndividual, x::Vector{Float64}, y::Vector{Float64})
    # Diese Funktion wird in symbolicRegression.jl definiert
    return fitness_function(individual, x, y)
end

# Selektion (z.B. Turnierselektion)
function selection(population::Vector{CGPIndividual})
    selected = tournament_selection(population)
    return selected
end

# Mutation eines Individuums
function mutation(individual::CGPIndividual)
    if rand() < MUTATION_RATE
        # Zufällige Mutation der Gene
        individual.genes[rand(1:length(individual.genes))] = rand()
    end
    return individual
end

# Rekombination von zwei Eltern
function recombination(parent1::CGPIndividual, parent2::CGPIndividual)
    if rand() < RECOMBINATION_RATE
        crossover_point = rand(1:length(parent1.genes))
        child_genes = vcat(parent1.genes[1:crossover_point], parent2.genes[crossover_point+1:end])
        return CGPIndividual(child_genes, Inf)
    else
        return parent1  # Keine Rekombination, Rückgabe des ersten Elternteils
    end
end

# Evolve Population: Selektion, Mutation und Rekombination
function evolve_population(population::Vector{CGPIndividual}, x::Vector{Float64}, y::Vector{Float64})
    new_population = []
    for i in 1:length(population)
        parent1 = selection(population)
        parent2 = selection(population)
        child = recombination(parent1, parent2)
        child = mutation(child)
        push!(new_population, child)
    end
    return new_population
end

# Hilfsfunktion zur Selektion (Turnierselektion)
function tournament_selection(population::Vector{CGPIndividual})
    selected = rand(population, TOURNAMENT_SIZE)
    best = argmin([ind.fitness for ind in selected])
    return selected[best]
end

# Finden des besten Individuums in der Population
function find_best_individual(population::Vector{CGPIndividual}, x::Vector{Float64}, y::Vector{Float64})
    best_individual = population[1]
    for individual in population
        individual.fitness = evaluate_fitness(individual, x, y)
        if individual.fitness < best_individual.fitness
            best_individual = individual
        end
    end
    return best_individual
end
