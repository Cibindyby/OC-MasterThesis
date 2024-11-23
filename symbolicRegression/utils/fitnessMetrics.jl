using Statistics

function fitness_regression(prediction::Vector{Float32}, label::Vector{Float32})::Float32
    @assert length(prediction) == length(label)
    
    fitness = mean(abs.(prediction .- label))
    
    return fitness
end

