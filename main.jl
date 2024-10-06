#Aufruf aller relevanten Methoden für jeweiliges Testszenario

# main.jl

# Laden der benötigten Module
include("CGP.jl")
include("symbolicRegression/symbolicRegression.jl")
include("symbolicRegression/keijzer6.jl")

# Initialisierung der Hyperparameter für die kartesische genetische Programmierung
global POPULATION_SIZE = 100
global GENERATIONS = 5 #500
global MUTATION_RATE = 0.1
global RECOMBINATION_RATE = 0.7
global TOURNAMENT_SIZE = 5

# Ausführung der symbolischen Regression mit dem Keijzer-6-Datensatz
function main()
    # Lade den Keijzer-6 Datensatz
    x, y = load_keijzer6_dataset()
    
    # Initialisiere Population
    population = initialize_population(POPULATION_SIZE)
    
    # Starte die CGP-Optimierung
    for generation in 1:GENERATIONS
        population = evolve_population(population, x, y)
        best_individual = find_best_individual(population, x, y)
        println("Generation $generation: Best Fitness = ", evaluate_fitness(best_individual, x, y))
    end
    
    println("Beste Lösung gefunden!")
end

main()
