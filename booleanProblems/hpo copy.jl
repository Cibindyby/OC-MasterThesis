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
using Optim

include("globalParams.jl")

include("utils/runner_multiple_parents_with_elitist_mulambda.jl")



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

useOffset = false
if ARGS[4] == "0"
    useOffset = false
elseif ARGS[4] == "1"
    useOffset = true
end



function writeHpoResults(results::String)

    # Öffne die Datei
    open(save_path, "a") do file
        write(file, "$results\n")
        close(file)
    end
end

function hpo()

    if crossover_rate_type == 1 #range for constant rate
        rangeForCrossoverRate = 0.1:0.1:1.0
    elseif crossover_rate_type == 2 # range for delta (Clegg)
        rangeForCrossoverRate = 0.005:0.005:0.050
    elseif crossover_rate_type == 3 # range for start (one fifth)
        rangeForCrossoverRate = 0.3:0.05:0.75
    end

    if useOffset
        offset_rng = 70:50:520
    else
        offset_rng = 0:0
    end

    parameterVector = Vector{Vector{Float32}}()
    costVector = Vector{Float32}()
    for rate_start_or_delta in rangeForCrossoverRate

        for offset in offset_rng

            paramsNow = Vector{Float32}()
            push!(paramsNow, rate_start_or_delta)
            push!(paramsNow, offset)
            push!(parameterVector, paramsNow)

            cost = meanAusMehrerenIterationen(rate_start_or_delta, offset)
            push!(costVector, cost)

        end
    end

    min_cost = argmin(costVector)
    costVal = costVector[min_cost]
    params_min = parameterVector[min_cost]

    println("Beste Parameter: $params_min")
    println("Bestes Ergebnis: $costVal")

    writeHpoResults("Endergenis HPO: Parameter -> Rate: $params_min; Ergebnis -> $costVal")
end

function meanAusMehrerenIterationen(rate_start_or_delta, offset)
   
    #default values
    mu = 1
    lambda = 4
    eval_after_iterations = 50000
    nbr_inputs = 3 #Achtung, das gilt nur für Parity!!!
    nbr_outputs = 1
    crossover_rate = 0.7
    crossover_start = 0.9
    crossover_delta = 0.05
    tournament_size = 0

    nbr_cmp_nodes, pop_size, elit = get_fixed_hyperparameter()


    if crossover_rate_type == 1 #range for constant rate
        crossover_rate = rate_start_or_delta
    elseif crossover_rate_type == 2 # range for delta
        crossover_delta = rate_start_or_delta
    elseif crossover_rate_type == 3 # range for start
        crossover_start = rate_start_or_delta
    end

    crossover_offset = offset

    # cgp parameter
    parameterSet = CgpParameters(
        nbr_cmp_nodes,
        pop_size,
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
        elit
    )

    data, label, eval_data, eval_label = load_dataset()


    iterationsAll = Vector{Float32}()
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

        push!(iterationsAll, iterations)

    end

    meanAll = mean(iterationsAll)
    open(save_path, "a") do file
        write(file, "Parameter set: \n
                    crossover_rate_depending_on_type (rate, delta or start) = $rate_start_or_delta, \n
                    crossover_offset = $offset\n")
        write(file, "Ergebnis (mean) = $meanAll Iterations\n\n")
    end

    return meanAll

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

function get_fixed_hyperparameter()
    
    if datasetToLoad == 0 #parity

        if crossover_type == 0 #SinglePointCrossover
            
            nbr_cmp_nodes = 6500
            pop_size = 50
            elit = 4

        elseif crossover_type == 1 #TwoPointCrossover

            nbr_cmp_nodes = 9000
            pop_size = 30
            elit = 8

        elseif crossover_type == 2 #UniformCrossover

            nbr_cmp_nodes = 4500
            pop_size = 48
            elit = 2

        elseif crossover_type == 3 #NoCrossover

            nbr_cmp_nodes = 4500
            pop_size = 50
            elit = 8

        end

    elseif datasetToLoad == 1 #Encode

        if crossover_type == 0 #SinglePointCrossover

            nbr_cmp_nodes = 4000
            pop_size = 50
            elit = 2

        elseif crossover_type == 1 #TwoPointCrossover

            nbr_cmp_nodes = 1500
            pop_size = 44
            elit = 2

        elseif crossover_type == 2 #UniformCrossover

            nbr_cmp_nodes = 6500
            pop_size = 40
            elit = 2

        elseif crossover_type == 3 #NoCrossover
            
            nbr_cmp_nodes = 3000
            pop_size = 50
            elit = 2

        end

    elseif datasetToLoad == 2 #Decode

        if crossover_type == 0 #SinglePointCrossover

            nbr_cmp_nodes = 6000
            pop_size = 48
            elit = 8

        elseif crossover_type == 1 #TwoPointCrossover

            nbr_cmp_nodes = 2500
            pop_size = 50
            elit = 8

        elseif crossover_type == 2 #UniformCrossover

            nbr_cmp_nodes = 3500
            pop_size = 48
            elit = 2

        elseif crossover_type == 3 #NoCrossover
            
            nbr_cmp_nodes = 5500
            pop_size = 50
            elit = 6

        end

    elseif datasetToLoad == 3 #Multiply

        if crossover_type == 0 #SinglePointCrossover

            nbr_cmp_nodes = 3500
            pop_size = 44
            elit = 2

        elseif crossover_type == 1 #TwoPointCrossover

            nbr_cmp_nodes = 4500
            pop_size = 46
            elit = 2

        elseif crossover_type == 2 #UniformCrossover

            nbr_cmp_nodes = 3500
            pop_size = 48
            elit = 2

        elseif crossover_type == 3 #NoCrossover
            
            nbr_cmp_nodes = 2500
            pop_size = 26
            elit = 2

        end

    end

    return nbr_cmp_nodes, pop_size, elit

end

save_path = joinpath(["Experiments_Boolean", 
                            get_dataset_string(datasetToLoad), 
                            "MuLambda", 
                            get_crossover_type(crossover_type), 
                            get_rate_type(crossover_rate_type),
                            "useOffset_$useOffset",
                            "HPOResults.txt"])

mkpath(dirname(save_path))

# Öffne die Datei
open(save_path, "w") do file
    write(file, "")
    close(file)
end

hpo()

