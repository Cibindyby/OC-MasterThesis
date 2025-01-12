#just some testing


import XLSX

save_path = joinpath(["booleanProblems","csvTest.csv"])
test_crossover_type = 2
test_crossover_rate_type = 3
test_offset = 0


mkpath(dirname(save_path))

# Öffne die Datei
open(save_path, "w") do file
    write(file, "")
    close(file)
end

open(save_path, "a") do file
    write(file, "Spalte1, Spalte2, Spalte3\n")
end

for i in 0:10
    open(save_path, "a") do file
        write(file, "$i, $(i+1), $(i+2)\n")
    end
end

excelFile = XLSX.readxlsx("HPOErgebnisse.xlsx")
worksheet = excelFile["Parity"]
if test_crossover_type == 3
    lineCounter = 20
else
    lineCounter = test_crossover_type * 6 + test_crossover_rate_type * 2 + test_offset
end

nbr_computational_nodes = worksheet[lineCounter,:][4]
population_size = worksheet[lineCounter,:][5]
crossover_rate = worksheet[lineCounter,:][6]
crossover_delta = worksheet[lineCounter,:][7]
elitism_number = worksheet[lineCounter,:][8]
offset = worksheet[lineCounter,:][9]

print("$nbr_computational_nodes, $population_size, $crossover_rate, $crossover_delta, $elitism_number, $offset")

