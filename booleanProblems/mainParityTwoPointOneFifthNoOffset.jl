#= 
folgende Strategien werden verwendet:
- 1-lambda, kein Crossover, Single-Active-Mutation
- mu-lambda, 1-point-crossover (konstante Rekombinationsrate + ohne Offset), Single-Active-Mutation
- mu-lambda, 1-point-crossover (sinkende Rekombinationsrate + ohne Offset), Single-Active-Mutation
- mu-lambda, 1-point-crossover (one-fifth Rekombinationsrate + ohne Offset), Single-Active-Mutation
- mu-lambda, 1-point-crossover (konstante Rekombinationsrate + mit Offset), Single-Active-Mutation
- mu-lambda, 1-point-crossover (sinkende Rekombinationsrate + mit Offset), Single-Active-Mutation
- mu-lambda, 1-point-crossover (one-fifth Rekombinationsrate + mit Offset), Single-Active-Mutation
- mu-lambda, 2-point-crossover (konstante Rekombinationsrate + ohne Offset), Single-Active-Mutation
- mu-lambda, 2-point-crossover (sinkende Rekombinationsrate + ohne Offset), Single-Active-Mutation
- mu-lambda, 2-point-crossover (one-fifth Rekombinationsrate + ohne Offset), Single-Active-Mutation
- mu-lambda, 2-point-crossover (konstante Rekombinationsrate + mit Offset), Single-Active-Mutation
- mu-lambda, 2-point-crossover (sinkende Rekombinationsrate + mit Offset), Single-Active-Mutation
- mu-lambda, 2-point-crossover (one-fifth Rekombinationsrate + mit Offset), Single-Active-Mutation
- mu-lambda, uniform-crossover (konstante Rekombinationsrate + ohne Offset), Single-Active-Mutation
- mu-lambda, uniform-crossover (sinkende Rekombinationsrate + ohne Offset), Single-Active-Mutation
- mu-lambda, uniform-crossover (one-fifth Rekombinationsrate + ohne Offset), Single-Active-Mutation
- mu-lambda, uniform-crossover (konstante Rekombinationsrate + mit Offset), Single-Active-Mutation
- mu-lambda, uniform-crossover (sinkende Rekombinationsrate + mit Offset), Single-Active-Mutation
- mu-lambda, uniform-crossover (one-fifth Rekombinationsrate + mit Offset), Single-Active-Mutation
=#

using Hyperopt
using Statistics

include("globalParams.jl")

include("utils/runner_multiple_parents_with_elitist_mulambda.jl")

nbr_computational_nodes = 1500
population_size = 50
elitism_number = 4
mu = 1
lambda = 4
eval_after_iterations = 200
nbr_inputs = 3
nbr_outputs = 1

#crossover type:
# single point = 0
# two point = 1
# uniform = 2
# no crossover = 3
crossover_type = 1


# Parity = 0
# Encode = 1
# Decode = 2
# Multiply = 3
datasetToLoad = 0
include("datasets/3parity.jl")
#include("datasets/4-16encode")
#include("datasets/16-4decode")
#include("datasets/3multiply.jl")

crossover_rate = 0.7
crossover_offset = 0
crossover_start = 0.5
crossover_delta = 0.05

# rate type:
# 1 -> konstant
# 2 -> Clegg
# 3 -> one Fifth Rule
crossover_rate_type = 3
tournament_size = 0

# cgp parameter
params = CgpParameters(
    nbr_computational_nodes,
    population_size,
    mu,
    lambda,
    eval_after_iterations,
    nbr_inputs,
    nbr_outputs,
    crossover_type,
    crossover_rate, 
    crossover_offset,
    crossover_start,
    crossover_delta,
    crossover_rate_type,
    tournament_size,
    elitism_number
)


# Main function
function main()

    # Dataset selection (placeholder, implement actual dataset loading)
    data, label, eval_data, eval_label = load_dataset()

    # Logger setup
    selection = "MuLambda"
    dataset_string = get_dataset_string(datasetToLoad)
    crossover_type = get_crossover_type(params.crossover_type)

    save_path = joinpath(["Experiments_Boolean", 
                            dataset_string, 
                            selection, 
                            crossover_type, 
                            "Crossover Rate Type " * string(params.crossover_rate_type),
                            "Ergebnisse.txt"])
    
    mkpath(dirname(save_path))

    # Öffne die Datei
    open(save_path, "a") do file
        runner = RunnerElitistMuLambda(params, data, label, eval_data, eval_label)
        runtime = 0
        fitness_eval = Inf
        fitness_train = Inf

        while runtime < eval_after_iterations
            write(file, "Iteration: $runtime, Fitness: $(get_best_fitness(runner))\n")
            learn_step!(runner)
            runtime += 1

            if isapprox(get_best_fitness(runner), 0.0, atol=0.0001)
                break
            end
        end

        fitness_eval = get_test_fitness(runner)
        fitness_train = get_best_fitness(runner)

        # Saving results
        println(runtime)
        write(file, "End at iteration: $runtime\n")
        write(file, "Fitness Eval: $fitness_eval\n")
        write(file, "Fitness Train: $fitness_train\n")
        close(file)
    end
end

function writeHpoResults(results::String)

    save_path = joinpath(["Experiments_Boolean", 
                            "Parity", 
                            "MuLambda", 
                            "TwoPointCrossover", 
                            "Crossover Rate Type 3",
                            "HPOResults.txt"])

    # Öffne die Datei
    open(save_path, "a") do file
        write(file, "$results\n")
        close(file)
    end
end

function hpo(iteration::Int)
    ho = @hyperopt for i = 4000, #aus 40000 Kombinationen
        nbr_computational_nodes = 50:50:2000, 
        population_size = 10:10:100, 
        crossover_start = 0.1:0.1:1.0, 
        elitism_number = 2:2:20
        
        meanAusMehrerenIterationen(nbr_computational_nodes, population_size, crossover_start, elitism_number)
    end

    beste_parameter = ho.minimizer
    bestes_ergebnis = ho.minimum
    println("Beste Parameter: ", beste_parameter)
    println("Bestes Ergebnis: ", bestes_ergebnis)

    writeHpoResults("Iteration $iteration: Parameter -> $beste_parameter; Ergebnis -> $bestes_ergebnis (nbr_computational_nodes, population_size, crossover_start, elitism_number)")
end

function meanAusMehrerenIterationen(nbr_computational_nodes, population_size, crossover_start, elitism_number)

    if(population_size < elitism_number)
        return Inf
    end
    # cgp parameter
    parameterSet = CgpParameters(
        nbr_computational_nodes,
        population_size,
        mu,
        lambda,
        eval_after_iterations,
        nbr_inputs,
        nbr_outputs,
        crossover_type,
        crossover_rate, 
        crossover_offset,
        crossover_start,
        crossover_delta,
        crossover_rate_type,
        tournament_size,
        elitism_number
    )

    data, label, eval_data, eval_label = load_dataset()


    fitnessAll = Vector{Float32}()
    for i in 1:10
        runner = RunnerElitistMuLambda(parameterSet, data, label, eval_data, eval_label)

        iterations = 0

        while iterations < eval_after_iterations
            learn_step!(runner)
            iterations = iterations + 1

            if isapprox(get_best_fitness(runner), 0.0, atol=0.0001)
                break
            end
        end

        push!(fitnessAll, get_test_fitness(runner))

    end

    return mean(fitnessAll)

end


function load_dataset()
    data, label = get_dataset()
    eval_data, eval_label = get_eval_dataset()
    return data, label, eval_data, eval_label
end

function get_dataset_string(dataset_id)
    if (dataset_id == 0)
        return "Parity"
    elseif (dataset_id == 1)
        return "Encode"
    elseif (dataset_id == 2)
        return "Decode"
    elseif (dataset_id == 3)
        return "Multiply"
    else 
        println("Error occured: false dataset ID!!")
        return
    end
end

function get_crossover_type(crossover_id)
    if (crossover_id == 0)
        return "SinglePointCrossover"
    elseif (crossover_id == 1)
        return "TwoPointCrossover"
    elseif (crossover_id == 2)
        return "UniformCrossover"
    elseif (crossover_id == 3)
        return "NoCrossover"
    else 
        println("Error occured: false dataset ID!!")
        return
    end
end


# Run the main function
#main()

save_path = joinpath(["Experiments_Boolean", 
                            "Parity", 
                            "MuLambda", 
                            "TwoPointCrossover", 
                            "Crossover Rate Type 3",
                            "HPOResults.txt"])

mkpath(dirname(save_path))

# Öffne die Datei
open(save_path, "w") do file
    write(file, "")
    close(file)
end

for i in 1:10
    hpo(i)
end

