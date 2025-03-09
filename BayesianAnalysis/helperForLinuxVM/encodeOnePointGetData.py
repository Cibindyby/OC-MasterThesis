# !/usr/bin/env python

"""

"""
import numpy as np
import pandas as pd

# ++++++++++++++++++++
# Daten laden
# ++++++++++++++++++++

maximale_iterationen= 10000
stop_krit = 0.000001

def get_last_iterations(nameOfTable, nameOfSheet):
    print(nameOfTable)
    print(nameOfSheet)
    print("\n")
    global maximale_iterationen
    global stop_krit

    df = pd.read_excel(f'Endergebnisse/Encode/{nameOfTable}.xlsx', nameOfSheet)

    source_names = df['Source.Name'].unique()

    last_fitness_all = []


    # Iteriere über alle Durchgänge
    for source in source_names:
        
        # Filtere die Daten der aktuellen Iteration
        fitness_and_iteration_for_one_source = df[df['Source.Name'] == source][[' Fitness nach Mutation', 'Iteration']]
        
        for iteration in fitness_and_iteration_for_one_source['Iteration']:
            fitness= fitness_and_iteration_for_one_source[fitness_and_iteration_for_one_source['Iteration'] == iteration][' Fitness nach Mutation'].item()
            
            if (iteration == maximale_iterationen) | (fitness < stop_krit):
                last_fitness_all.append(fitness)


    np_array_last_iteration_all = np.array(last_fitness_all)
    return np_array_last_iteration_all


list_of_tables = [
    'EncodeNoCrossover',
    'EncodeOnePointKonstant',
    'EncodeOnePointClegg',
    'EncodeOnePointOneFifth'
]

list_of_sheets = [
    ['EncodeNoCrossover'],
    ['EncodeOnePointKonstant125', 'EncodeOnePointKonstant25', 'EncodeOnePointKonstant375', 'EncodeOnePointKonstant5', 'EncodeOnePointKonstant625', 'EncodeOnePointKonstant75', 'EncodeOnePointKonstant875', 'EncodeOnePointKonstant1'],
    ['EncodeOnePointClegg05', 'EncodeOnePointClegg15', 'EncodeOnePointClegg25', 'EncodeOnePointClegg35', 'EncodeOnePointClegg45', 'EncodeOnePointClegg55'],
    ['EncodeOnePointOneFifth125', 'EncodeOnePointOneFifth25', 'EncodeOnePointOneFifth375', 'EncodeOnePointOneFifth5', 'EncodeOnePointOneFifth625', 'EncodeOnePointOneFifth75', 'EncodeOnePointOneFifth875', 'EncodeOnePointOneFifth1']
]

list_of_algo_names = [
    ['Encode keine Rekombination'],
    ['Encode One-Point Konstant: 0,125', 'Encode One-Point Konstant: 0,25', 'Encode One-Point Konstant: 0,375', 'Encode One-Point Konstant: 0,5', 'Encode One-Point Konstant: 0,625', 'Encode One-Point Konstant: 0,75', 'Encode One-Point Konstant: 0,875', 'Encode One-Point Konstant: 1,0'],
    ['Encode One-Point Clegg: 0,0005', 'Encode One-Point Clegg: 0,0015', 'Encode One-Point Clegg: 0,0025', 'Encode One-Point Clegg: 0,0035', 'Encode One-Point Clegg: 0,0045', 'Encode One-Point Clegg: 0,0055'],
    ['Encode One-Point One-Fifth: 0,125', 'Encode One-Point One-Fifth: 0,25', 'Encode One-Point One-Fifth: 0,375', 'Encode One-Point One-Fifth: 0,5', 'Encode One-Point One-Fifth: 0,625', 'Encode One-Point One-Fifth: 0,75', 'Encode One-Point One-Fifth: 0,875', 'Encode One-Point One-Fifth: 1,0']
]

data_counter = 0
for table_index in range(0, 4, 1):
    if table_index == 0: #no Crossover
            name_of_algo = "Encode keine Rekombination"
            last_iterations_all = get_last_iterations("EncodeNoCrossover", "EncodeNoCrossover")
            np.savez(
                f"bayesianAnalysis/helperForLinuxVM/encodeOnePointData/data{data_counter}",
                last_iterations_all=last_iterations_all,
                name_of_algo=np.array(name_of_algo, dtype='S')
            )
            print(data_counter)
            data_counter += 1
    elif table_index == 2: #Clegg
        for sheet_index in range(0, 6, 1): 
            name_of_algo = list_of_algo_names[table_index][sheet_index]
            print(name_of_algo)
            last_iterations_all = get_last_iterations(list_of_tables[table_index], list_of_sheets[table_index][sheet_index])
            np.savez(
                f"bayesianAnalysis/helperForLinuxVM/encodeOnePointData/data{data_counter}",
                last_iterations_all=last_iterations_all,
                name_of_algo=np.array(name_of_algo, dtype='S')
            )
            print(data_counter)
            data_counter += 1
    else:
        for sheet_index in range(0, 8, 1): 
            name_of_algo = list_of_algo_names[table_index][sheet_index]
            last_iterations_all = get_last_iterations(list_of_tables[table_index], list_of_sheets[table_index][sheet_index])
            np.savez(
                f"bayesianAnalysis/helperForLinuxVM/encodeOnePointData/data{data_counter}",
                last_iterations_all=last_iterations_all,
                name_of_algo=np.array(name_of_algo, dtype='S')
            )
            print(data_counter)
            data_counter += 1
