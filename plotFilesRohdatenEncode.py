import matplotlib.pyplot as plt

x_konstant = [0.125, 0.25, 0.375, 0.5, 0.625, 0.75, 0.875, 1.0]
y_konstant_one_point = [20, 42, 43, 34, 45, 55, 59, 58]
y_konstant_two_point = [27, 35, 45, 50, 61, 61, 73, 65]
y_konstant_uniform = [52, 69, 64, 68, 78, 81, 83, 67]

fig, ax = plt.subplots(figsize=(10, 10))  # Größeres Format

# Linienplots mit verbesserten Parametern
ax.plot(
    x_konstant,
    y_konstant_one_point,
    linestyle='-',
    color='b',
    marker='o',  # Korrekte Parameter-Schreibweise
    markersize=8,
    markerfacecolor='white',
    markeredgewidth=1.5,
    label='One-Point Rekombination'
)

ax.plot(
    x_konstant,
    y_konstant_two_point,
    linestyle='-',
    color='g',
    marker='s',  # Unterschiedlicher Marker
    markersize=8,
    markerfacecolor='white',
    markeredgewidth=1.5,
    label='Two-Point Rekombination'
)

ax.plot(
    x_konstant,
    y_konstant_uniform,
    linestyle='-',
    color='r',
    marker='D',  # Unterschiedlicher Marker
    markersize=8,
    markerfacecolor='white',
    markeredgewidth=1.5,
    label='Uniform Rekombination'
)

# Beschriftungen und Formatierung
ax.set_title("Konstante Rekomb.-Rate: Pos. Rekomb.", 
            loc='left', pad=20, fontsize=25, fontweight='bold')
ax.set_xlabel("Start-Rekombinationsrate", labelpad=15, fontsize=25)
ax.set_ylabel("Anzahl positiver Rekombinationen", labelpad=15, fontsize=25)

# Grid und Legende
ax.grid(True, alpha=0.3, linestyle='--')
ax.legend(frameon=True, shadow=True, loc='upper left', fontsize=25)

# Achsenlimits für bessere Darstellung
ax.set_ylim(0, 110)
ax.set_xlim(0.05, 1.05)
ax.tick_params(axis="both", labelsize=20)

# Speichern mit höherer Qualität
plt.tight_layout()
plt.savefig(
    "EncodePlotPositiveRekombinationKonstant.png",
    dpi=300,
    bbox_inches='tight'
)
plt.close()

x_clegg = [0.0005, 0.0015, 0.0025, 0.0035, 0.0045, 0.0055]
y_clegg_one_point = [48, 51, 39, 34, 38, 55]
y_clegg_two_point = [70, 53, 75, 64, 51, 52]
y_clegg_uniform = [76, 78, 74, 56, 70, 68]

fig, ax = plt.subplots(figsize=(10, 10))  # Größeres Format

# Linienplots mit verbesserten Parametern
ax.plot(
    x_clegg,
    y_clegg_one_point,
    linestyle='-',
    color='b',
    marker='o',  # Korrekte Parameter-Schreibweise
    markersize=8,
    markerfacecolor='white',
    markeredgewidth=1.5,
    label='One-Point Rekombination'
)

ax.plot(
    x_clegg,
    y_clegg_two_point,
    linestyle='-',
    color='g',
    marker='s',  # Unterschiedlicher Marker
    markersize=8,
    markerfacecolor='white',
    markeredgewidth=1.5,
    label='Two-Point Rekombination'
)

ax.plot(
    x_clegg,
    y_clegg_uniform,
    linestyle='-',
    color='r',
    marker='D',  # Unterschiedlicher Marker
    markersize=8,
    markerfacecolor='white',
    markeredgewidth=1.5,
    label='Uniform Rekombination'
)

# Beschriftungen und Formatierung
ax.set_title("linear fallende Rekomb.-Rate: Pos. Rekomb.", 
            loc='left', pad=20, fontsize=25, fontweight='bold')
ax.set_xlabel("Delta-Rekombinationsrate", labelpad=15, fontsize=25)
ax.set_ylabel("Anzahl positiver Rekombinationen", labelpad=15, fontsize=25)

# Grid und Legende
ax.grid(True, alpha=0.3, linestyle='--')
ax.legend(frameon=True, shadow=True, loc='upper left', fontsize=25)

# Achsenlimits für bessere Darstellung
ax.set_ylim(0, 110)
ax.set_xlim(0, 0.006)
ax.tick_params(axis="both", labelsize=20)

# Speichern mit höherer Qualität
plt.tight_layout()
plt.savefig(
    "EncodePlotPositiveRekombinationClegg.png",
    dpi=300,
    bbox_inches='tight'
)
plt.close()

x_one_fifth = [0.125, 0.25, 0.375, 0.5, 0.625, 0.75, 0.875, 1.0]
y_one_fifth_one_point = [19, 22, 20, 26, 35, 25, 32, 42]
y_one_fifth_two_point = [10, 16, 17, 24, 32, 34, 36, 43]
y_one_fifth_uniform = [18, 25, 29, 44, 40, 47, 51, 55]

fig, ax = plt.subplots(figsize=(10, 10))  # Größeres Format

# Linienplots mit verbesserten Parametern
ax.plot(
    x_one_fifth,
    y_one_fifth_one_point,
    linestyle='-',
    color='b',
    marker='o',  # Korrekte Parameter-Schreibweise
    markersize=8,
    markerfacecolor='white',
    markeredgewidth=1.5,
    label='One-Point Rekombination'
)

ax.plot(
    x_one_fifth,
    y_one_fifth_two_point,
    linestyle='-',
    color='g',
    marker='s',  # Unterschiedlicher Marker
    markersize=8,
    markerfacecolor='white',
    markeredgewidth=1.5,
    label='Two-Point Rekombination'
)

ax.plot(
    x_one_fifth,
    y_one_fifth_uniform,
    linestyle='-',
    color='r',
    marker='D',  # Unterschiedlicher Marker
    markersize=8,
    markerfacecolor='white',
    markeredgewidth=1.5,
    label='Uniform Rekombination'
)

# Beschriftungen und Formatierung
ax.set_title("One-Fifth Rekomb.-Rate: Pos Rekomb.", 
            loc='left', pad=20, fontsize=25, fontweight='bold')
ax.set_xlabel("Start-Rekombinationsrate", labelpad=15, fontsize=25)
ax.set_ylabel("Anzahl positiver Rekombinationen", labelpad=15, fontsize=25)
ax.tick_params(axis="both", labelsize=20)

# Grid und Legende
ax.grid(True, alpha=0.3, linestyle='--')
ax.legend(frameon=True, shadow=True, loc='upper left', fontsize=25)

# Achsenlimits für bessere Darstellung
ax.set_ylim(0, 110)
ax.set_xlim(0.05, 1.05)

# Speichern mit höherer Qualität
plt.tight_layout()
plt.savefig(
    "EncodePlotPositiveRekombinationOneFifth.png",
    dpi=300,
    bbox_inches='tight'
)
plt.close()