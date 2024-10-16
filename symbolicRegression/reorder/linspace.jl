#=

using LinearAlgebra

function linspace(x0::Int, xend::Int, n::Int)::Vector{Int}
    a = range(Float64(x0), Float64(xend), length=n)
    x = round.(Int, a)
    return x
end

=#