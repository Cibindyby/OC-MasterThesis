import numpy as np  # type: ignore

for i in range(0,22,1):
    data = np.load(f"BayesianAnalysis/helperForLinuxVM/encodeOnePointData/data{i}.npz")
    array = data["last_iterations_all"]
    name = data["name_of_algo"].item().decode()
    print(f"{name}: {len(array)}")