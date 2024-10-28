function fitness_regression(prediction::Vector{Float32}, label::Vector{Float32})::Float32
    @assert length(prediction) == length(label) "Längen von prediction und label müssen übereinstimmen"

    fitness::Float32 = 0.0
    
    for (x, y) in zip(prediction, label)
        fitness += abs(x - y)
    end
    
    fitness = fitness / Float32(length(prediction))

    println("fitness is calculated: $fitness")
    if fitness <= 2
        println("prediction: $prediction")
        println("labels: $label")
    end
    
    return fitness
end