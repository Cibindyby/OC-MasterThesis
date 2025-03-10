# !/usr/bin/env python

"""

"""
import numpy as np
import pandas as pd
from cmpbayes import Calvo, NonNegative

# ++++++++++++++++++++
# Daten laden
# ++++++++++++++++++++

maximale_iterationen= 6500
stop_krit = 0.01

def get_last_iterations(nameOfTable, nameOfSheet):
    global maximale_iterationen
    global stop_krit

    df = pd.read_excel(f'Endergebnisse/Keijzer/{nameOfTable}.xlsx', nameOfSheet)

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
            max_iteration_if_not_censored = max(max_iteration_if_not_censored, maximale_iterationen+500)
        if (0.02 <= fit) & (fit < 0.03):
            max_iteration_if_not_censored = max(max_iteration_if_not_censored, maximale_iterationen+1500)
        if (0.03 <= fit) & (fit < 0.04):
            max_iteration_if_not_censored = max(max_iteration_if_not_censored, maximale_iterationen+2500)
        if (0.04 <= fit) & (fit < 0.05):
            max_iteration_if_not_censored = max(max_iteration_if_not_censored, maximale_iterationen+3500)
        if (0.05 <= fit) & (fit < 0.06):
            max_iteration_if_not_censored = max(max_iteration_if_not_censored, maximale_iterationen+4500)
        if (0.06 <= fit) & (fit < 0.07):
            max_iteration_if_not_censored = max(max_iteration_if_not_censored, maximale_iterationen+5500)
        if 0.07 <= fit:
            max_iteration_if_not_censored = max(max_iteration_if_not_censored, maximale_iterationen+6500)

    #print(last_iteration)
    #print(len(last_iteration))
    #print(fertig_geworden)

    np_array_last_iteration_all = np.array(last_iteration_all)
    np_array_last_iteration_finished = np.array(last_iteration_finished)
    return np_array_last_iteration_all, np_array_last_iteration_finished, len(not_finished_fitness), max_iteration_if_not_censored

def calvo(algorithm_labels, results):
    #  ++++++++++++++++++++++++++++++++++++++
    # RANKING
    #  ++++++++++++++++++++++++++++++++++++++
    # Berechne Ranking zwischen n vielen algorithmen; in diesem Beispiel sind es 4 Algorithmen á 100 samples

    model = Calvo(results,
                higher_better=False,
                algorithm_labels=algorithm_labels).fit(random_seed=0 + 1)
    sample = np.concatenate(model.infdata_.posterior.weights)
    sample = pd.DataFrame(sample, columns=model.infdata_.posterior.weights.algorithm_labels)
    sample = sample.mean()
    print(sample)

    with open("BayesianAnalysis/bayesianResults/Keijzer/calvo.txt", "a") as file:
        file.write(f"{sample}")


def hpdi(result, max_iteration_without_censoring, number_censored, name_algo):
    #  ++++++++++++++++++++++++++++++++++++++
    # HPDI (& Ranking)
    #  ++++++++++++++++++++++++++++++++++++++
    # Berechne das HPDI für jeweils 2 algorithmen
    x1 = result
    x2 = result
    # Nonnegative kann auch mit "zensierten" Werten umgehen. D.h. falls bspw. bei x1 insgesamt 4 Runs nicht fertig geworden sind,
    # gibt man bei n_censored1=4 ein. Dadurch können die auch mit einberechnet werden in die Statistik; und man nimmt an, dass
    # die Fehlenden Werte ungefähr den Wert mean_upper haben.
    model = NonNegative(x1,
                        x2,
                        mean_upper=max_iteration_without_censoring,
                        # # max-wert, den die Werte einnehmen können. Nur wichtig, wenn "zensierte" werte da sind
                        n_censored1=number_censored,
                        n_censored2=number_censored,
                        censoring_point=maximale_iterationen,
                        ).fit(num_samples=5000, random_seed=2)
    data = np.concatenate(model.infdata_.posterior.mean1)
    data = np.sort(data)
    hdi = (data[int(len(data) * 0.025)], data[int(len(data) * 0.975)])
    print("HDPI Algo 1: ", hdi)
    data = np.concatenate(model.infdata_.posterior.mean2)
    data = np.sort(data)
    hdi = (data[int(len(data) * 0.025)], data[int(len(data) * 0.975)])
    print("HDPI Algo 2: ", hdi)


    with open("BayesianAnalysis/bayesianResults/Keijzer/hpdi.txt", "a") as file:
        file.write(f"{name_algo}: {hdi}\n")



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

list_of_algo_names = [
    ['Keijzer keine Rekombination'],
    ['Keijzer One-Point Konstant kein Offset', 'Keijzer One-Point Konstant mit Offset', 'Keijzer One-Point Clegg kein Offset', 'Keijzer One-Point Clegg mit Offset', 'Keijzer One-Point OneFifth kein Offset', 'Keijzer One-Point One-Fifth mit Offset'],
    ['Keijzer Two-Point Konstant kein Offset', 'Keijzer Two-Point Konstant mit Offset', 'Keijzer Two-Point Clegg kein Offset', 'Keijzer Two-Point Clegg mit Offset', 'Keijzer Two-Point OneFifth kein Offset', 'Keijzer Two-Point OneFifth mit Offset'],
    ['Keijzer Uniform Konstant kein Offset', 'Keijzer Uniform Konstant mit Offset', 'Keijzer Uniform Clegg kein Offset', 'Keijzer Uniform Clegg mit Offset', 'Keijzer Uniform OneFifth kein Offset', 'Keijzer Uniform OneFifth mit Offset']
]


with open("BayesianAnalysis/bayesianResults/Keijzer/hpdi.txt", "w") as file:
    file.write("")


with open("BayesianAnalysis/bayesianResults/Keijzer/calvo.txt", "w") as file:
    file.write("")

calvo_names = []
calvo_results = []
for table_index in range(0,4,1):
    if table_index == 0: #no crossover
        last_iterations_all, last_iterations_finished, number_not_finished, max_iteration_estimation = get_last_iterations("KeijzerNoCrossover", "KeijzerNoCrossover")
        hpdi(last_iterations_finished, max_iteration_estimation, number_not_finished, "Keijzer keine Rekombination")
        #print(len(last_iterations_all))
        calvo_names.append("Keijzer keine Rekombination")
        calvo_results.append(last_iterations_all)
    else:
        for sheet_index in range(0,6,1):
            last_iterations_all, last_iterations_finished, number_not_finished, max_iteration_estimation = get_last_iterations(list_of_tables[table_index], list_of_sheets[table_index][sheet_index])
            hpdi(last_iterations_finished, max_iteration_estimation, number_not_finished, list_of_algo_names[table_index][sheet_index])
            #print(f"{len(last_iterations_all)} -> {list_of_algo_names[table_index][sheet_index]}")
            calvo_names.append(list_of_algo_names[table_index][sheet_index])
            calvo_results.append(last_iterations_all)

calvo(calvo_names, np.stack(calvo_results, axis=1))