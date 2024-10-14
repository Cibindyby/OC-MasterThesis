using Random

function get_argmins_of_value(vecs::Vector{Float32}, comp_value::Float32)
    return findall(x -> x == comp_value, vecs)
end

function get_argmin(nets::Vector{Float32})
    return argmin(nets)
end

function get_min(nets::Vector{Float32})
    return minimum(nets)
end

function vect_difference(v1::Vector{Int}, v2::Vector{Int})
    return setdiff(v1, v2)
end

function gen_random_number_for_node(excluded::Int, upper_range::Int)
    if upper_range <= 1
        return 0
    end
    
    while true
        rand_nbr = rand(0:upper_range-1)
        if rand_nbr != excluded
            return rand_nbr
        end
    end
end

function transpose(v::Vector{Vector{T}}) where T
    isempty(v) && return Vector{Vector{T}}()
    return [[v[j][i] for j in 1:length(v)] for i in 1:length(v[1])]
end

function float_loop(start::Float32, threshold::Float32, step_size::Float32)
    threshold += 1.0f0
    return Iterators.takewhile(x -> x < threshold, 
                               Iterators.countfrom(start, step_size))
end

