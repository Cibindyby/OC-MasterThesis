using LinearAlgebra

function add(con1::Vector{Float32}, con2::Vector{Float32})::Vector{Float32}
    return con1 .+ con2
end

function subtract(con1::Vector{Float32}, con2::Vector{Float32})::Vector{Float32}
    return con1 .- con2
end

function mul(con1::Vector{Float32}, con2::Vector{Float32})::Vector{Float32}
    return con1 .* con2
end

function div(con1::Vector{Float32}, con2::Vector{Float32})::Vector{Float32}
    return [isapprox(b, 0.0, atol=1e-5) ? 1.0f0 : a / b for (a, b) in zip(con1, con2)]
end

function sinReg(con1::Vector{Float32})::Vector{Float32}
    try
        return sin.(con1)
    catch
        return con1
    end
end

function cosReg(con1::Vector{Float32})::Vector{Float32}
    try
        return cos.(con1)
    catch
        return con1
    end
end

function lnReg(con1::Vector{Float32})::Vector{Float32}
    return [isapprox(x, 0.0, atol=1e-5) ? 1.0f0 : log(abs(x)) for x in con1]
end

function expReg(con1::Vector{Float32})::Vector{Float32}
    return exp.(con1)
end

# +, - *, /, sin, cos, ln(|n|), e^n

