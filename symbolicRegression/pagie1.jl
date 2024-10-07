# Funktion zum Laden des Pagie-1-Datensatzes

#todo Berechnung fixen: jeder Wert von x1 und x2

# E[-5, 5, 0.4]
# dataset: Punkte zwischen -5 und 5 in 0.4 Schritten
using Plots

function get_y!(y, x1, x2)
    for i in 1:1:length(x1)
        yElem = (1/(1+x1[i]^-4)) + (1/(1+x2[i]^-4))
        append!(y, yElem)
    end
end

function get_training_dataset()
    x1 = Float32[]
    x2 = Float32[]

    for elem in -5.0:0.4:5.0
        i = Float32(elem)
        append!(x1, i)
        append!(x2, i)
    end
    y=Float32[]
    get_y!(y, x1, x2)

    return (x1, x2, y)
end

function get_eval_dataset()
    #siehe Paper "None"
end


print(get_training_dataset())
plot(get_training_dataset())
