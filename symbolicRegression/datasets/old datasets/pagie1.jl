# Funktion zum Laden des Pagie-1-Datensatzes
# aus DOI 10.1007/s10710-012-9177-2 / DOI: 10.5220/0010110700590070
#todo Berechnung fixen: jeder Wert von x1 und x2

# E[-5, 5, 0.4]
# dataset: Punkte zwischen -5 und 5 in 0.4 Schritten
using Plots

function get_y!(y, x1, x2)
    for i in 1:1:length(x1)
        vector=Float32[]
        for j in 1:1:length(x2)
            yElem = (1/(1+x1[i]^-4)) + (1/(1+x2[j]^-4))
            append!(vector, yElem)
        end
        y[i, :] = vector
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
    y=zeros(Float32, length(x1), length(x2))
    get_y!(y, x1, x2)

    return (x1, x2, y)
end

function get_eval_dataset()
    #siehe Paper "None"
end


#print(get_training_dataset())
#x1, x2, y = get_training_dataset()
#plt = plot3d(x1, x2, y)

#savefig(plt, "symbolicRegression/Plots/PagieTrainingData")
