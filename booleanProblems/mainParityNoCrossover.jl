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

include("globalParams.jl")

include("utils/runner.jl")

nbr_computational_nodes = 500
population_size = 50
mu = 1
lambda = 4
eval_after_iterations = 5000
nbr_inputs = 3
nbr_outputs = 1

#crossover type:
# single point = 0
# two point = 1
# uniform = 2
# no crossover = 3
crossover_type = 3


# Parity = 0
# Encode = 1
# Decode = 2
# Multiply = 3
datasetToLoad = 0
include("datasets/3parity.jl")
#include("datasets/4-16encode")
#include("datasets/16-4decode")
#include("datasets/3multiply.jl")

crossover_rate = 0.0
crossover_offset = 0
crossover_start = 0.0
crossover_delta = 0.0
crossover_rate_type = 1
tournament_size = 0
elitism_number = 0

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
    selection = "MuLambdaWithoutElitists"
    dataset_string = get_dataset_string(datasetToLoad)
    crossover_type = get_crossover_type(params.crossover_type)

    save_path = joinpath(["Experiments_Boolean", 
                            dataset_string, 
                            selection, 
                            crossover_type, 
                            "Crossover Rate " * string(params.crossover_rate),
                            "Ergebnisse.txt"])
    
    mkpath(dirname(save_path))

    # Öffne die Datei
    open(save_path, "w") do file
        runner = RunnerMuLambda(params, data, label, eval_data, eval_label)
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

        parent = get_parent(runner)
        get_active_nodes_id!(parent)
        write(file, "$(parent.active_nodes)")
    end
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
main()

