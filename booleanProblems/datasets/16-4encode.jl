using LinearAlgebra

function get_dataset()
    data = [
        [true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false],
        [false, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false],
        [false, false, true, false, false, false, false, false, false, false, false, false, false, false, false, false],
        [false, false, false, true, false, false, false, false, false, false, false, false, false, false, false, false],
        [false, false, false, false, true, false, false, false, false, false, false, false, false, false, false, false],
        [false, false, false, false, false, true, false, false, false, false, false, false, false, false, false, false],
        [false, false, false, false, false, false, true, false, false, false, false, false, false, false, false, false],
        [false, false, false, false, false, false, false, true, false, false, false, false, false, false, false, false],
        [false, false, false, false, false, false, false, false, true, false, false, false, false, false, false, false],
        [false, false, false, false, false, false, false, false, false, true, false, false, false, false, false, false],
        [false, false, false, false, false, false, false, false, false, false, true, false, false, false, false, false],
        [false, false, false, false, false, false, false, false, false, false, false, true, false, false, false, false],
        [false, false, false, false, false, false, false, false, false, false, false, false, true, false, false, false],
        [false, false, false, false, false, false, false, false, false, false, false, false, false, true, false, false],
        [false, false, false, false, false, false, false, false, false, false, false, false, false, false, true, false],
        [false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true]
    ]

    labels = [
        [false, false, false, false],
        [false, false, false, true],
        [false, false, true, false],
        [false, false, true, true],
        [false, true, false, false],
        [false, true, false, true],
        [false, true, true, false],
        [false, true, true, true],
        [true, false, false, false],
        [true, false, false, true],
        [true, false, true, false],
        [true, false, true, true],
        [true, true, false, false],
        [true, true, false, true],
        [true, true, true, false],
        [true, true, true, true]
    ]

    data = BitMatrix(data)
    labels = BitMatrix(labels)

    return (data, labels)
end

