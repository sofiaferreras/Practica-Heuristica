#Parametros
param numero_asientos{i in 1..5} := [1 90, 2 120, 3 200, 4 150, 5 190];
param capacidad{i in 1..5} := [1 1700, 2 2700, 3 1300, 4 1700, 5 2000];
param min_billetes_2:= 20;
param min_billetes_3:= 10;

# Variables de decisión
var x{i in 1..5, j in 1..3} >= 0;

# Función objetivo
maximize z: sum {i in 1..5} (19 * x[i,1] + 49 * x[i,2] + 69 * x[i,3]);

# Restricciones
s.t. restriccion1{i in 1..5}: 
    x[i,1] + x[i,2] + x[i,3] <= numero_asientos[i];

s.t. restriccion2{i in 1..5}:
    (x[i,1] + 20*x[i,2] + 40*x[i,3]) <= capacidad[i];

s.t. restriccion3{i in 1..5}: 
    x[i, 2] >= min_billetes_2;

s.t. restriccion4{i in 1..5}:
    x[i,3] >= min_billetes_3;

s.t. restriccion4: 
    sum {i in 1..5} x[i,1] - 0.6 * sum {i in 1..5} (x[i,1] + x[i,2] + x[i,3]) >= 0;

