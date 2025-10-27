#-----------------Graficas  con datos   Originales -----------------------------------------#
#-------------------------------------------------------------------------------------------#
## Despues de haber corrido todo el codigo paso por paso
## se podra desplegar cualquier grafica desde esta seccion 
## unicamente dando Run(Correr) al nombre de la grafica que se desea
## desplegar

## Los summary nos proporcionan una idea general del estado de los datos,
## cual de ellos es el mas elevado o mas bajo respectivamente

## Parametros basicos nos desplega una grafica con los parametros basicos
## Global, Directa, Difusa y Calculada

ParametrosBasicos

#CONSTANTE SOLAR
#  1367
#
Gdisp

Gporcentaje

BalanceDeOndaCorta

BalanceDeOndaLarga

TemperaturaOndaLarga

TermopilaOndaLarga

Metereologia1

Metereologia2

GraficaUVB

UVB_SIG

GraficaZenDeg


summary(DataFrame$GLOBAL_Avg)

# summary(DataFrame$GLOBAL_Max)
#summary(DataFrame$GLOBAL_Min)

summary(DataFrame$DIRECT_Avg)

#summary(DataFrame$DIRECT_Max)
#summary(DataFrame$DIRECT_Min)

summary(DataFrame$DIFFUSE_Avg)

#summary(DataFrame$DIFFUSE_Min)
#summary(DataFrame$DIFFUSE_Max)

summary(DataFrame$GH_CALC_Avg)

## Gdisp hace referencia a la grafica de dispersion
## La grafica de dispersion es global contra calculada

Gdisp

summary(DataFrame$GLOBAL_Avg)
summary(DataFrame$GH_CALC_Avg)
summary(DataFrame$DIRECT_Avg)
summary(DataFrame$DIFFUSE_Avg)

## Gdiferencia hace referencia a la grafica de diferencia
## La grafica de diferencia se compone de los datos de la formula (global-calculada) y Timestamp

Gdiferencia 

summary(DataFrame$GLOBAL_Avg)
summary(DataFrame$GH_CALC_Avg)
summary(DataFrame$DIRECT_Avg)
summary(DataFrame$DIFFUSE_Avg)

## Gporcentaje hace referencia a la grafica de porcentaje
## La grafica de porcentaje se compone de los datos de la formula ((calculada-global)/global) y Timestamp

Gporcentaje

summary(DataFrame$GLOBAL_Avg)
summary(DataFrame$GH_CALC_Avg)
summary(DataFrame$DIRECT_Avg)
summary(DataFrame$DIFFUSE_Avg)

## Gcociente hace referencia a la grafica de cociente 
## La grafica de cociente se compone de los datos de la formula (global/calculada) y Timestamp

Gcociente

summary(DataFrame$GLOBAL_Avg)
summary(DataFrame$GH_CALC_Avg)
summary(DataFrame$DIRECT_Avg)
summary(DataFrame$DIFFUSE_Avg)

## La grafica de onda corta se compone por los datos GLOBAL,UPWARD_SW

BalanceDeOndaCorta

summary(DataFrame$GLOBAL_Avg)
#summary(DataFrame$GLOBAL_Max)
#summary(DataFrame$GLOBAL_Min)

summary(DataFrame$UPWARD_SW_Avg)
#summary(DataFrame$UPWARD_SW_Min)
#summary(DataFrame$UPWARD_SW_Max)

## La grafica de onda Larga se compone por los datos AIR TEMPERATURE,DOWNWARD y UPWARD_LW

BalanceDeOndaLarga

summary(DataFrame$DOWNWARD_Avg)
#summary(DataFrame$DOWNWARD_Max)
#summary(DataFrame$DOWNWARD_Min)

summary(DataFrame$UPWARD_LW_Avg)

#summary(DataFrame$UPWARD_LW_Max)
#summary(DataFrame$UPWARD_SW_Min)
## Grafica de temperatura de onda larga

TemperaturaOndaLarga

TermopilaOndaLarga

## Metreologia1 hace referencia a la grafica con los datos de AIR TEMPERATURE Y RELATIVE HUMIDITY

Metereologia1

summary(DataFrame$RELATIVE_HUMIDITY_Avg)
summary(DataFrame$AIR_TEMPERATURE_Avg)
summary(DataFrame$PRESSURE_Avg)

## Meteorologia2 hace refrencia a la grafica con los datos de PRESSURE Y RELATIVE HUMIDITY

Metereologia2

summary(DataFrame$RELATIVE_HUMIDITY_Avg)
summary(DataFrame$AIR_TEMPERATURE_Avg)
summary(DataFrame$PRESSURE_Avg)

## GRAFICAUVB hace referencia a la grafica de luz ultravioleta uvb que es muy peligrosa para todo 
## tipo de vida 

GraficaUVB

UVB_SIG



summary(DataFrame$UVBw_Avg)
#summary(DataFrame$UVBw_Min)
#summary(DataFrame$UVBw_Max)
#-------------------------------------------------------------------------------------------#


#-----------------Graficas  con datos   NULL -----------------------------------------#

#-------------------------------------------------------------------------------------------#
## Despues de haber corrido todo el codigo paso por paso
## se podra desplegar cualquier grafica desde esta seccion 
## unicamente dando Run(Correr) al nombre de la grafica que se desea
## desplegar

## Los summary nos proporcionan una idea general del estado de los datos,
## cual de ellos es el mas elevado o mas bajo respectivamente

#CONSTANTE SOLAR
#  1367
#

## Parametros basicos nos desplega una grafica con los parametros basicos
## Global, Directa, Difusa y Calculada

ParametrosBasicosCorregidos

GdispCorregido

GporcentajeCorregido

BalanceDeOndaCortaCorregido

BalanceDeOndaLargaCorregido

TemperaturaOndaLargac

TermopilaOndaLargac

Metereologia1Corregido

Metereologia2Corregido

GraficaUVBCorregido

UVB_SIGc

summary(DataFrameCorregido$GLOBAL_Avg)
#summary(DataFrameCorregido$GLOBAL_Max)
#summary(DataFrameCorregido$GLOBAL_Min)

summary(DataFrameCorregido$DIRECT_Avg)
#summary(DataFrameCorregido$DIRECT_Max)
#summary(DataFrameCorregido$DIRECT_Min)

summary(DataFrameCorregido$DIFFUSE_Avg)
#summary(DataFrameCorregido$DIFFUSE_Min)
#summary(DataFrameCorregido$DIFFUSE_Max)

summary(DataFrameCorregido$GH_CALC_Avg)

## Gdisp hace referencia a la grafica de dispersion
## La grafica de dispersion es global contra calculada

GdispCorregido

summary(DataFrameCorregido$GLOBAL_Avg)
summary(Calculada_Nueva)
summary(DataFrameCorregido$DIRECT_Avg)
summary(DataFrameCorregido$DIFFUSE_Avg)

## Gdiferencia hace referencia a la grafica de diferencia
## La grafica de diferencia se compone de los datos de la formula (global-calculada) y Timestamp

GdiferenciaCorregido

summary(DataFrameCorregido$GLOBAL_Avg)
summary(Calculada_Nueva)
summary(DataFrameCorregido$DIRECT_Avg)
summary(DataFrameCorregido$DIFFUSE_Avg)

## Gporcentaje hace referencia a la grafica de porcentaje
## La grafica de porcentaje se compone de los datos de la formula ((calculada-global)/global) y Timestamp

GporcentajeCorregido

summary(DataFrameCorregido$GLOBAL_Avg)
summary(Calculada_Nueva)
summary(DataFrameCorregido$DIRECT_Avg)
summary(DataFrameCorregido$DIFFUSE_Avg)


## Gcociente hace referencia a la grafica de cociente 
## La grafica de cociente se compone de los datos de la formula (global/calculada) y Timestamp

GcocienteCorregido

summary(DataFrameCorregido$GLOBAL_Avg)
summary(Calculada_Nueva)
summary(DataFrameCorregido$DIRECT_Avg)
summary(DataFrameCorregido$DIFFUSE_Avg)

## La grafica de onda corta se compone por los datos GLOBAL,UPWARD_SW

BalanceDeOndaCortaCorregido

summary(DataFrameCorregido$GLOBAL_Avg)
#summary(DataFrameCorregido$GLOBAL_Max)
#summary(DataFrameCorregido$GLOBAL_Min)

summary(DataFrameCorregido$UPWARD_SW_Avg)
#summary(DataFrameCorregido$UPWARD_SW_Min)
#summary(DataFrameCorregido$UPWARD_SW_Max)


## La grafica de onda Larga se compone por los datos AIR TEMPERATURE,DOWNWARD y UPWARD_LW

BalanceDeOndaLargaCorregido

summary(DataFrameCorregido$DOWNWARD_Avg)
#summary(DataFrameCorregido$DOWNWARD_Max)
#summary(DataFrameCorregido$DOWNWARD_Min)

summary(DataFrameCorregido$UPWARD_LW_Avg)
#summary(DataFrameCorregido$UPWARD_LW_Max)
#summary(DataFrameCorregido$UPWARD_SW_Min)

## Temperatura pirgeoometro en centifrados

TemperaturaOndaLargac

TermopilaOndaLargac

## Metreologia1 hace referencia a la grafica con los datos de AIR TEMPERATURE Y RELATIVE HUMIDITY

Metereologia1Corregido

summary(DataFrameCorregido$RELATIVE_HUMIDITY_Avg)
summary(DataFrameCorregido$AIR_TEMPERATURE_Avg)
summary(DataFrameCorregido$PRESSURE_Avg)

##Meteorologia2 hace refrencia a la grafica con los datos de PRESSURE Y RELATIVE HUMIDITY

Metereologia2Corregido

summary(DataFrameCorregido$RELATIVE_HUMIDITY_Avg)
summary(DataFrameCorregido$AIR_TEMPERATURE_Avg)
summary(DataFrameCorregido$PRESSURE_Avg)

## GRAFICAUVB hace referencia a la grafica de luz ultravioleta uvb que es muy peligrosa para todo 
## tipo de vida 

GraficaUVBCorregido
UVB_SIG

summary(DataFrameCorregido$UVBw_Avg)
#summary(DataFrameCorregido$UVBw_Max)
#summary(DataFrameCorregido$UVBw_Min)
#-------------------------------------------------------------------------------------------#
