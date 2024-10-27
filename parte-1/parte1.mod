/* PARTE 1: MODELO DE PROGRAMACIÓN LINEAL */

/* El problema trata de asignar billetes de avión a diferentes 
tarifas para maximizar el beneficio de una compañía aérea. */

/* Declaración de sets de aviones y tarifas */ 
/* Tenemos 5 aviones y 3 tarifas */
set AVIONES; 
set TARIFAS;

/* Parámetros */
param numero_asientos{AVIONES}; /* Número de asientos de cada avión */
param capacidad{AVIONES};       /* Capacidad de peso de cada avión */

param min_billetes_2;           /* Número mínimo de billetes de tarifa 2 */
param min_billetes_3;           /* Número mínimo de billetes de tarifa 3 */

param precios{TARIFAS};         /* Precio de cada tarifa */
param peso{TARIFAS};            /* Peso de cada tarifa */

param porcentaje;               /* Porcentaje de billetes mínimos de la tarifa 1 que se debe vender */

/* Variables de decisión */
/* La variable de decisión es el número de billetes de cada tarifa que se venden en cada avión */
var billetes{AVIONES, TARIFAS} >= 0, integer; 

/* Función objetivo */
maximize beneficio: 
    sum {i in AVIONES, j in TARIFAS} precios[j] * billetes[i,j];

/* Restricciones */
/* Todas las restricciones se encuentran desarroladas y explicadas en la memoria de la práctica */

s.t. restriccion_sitios_max {i in AVIONES}: 
    sum {j in TARIFAS} billetes[i,j] <= numero_asientos[i];
    /* El número de billetes de cada avión no puede superar el número de asientos de cada avión */

s.t. restriccion_capacidad_max {i in AVIONES}:
    sum {j in TARIFAS} peso[j] * billetes[i,j] <= capacidad[i];
    /* El peso del equipaje de cada billete vendido en cada avión no puede superar la capacidad de peso de cada avión */

s.t. restriccion_min_billetes_2 {i in AVIONES}: 
    billetes[i,"T2"] >= min_billetes_2;
    /* El número de billetes de tarifa 2 vendidos en cada avión no puede ser inferior al número mínimo de billetes de tarifa 2 */

s.t. restriccion_min_billetes_3 {i in AVIONES}:
    billetes[i,"T3"] >= min_billetes_3;
    /* El número de billetes de tarifa 3 vendidos en cada avión no puede ser inferior al número mínimo de billetes de tarifa 3 */

s.t. restriccion_min_oferta_60: 
    sum {i in AVIONES} billetes[i,"T1"] >= porcentaje * (sum {i in AVIONES} (billetes[i,"T1"] + billetes[i,"T2"] + billetes[i,"T3"]));
    /* El número de billetes de tarifa 1 vendidos en todos los aviones debe ser al menos el porcentaje de la suma de todos los billetes vendidos */

solve;

display beneficio;
