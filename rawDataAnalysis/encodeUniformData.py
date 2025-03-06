import pandas as pd
import openpyxl
import numpy as np
import statistics

import matplotlib.pyplot as plt

fitness_finished_when = 0.000001

def get_row_of_table(nameOfTable, nameOfSheet, nameConfig):
    df = pd.read_excel(f'Endergebnisse/Encode/{nameOfTable}.xlsx', nameOfSheet)
    runs = df['Source.Name'].nunique()

    # Zähler initialisieren
    mutation_better = 0 #Mutationschritt hat Erfolg gebracht
    crossover_better = 0 #Rekombinationsschritt hat Erfolg gebracht
    better_if_no_mutation_happend = 0 #Mutation hat Erfolg von Rekombination kaputt gemacht
    crossover_finished_learning_potential = 0 #Wie oft hätte Crossover beenden können (falls Mutation nichts schlechter gemacht hätte)
    mutation_finished_learning = 0 #Wie oft hat Mutation Lernen beendet?
    iterations_of_successful_crossover = [] # In welchen Iterationen war Rekombination erfolgreich?
    iterations_until_training_ends_potential = [] # In welchen Iterationen hätte Training beendet werden können?
    anzahl_konvergent = 0 #Wie viele sind fertig geworden?

    # Gruppieren nach 'Source.Name'
    grouped = df.groupby('Source.Name')

    for name, group in grouped:
        # Vorherige Fitness nach Mutation initialisieren
        prev_mutation_fitness = None
        
        for index, row in group.iterrows():
            # Vergleich Mutation vs. Rekombination in der gleichen Zeile
            if row[' Fitness nach Mutation'] < row[' Fitness nach Rekombination']:
                mutation_better += 1

            if row[' Fitness nach Mutation'] > row[' Fitness nach Rekombination']:
                better_if_no_mutation_happend += 1

            if row[' Fitness nach Mutation'] < fitness_finished_when:
                anzahl_konvergent += 1

            if row[' Fitness nach Rekombination'] < fitness_finished_when:
                crossover_finished_learning_potential += 1
                iterations_until_training_ends_potential.append(row['Iteration'])

            if (row[' Fitness nach Mutation'] < fitness_finished_when) & (row[' Fitness nach Rekombination'] >= fitness_finished_when):
                mutation_finished_learning += 1
                iterations_until_training_ends_potential.append(row['Iteration'])
            
            # Vergleich Rekombination mit vorheriger Mutation
            if prev_mutation_fitness is not None:
                if row[' Fitness nach Rekombination'] < prev_mutation_fitness:
                    crossover_better += 1
                    iterations_of_successful_crossover.append(row['Iteration'])
            
            # Aktualisieren der vorherigen Mutation Fitness für die nächste Iteration
            prev_mutation_fitness = row[' Fitness nach Mutation']


    meanCounterMutationBetter = mutation_better / runs

    meanCounterCrossoverBetter = crossover_better / runs
    if len(iterations_of_successful_crossover) != 0:
        median_iterations_crossover_better = statistics.median(iterations_of_successful_crossover)
    else:
        median_iterations_crossover_better = "-"

    median_final_iterations = statistics.median(iterations_until_training_ends_potential)

    print("\t\t\\hline")
    print(f"\t\t{nameConfig} & {mutation_better} & {crossover_better} & {better_if_no_mutation_happend} & {median_iterations_crossover_better} & {median_final_iterations} & {anzahl_konvergent}\\\\")

    # Ergebnis ausgeben
    #print(f"\nIn insgesamt {mutation_better} Fällen lieferte der Mutationsschritt ein besseres Ergebnis.")
    #print(f"Mean = {meanCounterMutationBetter}")
    #print(f"In insgesamt {crossover_better} Fällen lieferte der Rekombinationsschritt ein besseres Ergebnis.")
    #print(f"Mean = {meanCounterCrossoverBetter}")
    #print(f"In insgesamt {better_if_no_mutation_happend} Fällen wäre es besser gewesen nach der Rekombination keine Mutation mehr auszuführen (das betrifft nicht nur den letzten Lernschritt!).")
    #print(f"In insgesamt {mutation_finished_learning} Fällen hat Mutation das Training beendet.")
    #print(f"In insgesamt {crossover_finished_learning_potential} Fällen hätte Rekombination das Training beenden können.")
    #print(f"In folgenden Iterationen war Rekombination erfolgreich: {iterations_of_successful_crossover} -> Median ist: {median_iterations_recombination_better}")
    #print(f"Die Durchläufe, die fertig wurden haben so viele Iterationen gebraucht (mit theoretischen Beendigungen von Rekombination): {iterations_until_training_ends_potential} -> Median ist: {median_final_iterations}")

print("\\begin{table}[H]\n\t\\centering\n\t\\begin{tabular}{c | c | c | c | c | c | c}\n\t\t\\begin{turn}{270} \\textbf{CGP-Konfigurationen} \\end{turn} & \\begin{turn}{270} \\textbf{Anzahl pos. Mutationen} \\end{turn} & \\begin{turn}{270} \\textbf{Anzahl pos. Rekomb.} \\end{turn} & \\begin{turn}{270} \\textbf{Anzahl neg. Mutationen} \\end{turn} & \\begin{turn}{270} \\textbf{Median Iter. pos. Rekomb.} \\end{turn} & \\begin{turn}{270} \\textbf{Median Iter. bis Konv.} \\end{turn} & \\begin{turn}{270} \\textbf{Stopp-Kriterium erfüllt} \\end{turn}\\\\")


list_of_tables = [
    'EncodeUniformKonstant',
    'EncodeUniformClegg',
    'EncodeUniformOneFifth'
]

list_of_sheets = [
    ['EncodeUniformKonstant125', 'EncodeUniformKonstant25', 'EncodeUniformKonstant375', 'EncodeUniformKonstant5', 'EncodeUniformKonstant625', 'EncodeUniformKonstant75', 'EncodeUniformKonstant875', 'EncodeUniformKonstant1'],
    ['EncodeUniformClegg05', 'EncodeUniformClegg15', 'EncodeUniformClegg25', 'EncodeUniformClegg35', 'EncodeUniformClegg45', 'EncodeUniformClegg55'],
    ['EncodeUniformOneFifth125', 'EncodeUniformOneFifth25', 'EncodeUniformOneFifth375', 'EncodeUniformOneFifth5', 'EncodeUniformOneFifth625', 'EncodeUniformOneFifth75', 'EncodeUniformOneFifth875', 'EncodeUniformOneFifth1']
]

list_of_names = [
    ['Uniform Konstant: 0,125', 'Uniform Konstant: 0,25', 'Uniform Konstant: 0,375', 'Uniform Konstant: 0,5', 'Uniform Konstant: 0,625', 'Uniform Konstant: 0,75', 'Uniform Konstant: 0,875', 'Uniform Konstant: 1,0'],
    ['Uniform Clegg: 0,0005', 'Uniform Clegg: 0,0015', 'Uniform Clegg: 0,0025', 'Uniform Clegg: 0,0035', 'Uniform Clegg: 0,0045', 'Uniform Clegg: 0,0055'],
    ['Uniform One-Fifth: 0,125', 'Uniform One-Fifth: 0,25', 'Uniform One-Fifth: 0,375', 'Uniform One-Fifth: 0,5', 'Uniform One-Fifth: 0,625', 'Uniform One-Fifth: 0,75', 'Uniform One-Fifth: 0,875', 'Uniform One-Fifth: 1,0']
]


for table_index in range(0, 3, 1):
    if table_index == 1: #Clegg
        for sheet_index in range(0, 6, 1): 
            get_row_of_table(list_of_tables[table_index], list_of_sheets[table_index][sheet_index], list_of_names[table_index][sheet_index])

    else:
        for sheet_index in range(0, 8, 1): 
            get_row_of_table(list_of_tables[table_index], list_of_sheets[table_index][sheet_index], list_of_names[table_index][sheet_index])


print("\t\\end{tabular}\n\t\\caption{Encode Uniform Rekombination: Auswertung der Rohdaten}\n\t\\label{table:encodeUniformRohdaten}\n\\end{table}")