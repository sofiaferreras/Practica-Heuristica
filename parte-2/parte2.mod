/*PARTE 2: MODELO DE PROGRAMACIÓN ENTERA*/
/* El problema trata de asignar aviones a pistas de aterrizaje para minimizar las pérdidas por minuto de restraso de una compañía aérea. */

set AV;   /* Conjunto de aviones */ 
set ST;   /* Conjunto de slots de tiempo */
set PT;   /* Conjunto de pistas de aterrizaje */

param Coste{AV};    /* Coste de retraso por minuto de cada avión */
param HL{AV};       /* Hora limite de aterrizaje de cada avión */
param HI{ST};       /* Hora de inicio de cada slot */
param HA{AV};       /* Hora de llegada a la pista de aterrizaje de cada avión */
param sig_slot{ST} symbolic;  /* Slot siguiente, explicado en el .dat */
param ant_slot{ST} symbolic;  /* Slot anterior, explicado en el .dat*/

set aterrizar_PT1;  /* Conjunto de slots no ocupados por un avion, para aterrizar en la pista PT1 */
set aterrizar_PT2;  /* Conjunto de slots no ocupados por un avion, para aterrizar en la pista PT2 */
set aterrizar_PT3;  /* Conjunto de slots no ocupados por un avion, para aterrizar en la pista PT3 */
set aterrizar_PT4;  /* Conjunto de slots no ocupados por un avion, para aterrizar en la pista PT4 */

/* Definimos los slots validos para aterrizar en cada pista */
/* Duamante el proceso de resolución, se asignarán los slots no ocupados correctamente a cada pista */
set validos_para_pistas{k in PT} :=
    if k == "PT1" then aterrizar_PT1
    else if k == "PT2" then aterrizar_PT2
    else if k == "PT3" then aterrizar_PT3  
    else aterrizar_PT4; 

param M;  /* Numero de gran valor, explicado en el .dat*/

var aterriza_si_o_no{AV, ST, PT} binary; /* Variable binaria que indica si un avión i aterriza en un slot j en una pista k */

/* Función objetivo: tratar minimizar las pérdidas que pueden suceder por los retrasos*/
minimize perdidas: 
    sum{i in AV, j in ST, k in PT} (HI[j] - HA[i]) * Coste[i]* aterriza_si_o_no[i,j,k];
    /* La función objetivo se basa en la suma de los retrasos por el coste incurrido cada minuto de retraso de cada avión i en cada slot j en cada pista k */

s.t. tiene_slot{i in AV}: 
    sum{j in ST, k in PT} aterriza_si_o_no[i,j,k] = 1;
    /* Cada avión i debe tener asignado un slot j en una pista k */

s.t. slot_disponible_para_aterrizar{i in AV, j in ST, k in PT}:
    aterriza_si_o_no[i,j,k] <= (if j in validos_para_pistas[k] then 1 else 0);
    /* Un avión i solo puede aterrizar en un slot j si este slot j es válido para la pista k */

s.t. consecutivos_arriba{i in AV, j in ST, k in PT}:
    HI[j] >= HA[i] - M * (1 - aterriza_si_o_no[i,j,k]);
    /* Si un avión i aterriza en un slot j en una pista k, entonces la hora de inicio de este slot j debe ser mayor o igual a la hora de llegada del avión i */

s.t. consecutivos_abajo{i in AV, j in ST, k in PT}:
    HI[j] <= HL[i] + M * (1 - aterriza_si_o_no[i,j,k]);
    /* Si un avión i aterriza en un slot j en una pista k, entonces la hora de inicio de este slot j debe ser menor o igual a la hora límite de aterrizaje del avión i */

s.t. no_slots_consecutivos{i in AV, j in ST, k in PT: sig_slot[j] != j and ant_slot[j] != j}:
    aterriza_si_o_no[i,j,k] + sum{m in AV : m!= i} (aterriza_si_o_no[m, sig_slot[j], k] + aterriza_si_o_no[m, ant_slot[j], k]) <= 1;
    /* Si un avión i aterriza en un slot j en una pista k, entonces no puede aterrizar en los slots anteriores ni en los slots siguientes */

solve;
display perdidas;

end;