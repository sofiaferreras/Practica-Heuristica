set AV;  
set ST;
set PT;

param Coste{AV};
param HL{AV};
param HS{ST};
param HA{AV};
param sig_slot{ST} symbolic; 
param ant_slot{ST} symbolic;

set aterrizar_PT1;
set aterrizar_PT2;
set aterrizar_PT3;
set aterrizar_PT4;

param M := 10000; 

var aterriza_si_o_no{AV, ST, PT} binary;
set validos := { j in ST: j < card(ST)};

minimize perdidas: 
    sum{i in AV, j in ST, k in PT} Coste[i] * (HS[j] - HA[i]) * aterriza_si_o_no[i,j,k];

set validos_para_pistas{k in PT} :=
    if k == "PT1" then aterrizar_PT1
    else if k == "PT2" then aterrizar_PT2
    else if k == "PT3" then aterrizar_PT3
    else aterrizar_PT4;

s.t. avion_aterrizado{i in AV}: 
    sum{j in ST, k in PT} aterriza_si_o_no[i,j,k] = 1;

s.t. capacidad_maxima_slot {j in ST, k in PT}: 
    sum{i in AV} aterriza_si_o_no[i,j,k] <= 1;

s.t. consecutivos_arriba{i in AV, j in ST, k in PT}:
    HS[j] >= HA[i] - M * (1 - aterriza_si_o_no[i,j,k]);

s.t. consecutivos_abajo{i in AV, j in ST, k in PT}:
    HS[j] <= HL[i] + M * (1 - aterriza_si_o_no[i,j,k]);

s.t. no_consecutivos{i in AV, j in ST, k in PT: sig_slot[j] != j and ant_slot[j] != j}:
    aterriza_si_o_no[i,j,k] + sum{m in AV : m!= i} (aterriza_si_o_no[m, sig_slot[j], k] + aterriza_si_o_no[m, ant_slot[j], k]) <= 1;

s.t. asignacion_correcta{i in AV, j in ST, k in PT}:
    aterriza_si_o_no[i,j,k] <= (if j in validos_para_pistas[k] then 1 else 0);

solve;
display perdidas;