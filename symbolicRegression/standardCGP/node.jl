using Random
using Printf
using LinearAlgebra

# using .utils.boolean_functions as bf
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
    @printf(io, "Node Pos: %d, ", node.position)
    @printf(io, "Node Type: %s, ", node.node_type)
    @printf(io, "Function ID: %d, ", node.function_id)
    @printf(io, "Connections: (%d, %d), ", node.connection0, node.connection1)
end

function Node(position::Int, nbr_inputs::Int, graph_width::Int, node_type::NodeType)
    function_id = rand(0:7)
    connection0::Int = -1
    connection1::Int = -1

    if node_type == InputNode
        connection0 = typemax(Int)
        connection1 = typemax(Int)
    elseif node_type == ComputationalNode
        connection0 = rand(0:position-1)
        connection1 = rand(0:position-1)
    elseif node_type == OutputNode
        connection0 = rand(0:nbr_inputs + graph_width - 1)
        connection1 = typemax(Int)
    end

    return Node(position, node_type, nbr_inputs, graph_width, function_id, connection0, connection1)
end

function nodeExecute(node::Node, conn1_value::Vector{Float32}, conn2_value::Vector{Float32})::Vector{Float32}
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
        throw(ArgumentError("wrong function id: $(node.function_id)"))
    end
end

function mutate!(self::Node)
    @assert self.node_type != InputNode

    if self.node_type == OutputNode
        mutate_output_node!(self)
    elseif self.node_type == ComputationalNode
        mutate_computational_node!(self)
    else
        throw(ArgumentError("Trying to mutate input node"))
    end
end

function mutate_connection!(connection::Ref{Int}, upper_range::Int)
    connection[] = gen_random_number_for_node(connection[], upper_range)
end

function mutate_function!(self)
    self.function_id = gen_random_number_for_node(self.function_id, 8)
end

function mutate_output_node!(self)
    mutate_connection!(Ref(self.connection0), self.graph_width + self.nbr_inputs)
    @assert self.connection0 < self.position
end

function mutate_computational_node!(self)
    rand_nbr = rand(0:2)
    if rand_nbr == 0
        mutate_connection!(Ref(self.connection0), self.position)
    elseif rand_nbr == 1
        mutate_connection!(Ref(self.connection1), self.position)
    elseif rand_nbr == 2
        mutate_function!(self)
    else
        throw(ArgumentError("Mutation: output node something wrong"))
    end

    @assert self.connection0 < self.position
    @assert self.connection1 < self.position
end

