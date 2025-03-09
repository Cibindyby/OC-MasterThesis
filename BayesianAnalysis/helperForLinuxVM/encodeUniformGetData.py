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
    'EncodeUniformKonstant',
    'EncodeUniformClegg',
    'EncodeUniformOneFifth'
]

list_of_sheets = [
    ['EncodeNoCrossover'],
    ['EncodeUniformKonstant125', 'EncodeUniformKonstant25', 'EncodeUniformKonstant375', 'EncodeUniformKonstant5', 'EncodeUniformKonstant625', 'EncodeUniformKonstant75', 'EncodeUniformKonstant875', 'EncodeUniformKonstant1'],
    ['EncodeUniformClegg05', 'EncodeUniformClegg15', 'EncodeUniformClegg25', 'EncodeUniformClegg35', 'EncodeUniformClegg45', 'EncodeUniformClegg55'],
    ['EncodeUniformOneFifth125', 'EncodeUniformOneFifth25', 'EncodeUniformOneFifth375', 'EncodeUniformOneFifth5', 'EncodeUniformOneFifth625', 'EncodeUniformOneFifth75', 'EncodeUniformOneFifth875', 'EncodeUniformOneFifth1']
]

list_of_algo_names = [
    ['Encode keine Rekombination'],
    ['Encode Uniform Konstant: 0,125', 'Encode Uniform Konstant: 0,25', 'Encode Uniform Konstant: 0,375', 'Encode Uniform Konstant: 0,5', 'Encode Uniform Konstant: 0,625', 'Encode Uniform Konstant: 0,75', 'Encode Uniform Konstant: 0,875', 'Encode Uniform Konstant: 1,0'],
    ['Encode Uniform Clegg: 0,0005', 'Encode Uniform Clegg: 0,0015', 'Encode Uniform Clegg: 0,0025', 'Encode Uniform Clegg: 0,0035', 'Encode Uniform Clegg: 0,0045', 'Encode Uniform Clegg: 0,0055'],
    ['Encode Uniform One-Fifth: 0,125', 'Encode Uniform One-Fifth: 0,25', 'Encode Uniform One-Fifth: 0,375', 'Encode Uniform One-Fifth: 0,5', 'Encode Uniform One-Fifth: 0,625', 'Encode Uniform One-Fifth: 0,75', 'Encode Uniform One-Fifth: 0,875', 'Encode Uniform One-Fifth: 1,0']
]

data_counter = 0
for table_index in range(0, 4, 1):
    if table_index == 0: #no Crossover
            name_of_algo = "Encode keine Rekombination"
            last_iterations_all = get_last_iterations("EncodeNoCrossover", "EncodeNoCrossover")
            np.savez(
                f"bayesianAnalysis/helperForLinuxVM/encodeUniformData/data{data_counter}",
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
                f"bayesianAnalysis/helperForLinuxVM/encodeUniformData/data{data_counter}",
                last_iterations_all=last_iterations_all,
                name_of_algo=np.array(name_of_algo, dtype='S')
            )
            data_counter =+ 1
    else:
        for sheet_index in range(0, 8, 1): 
            name_of_algo = list_of_algo_names[table_index][sheet_index]
            last_iterations_all = get_last_iterations(list_of_tables[table_index], list_of_sheets[table_index][sheet_index])
            np.savez(
                f"bayesianAnalysis/helperForLinuxVM/encodeUniformData/data{data_counter}",
                last_iterations_all=last_iterations_all,
                name_of_algo=np.array(name_of_algo, dtype='S')
            )
            data_counter =+ 1
