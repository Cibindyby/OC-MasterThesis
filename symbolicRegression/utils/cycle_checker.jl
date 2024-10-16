using DataStructures

mutable struct CGPEdges
    edges::Vector{Vector{Int}}
end

function CGPEdges(nbr_nodes::Int)
    edges = [Vector{Int}(undef, 0) for _ in 1:nbr_nodes]
    CGPEdges(edges)
end

function add_edge!(cgp::CGPEdges, node_id::Int, prev_node_id::Int)
    push!(cgp.edges[node_id], prev_node_id)
end

function remove_edge!(cgp::CGPEdges, node_id::Int, prev_node_id::Int)
    index = findfirst(x -> x == prev_node_id, cgp.edges[node_id])
    deleteat!(cgp.edges[node_id], index)
end

function leads_to_cycle(cgp::CGPEdges, node_id::Int, prev_node_id::Int)
    to_check = Vector{Int}()
    checked = Set{Int}()

    append!(to_check, cgp.edges[prev_node_id])
    union!(checked, cgp.edges[prev_node_id])

    while !isempty(to_check)
        checking = pop!(to_check)
        if checking == node_id
            return true
        end

        for new_edge in cgp.edges[checking]
            if !(new_edge in checked)
                push!(to_check, new_edge)
                push!(checked, new_edge)
            end
        end
    end
    return false
end

