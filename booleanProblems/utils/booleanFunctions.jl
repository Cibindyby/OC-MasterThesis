using LinearAlgebra

function and(con1::AbstractVector{Bool}, con2::AbstractVector{Bool})::Vector{Bool}
    return con1 .& con2
end

function or(con1::AbstractVector{Bool}, con2::AbstractVector{Bool})::Vector{Bool}
    return con1 .| con2
end

function nand(con1::AbstractVector{Bool}, con2::AbstractVector{Bool})::Vector{Bool}
    return .!and(con1, con2)
end

function nor(con1::AbstractVector{Bool}, con2::AbstractVector{Bool})::Vector{Bool}
    return .!or(con1, con2)
end

