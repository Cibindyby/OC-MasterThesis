# Funktion zum Laden des Keijzer-6-Datensatzes

#todo fix
#todo Braucht man Aufteilung von Daten?
function load_dataset()
    x = collect(range(-1.0,1.0,20))  # Beispielwerte für Keijzer-6 
    y = [sum(1/i for i in 1:x_val for x_val in x)]  # Keijzer-6 Formel
    return x, y
end

print(load_keijzer6_dataset())