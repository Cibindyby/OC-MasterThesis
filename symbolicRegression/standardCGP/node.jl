using Random
using LinearAlgebra

include("../utils/symbolicRegressionFunctions.jl")
include("../utils/nodeType.jl")
include("../utils/utilityFuncs.jl")

mutable struct Node
    position::Int
    node_type::NodeType
    nbr_inputs::Int
    graph_width::Int
    function_id::Int
    connection0::Int
    connection1::Int
end

function Base.show(io::IO, node::Node)
    print(io, "Node Pos: $(node.position), ")
    print(io, "Node Type: $(node.node_type), ")
    print(io, "Function ID: $node.function_id, ")
    println(io, "Connections: ($(node.connection0), $(node.connection1)), ")
end

function Node(position::Int, nbr_inputs::Int, graph_width::Int, node_type::NodeType)
    function_id = rand(0:7)
    connection0 = typemax(Int)
    connection1 = typemax(Int)

    if node_type == ComputationalNode
        connection0 = rand(0:position-1)
        connection1 = rand(0:position-1)
    elseif node_type == OutputNode
        connection0 = rand(0:nbr_inputs+graph_width-1)
    end

    Node(position, node_type, nbr_inputs, graph_width, function_id, connection0, connection1)
end

function nodeExecute(node::Node, conn1_value::Vector{Float32}, conn2_value::Vector{Float32})
    @assert node.node_type != InputNode

    if node.function_id == 0
        return add(conn1_value, conn2_value)
    elseif node.function_id == 1
        return subtract(conn1_value, conn2_value)
    elseif node.function_id == 2
        return mul(conn1_value, conn2_value)
    elseif node.function_id == 3
        return div(conn1_value, conn2_value)
    elseif node.function_id == 4
        return sinReg(conn1_value)
    elseif node.function_id == 5
        return cosReg(conn1_value)
    elseif node.function_id == 6
        return lnReg(conn1_value)
    elseif node.function_id == 7
        return expReg(conn1_value)
    else
        error("wrong function id: $(node.function_id)")
    end
end

function mutate!(node::Node)
    @assert node.node_type != InputNode

    if node.node_type == OutputNode
        mutate_output_node!(node)
    elseif node.node_type == ComputationalNode
        mutate_computational_node!(node)
    else
        error("Trying to mutate input node")
    end
end

function mutate_connection0!(self::Node, connection0::Int, upper_range::Int)
    self.connection0 = gen_random_number_for_node(connection0, upper_range)
end

function mutate_connection1!(self::Node, connection1::Int, upper_range::Int)
    self.connection1 = gen_random_number_for_node(connection1, upper_range)
end

function mutate_function!(node::Node)
    node.function_id = gen_random_number_for_node(node.function_id, 8)
end

function mutate_output_node!(node::Node)
    mutate_connection0!(node, node.connection0, node.graph_width + node.nbr_inputs)
    @assert node.connection0 < node.position
end

function mutate_computational_node!(node::Node)
    rand_nbr = rand(0:2)
    if rand_nbr == 0
        mutate_connection0!(node, node.connection0, node.position)
    elseif rand_nbr == 1
        mutate_connection1!(node, node.connection1, node.position)
    elseif rand_nbr == 2
        mutate_function!(node)
    else
        error("Mutation: output node something wrong")
    end

    @assert node.connection0 < node.position
    @assert node.connection1 < node.position
end


