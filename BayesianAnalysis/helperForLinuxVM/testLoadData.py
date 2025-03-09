import numpy as np

for i in range(0,2,1):
    data = np.load(f"bayesianAnalysis/helperForLinuxVM/encodeOnePointData/data{i}.npz")
    array = data["last_iterations_all"]
    name = data["name_of_algo"].item().decode()
    print(f"{name}: {len(array)}")