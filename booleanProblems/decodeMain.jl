#= 
folgende Strategien werden verwendet:
- mu-lambda, kein Crossover, Single-Active-Mutation
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

import XLSX

datasetToLoad = parse(Int, ARGS[1])

if datasetToLoad == 0
    include("datasets/3parity.jl")
elseif datasetToLoad == 1
    include("datasets/16-4encode.jl")
elseif datasetToLoad == 2
    include("datasets/4-16decode.jl")
elseif datasetToLoad == 3
    include("datasets/3multiply.jl")
end

crossover_type = parse(Int, ARGS[2])
crossover_rate_type = parse(Int, ARGS[3])

useOffset = parse(Int, ARGS[4])

crossover_rate_value = parse(Float32, ARGS[5])
offset_value = parse(Int, ARGS[6])
jobCounter = parse(Int, ARGS[7])


function main()
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

    runner = RunnerElitistMuLambda(parameterSet, data, label, eval_data, eval_label)

    iterations = 0

    while iterations < eval_after_iterations
        #learn steps aufteilen

        get_child_ids(runner)
        crossover(runner)
        eval_chromosomes!(runner)
        fitnessAfterCrossover = get_best_fitness(runner)

        mutate_chromosomes!(runner)
        eval_chromosomes!(runner)
        fitnessAfterMutation = get_best_fitness(runner)

        get_elitists(runner)

        numberActiveNodesArray = Vector{Int}()
        ratioActiveNodesArray = Vector{Float32}()

        for chromo in runner.population

            numberActiveNodes = length(chromo.active_nodes)
            push!(numberActiveNodesArray, numberActiveNodes)

            ratioActiveNodes = numberActiveNodes / (nbr_inputs + nbr_outputs + nbr_computational_nodes)
            push!(ratioActiveNodesArray, ratioActiveNodes)

        end
        activeNodesNumber = mean(numberActiveNodesArray)
        activeNodesRatio = mean(ratioActiveNodesArray)

        iterations = iterations + 1

        open(save_path, "a") do file
            write(file, replace(string("$iterations; $fitnessAfterCrossover; $fitnessAfterMutation; $activeNodesNumber; $activeNodesRatio\n"), "." => ","))
            close(file)
        end

        if isapprox(get_best_fitness(runner), 0.0, atol=0.0001)
            break
        end

    end
end


function load_dataset()
    data, label = get_dataset()
    eval_data, eval_label = get_eval_dataset()
    return data, label, eval_data, eval_label
end


function get_rate_type(rate_type_id)
    if (rate_type_id == 1)
        return "Konstant"
    elseif (rate_type_id == 2)
        return "Clegg"
    elseif (rate_type_id == 3)
        return "OneFifthRule"
    else 
        println("Error occured: false rate type ID -> $rate_type_id !!")
        return
    end
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
        println("Error occured: false dataset ID -> $dataset_id !!")
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
        println("Error occured: false crossover ID -> $crossover_id !!")
        return
    end
end


save_path = joinpath(["Experiments_Boolean", 
                            get_dataset_string(datasetToLoad), 
                            "MuLambda", 
                            get_crossover_type(crossover_type), 
                            get_rate_type(crossover_rate_type),
                            "useOffset_$useOffset",
                            "mainResultsCrossoverRate$(crossover_rate_value)Offset$(offset_value)",
                            "$(jobCounter)Result.csv"])
mkpath(dirname(save_path))

# Öffne die Datei
open(save_path, "w") do file
    write(file, "")
    close(file)
end

open(save_path, "a") do file
    write(file, "Iteration; Fitness nach Rekombination; Fitness nach Mutation; Anzahl aktiver Knoten; Anteil aktiver Knoten\n")
    close(file)
end

excelFile = XLSX.readxlsx("HPOErgebnisse.xlsx")
worksheet = excelFile["Decode"]
if crossover_type == 3
    lineCounter = 20
else
    lineCounter = crossover_type * 6 + crossover_rate_type * 2 + useOffset
end


# Ergebnisse Henning HPO
nbr_computational_nodes = worksheet[lineCounter,:][4]
population_size = worksheet[lineCounter,:][5]
if crossover_rate_type == 1 || crossover_rate_type == 3
    crossover_rate = crossover_rate_value
    crossover_start = crossover_rate_value
    crossover_delta = 0.0
else
    crossover_rate = 0.9
    crossover_delta = crossover_rate_value
    crossover_start = 0.9
end
elitism_number = worksheet[lineCounter,:][8]
crossover_offset = offset_value

mu = 1
lambda = 4
eval_after_iterations = 10000 #niedriger, wegen Zeit (ursprünglich 35000)
nbr_inputs = 4 #Achtung, das gilt nur für Decode!!!
nbr_outputs = 16
tournament_size = 0

main()