using Printf

struct CgpParameters
    nbr_computational_nodes::Int
    population_size::Int
    mu::Int
    lambda::Int
    eval_after_iterations::Int
    nbr_inputs::Int
    nbr_outputs::Int
    crossover_type::Int
    crossover_rate::Float32
    crossover_offset::Int
    tournament_size::Int
    elitism_number::Int
end

function Base.show(io::IO, params::CgpParameters)
    println(io, "############ Parameters ############")
    @printf(io, "graph_width: %d\n", params.nbr_computational_nodes)
    @printf(io, "mu: %d\n", params.mu)
    @printf(io, "lambda: %d\n", params.lambda)
    @printf(io, "eval_after_iterations: %d\n", params.eval_after_iterations)
    @printf(io, "nbr_inputs: %d\n", params.nbr_inputs)
    @printf(io, "nbr_outputs: %d\n", params.nbr_outputs)
    @printf(io, "crossover_type: %d\n", params.crossover_type)
    @printf(io, "crossover_rate: %.2f\n", params.crossover_rate)
    @printf(io, "crossover_offset: %d\n", params.crossover_offset)
    println(io, "#########################")
end

function CgpParameters()
    CgpParameters(
        0,    # nbr_computational_nodes
        0,    # population_size
        1,    # mu
        4,    # lambda
        500,  # eval_after_iterations
        0,    # nbr_inputs
        0,    # nbr_outputs
        0,    # crossover_type
        -1.0, # crossover_rate
        0,    # crossover_offset
        0,    # tournament_size
        0,    # elitism_number
    )
end

