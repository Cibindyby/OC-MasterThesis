# Testszenario Symbolic Regression mit folgenden Tests:
    # Keijzer-6
    # Koza-3
    # Nguyen-7
    # Pagie-1
# gibt Berechnung der Fitness und Testdaten


include("keijzer6.jl")

function keijzer6()
    print("Testszenario: symbolische Regression - Keijzer-6")
    keijzer6.load_keijzer6_dataset()
end

function koza3()
    print("Testszenario: symbolische Regression - Koza-3")
end

function nguyen7()
    print("Testszenario: symbolische Regression - Nguyen-7")
end

function pagie1()
    print("Testszenario: symbolische Regression - Pagie-1")
end


# Fitness-Funktion für symbolische Regression (MSE)
function fitness_function(individual::CGPIndividual, x::Vector{Float64}, y::Vector{Float64})
    predictions = [evaluate_individual(individual, xi) for xi in x]
    mse = mean((predictions .- y) .^ 2)
    return mse
end

# Evaluierung eines CGP-Individuums (wie gut passt es zu den Daten)
function evaluate_individual(individual::CGPIndividual, x::Float64)
    # Einfache lineare Kombination der Gene für Beispielzwecke
    return sum(individual.genes) * x
end
