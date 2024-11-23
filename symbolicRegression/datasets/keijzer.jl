# Import necessary libraries
using LinearAlgebra

# Assuming float_loop is defined in a separate module
include("../utils/utilityFuncs.jl")

function make_label(inputs::Vector{Float32})
    labels = Float32[]
    summe = Float32(0.0)
    for d in inputs
        summe = summe + (1.0f0 / d[1])
        push!(labels, summe)
    end
    return labels
end

function get_dataset()
    data = Float32[]

    for x in float_loop(1.0f0, 50.0f0, 1.0f0)
        push!(data, x)
    end

    labels = make_label(data)

    return (data, labels)
end

function get_eval_dataset()
    data = Float32[]

    for x in float_loop(1.0f0, 120.0f0, 1.0f0)
        push!(data, x)
    end

    labels = make_label(data)

    return (data, labels)
end

