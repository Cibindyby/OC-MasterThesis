using Random
using Printf
include("../globalParams.jl")
include("node.jl")
include("../utils/fitnessMetrics.jl")

mutable struct Chromosome
    params::CgpParameters
    nodes_grid::Vector{Node}
    output_node_ids::Vector{Int}
    active_nodes::Union{Vector{Int}, Nothing}
end

function Base.show(io::IO, c::Chromosome)
    println(io, "+++++++++++++++++ Chromosome +++++++++++")
    println(io, "Nodes:")
    for node in c.nodes_grid
        print(io, node)
    end
    println(io, "Active_nodes: ", c.active_nodes)
    println(io, "Output_nodes: ", c.output_node_ids)
end

function Chromosome(params::CgpParameters)
    @assert params.nbr_outputs == 1

    nodes_grid = Vector{Node}()
    output_node_ids = Vector{Int}()

    # input nodes
    for position in 0:params.nbr_inputs-1
        inputNode = Node(position, params.nbr_inputs, params.nbr_computational_nodes, InputNode)
        push!(nodes_grid, inputNode)
    end
    # computational nodes
    for position in params.nbr_inputs:(params.nbr_inputs + params.nbr_computational_nodes - 1)
        push!(nodes_grid, Node(position, params.nbr_inputs, params.nbr_computational_nodes, ComputationalNode))
    end
    # output nodes
    for position in (params.nbr_inputs + params.nbr_computational_nodes):(params.nbr_inputs + params.nbr_computational_nodes + params.nbr_outputs - 1)
        push!(nodes_grid, Node(position, params.nbr_inputs, params.nbr_computational_nodes, OutputNode))
    end

    # get position of output nodes
    for position in (params.nbr_inputs + params.nbr_computational_nodes):(params.nbr_inputs + params.nbr_computational_nodes + params.nbr_outputs - 1)
        push!(output_node_ids, position)
    end

    return Chromosome(params, nodes_grid, output_node_ids, nothing)
end

using DataStructures

function evaluate!(self::Chromosome, inputs::Vector{Float32}, labels::Vector{Float32})
    get_active_nodes_id!(self)

    outputsNode = Dict{Int, Vector{Float32}}()
    prediction = Vector{Float32}()
    
    for node_id in self.active_nodes
        current_node = self.nodes_grid[node_id + 1]
        outputsNode[node_id] = Vector{Float32}()

        if current_node.node_type == InputNode
            outputsNode[node_id] = inputs[:, node_id + 1]
        elseif current_node.node_type == OutputNode
            con1 = current_node.connection0
            prev_output1 = outputsNode[con1]
            outputsNode[node_id] = copy(prev_output1)
            prediction = copy(prev_output1)
        elseif current_node.node_type == ComputationalNode
            con1 = current_node.connection0
            prev_output1 = outputsNode[con1]

            if current_node.function_id <= 3  # case: two inputs needed
                con2 = current_node.connection1
                prev_output2 = outputsNode[con2]
                calculated_result = nodeExecute(current_node,prev_output1, prev_output2)
            else  # case: only one input needed
                calculated_result = nodeExecute(current_node, prev_output1, Vector{Float32}())
            end
            outputsNode[node_id] = calculated_result
        end
    end
    fitness = fitness_regression(prediction, labels)

    return fitness
end

using Random
using DataStructures: Set

function get_active_nodes_id!(self)
    active = Set{Int}()
    to_visit = Vector{Int}()

    for output_node_id in self.output_node_ids
        push!(active, output_node_id)
        push!(to_visit, output_node_id)
    end

    while !isempty(to_visit)
        current_node_id = pop!(to_visit)
        current_node = self.nodes_grid[current_node_id+1]

        if current_node.node_type == InputNode
            continue
        elseif current_node.node_type == ComputationalNode
            connection0 = current_node.connection0
            if !in(connection0, active)
                push!(to_visit, connection0)
                push!(active, connection0)
            end
            if current_node.function_id <= 3
                connection1 = current_node.connection1
                if !in(connection1, active)
                    push!(to_visit, connection1)
                    push!(active, connection1)
                end
            end
        elseif current_node.node_type == OutputNode
            connection0 = current_node.connection0
            if !in(connection0, active)
                push!(to_visit, connection0)
                push!(active, connection0)
            end
        end
    end

    active_nodes = sort(collect(active))
    self.active_nodes = active_nodes
end

function mutate_single!(self::Chromosome)
    start_id = self.params.nbr_inputs + 1
    if start_id == 1
        start_id = 2
    end
    end_id = self.params.nbr_inputs + 1 + self.params.nbr_computational_nodes + self.params.nbr_outputs

    between = start_id:end_id - 1
    rng = MersenneTwister()

    while true
        random_node_id = rand(rng, between)
        mutate!(self.nodes_grid[random_node_id])

        if in(random_node_id - 1, self.active_nodes)
            break
        end
    end
end


