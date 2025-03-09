import os

import matplotlib.pyplot as plt  # type: ignore
import numpy as np  # type: ignore
import scipy.stats as st  # type: ignore

from cmpbayes import NonNegative, Calvo

rope = 200

baseline_numpy_array = np.array([100, 400, 500, 600, 550])
vergleichsalgo = np.array([700, 800, 750, 850,770])

model = NonNegative(baseline_numpy_array,
                    vergleichsalgo,
                    mean_upper=1_000_000,
                    # var_lower=.1,
                    # var_upper=10,
                    n_censored1=0,
                    n_censored2=0,
                    censoring_point=0,
                    ).fit(
    num_samples=5000, random_seed=1)
data = np.concatenate(model.infdata_.posterior.mean1)
data = np.sort(data)
# high posterior density interval
hpdi = (data[int(len(data) * 0.025)], data[int(len(data) * 0.975)])  # in absoluten zahlen


post = np.sort((model.infdata_.posterior.mean2.to_numpy() / model.infdata_.posterior.mean1.to_numpy()).ravel())

lower = post[int(len(post) * 0.025)]
upper = post[int(len(post) * 0.975)]
hpdi_relative = (lower, upper)


rope = [-rope, rope]

props = {
    'p(algo)': (data < rope[0]).sum() / len(data),
    'p(equal)': np.logical_and(rope[0] < data, data < rope[1]).sum() / len(data),
    'p(baseline)': (data > rope[1]).sum() / len(data)
}


print(f"Hpdi in realtiven zahlen: {hpdi_relative}")
print(f"Hpdi in absoluten zahlen: {hpdi}")
print(f"probs: {props}")
"""
ErklÃ¤rung:
annahme: Die Werte zum Vergleichen sind anzahl an iterationen 
HPDI in relativen Zahlen: BSpw.:
(1.0935338654796798, 3.0876414339764513)
das bedeutet: Die Baseline wird mit dem vergleichsalgorithmus verglichen. Hier wird der Vergleichsalgorithmus, 
verglichen mit der Baseline, um den Faktor 1.09 bis 3.09 schlechter sein. D.h. es braucht, zu 95%iger 
wahrscheinlichkeit, bis zu das 3 fache an iterationen 

HPDI in absoluten zahlen:
Das selbe wie von relativen zahlen, bloÃŸ in absoluten zahlen ausgedrÃ¼ckt. Bspw:
(252.2609856054175, 706.4107141279644)
Vergleichsalgo wird 252 bis 706 iterationen mehr brauchen als die baseline

probs: wahrscheinlichkeiten, dass der vergleichsalgo oder die baseline besser sein wird, oder die wahrscheinlichkeit 
dass beide gleich gut sind.

"""

metrics = np.array([1,2,3], [4,5,6], [7,8, 9], [10, 11, 12])
algorithm_labels = ["Algo1", "Algo2", "Algo3", "Algo4"]

model = Calvo(metrics,
              higher_better=False,
              algorithm_labels=algorithm_labels).fit(random_seed=100 + 1)
sample = np.concatenate(model.infdata_.posterior.weights)
sample = pd.DataFrame(sample, columns=model.infdata_.posterior.weights.algorithm_labels)
sample = sample.mean()
print(sample)