#=
using Random
using LinearAlgebra
using Statistics

include("../utils/symbolicRegressionFunctions.jl")
include("../utils/nodeType.jl")
include("../utils/utilityFuncs.jl")

@enum NodeType InputNode ComputationalNode OutputNode

mutable struct NodeReorder
    position::Int
    node_type::NodeType
    nbr_inputs::Int
    graph_width::Int
    function_id::Int
    connection0::Int
    connection1::Int
end

function Base.show(io::IO, node::NodeReorder)
    print(io, "Node Pos: $(node.position), ")
    print(io, "Node Type: $(node.node_type), ")
    func_name = ["AND", "OR", "NAND", "NOR"][node.function_id + 1]
    print(io, "Func: $func_name, ")
    println(io, "Connections: ($(node.connection0), $(node.connection1)), ")
end

function NodeReorder(position::Int, nbr_inputs::Int, graph_width::Int, node_type::NodeType)
    function_id = rand(0:3)
    connection0 = typemax(Int)
    connection1 = typemax(Int)

    if node_type == ComputationalNode
        connection0 = rand(0:position-1)
        connection1 = rand(0:position-1)
    elseif node_type == OutputNode
        connection0 = rand(0:nbr_inputs+graph_width-1)
    end

    NodeReorder(position, node_type, nbr_inputs, graph_width, function_id, connection0, connection1)
end

function execute(node::NodeReorder, conn0_value::Vector{Float32}, conn1_value::Union{Nothing, Vector{Float32}})
    @assert node.node_type != InputNode

    function_set = [
        (x, y) -> x .+ y,
        (x, y) -> x .- y,
        (x, y) -> x .* y,
        (x, y) -> x ./ y,
        x -> sin.(x),
        x -> cos.(x),
        x -> log.(x),
        x -> exp.(x)
    ]

    if node.function_id <= 3
        return function_set[node.function_id + 1](conn0_value, conn1_value)
    else
        return function_set[node.function_id + 1](conn0_value)
    end
end

function mutate!(node::NodeReorder)
    @assert node.node_type != InputNode

    if node.node_type == OutputNode
        mutate_output_node!(node)
    elseif node.node_type == ComputationalNode
        mutate_computational_node!(node)
    else
        error("Trying to mutate input node")
    end
end

function mutate_connection!(connection::Ref{Int}, upper_range::Int)
    connection[] = utils.utility_funcs.gen_random_number_for_node(connection[], upper_range)
end

function mutate_function!(node::NodeReorder)
    node.function_id = utils.utility_funcs.gen_random_number_for_node(node.function_id, 4)
end

function mutate_output_node!(node::NodeReorder)
    mutate_connection!(Ref(node.connection0), node.graph_width + node.nbr_inputs)
    @assert node.connection0 < node.position
end

function mutate_computational_node!(node::NodeReorder)
    rand_nbr = rand(0:2)
    if rand_nbr == 0
        mutate_connection!(Ref(node.connection0), node.position)
    elseif rand_nbr == 1
        mutate_connection!(Ref(node.connection1), node.position)
    else
        mutate_function!(node)
    end

    @assert node.connection0 < node.position "what was mutated?: $rand_nbr"
    @assert node.connection1 < node.position "what was mutated?: $rand_nbr"
end

function set_new_position!(node::NodeReorder, new_pos::Int, mutate_new_connections::Bool)
    if mutate_new_connections
        if node.connection0 >= new_pos
            mutate_connection!(Ref(node.connection0), new_pos - 1)
        end
        if node.connection1 >= new_pos
            mutate_connection!(Ref(node.connection1), new_pos - 1)
        end
    end
    node.position = new_pos
end

function set_connection0!(node::NodeReorder, new_con::Int)
    node.connection0 = new_con
end

function set_connection1!(node::NodeReorder, new_con::Int)
    node.connection1 = new_con
end

=#