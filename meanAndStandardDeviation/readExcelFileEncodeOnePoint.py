import pandas as pd
import openpyxl
import numpy as np
import statistics

import matplotlib.pyplot as plt

plots_array_fitness = []
plots_array_active_nodes = []
highest_y_value_fitness = 0.0
lowest_y_value_fitness = 0.0
highest_y_value_active_nodes = 0.0
lowest_y_value_active_nodes = 0.0

def create_all_plots(nameOfTable, nameOfSheet, nameOfPlot):
    global highest_y_value_fitness
    global highest_y_value_active_nodes
    global lowest_y_value_fitness
    global lowest_y_value_active_nodes
    
    df = pd.read_excel(f'Endergebnisse/Encode/{nameOfTable}.xlsx', nameOfSheet)

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

    for i in y_plus:
        highest_y_value_fitness = max(i, highest_y_value_fitness)

    for i in y_minus:
        lowest_y_value_fitness = min(i, lowest_y_value_fitness)

    # Plot erstellen
    fig_fitness, ax_fitness = plt.subplots(figsize=(10, 8))
    ax_fitness.plot(x, y, linestyle='-', color='b', label='Mittelwert Fitness')
    ax_fitness.plot(x, y_plus, linestyle='-', color='g', label="positive Standardabweichung")
    ax_fitness.plot(x, y_minus, linestyle='-', color='r', label="negative Standardabweichung")
    ax_fitness.set_title(nameOfPlot, loc='left')
    ax_fitness.fill_between(x, y, y_plus, color='g', alpha= 0.1)
    ax_fitness.fill_between(x, y_minus, y, color='r', alpha=0.1)
    ax_fitness.legend(bbox_to_anchor=(0.82, 1.13),loc='upper center')
    ax_fitness.annotate(f'{y[-1]:.4f}', xy=(x[-1], y[-1]), xytext=(27, -7),
             textcoords='offset points',
             ha='left',
             va='bottom')
    ax_fitness.annotate(f'{y_plus[-1]:.4f}', xy=(x[-1], y_plus[-1]), xytext=(27,0),
             textcoords='offset points',
             ha='left',
             va='bottom')
    ax_fitness.annotate(f'{y_minus[-1]:.4f}', xy=(x[-1], y_minus[-1]), xytext=(27, -14),
             textcoords='offset points',
             ha='left',
             va='bottom')
    ax_fitness.set_xlabel("Iteration")
    ax_fitness.set_ylabel("Fitness")
    ax_fitness.grid(True)
    #plt.show()
    plots_array_fitness.append([fig_fitness, nameOfSheet])


    # Y-Achse: active nodes
    y_active = result_means_array_active
    y_plus_active = positive_site_active
    y_minus_active = negative_site_active
    
    for i in y_plus_active:
        highest_y_value_active_nodes = max(i, highest_y_value_active_nodes)

    for i in y_minus_active:
        lowest_y_value_active_nodes = min(i, lowest_y_value_active_nodes)

    # Plot erstellen
    fig_active, ax_active = plt.subplots(figsize=(10, 8))
    ax_active.plot(x, y_active, linestyle='-', color='b', label='Mittelwert Anteil aktiver Knoten')
    ax_active.plot(x, y_plus_active, linestyle='-', color='g', label="positive Standardabweichung")
    ax_active.plot(x, y_minus_active, linestyle='-', color='r', label="negative Standardabweichung")
    ax_active.set_title(nameOfPlot, loc='left')
    ax_active.set_xlabel("Iteration")
    ax_active.set_ylabel("Anteil aktiver Knoten")
    ax_active.fill_between(x, y_active, y_plus_active, color='g', alpha= 0.1)
    ax_active.fill_between(x, y_minus_active, y_active, color='r', alpha=0.1)
    ax_active.grid(True)
    ax_active.annotate(f'{y_active[-1]:.4f}', xy=(x[-1], y_active[-1]), xytext=(27, -7),
             textcoords='offset points',
             ha='left',
             va='bottom')
    ax_active.annotate(f'{y_plus_active[-1]:.4f}', xy=(x[-1], y_plus_active[-1]), xytext=(27, -7),
             textcoords='offset points',
             ha='left',
             va='bottom')
    ax_active.annotate(f'{y_minus_active[-1]:.4f}', xy=(x[-1], y_minus_active[-1]), xytext=(27, -7),
             textcoords='offset points',
             ha='left',
             va='bottom')
    #plt.show()
    plots_array_active_nodes.append([fig_active, nameOfSheet])


list_of_tables = [
    'EncodeOnePointKonstant',
    'EncodeOnePointClegg',
    'EncodeOnePointOneFifth'
]

list_of_sheets = [
    ['EncodeOnePointKonstant125', 'EncodeOnePointKonstant25', 'EncodeOnePointKonstant375', 'EncodeOnePointKonstant5', 'EncodeOnePointKonstant625', 'EncodeOnePointKonstant75', 'EncodeOnePointKonstant875', 'EncodeOnePointKonstant1'],
    ['EncodeOnePointClegg05', 'EncodeOnePointClegg15', 'EncodeOnePointClegg25', 'EncodeOnePointClegg35', 'EncodeOnePointClegg45', 'EncodeOnePointClegg55'],
    ['EncodeOnePointOneFifth125', 'EncodeOnePointOneFifth25', 'EncodeOnePointOneFifth375', 'EncodeOnePointOneFifth5', 'EncodeOnePointOneFifth625', 'EncodeOnePointOneFifth75', 'EncodeOnePointOneFifth875', 'EncodeOnePointOneFifth1']
]

list_of_plots = [
    ['Encode One-Point Konstant: 0,125', 'Encode One-Point Konstant: 0,25', 'Encode One-Point Konstant: 0,375', 'Encode One-Point Konstant: 0,5', 'Encode One-Point Konstant: 0,625', 'Encode One-Point Konstant: 0,75', 'Encode One-Point Konstant: 0,875', 'Encode One-Point Konstant: 1,0'],
    ['Encode One-Point Clegg: 0,0005', 'Encode One-Point Clegg: 0,0015', 'Encode One-Point Clegg: 0,0025', 'Encode One-Point Clegg: 0,0035', 'Encode One-Point Clegg: 0,0045', 'Encode One-Point Clegg: 0,0055'],
    ['Encode One-Point One-Fifth: 0,125', 'Encode One-Point One-Fifth: 0,25', 'Encode One-Point One-Fifth: 0,375', 'Encode One-Point One-Fifth: 0,5', 'Encode One-Point One-Fifth: 0,625', 'Encode One-Point One-Fifth: 0,75', 'Encode One-Point One-Fifth: 0,875', 'Encode One-Point One-Fifth: 1,0']
]


for table_index in range(0, 3, 1):
    if table_index == 1: #Clegg
        for sheet_index in range(0, 6, 1): 
            print(f'Creating plots for: \n{list_of_tables[table_index]}, \n{list_of_sheets[table_index][sheet_index]}, \n{list_of_plots[table_index][sheet_index]}\n\n')
            create_all_plots(list_of_tables[table_index], list_of_sheets[table_index][sheet_index], list_of_plots[table_index][sheet_index])

    else:
        for sheet_index in range(0, 8, 1): 
            print(f'Creating plots for: \n{list_of_tables[table_index]}, \n{list_of_sheets[table_index][sheet_index]}, \n{list_of_plots[table_index][sheet_index]}\n\n')
            create_all_plots(list_of_tables[table_index], list_of_sheets[table_index][sheet_index], list_of_plots[table_index][sheet_index])


for plotAndName in plots_array_fitness:
    ax = plotAndName[0].gca()
    ax.set_ylim(top=highest_y_value_fitness*1.05, bottom=lowest_y_value_fitness)
    plotAndName[0].savefig(f'Plots/Encode/OnePoint/{plotAndName[1]}Fitness.png')
    plt.close(plotAndName[0])

    

for plotAndName in plots_array_active_nodes:
    ax = plotAndName[0].gca()
    ax.set_ylim(top=highest_y_value_active_nodes*1.05, bottom=lowest_y_value_active_nodes)
    plotAndName[0].savefig(f'Plots/Encode/OnePoint/{plotAndName[1]}ActiveNodes.png')
    plt.close(plotAndName[0])
