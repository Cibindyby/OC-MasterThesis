# Funktion zum Laden des Nguyen-7-Datensatzes
# aus DOI 10.1007/s10710-012-9177-2 / DOI: 10.5220/0010110700590070
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


#print(get_training_dataset())
#plt = plot(get_training_dataset())

#savefig(plt, "symbolicRegression/Plots/NgyuenTrainingData")