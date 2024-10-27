/* Declaración de sets de AV y TR */ 
set AV;   /* Conjunto de AV */ 
set ST;   /* Conjunto de slots de tiempo */
set PT;   /* Conjunto de pistas de aterrizaje */
set TR; /* Conjunto de TR */

/* Variables de decisión */
var billetes{AV, TR} >= 0, integer;      /* La variable de decisión es el número de billetes de cada tarifa que se venden en cada avión */
var aterriza_si_o_no{AV, ST, PT} binary; /* Variable binaria que indica si un avión i aterriza en un slot j en una pista k */


/* Parámetros */
param numero_asientos{AV}; /* Número de asientos de cada avión */
param capacidad{AV};       /* Capacidad de peso de cada avión */

param min_billetes_2;           /* Número mínimo de billetes de tarifa 2 */
param min_billetes_3;           /* Número mínimo de billetes de tarifa 3 */

param precios{TR};         /* Precio de cada tarifa */
param peso{TR};            /* Peso de cada tarifa */

param porcentaje;               /* Porcentaje de billetes mínimos de la tarifa 1 que se debe vender */

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

/* Función objetivo */
maximize ingresos: 
    (sum {i in AV, j in TR} precios[j] * billetes[i,j]) - (sum{i in AV, j in ST, k in PT} (HI[j] - HA[i]) * Coste[i]* aterriza_si_o_no[i,j,k]);

/* Restricciones */
/* Todas las restricciones se encuentran desarrolladas y explicadas en la memoria de la práctica */

s.t. restriccion_sitios_max {i in AV}: 
    sum {j in TR} billetes[i,j] <= numero_asientos[i];
    /* El número de billetes de cada avión no puede superar el número de asientos de cada avión */

s.t. restriccion_capacidad_max {i in AV}:
    sum {j in TR} peso[j] * billetes[i,j] <= capacidad[i];
    /* El peso del equipaje de cada billete vendido en cada avión no puede superar la capacidad de peso de cada avión */

s.t. restriccion_min_billetes_2 {i in AV}: 
    billetes[i,"T2"] >= min_billetes_2;
    /* El número de billetes de tarifa 2 vendidos en cada avión no puede ser inferior al número mínimo de billetes de tarifa 2 */

s.t. restriccion_min_billetes_3 {i in AV}:
    billetes[i,"T3"] >= min_billetes_3;
    /* El número de billetes de tarifa 3 vendidos en cada avión no puede ser inferior al número mínimo de billetes de tarifa 3 */

s.t. restriccion_min_oferta_60: 
    sum {i in AV} billetes[i,"T1"] >= porcentaje * (sum {i in AV} (billetes[i,"T1"] + billetes[i,"T2"] + billetes[i,"T3"]));
    /* El número de billetes de tarifa 1 vendidos en todos los AV debe ser al menos el porcentaje de la suma de todos los billetes vendidos */

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
display ingresos;
end; 