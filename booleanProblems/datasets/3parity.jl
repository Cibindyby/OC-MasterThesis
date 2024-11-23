using LinearAlgebra

function get_dataset()
    data = [
        [false, false, false],
        [false, false, true],
        [false, true, false],
        [false, true, true],
        [true, false, false],
        [true, false, true],
        [true, true, false],
        [true, true, true]
    ]

    labels = [
        [true],
        [false],
        [false],
        [true],
        [false],
        [true],
        [true],
        [false]
    ]

    data = hcat(data...)'
    labels = hcat(labels...)'

    return (data, labels)
end

#same data as train dataset
function get_eval_dataset()
    data = [
        [false, false, false],
        [false, false, true],
        [false, true, false],
        [false, true, true],
        [true, false, false],
        [true, false, true],
        [true, true, false],
        [true, true, true]
    ]

    labels = [
        [true],
        [false],
        [false],
        [true],
        [false],
        [true],
        [true],
        [false]
    ]

    data = hcat(data...)'
    labels = hcat(labels...)'

    return (data, labels)
end

get_dataset()