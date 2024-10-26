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

var beneficio{AV, ST, PT} binary;

minimize coste_total: sum{j in ST, i in AV} RT[i,j] * Coste[i] * (sum {k in PT} beneficio[i,j,k]);


solve;
display beneficio;
display coste_total;