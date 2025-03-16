import matplotlib.pyplot as plt

x_konstant = [0.125, 0.25, 0.375, 0.5, 0.625, 0.75, 0.875, 1.0]
y_konstant_one_point = [9, 23, 42, 57, 48, 65, 85, 136]
y_konstant_two_point = [41, 82, 91, 85, 93, 145, 140, 220]
y_konstant_uniform = [124, 157, 251, 184, 295, 276, 332, 328]

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
ax.set_ylim(0, 500)
ax.set_xlim(0.05, 1.05)
ax.tick_params(axis="both", labelsize=20)

# Speichern mit höherer Qualität
plt.tight_layout()
plt.savefig(
    "KozaPlotPositiveRekombinationKonstant.png",
    dpi=300,
    bbox_inches='tight'
)
plt.close()

x_clegg = [0.0005, 0.0015, 0.0025, 0.0035, 0.0045, 0.0055]
y_clegg_one_point = [98, 78, 52, 61, 62, 50]
y_clegg_two_point = [193, 105, 106, 95, 100, 94]
y_clegg_uniform = [373, 259, 319, 318, 304, 300]

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
ax.set_ylim(0, 500)
ax.set_xlim(0, 0.006)
ax.tick_params(axis="both", labelsize=20)

# Speichern mit höherer Qualität
plt.tight_layout()
plt.savefig(
    "KozaPlotPositiveRekombinationClegg.png",
    dpi=300,
    bbox_inches='tight'
)
plt.close()

x_one_fifth = [0.125, 0.25, 0.375, 0.5, 0.625, 0.75, 0.875, 1.0]
y_one_fifth_one_point = [2, 7, 13, 14, 18, 17, 29, 38]
y_one_fifth_two_point = [5, 10, 15, 15, 22, 26, 42, 35]
y_one_fifth_uniform = [12, 24, 36, 61, 72, 90, 92, 83]

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
ax.set_ylim(0, 500)
ax.set_xlim(0.05, 1.05)

# Speichern mit höherer Qualität
plt.tight_layout()
plt.savefig(
    "KozaPlotPositiveRekombinationOneFifth.png",
    dpi=300,
    bbox_inches='tight'
)
plt.close()