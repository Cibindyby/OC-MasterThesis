# !/usr/bin/env python

"""

"""
import numpy as np
import pandas as pd
from cmpbayes import Calvo, NonNegative

maximale_iterationen = 50000
def calvo_and_hpdi_for_all():

    calvo_names = []
    calvo_results = []
    for i in range(0,22,1):
        data = np.load(f"BayesianAnalysis/helperForLinuxVM/kozaUniformData/data{i}.npz")
        last_iterations_all = data["last_iterations_all"]
        last_iterations_finished = data["last_iterations_finished"]
        number_not_finished = data["number_not_finished"].item()
        max_iteration_estimation = data["max_iteration_if_not_censored"].item()
        name = data["name_of_algo"].item().decode()
        
        hpdi(last_iterations_finished, max_iteration_estimation, number_not_finished, name)

        calvo_names.append(name)
        calvo_results.append(last_iterations_all)

    calvo(calvo_names, np.stack(calvo_results, axis=1))
    


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
    mean = np.mean(data)
    hdi = (data[int(len(data) * 0.025)], data[int(len(data) * 0.975)])
    print("HDPI Algo 2: ", hdi)


    with open("BayesianAnalysis/bayesianResults/Keijzer/hpdi.txt", "a") as file:
        file.write(f"{name_algo} & {hdi} & {mean} \\\\\n\\hline\n")



with open("BayesianAnalysis/bayesianResults/KozaUniform/hpdi.txt", "w") as file:
    file.write("")


with open("BayesianAnalysis/bayesianResults/KozaUniform/calvo.txt", "w") as file:
    file.write("")


calvo_and_hpdi_for_all()