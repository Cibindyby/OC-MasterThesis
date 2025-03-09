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
    'EncodeTwoPointKonstant',
    'EncodeTwoPointClegg',
    'EncodeTwoPointOneFifth'
]

list_of_sheets = [
    ['EncodeNoCrossover'],
    ['EncodeTwoPointKonstant125', 'EncodeTwoPointKonstant25', 'EncodeTwoPointKonstant375', 'EncodeTwoPointKonstant5', 'EncodeTwoPointKonstant625', 'EncodeTwoPointKonstant75', 'EncodeTwoPointKonstant875', 'EncodeTwoPointKonstant1'],
    ['EncodeTwoPointClegg05', 'EncodeTwoPointClegg15', 'EncodeTwoPointClegg25', 'EncodeTwoPointClegg35', 'EncodeTwoPointClegg45', 'EncodeTwoPointClegg55'],
    ['EncodeTwoPointOneFifth125', 'EncodeTwoPointOneFifth25', 'EncodeTwoPointOneFifth375', 'EncodeTwoPointOneFifth5', 'EncodeTwoPointOneFifth625', 'EncodeTwoPointOneFifth75', 'EncodeTwoPointOneFifth875', 'EncodeTwoPointOneFifth1']
]

list_of_algo_names = [
    ['Encode keine Rekombination'],
    ['Encode Two-Point Konstant: 0,125', 'Encode Two-Point Konstant: 0,25', 'Encode Two-Point Konstant: 0,375', 'Encode Two-Point Konstant: 0,5', 'Encode Two-Point Konstant: 0,625', 'Encode Two-Point Konstant: 0,75', 'Encode Two-Point Konstant: 0,875', 'Encode Two-Point Konstant: 1,0'],
    ['Encode Two-Point Clegg: 0,0005', 'Encode Two-Point Clegg: 0,0015', 'Encode Two-Point Clegg: 0,0025', 'Encode Two-Point Clegg: 0,0035', 'Encode Two-Point Clegg: 0,0045', 'Encode Two-Point Clegg: 0,0055'],
    ['Encode Two-Point One-Fifth: 0,125', 'Encode Two-Point One-Fifth: 0,25', 'Encode Two-Point One-Fifth: 0,375', 'Encode Two-Point One-Fifth: 0,5', 'Encode Two-Point One-Fifth: 0,625', 'Encode Two-Point One-Fifth: 0,75', 'Encode Two-Point One-Fifth: 0,875', 'Encode Two-Point One-Fifth: 1,0']
]

data_counter = 0
for table_index in range(0, 4, 1):
    if table_index == 0: #no Crossover
            name_of_algo = "Encode keine Rekombination"
            last_iterations_all = get_last_iterations("EncodeNoCrossover", "EncodeNoCrossover")
            np.savez(
                f"bayesianAnalysis/helperForLinuxVM/encodeTwoPointData/data{data_counter}",
                last_iterations_all=last_iterations_all,
                name_of_algo=np.array(name_of_algo, dtype='S')
            )
            data_counter =+ 1
    elif table_index == 2: #Clegg
        for sheet_index in range(0, 6, 1): 
            name_of_algo = list_of_algo_names[table_index][sheet_index]
            print(name_of_algo)
            last_iterations_all = get_last_iterations(list_of_tables[table_index], list_of_sheets[table_index][sheet_index])
            np.savez(
                f"bayesianAnalysis/helperForLinuxVM/encodeTwoPointData/data{data_counter}",
                last_iterations_all=last_iterations_all,
                name_of_algo=np.array(name_of_algo, dtype='S')
            )
            data_counter =+ 1
    else:
        for sheet_index in range(0, 8, 1): 
            name_of_algo = list_of_algo_names[table_index][sheet_index]
            last_iterations_all = get_last_iterations(list_of_tables[table_index], list_of_sheets[table_index][sheet_index])
            np.savez(
                f"bayesianAnalysis/helperForLinuxVM/encodeTwoPointData/data{data_counter}",
                last_iterations_all=last_iterations_all,
                name_of_algo=np.array(name_of_algo, dtype='S')
            )
            data_counter =+ 1
