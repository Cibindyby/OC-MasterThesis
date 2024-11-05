using Distributions
using Random

function make_label(inputs::Vector{Vector{Float32}})
    labels = Float32[]
    for d in inputs
        push!(labels, log1p(d[1]) + log1p(d[1]^2))
    end
    return labels
end

function get_dataset()
    data = Vector{Float32}[]
    
    between = Uniform(0.0f0, 2.0f0)
    
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

