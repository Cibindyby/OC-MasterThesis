using Random
using Printf
using LinearAlgebra

# using .utils.boolean_functions as bf
include("../utils/symbolicRegressionFunctions.jl")
include("../utils/nodeType.jl")
include("../utils/utilityFuncs.jl")

struct Node
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
    connection0::Int
    connection1::Int

    if node_type == NodeType.InputNode
        connection0 = typemax(Int)
        connection1 = typemax(Int)
    elseif node_type == NodeType.ComputationalNode
        connection0 = rand(0:position-1)
        connection1 = rand(0:position-1)
    elseif node_type == NodeType.OutputNode
        connection0 = rand(0:nbr_inputs + graph_width - 1)
        connection1 = typemax(Int)
    end

    return Node(position, node_type, nbr_inputs, graph_width, function_id, connection0, connection1)
end

function execute(node::Node, conn1_value::Vector{Float32}, conn2_value::Union{Vector{Float32}, Nothing})
    @assert node.node_type != NodeType.InputNode

    if node.function_id == 0
        return symbolicRegressionFunctions.add(conn1_value, conn2_value)
    elseif node.function_id == 1
        return symbolicRegressionFunctions.subtract(conn1_value, conn2_value)
    elseif node.function_id == 2
        return symbolicRegressionFunctions.mul(conn1_value, conn2_value)
    elseif node.function_id == 3
        return symbolicRegressionFunctions.div(conn1_value, conn2_value)
    elseif node.function_id == 4
        return symbolicRegressionFunctions.sin(conn1_value)
    elseif node.function_id == 5
        return symbolicRegressionFunctions.cos(conn1_value)
    elseif node.function_id == 6
        return symbolicRegressionFunctions.ln(conn1_value)
    elseif node.function_id == 7
        return symbolicRegressionFunctions.exp(conn1_value)
    else
        throw(ArgumentError("wrong function id: $(node.function_id)"))
    end
end

function mutate!(self)
    @assert self.node_type != NodeType.InputNode

    if self.node_type == NodeType.OutputNode
        mutate_output_node!(self)
    elseif self.node_type == NodeType.ComputationalNode
        mutate_computational_node!(self)
    else
        throw(ArgumentError("Trying to mutate input node"))
    end
end

function mutate_connection!(connection::Ref{Int}, upper_range::Int)
    connection[] = utilityFuncs.gen_random_number_for_node(connection[], upper_range)
end

function mutate_function!(self)
    self.function_id = utilityFuncs.gen_random_number_for_node(self.function_id, 8)
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

