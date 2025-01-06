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
    include("datasets/keijzer.jl")
elseif datasetToLoad == 1
    include("datasets/koza_3.jl")
elseif datasetToLoad == 2
    include("datasets/nguyen_7.jl")
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
    if crossover_type == 3 # no crossover
        
        iter = 150
        ho = @hyperopt for i = iter, 
            nbr_cmp_nodes = 50:50:2000, 
            pop_size = 10:2:60, 
            elit = 2:2:20

            meanAusMehrerenIterationen(nbr_cmp_nodes, pop_size, 0.0, elit, 0.0)
        end

    else
        iter = 150

    if crossover_rate_type == 1 #range for constant rate
        rangeForCrossoverRate = 0.1:0.1:1.0
    elseif crossover_rate_type == 2 # range for delta (Clegg)
        rangeForCrossoverRate = 0.005:0.005:0.050
    elseif crossover_rate_type == 3 # range for start (one fifth)
        rangeForCrossoverRate = 0.3:0.05:0.75
    end

    if useOffset

            ho = @hyperopt for i = iter, 
                nbr_cmp_nodes = 50:50:2000, 
                pop_size = 10:2:60, 
                rate_start_or_delta = rangeForCrossoverRate,
                elit = 2:2:20,
                offset = 0:50:500

                meanAusMehrerenIterationen(nbr_cmp_nodes, pop_size, rate_start_or_delta, elit, offset)
            end

        else
            ho = @hyperopt for i = iter, 
                nbr_cmp_nodes = 50:50:2000, 
                pop_size = 10:2:60, 
                rate_start_or_delta = rangeForCrossoverRate,
                elit = 2:2:20

                meanAusMehrerenIterationen(nbr_cmp_nodes, pop_size, rate_start_or_delta, elit, 0)
            end
        end
    end

    beste_parameter = ho.minimizer
    bestes_ergebnis = ho.minimum
    println("Beste Parameter: ", beste_parameter)
    println("Bestes Ergebnis: ", bestes_ergebnis)

    writeHpoResults("Endergenis HPO: Parameter -> $beste_parameter; Ergebnis -> $bestes_ergebnis (nbr_computational_nodes, population_size, (crossover_delta), elitism_number, (offset))")
end


function meanAusMehrerenIterationen(nbr_cmp_nodes, pop_size, rate_start_or_delta, elit, offset)
   
    #default values
    mu = 1
    lambda = 4
    eval_after_iterations = 500
    nbr_inputs = 1
    nbr_outputs = 1
    crossover_rate = 0.7
    crossover_start = 0.9
    crossover_delta = 0.05
    tournament_size = 0

    if(pop_size < elit)
        open(save_path, "a") do file
            write(file, "Parameter set: \n
                        number_comp_nodes = $nbr_cmp_nodes, \n
                        population_size = $pop_size, \n
                        crossover_rate_depending_on_type (rate, delta or start) = $rate_start_or_delta, \n
                        eilit_number = $elit, \n
                        crossover_offset = $offset\n")
            write(file, "Ergebnis (mean) = Inf (weil mu > lambda)\n\n")
        end
        return Inf
    end

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


    fitnessAll = Vector{Float32}()
    iterationsAll = Vector{Float32}()
    for i in 1:10
        runner = RunnerElitistMuLambda(parameterSet, data, label, eval_data, eval_label)

        iterations = 0

        while iterations < eval_after_iterations
            learn_step!(runner)
            iterations = iterations + 1
            fitness = get_best_fitness(runner)

            if isapprox(fitness, 0.0, atol=0.0001)
                break
            end

            # braucht keine höhere Gewichtung für Iterationen, weil Iterationen nur wichtig sind für Durchläufe, die sowieso schon fertig werden
        end

        push!(fitnessAll, fitness)
        push!(iterationsAll, iterations)

    end

    meanAllFitness = mean(fitnessAll)
    meanAllIteration = mean(iterationsAll)
    open(save_path, "a") do file
        write(file, "Parameter set: \n
                    crossover_rate_depending_on_type (rate, delta or start) = $rate_start_or_delta, \n
                    crossover_offset = $offset\n")
        write(file, "Ergebnis (mean) = \n 
                        $meanAllFitness Fitness\n 
                        $meanAllIteration Iterations\n\n")
    end

    return meanAllFitness

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
        return "Keijzer"
    elseif (dataset_id == 1)
        return "Koza"
    elseif (dataset_id == 2)
        return "Nguyen"
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
    
    if datasetToLoad == 0 #keijzer

        if crossover_type == 0 #SinglePointCrossover
            
            nbr_cmp_nodes = 500
            pop_size = 44
            elit = 8

        elseif crossover_type == 1 #TwoPointCrossover

            nbr_cmp_nodes = 500
            pop_size = 40
            elit = 10

        elseif crossover_type == 2 #UniformCrossover

            nbr_cmp_nodes = 500
            pop_size = 50
            elit = 8

        elseif crossover_type == 3 #NoCrossover

            nbr_cmp_nodes = 500
            pop_size = 28
            elit = 10

        end

    elseif datasetToLoad == 1 #Koza

        if crossover_type == 0 #SinglePointCrossover

            nbr_cmp_nodes = 500
            pop_size = 16
            elit = 6

        elseif crossover_type == 1 #TwoPointCrossover

            nbr_cmp_nodes = 500
            pop_size = 48
            elit = 10

        elseif crossover_type == 2 #UniformCrossover

            nbr_cmp_nodes = 500
            pop_size = 44
            elit = 8

        elseif crossover_type == 3 #NoCrossover
            
            nbr_cmp_nodes = 500
            pop_size = 40
            elit = 8

        end

    elseif datasetToLoad == 2 #Nguyen

        if crossover_type == 0 #SinglePointCrossover

            nbr_cmp_nodes = 500
            pop_size = 48
            elit = 10

        elseif crossover_type == 1 #TwoPointCrossover

            nbr_cmp_nodes = 1500
            pop_size = 36
            elit = 6

        elseif crossover_type == 2 #UniformCrossover

            nbr_cmp_nodes = 1000
            pop_size = 38
            elit = 10

        elseif crossover_type == 3 #NoCrossover
            
            nbr_cmp_nodes = 1500
            pop_size = 50
            elit = 6

        end

    end

    return nbr_cmp_nodes, pop_size, elit

end

save_path = joinpath(["Experiments_Regression", 
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

