using Distributions

function make_label(inputs::Vector{Vector{Float32}})
    labels = Float32[]
    for d in inputs
        push!(labels, d[1]^6 - 2 * d[1]^4 + d[1]^2)
    end
    return labels
end

function get_dataset()
    data = Vector{Float32}[]
    
    between = Uniform(-1.0f0, 1.0f0)
    
    for _ in 1:20
        elem = Float32[rand(between)]
        push!(data, elem)
    end
    
    labels = make_label(data)
    
    return (data, labels)
end

function get_eval_dataset()
    return get_dataset()
end

get_dataset()