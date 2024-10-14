using Random
using Printf
include("../globalParams.jl")
include("node.jl")

struct Chromosome
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
    push!(nodes_grid, Node[])

    # input nodes
    for position in 0:params.nbr_inputs-1
        push!(nodes_grid, Node(position, params.nbr_inputs, params.nbr_computational_nodes, NodeType.InputNode))
    end
    # computational nodes
    for position in params.nbr_inputs:(params.nbr_inputs + params.nbr_computational_nodes - 1)
        push!(nodes_grid, Node(position, params.nbr_inputs, params.nbr_computational_nodes, NodeType.ComputationalNode))
    end
    # output nodes
    for position in (params.nbr_inputs + params.nbr_computational_nodes):(params.nbr_inputs + params.nbr_computational_nodes + params.nbr_outputs - 1)
        push!(nodes_grid, Node(position, params.nbr_inputs, params.nbr_computational_nodes, NodeType.OutputNode))
    end

    # get position of output nodes
    for position in (params.nbr_inputs + params.nbr_computational_nodes):(params.nbr_inputs + params.nbr_computational_nodes + params.nbr_outputs - 1)
        push!(output_node_ids, position)
    end

    return Chromosome(params, nodes_grid, output_node_ids, nothing)
end

function evaluate!(self, inputs::Vector{Vector{Float32}}, labels::Vector{Float32})
    # let active_nodes = self.get_active_nodes_id();
    # self.active_nodes = Some(self.get_active_nodes_id());
    self.get_active_nodes_id()

    outputs = Dict{Int, Vector{Float32}}()

    # iterate through each input and calculate for each new vector its output
    for node_id in self.active_nodes
        current_node = self.nodes_grid[node_id + 1]  # Adjust for 1-based indexing

        if current_node.node_type == NodeType.InputNode
            outputs[node_id] = inputs[node_id + 1]  # Adjust for 1-based indexing
        elseif current_node.node_type == NodeType.OutputNode
            con1 = current_node.connection0
            prev_output1 = outputs[con1]
            outputs[node_id] = copy(prev_output1)
        elseif current_node.node_type == NodeType.ComputationalNode
            con1 = current_node.connection0
            prev_output1 = outputs[con1]

            if current_node.function_id <= 3  # case: two inputs needed
                con2 = current_node.connection1
                prev_output2 = outputs[con2]
                calculated_result = current_node.execute(prev_output1, prev_output2)
            else  # case: only one input needed
                calculated_result = current_node.execute(prev_output1, nothing)
            end
            outputs[node_id] = calculated_result
        end
    end

    output_start_id = self.params.nbr_inputs + self.params.nbr_computational_nodes
    outs = outputs[output_start_id]
    @assert self.nodes_grid[output_start_id + 1].node_type == NodeType.OutputNode  # Adjust for 1-based indexing

    fitness = fitness_metrics.fitness_regression(outs, labels)

    return fitness
end

using Random
using DataStructures: Set

function get_active_nodes_id!(self)
    active = Set{Int}(undef, self.params.nbr_inputs + self.params.nbr_computational_nodes + self.params.nbr_outputs)
    to_visit = Vector{Int}()

    for output_node_id in self.output_node_ids
        push!(active, output_node_id)
        push!(to_visit, output_node_id)
    end

    while !isempty(to_visit)
        current_node_id = pop!(to_visit)
        current_node = self.nodes_grid[current_node_id]

        if current_node.node_type == NodeType.InputNode
            continue
        elseif current_node.node_type == NodeType.ComputationalNode
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
        elseif current_node.node_type == NodeType.OutputNode
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

function mutate_single!(self)
    start_id = self.params.nbr_inputs
    if start_id == 1
        start_id = 2
    end
    end_id = self.params.nbr_inputs + self.params.nbr_computational_nodes + self.params.nbr_outputs

    between = start_id:end_id - 1
    rng = MersenneTwister()

    while true
        random_node_id = rand(rng, between)
        self.nodes_grid[random_node_id].mutate()

        if in(random_node_id, self.active_nodes)
            break
        end
    end
end

function reorder!(self)
    return
end

