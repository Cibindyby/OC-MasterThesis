using LinearAlgebra

function fitness_boolean(output::BitMatrix, labels::BitMatrix)
    fitness = 0
    nbr_correct = .!(output .⊻ labels)
    fitness = sum(nbr_correct)
    
    fitness = 1.0 - (Float32(fitness) / Float32(length(labels)))
    return fitness
end

