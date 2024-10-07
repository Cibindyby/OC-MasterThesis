# Funktion zum Laden des Keijzer-6-Datensatzes

# E[1, 50, 1]
# Intervall: [1;50]; Schrittgröße: 1
# eval dataset: 120 Punkte
using Plots

function get_y!(y, x)
    summe = 0.0
    for i in x
        summe += 1.0 / i
        append!(y, summe)
    end
end

function get_training_dataset()
    x = Float32[]

    for elem in 1.0:1.0:50.0
        i = Float32(elem)
        append!(x, i)
    end
    y=Float32[]
    get_y!(y, x)

    return (x, y)
end

function get_eval_dataset()
    x = Float32[]

    for elem in -1.0:(2.0/120.0):1.0
        i = Float32(elem)
        append!(x, elem)
    end
    y = Float32[]
    get_y!(y, x)

    return (x, y)
end


print(get_training_dataset())
plot(get_training_dataset())
