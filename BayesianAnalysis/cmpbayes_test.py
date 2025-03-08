import matplotlib.pyplot as plt  # type: ignore
import numpy as np  # type: ignore
import scipy.stats as st  # type: ignore

from cmpbayes import NonNegative

# scale == 1 / beta.
size = 20
y1 = st.gamma.rvs(a=3, scale=1 / 10, size=size)
y2 = st.gamma.rvs(a=4, scale=1 / 10, size=size)

print(f"{y1}\n")
print(f"{y2}\n")
print("\n")

num_samples = 5000
seed = 1

n_censored1 = 2
n_censored2 = 5
censoring_point = 10

model = NonNegative(y1,
                    y2,
                    n_censored1=n_censored1,
                    n_censored2=n_censored2,
                    censoring_point=censoring_point).fit(
                        num_samples=num_samples, random_seed=seed)

model._analyse()

post = model.infdata_.posterior

diff = post.mean2.to_numpy() - post.mean1.to_numpy()

print(f"{diff}\n")

plt.hist(diff.ravel(),
            bins=100,
            density=True,
            label=(f"n_censored1={n_censored1}, "
                f"n_censored2={n_censored2}, "
                f"censoring_point={censoring_point}"))
plt.legend()
plt.show()
