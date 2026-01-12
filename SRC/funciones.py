import pandas as pd 
import numpy as np 
import plotly.express as px 
from tkinter import Tk
from tkinter.filedialog import askopenfilename
from datetime import datetime

#Abrir la ventana para la seleccion del archivo csv 

def seleccion_datos():
    #Ventana de tkinter
    Tk().withdraw()
    #Explorador de archivos
    filename = askopenfilename(
        title="Selecciona un archivo CSV",
        filetypes=[("Archivos CSV", "*.csv")]
    )
    #Retorno de la base selccionada
    df = pd.read_csv(filename)
    return df


#Comprobación lectura de datos 
datos = seleccion_datos()
#print(datos.head())

#Conteo de Nan antes de la sustitucion 
#print(datos.isna().sum())
#Se verifica que no existen datos Nan

#limpieza de datos eliminando los -999.9 y -999.0
def limpieza(datos):
    return datos.replace([-999.9,-999.0],np.nan)

#aplicamos la limpieza 

#df = limpieza(datos) 

#print(df.isna().sum())
#limpieza verificada
#preprocesamiento de datos 
def preprocesamiento(df):
   #Convertimos las columna timestamp Formato
   df['TIMESTAMP'] = pd.to_datetime(df['TIMESTAMP'],dayfirst = True)
    #Convertimos los datos a numericos 
   numeric_cols = df.columns.drop('TIMESTAMP')
   df[numeric_cols] = df[numeric_cols].apply(pd.to_numeric,errors='coerce')

   #Conversion de temperatura de columnas 
   for col in ['CRPTemp_Avg','UVTEMP_Avg','DEW_POINT_Avg']:
       if col in df.columns:
           df[col] = df[col]+273.15

    #Calculos derivados 
   if set(['GH_CALC_Avg','GLOBAL_Avg']).issubset(df.columns):
       df['dif_GH_CALC_GLOBAL'] = df['GH_CALC_Avg']-df['GLOBAL_Avg']
       df['ratio_GH_CALC_GLOBAL']=df['GH_CALC_Avg']/df['GLOBAL_Avg']

   if set(['DIFFUSE_Avg', 'DIRECT_Avg']).issubset(df.columns):
       df['sum_SW'] = df['DIFFUSE_Avg'] +df['DIRECT_Avg']*np.cos(np.radians(df['ZenDeg']))
       df['percent'] = 0.01*df['sum_SW']
   return df 

#Enlistamos los grupos de variables 
#Estan enumerados para la interfaz
groups = {
    "1. Parámetros Básicos": ["GLOBAL_Avg","DIRECT_Avg","DIFFUSE_Avg","GH_CALC_Avg","percent"],
    "2. Balance de onda corta": ["GLOBAL_Avg","UPWARD_SW_Avg"],
    "3. Balance de onda larga": ["DOWNWARD_Avg","UPWARD_LW_Avg","DWIRTEMP_Avg","UWIRTEMP_Avg","CRPTemp_Avg"],
    "4. Meteorología": ["CRPTemp_Avg","RELATIVE_HUMIDITY_Avg","PRESSURE_Avg","DEW_POINT_Avg"],
    "5. Ultravioleta": ["UVB_Avg","UVTEMP_Avg","UVSIGNAL_Avg"],
    "6. Dispersión": ["dif_GH_CALC_GLOBAL","ratio_GH_CALC_GLOBAL","sum_SW"]
}

#Una vez armadas las funciones trabajamos sobre la base de datos 
df = seleccion_datos()
df = limpieza(df)
df = preprocesamiento(df)

#Seleccionamos el grupo 
#print('\n Selecciona el grupo de variables ')
#for key in groups:
#    print(key)
#grupo = input("\n Ingresa el numero de grupo ")

#grupo_clave = [g for g in groups.keys() if g.startswith(grupo + ".")][0]
#variables = groups[grupo_clave]

#Seleccion autoamtica de variables 

while True:
    #Seleccionamos el grupo 
    print('\n Selecciona el grupo de variables ')
    for key in groups:
        print(key)
    grupo = input("\n Ingresa el numero de grupo ")

    try:
        grupo_clave = [g for g in groups.keys() if g.startswith(grupo + ".")][0]
    except IndexError:
        print("\n Grupo no valido intente de nuevo")
        continue
    variables =groups[grupo_clave]

    #Seleccion de variables en el grupo 
    print('"\n Variables disponibles ')
    for i, var in enumerate(variables,1):
        print(f"{i},{var}")
    var_indices = input("\n Seleccione las variables a graficar (ejemplo : 1,2,4):")
    try:
        var_indices = [int(x.strip())-1 for x in var_indices.split(",")]
        variables_seleccionadas = [ variables[i] for i in var_indices]
    except:
        print("\n Error en seleccion intente de nuevo")
        continue 
    print('\n Variables seleccionadas',variables_seleccionadas)

    #Seleccion de fechas
    print("\nFormato de fecha: DD/MM/AAAA HH:MM")
    inicio = input("Fecha y hora de inicio: ")
    fin = input("Fecha y hora de fin: ")
    try:
        inicio_dt = datetime.strptime(inicio, "%d/%m/%Y %H:%M")
        fin_dt = datetime.strptime(fin, "%d/%m/%Y %H:%M")
    except: 
        print("\n Formato no valido reintente")
        continue
    df_filtro = df[(df['TIMESTAMP'] >= inicio_dt) & (df['TIMESTAMP'] <= fin_dt)] 


    #Verificar la selccion de datos
    if df_filtro.empty:
        print("\n No se encontraron datos en la selccion")
        continue


#Eleccion de variables en el grupo 
#print ("\n Variables disponibles en el grupo ")

#for i, var in enumerate(variables, 1):
#    print(f"{i}.{var}")

#var_index = int(input("\"Selecciona la variable a graficar (numero):")) -1
#variable_seleccionada = variables[var_index]

#Seleccion de mas parametros 
#print('"\n Variables disponibles ')
#for i, var in enumerate(variables,1):
#    print(f"{i},{var}")
#var_indices = input("\n Seleccione las variables a graficar (ejemplo : 1,2,4):")
#var_indices = [int(x.strip())-1 for x in var_indices.split(",")]
#variables_seleccionadas = [ variables[i] for i in var_indices]

#print('\n Variables seleccioanadas',variables_seleccionadas)

#Selecciona de fechas 

#print("\nFormato de fecha: DD/MM/AAAA HH:MM")
#inicio = input("Fecha y hora de inicio: ")
#fin = input("Fecha y hora de fin: ")

#inicio_dt = datetime.strptime(inicio, "%d/%m/%Y %H:%M")
#fin_dt = datetime.strptime(fin, "%d/%m/%Y %H:%M")

#df_filtro = df[(df['TIMESTAMP'] >= inicio_dt) & (df['TIMESTAMP'] <= fin_dt)] 


#Graficos mediante plotly

#fig = px.line(df_filtro, x='TIMESTAMP', y=variable_seleccionada, title=f"{variable_seleccionada} vs Tiempo")
#fig.show()

 #Grafico de multiples variables
    fig = px.line(df_filtro, x = 'TIMESTAMP', y = variables_seleccionadas, title='Variables seleccionadas vs tiempo')
    fig.update_traces(mode='lines',line=dict(width=2))

    fig.update_layout(xaxis_title='Tiempos',
                  yaxis_title="Valor",
                  legend_title='Variables')

    fig.show()
   
#Preguntar por la exportacion de datos 
    exportar = input("\n ¿Deseas exportar los datos? (s/n)")
    if exportar == "s":
        nombre = input("\n Nombre del archivo ")
        df_filtro.to_csv(nombre + ".csv", index = False)
        print(f"\n Archivo '{nombre}.csv' se guardó corectamente")
#Pregunta por mas consultas 
    consultas = input("\n ¿Quieres realizar otra consulta? (s/n)")
    if consultas != "s":
        print("\n consulta finalizada")
        break




