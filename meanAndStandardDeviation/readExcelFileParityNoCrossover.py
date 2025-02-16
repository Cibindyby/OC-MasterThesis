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

result_means = []
result_std_dev = []
result_means_active = []
result_std_dev_active = []

# Iteriere über jede Iteration
for iteration, count in iteration_counts.items():
    # Filtere die Daten der aktuellen Iteration
    data = df[df['Iteration'] == iteration][' Fitness nach Mutation']
    active_nodes = df[df['Iteration'] == iteration][' Anteil aktiver Knoten']
    

#TODO: Problem Lösen mit Werte auffüllen -> Welche Werte sollen aufgefüllt werden? Sollen die aufgefüllt werden?



    # Falls weniger als 50 Werte, mit letztem Wert auffüllen
    if not data.empty and count < runs:
        last_value = 0 #data.iloc[-1]  # Letzter bekannter 
        fill_values = pd.Series([last_value] * (runs - count))
        data = pd.concat([data, fill_values], ignore_index=True)

    # Falls weniger als 50 Werte, mit letztem Wert auffüllen
    if not active_nodes.empty and count < runs:
        last_value = data.iloc[-1]  # Letzter bekannter Wert
        fill_values = pd.Series([last_value] * (runs - count))
        active_nodes = pd.concat([active_nodes, fill_values], ignore_index=True)
    
    # Mittelwert berechnen und speichern
    mean_value = data.mean()
    result_means.append(mean_value)

    std_dev_value = statistics.stdev(data)
    result_std_dev.append(std_dev_value)

    # Mittelwert berechnen und speichern
    mean_value_active = active_nodes.mean()
    result_means_active.append(mean_value_active)

    std_dev_value_active = statistics.stdev(active_nodes)
    result_std_dev_active.append(std_dev_value_active)

# Ergebnis als NumPy-Array speichern
result_means_array = np.array(result_means)
result_std_dev_array = np.array(result_std_dev)

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
plt.plot(x, y_plus, linestyle='-', color='g', label="positive standard deviation")
plt.plot(x, y_minus, linestyle='-', color='r', label="negative standard deviation")
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
plt.plot(x, y_plus_active, linestyle='-', color='g', label="positive standard deviation")
plt.plot(x, y_minus_active, linestyle='-', color='r', label="negative standard deviation")
plt.title(nameOfTable)
plt.xlabel("Iteration")
plt.ylabel("Anteil aktiver Knoten")
plt.grid(True)
plt.legend()
plt.show()