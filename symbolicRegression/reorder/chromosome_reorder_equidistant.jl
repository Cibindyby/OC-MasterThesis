#=
include("../globalParams.jl")
include("../reorder/node_reorder.jl")
include("../utils/nodeType.jl")
include("../utils/fitnessMetrics.jl")
include("../utils/utilityFuncs.jl")
include("../reorder/linspace.jl")
using Random
using DataStructures

struct Chromosome
    params::CgpParameters
    nodes_grid::Vector{NodeReorder}
    output_node_ids::Vector{Int}
    active_nodes::Union{Vector{Int}, Nothing}
    rng::Random.MersenneTwister
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
    rng = MersenneTwister()
    nodes_grid = Vector{NodeReorder}()
    output_node_ids = Vector{Int}()

    # input nodes
    for position in 0:params.nbr_inputs-1
        push!(nodes_grid, NodeReorder(position, params.nbr_inputs, params.nbr_computational_nodes, NodeType.InputNode))
    end

    # computational nodes
    for position in params.nbr_inputs:(params.nbr_inputs + params.nbr_computational_nodes - 1)
        push!(nodes_grid, NodeReorder(position, params.nbr_inputs, params.nbr_computational_nodes, NodeType.ComputationalNode))
    end

    # output nodes
    for position in (params.nbr_inputs + params.nbr_computational_nodes):(params.nbr_inputs + params.nbr_computational_nodes + params.nbr_outputs - 1)
        push!(nodes_grid, NodeReorder(position, params.nbr_inputs, params.nbr_computational_nodes, NodeType.OutputNode))
    end

    for position in (params.nbr_inputs + params.nbr_computational_nodes):(params.nbr_inputs + params.nbr_computational_nodes + params.nbr_outputs - 1)
        push!(output_node_ids, position)
    end

    return Chromosome(params, nodes_grid, output_node_ids, nothing, rng)
end

function evaluate(c::Chromosome, inputs::Vector{Vector{Float32}}, labels::Vector{Float32})
    get_active_nodes_id!(c)

    outputs = DefaultDict{Int, Vector{Float32}}(Vector{Float32})

    for node_id in c.active_nodes
        current_node = c.nodes_grid[node_id]

        if current_node.node_type == NodeType.InputNode
            outputs[node_id] = inputs[node_id]
        elseif current_node.node_type == NodeType.OutputNode
            con1 = current_node.connection0
            prev_output1 = outputs[con1]
            outputs[node_id] = prev_output1
        elseif current_node.node_type == NodeType.ComputationalNode
            con1 = current_node.connection0
            prev_output1 = outputs[con1]

            if current_node.function_id <= 3
                con2 = current_node.connection1
                prev_output2 = outputs[con2]
                calculated_result = current_node.execute(prev_output1, prev_output2)
            else
                calculated_result = current_node.execute(prev_output1, nothing)
            end
            outputs[node_id] = calculated_result
        end
    end

    output_start_id = c.params.nbr_inputs + c.params.nbr_computational_nodes
    outs = outputs[output_start_id]
    @assert c.nodes_grid[output_start_id].node_type == NodeType.OutputNode

    fitness = fitness_metrics.fitness_regression(outs, labels)

    return fitness
end

function get_active_nodes_id!(c::Chromosome)
    active = Set{Int}()
    active_nodes = Vector{Int}()
    to_visit = Vector{Int}()

    for output_node_id in c.output_node_ids
        push!(active, output_node_id)
        push!(to_visit, output_node_id)
    end

    while !isempty(to_visit)
        current_node_id = pop!(to_visit)
        current_node = c.nodes_grid[current_node_id]

        if current_node.node_type == NodeType.InputNode
            continue
        elseif current_node.node_type == NodeType.ComputationalNode
            connection0 = current_node.connection0
            if !in(connection0, active)
                push!(to_visit, connection0)
                push!(active, connection0)
            end

            connection1 = current_node.connection1
            if !in(connection1, active)
                push!(to_visit, connection1)
                push!(active, connection1)
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
    c.active_nodes = active_nodes
end

function mutate_single(c::Chromosome)
    start_id = c.params.nbr_inputs
    end_id = c.params.nbr_inputs + c.params.nbr_computational_nodes + c.params.nbr_outputs

    between = start_id:end_id-1
    rng = MersenneTwister()

    while true
        random_node_id = rand(rng, between)
        c.nodes_grid[random_node_id].mutate()

        if in(random_node_id, c.active_nodes)
            break
        end
    end
end

function reorder(c::Chromosome)
    c_active_nodes = copy(c.active_nodes)

    # remove output nodes
    for output_node_id in reverse(c.params.nbr_inputs + c.params.nbr_computational_nodes:(c.params.nbr_inputs + c.params.nbr_computational_nodes + c.params.nbr_outputs - 1))
        index = findfirst(x -> x == output_node_id, c_active_nodes)
        if index !== nothing
            deleteat!(c_active_nodes, index)
        end
    end

    # remove input nodes
    for input_node_id in reverse(0:c.params.nbr_inputs-1)
        index = findfirst(x -> x == input_node_id, c_active_nodes)
        if index !== nothing
            deleteat!(c_active_nodes, index)
        end
    end

    if isempty(c_active_nodes)
        return
    end

    swap_nodes!(c, c_active_nodes)
end

function swap_nodes!(c::Chromosome, c_active_nodes::Vector{Int})
    new_pos_active = linspace(c.params.nbr_inputs, c.params.nbr_inputs + c.params.nbr_computational_nodes - 1, length(c_active_nodes))

    comp_nodes_ids = c.params.nbr_inputs:(c.params.nbr_inputs + c.params.nbr_computational_nodes - 1)
    old_pos_inactive = utility_funcs.vect_difference(comp_nodes_ids, c_active_nodes)
    new_pos_inactive = utility_funcs.vect_difference(comp_nodes_ids, new_pos_active)

    sort!(old_pos_inactive)
    sort!(new_pos_inactive)

    @assert length(c_active_nodes) == length(new_pos_active)
    @assert length(old_pos_inactive) == length(new_pos_inactive)

    swapped_pos_indices = DefaultDict{Int, Int}(Int)

    new_nodes_grid = copy(c.nodes_grid)

    for (old_node_id, new_node_id) in zip(c_active_nodes, new_pos_active)
        node = copy(c.nodes_grid[old_node_id])
        node.set_new_position(new_node_id, false)
        new_nodes_grid[new_node_id] = node
        swapped_pos_indices[old_node_id] = new_node_id
    end

    for (old_node_id, new_node_id) in zip(old_pos_inactive, new_pos_inactive)
        @assert !in(new_node_id, new_pos_active)
        node = copy(c.nodes_grid[old_node_id])
        node.set_new_position(new_node_id, true)
        new_nodes_grid[new_node_id] = node
    end

    for node_id in new_pos_active
        update_connections!(new_nodes_grid, node_id, swapped_pos_indices)
    end

    for node_id in (c.params.nbr_inputs + c.params.nbr_computational_nodes):(c.params.nbr_inputs + c.params.nbr_computational_nodes + c.params.nbr_outputs - 1)
        update_connections!(new_nodes_grid, node_id, swapped_pos_indices)
    end

    c.nodes_grid = new_nodes_grid

    get_active_nodes_id!(c)
end

function update_connections!(new_nodes_grid::Vector{NodeReorder}, node_id::Int, swapped_pos_indices::DefaultDict{Int, Int})
    con1 = new_nodes_grid[node_id].connection0
    con2 = new_nodes_grid[node_id].connection1

    new_nodes_grid[node_id].connection0 = get(swapped_pos_indices, con1, con1)
    new_nodes_grid[node_id].connection1 = get(swapped_pos_indices, con2, con2)
end

=#