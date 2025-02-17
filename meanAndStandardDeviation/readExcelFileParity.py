import pandas as pd
import openpyxl
import numpy as np
import statistics

import matplotlib.pyplot as plt

def create_all_plots(nameOfTable, nameOfSheet, nameOfPlot):
    df = pd.read_excel(f'Endergebnisse/Parity/{nameOfTable}.xlsx', nameOfSheet)

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
        #print(iteration)
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


    # X-Achse: Iterationen (1 bis Anzahl Mittelwerte)
    x = np.arange(1, len(result_means_array) + 1)
    marker_positions = range(99, len(x), 100)

    # Y-Achse: Mittelwerte
    y = result_means_array
    y_plus = positive_site
    y_minus = negative_site

    # Plot erstellen
    plt.figure(figsize=(10, 8))
    plt.plot(x, y, linestyle='-', color='b', label='Mittelwert Fitness', marker='o', markevery=marker_positions)
    plt.plot(x, y_plus, linestyle='-', color='g', label="positive Standardabweichung", marker='o', markevery=marker_positions)
    plt.plot(x, y_minus, linestyle='-', color='r', label="negative Standardabweichung", marker='o', markevery=marker_positions)
    plt.title(nameOfPlot, loc='left')
    plt.xlabel("Iteration")
    plt.ylabel("Fitness")
    plt.grid(True)
    plt.legend(bbox_to_anchor=(0.82, 1.13),loc='upper center')
    for i, (xi, yi) in enumerate(zip(x, y)):
        if xi%100 == 0:
            plt.annotate(f'{yi:.4f}', (xi, yi), textcoords="offset points", xytext=(0, 5), ha='center')
    
    for i, (xi, yi) in enumerate(zip(x, y_plus)):
        if xi%100 == 0:
            plt.annotate(f'{yi:.4f}', (xi, yi), textcoords="offset points", xytext=(0, 10), ha='center')
            
    for i, (xi, yi) in enumerate(zip(x, y_minus)):
        if xi%100 == 0:
            plt.annotate(f'{yi:.4f}', (xi, yi), textcoords="offset points", xytext=(0, -15), ha='center')
    
    #plt.show()
    plt.savefig(f'Endergebnisse/Parity/Plots/{nameOfSheet}Fitness.png')


    # Y-Achse: active nodes
    y_active = result_means_array_active
    y_plus_active = positive_site_active
    y_minus_active = negative_site_active

    # Plot erstellen
    plt.figure(figsize=(10, 8))
    plt.plot(x, y_active, linestyle='-', color='b', label='Mittelwert Anteil aktiver Knoten', marker='o', markevery=marker_positions)
    plt.plot(x, y_plus_active, linestyle='-', color='g', label="positive Standardabweichung", marker='o', markevery=marker_positions)
    plt.plot(x, y_minus_active, linestyle='-', color='r', label="negative Standardabweichung", marker='o', markevery=marker_positions)
    plt.title(nameOfPlot, loc='left')
    plt.xlabel("Iteration")
    plt.ylabel("Anteil aktiver Knoten")
    plt.grid(True)
    plt.legend(bbox_to_anchor=(0.82, 1.13),loc='upper center')
    for i, (xi, yi) in enumerate(zip(x, y_active)):
        if xi%100 == 0:
            plt.annotate(f'{yi:.4f}', (xi, yi), textcoords="offset points", xytext=(0, 5), ha='center')
    
    for i, (xi, yi) in enumerate(zip(x, y_plus_active)):
        if xi%100 == 0:
            plt.annotate(f'{yi:.4f}', (xi, yi), textcoords="offset points", xytext=(0, 10), ha='center')
            
    for i, (xi, yi) in enumerate(zip(x, y_minus_active)):
        if xi%100 == 0:
            plt.annotate(f'{yi:.4f}', (xi, yi), textcoords="offset points", xytext=(0, -15), ha='center')
    
    #plt.show()
    plt.savefig(f'Endergebnisse/Parity/Plots/{nameOfSheet}ActiveNodes.png')




list_of_tables = [
    'ParityNoCrossover',
    'ParityOnePoint',
    'ParityTwoPoint',
    'ParityUniform'
]

list_of_sheets = [
    ['ParityNoCrossover'],
    ['ParityOnePointKonstantNoOffset', 'ParityOnePointKonstantOffset', 'ParityOnePointCleggNoOffset', 'ParityOnePointCleggOffset', 'ParityOnePointOneFifthNoOffset', 'ParityOnePointOneFifthOffset'],
    ['ParityTwoPointKonstantNoOffset', 'ParityTwoPointKonstantOffset', 'ParityTwoPointCleggNoOffset', 'ParityTwoPointCleggOffset', 'ParityTwoPointOneFifthNoOffset', 'ParityTwoPointOneFifthOffset'],
    ['ParityUniformKonstantNoOffset', 'ParityUniformKonstantOffset', 'ParityUniformCleggNoOffset', 'ParityUniformCleggOffset', 'ParityUniformOneFifthNoOffset', 'ParityUniformOneFifthOffset']
]

list_of_plots = [
    ['Parity keine Rekombination'],
    ['Parity One-Point Konstant kein Offset', 'Parity One-Point Konstant mit Offset', 'Parity One-Point Clegg kein Offset', 'Parity One-Point Clegg mit Offset', 'Parity One-Point OneFifth kein Offset', 'Parity One-Point One-Fifth mit Offset'],
    ['Parity Two-Point Konstant kein Offset', 'Parity Two-Point Konstant mit Offset', 'Parity Two-Point Clegg kein Offset', 'Parity Two-Point Clegg mit Offset', 'Parity Two-Point OneFifth kein Offset', 'Parity Two-Point OneFifth mit Offset'],
    ['Parity Uniform Konstant kein Offset', 'Parity Uniform Konstant mit Offset', 'Parity Uniform Clegg kein Offset', 'Parity Uniform Clegg mit Offset', 'Parity Uniform OneFifth kein Offset', 'Parity Uniform OneFifth mit Offset']
]

nameOfTableUsed = ['ParityNoCrossover', 'ParityNoCrossover', 'Parity No Crossover']

for table_index in range(0, 4, 1):
    if table_index == 0: #no crossover
        print(f'Creating plots for: \n{list_of_tables[0]}, \n{list_of_sheets[0][0]}, \n{list_of_plots[0][0]}\n\n')
        create_all_plots(list_of_tables[0], list_of_sheets[0][0], list_of_plots[0][0])
    else:
        for sheet_index in range(0, 6, 1): 
            print(f'Creating plots for: \n{list_of_tables[table_index]}, \n{list_of_sheets[table_index][sheet_index]}, \n{list_of_plots[table_index][sheet_index]}\n\n')
            create_all_plots(list_of_tables[table_index], list_of_sheets[table_index][sheet_index], list_of_plots[table_index][sheet_index])
