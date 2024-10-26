set AV; 
set PT;
set ST;

param Coste{AV};
param HL{AV};
param HS{ST};
param HA{AV};
param RT{AV, ST};
param CONSE {ST, PT}; 
param M := 10000; 

var aterrizaje_correcto_o_no{AV, ST, PT} binary;

minimize coste_total_retrasos: 
    sum{j in ST, i in AV} RT[i,j] * Coste[i] * (sum {k in PT} aterrizaje_correcto_o_no[i,j,k]);

s.t. avion_aterrizado{i in AV}: 
    sum{j in ST, k in PT} aterrizaje_correcto_o_no[i,j,k] = 1;

s.t. capacidad_maxima_slot {j in ST, k in PT}: 
    sum{i in AV} aterrizaje_correcto_o_no[i,j,k] <= 1;

solve;
display aterrizaje_correcto_o_no;
display coste_total_retrasos;