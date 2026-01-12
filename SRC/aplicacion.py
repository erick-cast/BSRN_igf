#Tomamos la funciones previamente creadas y agregamos una interfaz con tkinter
import pandas as pd 
import numpy as np 
import plotly.express as px 
from tkinter import *
from tkinter import ttk
from tkinter.filedialog import askopenfilename
from datetime import datetime
import tkinter.messagebox as messagebox

#Seleccion de datos 
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

#limpieza de datos eliminando los -999.9 y -999.0
def limpieza(datos):
    return datos.replace([-999.9,-999.0],np.nan)

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

#Grupos 
groups = {
    "1. Parámetros Básicos": ["GLOBAL_Avg","DIRECT_Avg","DIFFUSE_Avg","GH_CALC_Avg","percent"],
    "2. Balance de onda corta": ["GLOBAL_Avg","UPWARD_SW_Avg"],
    "3. Balance de onda larga": ["DOWNWARD_Avg","UPWARD_LW_Avg","DWIRTEMP_Avg","UWIRTEMP_Avg","CRPTemp_Avg"],
    "4. Meteorología": ["CRPTemp_Avg","RELATIVE_HUMIDITY_Avg","PRESSURE_Avg","DEW_POINT_Avg"],
    "5. Ultravioleta": ["UVB_Avg","UVTEMP_Avg","UVSIGNAL_Avg"],
    "6. Dispersión": ["dif_GH_CALC_GLOBAL","ratio_GH_CALC_GLOBAL","sum_SW"]
}


#Insertamos la interfaz de tkinter

class App:
    def __init__(self,root):
        self.root = root  #iniciamos la ventana
        self.root.title("Visualizador de Datos Solarimétricos") #titulo de la ventana
        self.root.geometry("600x500") #tamaño de la interfaz

        self.df = None

        #Insertando titulo en la interfaz #pack pady es par ala orientacion 
        Label(root,text="Visualizador de datos",font=("Arial",16,"bold")).pack(pady=10)

        #Seleccion del archivo csv 
        Button(root, text=" Cargar archivo CSV", command=self.cargar_csv, width=25).pack(pady=10)

        #Abrimos un selector de variabels 
        Label(root,text="Seleccionar grupo de variables:").pack()
        self.combo_grupo = ttk.Combobox(root,values=list(groups.keys()),state="readonly", width=40) #readonly es para no escribirlo de manera manual
        self.combo_grupo.pack(pady=5)
        self.combo_grupo.bind("<<ComboboxSelected>>",self.actualizar_variables) #bind nos permite arrojar la actualziacion de las variables 

        #Se enlistan las subvariables y se seleccionan mdiante un click
        Label(root,text="Seleccionar variables (Ctrl + click):").pack()
        self.listbox_vars = Listbox(root,selectmode=MULTIPLE, width=40, height=7) #seleccionar multiples variables
        self.listbox_vars.pack(pady=5)

        #Seleccio nde fechas inicio
        Label(root,text="Fecha inicio (DD/MM/YYYY HH:MM)").pack()
        self.fecha_inicio = Entry(root,width=25)
        self.fecha_inicio.pack()
        #Fecha fin
        Label(root,text="Fecha fin (DD/MM/YYYY HH:MM)").pack()
        self.fecha_fin = Entry(root,width=25)
        self.fecha_fin.pack()

        #Se añade el boton para realizar la grafica
        Button(root,text=" Graficar",command=self.graficar,width=20).pack(pady=15)

        #Boton para la exportacion
        Button(root,text=" Exportar CSV",command=self.exportar,width=20).pack()
    
    #Interaccion con el usuario se añaden ventanas si el usuario está realziando algo de manera incorrecta 
    #interaccion carga de archivos y preprocesamiento 
    
    def cargar_csv(self):
        datos = seleccion_datos()
        if datos is None:
            return
        
        datos = limpieza(datos)
        self.df = preprocesamiento(datos)
        messagebox.showinfo("Éxito","Archivo cargado y procesado correctamente.")

   #En caso de no seleccioanr un archivo csv 
   
    def actualizar_variables(self, event):
        grupo = self.combo_grupo.get()
        self.listbox_vars.delete(0,END)
        for v in groups[grupo]:
            self.listbox_vars.insert(END,v)

    def graficar(self):
        if self.df is None:
            messagebox.showerror("Error","Primero debes cargar un archivo CSV.")
            return
        #selecciones de grupo
        grupo = self.combo_grupo.get()
        if not grupo:
            messagebox.showerror("Error","Selecciona un grupo.")
            return
        #seleccion dde variables
        indices = self.listbox_vars.curselection()
        if not indices:
            messagebox.showerror("Error","Selecciona al menos una variable.")
            return

        variables = [self.listbox_vars.get(i) for i in indices]

        #Formato de seleccion de fechas 

        try:
            inicio_dt = datetime.strptime(self.fecha_inicio.get(),"%d/%m/%Y %H:%M")
            fin_dt = datetime.strptime(self.fecha_fin.get(),"%d/%m/%Y %H:%M")
        except:
            messagebox.showerror("Error","Formato de fecha incorrecto.")
            return

       #uso del filtro timestamp misma funcion de seleccion de fechas 

        df_filtro = self.df[(self.df['TIMESTAMP'] >= inicio_dt) & (self.df['TIMESTAMP'] <= fin_dt)]

        if df_filtro.empty:
            messagebox.showwarning("Sin datos","No se encontraron datos en ese rango.")
            return

        fig = px.line(df_filtro,x="TIMESTAMP",y=variables, title="Variables seleccionadas")
        fig.show()

        #Error de exportacion }

    def exportar(self):
        if self.df is None:
            messagebox.showerror("Error","No hay datos cargados.")
            return
        
        nombre = "datos_filtrados"
        self.df.to_csv(nombre + ".csv",index=False)
        messagebox.showinfo("Éxito", f"Archivo '{nombre}.csv' guardado correctamente.")

#Ejecucion de la aplicacion 

root = Tk() #apararecer la ventana
app = App(root)#llamar a la app
root.mainloop() #consulta continua de la aplicacion 