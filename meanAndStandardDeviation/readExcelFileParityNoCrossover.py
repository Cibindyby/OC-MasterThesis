import pandas as pd
import openpyxl
import numpy as np
import statistics

import matplotlib.pyplot as plt

nameOfTable = 'ParityNoCrossover'

df = pd.read_excel('Endergebnisse/Parity/ParityNoCrossover.xlsx', nameOfTable)

maxIteration = np.max(df['Iteration'])

runs = df['Source.Name'].nunique()

iteration_counts = df['Iteration'].value_counts().sort_index()

result_means_fitness = []
result_std_dev_fitness = []
result_means_active = []
result_std_dev_active = []


# Iteriere über jede Iteration
for iteration, count in iteration_counts.items():
    # Filtere die Daten der aktuellen Iteration
    fitness_of_one_iteration = df[df['Iteration'] == iteration][[' Fitness nach Mutation', 'Source.Name']]
    active_nodes_of_one_iteration = df[df['Iteration'] == iteration][[' Anteil aktiver Knoten', 'Source.Name']]
    

    # Falls weniger als 50 Werte, mit letztem Wert auffüllen
    if not fitness_of_one_iteration.empty and count < runs:
        for source_name in fitness_of_last_iteration['Source.Name']:
            if not any(fitness_of_one_iteration['Source.Name'].isin([source_name])):
                fitness_of_one_iteration.loc[source_name] = pd.Series({' Fitness nach Mutation':fitness_of_last_iteration[fitness_of_last_iteration['Source.Name'] == source_name][' Fitness nach Mutation'].mean(), 'Source.Name':source_name})
        
    # Falls weniger als 50 Werte, mit letztem Wert auffüllen
    if not active_nodes_of_one_iteration.empty and count < runs:
        for source_name in active_nodes_of_last_iteration['Source.Name']:
            if not any(active_nodes_of_one_iteration['Source.Name'].isin([source_name])):
                active_nodes_of_one_iteration.loc[source_name] = pd.Series({' Anteil aktiver Knoten':active_nodes_of_last_iteration[active_nodes_of_last_iteration['Source.Name'] == source_name][' Anteil aktiver Knoten'].mean(), 'Source.Name':source_name})
    
    # Mittelwert berechnen und speichern
    print(iteration)
    mean_value_fitness = fitness_of_one_iteration[' Fitness nach Mutation'].mean()
    result_means_fitness.append(mean_value_fitness)

    std_dev_value_fitness = statistics.stdev(np.array(fitness_of_one_iteration[' Fitness nach Mutation']))
    result_std_dev_fitness.append(std_dev_value_fitness)

    # Mittelwert berechnen und speichern
    mean_value_active = active_nodes_of_one_iteration[' Anteil aktiver Knoten'].mean()
    result_means_active.append(mean_value_active)

    std_dev_value_active = statistics.stdev(np.array(active_nodes_of_one_iteration[' Anteil aktiver Knoten']))
    result_std_dev_active.append(std_dev_value_active)

    fitness_of_last_iteration = fitness_of_one_iteration
    active_nodes_of_last_iteration = active_nodes_of_one_iteration

# Ergebnis als NumPy-Array speichern
result_means_array = np.array(result_means_fitness)
result_std_dev_array = np.array(result_std_dev_fitness)

positive_site = result_means_array + result_std_dev_array
negative_site = result_means_array - result_std_dev_array

# Ergebnis als NumPy-Array speichern
result_means_array_active = np.array(result_means_active)
result_std_dev_array_active = np.array(result_std_dev_active)

positive_site_active = result_means_array_active + result_std_dev_array_active
negative_site_active = result_means_array_active - result_std_dev_array_active

# Array anzeigen
#print(result_means_array)
#print(result_std_dev_array)
#print(positive_site)
#print(negative_site)


# X-Achse: Iterationen (1 bis Anzahl Mittelwerte)
x = np.arange(1, len(result_means_array) + 1)

# Y-Achse: Mittelwerte
y = result_means_array
y_plus = positive_site
y_minus = negative_site

# Plot erstellen
plt.figure(figsize=(10, 6))
plt.plot(x, y, marker='o', linestyle='-', color='b', markersize=2, label='Mittelwert Fitness')
plt.plot(x, y_plus, linestyle='-', color='g', label="positive Standardabweichung")
plt.plot(x, y_minus, linestyle='-', color='r', label="negative Standardabweichung")
plt.title(nameOfTable)
plt.xlabel("Iteration")
plt.ylabel("Fitness")
plt.grid(True)
plt.legend()
plt.show()


# Y-Achse: active nodes
y_active = result_means_array_active
y_plus_active = positive_site_active
y_minus_active = negative_site_active

# Plot erstellen
plt.figure(figsize=(10, 6))
plt.plot(x, y_active, marker='o', linestyle='-', color='b', markersize=2, label='Mittelwert Anteil aktiver Knoten')
plt.plot(x, y_plus_active, linestyle='-', color='g', label="positive Standardabweichung")
plt.plot(x, y_minus_active, linestyle='-', color='r', label="negative Standardabweichung")
plt.title(nameOfTable)
plt.xlabel("Iteration")
plt.ylabel("Anteil aktiver Knoten")
plt.grid(True)
plt.legend()
plt.show()