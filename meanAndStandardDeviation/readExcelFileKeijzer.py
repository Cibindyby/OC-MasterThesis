import pandas as pd
import openpyxl
import numpy as np
import statistics

import matplotlib.pyplot as plt

def create_all_plots(nameOfTable, nameOfSheet, nameOfPlot):
    df = pd.read_excel(f'Endergebnisse/Keijzer/{nameOfTable}.xlsx', nameOfSheet)

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

    # Y-Achse: Mittelwerte
    y = result_means_array
    y_plus = positive_site
    y_minus = negative_site

    # Plot erstellen
    plt.figure(figsize=(10, 8))
    plt.plot(x, y, linestyle='-', color='b', label='Mittelwert Fitness')
    plt.plot(x, y_plus, linestyle='-', color='g', label="positive Standardabweichung")
    plt.plot(x, y_minus, linestyle='-', color='r', label="negative Standardabweichung")
    plt.title(nameOfPlot, loc='left')
    plt.fill_between(x, y, y_plus, color='g', alpha= 0.1)
    plt.fill_between(x, y_minus, y, color='r', alpha=0.1)
    plt.legend(bbox_to_anchor=(0.82, 1.13),loc='upper center')
    plt.annotate(f'{y[-1]:.4f}', xy=(x[-1], y[-1]), xytext=(27, -7),
             textcoords='offset points',
             ha='left',
             va='bottom')
    plt.annotate(f'{y_plus[-1]:.4f}', xy=(x[-1], y_plus[-1]), xytext=(27,0),
             textcoords='offset points',
             ha='left',
             va='bottom')
    plt.annotate(f'{y_minus[-1]:.4f}', xy=(x[-1], y_minus[-1]), xytext=(27, -14),
             textcoords='offset points',
             ha='left',
             va='bottom')
    plt.xlabel("Iteration")
    plt.ylabel("Fitness")
    plt.grid(True)
    #plt.show()
    plt.savefig(f'Endergebnisse/Keijzer/Plots/{nameOfSheet}Fitness.png')


    # Y-Achse: active nodes
    y_active = result_means_array_active
    y_plus_active = positive_site_active
    y_minus_active = negative_site_active

    # Plot erstellen
    plt.figure(figsize=(10, 8))
    plt.plot(x, y_active, linestyle='-', color='b', label='Mittelwert Anteil aktiver Knoten')
    plt.plot(x, y_plus_active, linestyle='-', color='g', label="positive Standardabweichung")
    plt.plot(x, y_minus_active, linestyle='-', color='r', label="negative Standardabweichung")
    plt.title(nameOfPlot, loc='left')
    plt.xlabel("Iteration")
    plt.ylabel("Anteil aktiver Knoten")
    plt.fill_between(x, y_active, y_plus_active, color='g', alpha= 0.1)
    plt.fill_between(x, y_minus_active, y_active, color='r', alpha=0.1)
    plt.grid(True)
    plt.annotate(f'{y_active[-1]:.4f}', xy=(x[-1], y_active[-1]), xytext=(27, -7),
             textcoords='offset points',
             ha='left',
             va='bottom')
    plt.annotate(f'{y_plus_active[-1]:.4f}', xy=(x[-1], y_plus_active[-1]), xytext=(27, -7),
             textcoords='offset points',
             ha='left',
             va='bottom')
    plt.annotate(f'{y_minus_active[-1]:.4f}', xy=(x[-1], y_minus_active[-1]), xytext=(27, -7),
             textcoords='offset points',
             ha='left',
             va='bottom')
    #plt.show()
    plt.savefig(f'Endergebnisse/Keijzer/Plots/{nameOfSheet}ActiveNodes.png')




list_of_tables = [
    'KeijzerNoCrossover',
    'KeijzerOnePoint',
    'KeijzerTwoPoint',
    'KeijzerUniform'
]

list_of_sheets = [
    ['KeijzerNoCrossover'],
    ['KeijzerOnePointKonstantNoOffset', 'KeijzerOnePointKonstantOffset', 'KeijzerOnePointCleggNoOffset', 'KeijzerOnePointCleggOffset', 'KeijzerOnePointOneFifthNoOffset', 'KeijzerOnePointOneFifthOffset'],
    ['KeijzerTwoPointKonstantNoOffset', 'KeijzerTwoPointKonstantOffset', 'KeijzerTwoPointCleggNoOffset', 'KeijzerTwoPointCleggOffset', 'KeijzerTwoPointOneFifthNoOffset', 'KeijzerTwoPointOneFifthOffset'],
    ['KeijzerUniformKonstantNoOffset', 'KeijzerUniformKonstantOffset', 'KeijzerUniformCleggNoOffset', 'KeijzerUniformCleggOffset', 'KeijzerUniformOneFifthNoOffset', 'KeijzerUniformOneFifthOffset']
]

list_of_plots = [
    ['Keijzer keine Rekombination'],
    ['Keijzer One-Point Konstant kein Offset', 'Keijzer One-Point Konstant mit Offset', 'Keijzer One-Point Clegg kein Offset', 'Keijzer One-Point Clegg mit Offset', 'Keijzer One-Point OneFifth kein Offset', 'Keijzer One-Point One-Fifth mit Offset'],
    ['Keijzer Two-Point Konstant kein Offset', 'Keijzer Two-Point Konstant mit Offset', 'Keijzer Two-Point Clegg kein Offset', 'Keijzer Two-Point Clegg mit Offset', 'Keijzer Two-Point OneFifth kein Offset', 'Keijzer Two-Point OneFifth mit Offset'],
    ['Keijzer Uniform Konstant kein Offset', 'Keijzer Uniform Konstant mit Offset', 'Keijzer Uniform Clegg kein Offset', 'Keijzer Uniform Clegg mit Offset', 'Keijzer Uniform OneFifth kein Offset', 'Keijzer Uniform OneFifth mit Offset']
]


for table_index in range(0, 4, 1):
    if table_index == 0: #no crossover
        print(f'Creating plots for: \n{list_of_tables[0]}, \n{list_of_sheets[0][0]}, \n{list_of_plots[0][0]}\n\n')
        create_all_plots(list_of_tables[0], list_of_sheets[0][0], list_of_plots[0][0])
    else:
        for sheet_index in range(0, 6, 1): 
            print(f'Creating plots for: \n{list_of_tables[table_index]}, \n{list_of_sheets[table_index][sheet_index]}, \n{list_of_plots[table_index][sheet_index]}\n\n')
            create_all_plots(list_of_tables[table_index], list_of_sheets[table_index][sheet_index], list_of_plots[table_index][sheet_index])
