# Funktion zum Laden des Nguyen-7-Datensatzes

# U[0, 2, 20]
# dataset: 20 gleichverteilte Punkte zwischen 0 und 2

using Plots

function get_y!(y, x)
    for i in x
        yElem = log(i+1) + log(i^2+1)
        append!(y, yElem)
    end
end

function get_training_dataset()
    x = Float32[]

    for elem in 0.0:(2.0/20):2.0
        i = Float32(elem)
        append!(x, i)
    end
    y=Float32[]
    get_y!(y, x)

    return (x, y)
end

function get_eval_dataset()
    #siehe Paper "None"
end


print(get_training_dataset())
plot(get_training_dataset())
