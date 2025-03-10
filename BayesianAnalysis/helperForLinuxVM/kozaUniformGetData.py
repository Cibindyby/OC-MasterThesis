# !/usr/bin/env python

"""

"""
import numpy as np
import pandas as pd

# ++++++++++++++++++++
# Daten laden
# ++++++++++++++++++++

maximale_iterationen= 50000
stop_krit = 0.01

def get_last_iterations(nameOfTable, nameOfSheet):
    global maximale_iterationen
    global stop_krit

    df = pd.read_excel(f'Endergebnisse/Koza/{nameOfTable}.xlsx', nameOfSheet)

    runs = df['Source.Name'].nunique()

    source_names = df['Source.Name'].unique()

    last_iteration_all = []
    last_iteration_finished = []

    not_finished_fitness = []


    # Iteriere über alle Durchgänge
    for source in source_names:
        
        # Filtere die Daten der aktuellen Iteration
        fitness_and_iteration_for_one_source = df[df['Source.Name'] == source][[' Fitness nach Mutation', 'Iteration']]
        
        for iteration in fitness_and_iteration_for_one_source['Iteration']:
            fitness= fitness_and_iteration_for_one_source[fitness_and_iteration_for_one_source['Iteration'] == iteration][' Fitness nach Mutation'].item()
            
            if fitness < stop_krit:
                last_iteration_all.append(iteration)
                last_iteration_finished.append(iteration)

            if (iteration == maximale_iterationen) & (fitness > stop_krit):
                not_finished_fitness.append(fitness)
                last_iteration_all.append(iteration)

    max_iteration_if_not_censored = max(last_iteration_all)

    for fit in not_finished_fitness:
        if (0.01 <= fit) & (fit < 0.02):
            max_iteration_if_not_censored = max(max_iteration_if_not_censored, maximale_iterationen+5000)
        if (0.02 <= fit) & (fit < 0.03):
            max_iteration_if_not_censored = max(max_iteration_if_not_censored, maximale_iterationen+10000)
        if (0.03 <= fit) & (fit < 0.04):
            max_iteration_if_not_censored = max(max_iteration_if_not_censored, maximale_iterationen+15000)
        if (0.04 <= fit) & (fit < 0.05):
            max_iteration_if_not_censored = max(max_iteration_if_not_censored, maximale_iterationen+20000)
        if (0.05 <= fit) & (fit < 0.06):
            max_iteration_if_not_censored = max(max_iteration_if_not_censored, maximale_iterationen+25000)
        if (0.06 <= fit) & (fit < 0.07):
            max_iteration_if_not_censored = max(max_iteration_if_not_censored, maximale_iterationen+30000)
        if 0.07 <= fit:
            max_iteration_if_not_censored = max(max_iteration_if_not_censored, maximale_iterationen+35000)

    #print(last_iteration)
    #print(len(last_iteration))
    #print(fertig_geworden)

    np_array_last_iteration_all = np.array(last_iteration_all)
    np_array_last_iteration_finished = np.array(last_iteration_finished)
    return np_array_last_iteration_all, np_array_last_iteration_finished, len(not_finished_fitness), max_iteration_if_not_censored


list_of_tables = [
    'KozaNoCrossover',
    'KozaUniformKonstant',
    'KozaUniformClegg',
    'KozaUniformOneFifth'
]

list_of_sheets = [
    ['KozaNoCrossover'],
    ['KozaUniformKonstant125', 'KozaUniformKonstant25', 'KozaUniformKonstant375', 'KozaUniformKonstant5', 'KozaUniformKonstant625', 'KozaUniformKonstant75', 'KozaUniformKonstant875', 'KozaUniformKonstant1'],
    ['KozaUniformClegg05', 'KozaUniformClegg15', 'KozaUniformClegg25', 'KozaUniformClegg35', 'KozaUniformClegg45', 'KozaUniformClegg55'],
    ['KozaUniformOneFifth125', 'KozaUniformOneFifth25', 'KozaUniformOneFifth375', 'KozaUniformOneFifth5', 'KozaUniformOneFifth625', 'KozaUniformOneFifth75', 'KozaUniformOneFifth875', 'KozaUniformOneFifth1']
]

list_of_algo_names = [
    ['Koza keine Rekombination'],
    ['Koza Uniform Konstant: 0,125', 'Koza Uniform Konstant: 0,25', 'Koza Uniform Konstant: 0,375', 'Koza Uniform Konstant: 0,5', 'Koza Uniform Konstant: 0,625', 'Koza Uniform Konstant: 0,75', 'Koza Uniform Konstant: 0,875', 'Koza Uniform Konstant: 1,0'],
    ['Koza Uniform Clegg: 0,0005', 'Koza Uniform Clegg: 0,0015', 'Koza Uniform Clegg: 0,0025', 'Koza Uniform Clegg: 0,0035', 'Koza Uniform Clegg: 0,0045', 'Koza Uniform Clegg: 0,0055'],
    ['Koza Uniform One-Fifth: 0,125', 'Koza Uniform One-Fifth: 0,25', 'Koza Uniform One-Fifth: 0,375', 'Koza Uniform One-Fifth: 0,5', 'Koza Uniform One-Fifth: 0,625', 'Koza Uniform One-Fifth: 0,75', 'Koza Uniform One-Fifth: 0,875', 'Koza Uniform One-Fifth: 1,0']
]

data_counter = 0
for table_index in range(0, 4, 1):
    if table_index == 0: #no Crossover
            name_of_algo = "Koza keine Rekombination"
            last_iterations_all, last_iterations_finished, number_not_finished, max_iteration_if_not_censored = get_last_iterations("KozaNoCrossover", "KozaNoCrossover")
            np.savez(
                f"bayesianAnalysis/helperForLinuxVM/kozaUniformData/data{data_counter}",
                last_iterations_all=last_iterations_all,
                last_iterations_finished = last_iterations_finished,
                number_not_finished = number_not_finished,
                max_iteration_if_not_censored = max_iteration_if_not_censored,
                name_of_algo=np.array(name_of_algo, dtype='S')
            )
            print(data_counter)
            data_counter += 1
    elif table_index == 2: #Clegg
        for sheet_index in range(0, 6, 1): 
            name_of_algo = list_of_algo_names[table_index][sheet_index]
            print(name_of_algo)
            last_iterations_all, last_iterations_finished, number_not_finished, max_iteration_if_not_censored = get_last_iterations(list_of_tables[table_index], list_of_sheets[table_index][sheet_index])
            np.savez(
                f"bayesianAnalysis/helperForLinuxVM/kozaUniformData/data{data_counter}",
                last_iterations_all=last_iterations_all,
                last_iterations_finished = last_iterations_finished,
                number_not_finished = number_not_finished,
                max_iteration_if_not_censored = max_iteration_if_not_censored,
                name_of_algo=np.array(name_of_algo, dtype='S')
            )
            print(data_counter)
            data_counter += 1
    else:
        for sheet_index in range(0, 8, 1): 
            name_of_algo = list_of_algo_names[table_index][sheet_index]
            last_iterations_all, last_iterations_finished, number_not_finished, max_iteration_if_not_censored = get_last_iterations(list_of_tables[table_index], list_of_sheets[table_index][sheet_index])
            np.savez(
                f"bayesianAnalysis/helperForLinuxVM/kozaUniformData/data{data_counter}",
                last_iterations_all=last_iterations_all,
                last_iterations_finished = last_iterations_finished,
                number_not_finished = number_not_finished,
                max_iteration_if_not_censored = max_iteration_if_not_censored,
                name_of_algo=np.array(name_of_algo, dtype='S')
            )
            print(data_counter)
            data_counter += 1
