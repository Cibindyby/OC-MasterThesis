# !/usr/bin/env python

"""

"""
import numpy as np
import pandas as pd
from cmpbayes import Calvo, NonNegative

#  ++++++++++++++++++++++++++++++++++++++
# RANKING
#  ++++++++++++++++++++++++++++++++++++++
# Berechne Ranking zwischen n vielen algorithmen; in diesem Beispiel sind es 4 Algorithmen á 100 samples
algorithm_labels = ["a", "b", "c", "d"]
rnd_arr = np.random.normal(100, 40, (100, len(algorithm_labels)))

model = Calvo(rnd_arr,
              higher_better=False,
              algorithm_labels=algorithm_labels).fit(random_seed=0 + 1)
sample = np.concatenate(model.infdata_.posterior.weights)
sample = pd.DataFrame(sample, columns=model.infdata_.posterior.weights.algorithm_labels)
sample = sample.mean()
print(sample)



#  ++++++++++++++++++++++++++++++++++++++
# HPDI (& Ranking)
#  ++++++++++++++++++++++++++++++++++++++
# Berechne das HPDI für jeweils 2 algorithmen
x1 = np.random.normal(100, 10, 100)
x2 = np.random.normal(60, 10, 100)
# Nonnegative kann auch mit "zensierten" Werten umgehen. D.h. falls bspw. bei x1 insgesamt 4 Runs nicht fertig geworden sind,
# gibt man bei n_censored1=4 ein. Dadurch können die auch mit einberechnet werden in die Statistik; und man nimmt an, dass
# die Fehlenden Werte ungefähr den Wert mean_upper haben.
model = NonNegative(x1,
                    x2,
                    # mean_upper=100,
                    # # max-wert, den die Werte einnehmen können. Nur wichtig, wenn "zensierte" werte da sind
                    # n_censored1=0,
                    # n_censored2=0,
                    # censoring_point=0,
                    ).fit(num_samples=5000, random_seed=2)
data = np.concatenate(model.infdata_.posterior.mean1)
data = np.sort(data)
hdi = (data[int(len(data) * 0.025)], data[int(len(data) * 0.975)])
print("HDPI Algo 1: ", hdi)
data = np.concatenate(model.infdata_.posterior.mean2)
data = np.sort(data)
hdi = (data[int(len(data) * 0.025)], data[int(len(data) * 0.975)])
print("HDPI Algo 2: ", hdi)


post = np.sort((model.infdata_.posterior.mean2.to_numpy() / model.infdata_.posterior.mean1.to_numpy()).ravel())

# prozentualer HPDI
lower = post[int(len(post) * 0.025)]
upper = post[int(len(post) * 0.975)]
hpdi_relative = (lower, upper)

# ROPE = Region of practical equivalence:
# Gibt ein Interval an, in dem die Werte "praktisch äquivalent" sind.
# Bspw: Algo 1 hat Werte [20, 21, 22, 19]
# Algo 2 hat Werte [18, 19, 19, 20]
# Und die Rope ist [15, 25]. Anschließend erstellt man die stat. Modelle für Algo1 und Algo2, basierend auf deren Werten.
# Die Rope sagt nun aus: Sind nun Werte von Algo 1 innerhalb der ROPE, dann sind alle Werte darin praktisch äquivalent.
# Genau das selbe gilt auch für Algo 2: Alle Werte sind in diesem Fall äquivalent.
# I.d.R. ist die ROPE abhängig vom Mittelwert eines Algorithmus / der Baseline.
rope = [-10, 10]

props = {
    'p(algo1)': (data < rope[0]).sum() / len(data),
    'p(equal)': np.logical_and(rope[0] < data, data < rope[1]).sum() / len(data),
    'p(algo2)': (data > rope[1]).sum() / len(data)
}
print(props)