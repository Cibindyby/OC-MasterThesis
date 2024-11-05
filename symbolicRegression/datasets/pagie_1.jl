include("../utils/utilityFuncs.jl")

function make_label(inputs::Vector{Vector{Float32}})
    labels = Float32[]
    for d in inputs
        push!(labels, 1 / (1 + d[1]^(-4)) + 1 / (1 + d[2]^(-4)))
    end
    return labels
end

function get_dataset()
    data = Vector{Float32}[]

    for x in float_loop(-5.0f0, 5.0f0, 0.4f0)
        for y in float_loop(-5.0f0, 5.0f0, 0.4f0)
            elem = Float32[x, y]
            push!(data, elem)
        end
    end

    labels = make_label(data)

    return (data, labels)
end

function get_eval_dataset()
    return get_dataset()
end

