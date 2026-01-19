#Tomamos la funciones previamente creadas y agregamos una interfaz con tkinter
import pandas as pd 
import numpy as np 
import matplotlib.pyplot as plt
from matplotlib.backends.backend_tkagg import FigureCanvasTkAgg
import plotly.express as px 
from tkinter import *
from tkinter import ttk
from tkinter.filedialog import askopenfilename,asksaveasfilename
from datetime import datetime
import tkinter.messagebox as messagebox
from tkcalendar import DateEntry

plt.style.use("seaborn-v0_8-whitegrid")

#----------------Seleccion de datos------------- 
def seleccion_datos():
    #Ventana de tkinter
    Tk().withdraw()
    #Explorador de archivos
    filename = askopenfilename(
        title="Selecciona un archivo CSV",
        filetypes=[("Archivos CSV", "*.csv")]
        
    )
    if not filename:
        return None 
    return pd.read_csv(filename)

#----------limpieza de datos eliminando los -999.9 y -999.0------
def limpieza(df):
    return df.replace([-999.9,-999.0],np.nan)

#----------------preprocesamiento de datos------------- 
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

#--------------------------Grupos--------------------- 
groups = {
    "1. Parámetros Básicos": ["GLOBAL_Avg","DIRECT_Avg","DIFFUSE_Avg","GH_CALC_Avg","percent"],
    "2. Balance de onda corta": ["GLOBAL_Avg","UPWARD_SW_Avg"],
    "3. Balance de onda larga": ["DOWNWARD_Avg","UPWARD_LW_Avg","DWIRTEMP_Avg","UWIRTEMP_Avg","CRPTemp_Avg"],
    "4. Meteorología": ["CRPTemp_Avg","RELATIVE_HUMIDITY_Avg","PRESSURE_Avg","DEW_POINT_Avg"],
    "5. Ultravioleta": ["UVB_Avg","UVTEMP_Avg","UVSIGNAL_Avg"],
    "6. Dispersión": ["dif_GH_CALC_GLOBAL","ratio_GH_CALC_GLOBAL","sum_SW"]
}


#-----------------Insertamos la interfaz de tkinter-----------

class App:
    def __init__(self,root):
        self.root = root  #iniciamos la ventana
        self.root.title("Visualizador de Datos Solarimétricos") #titulo de la ventana
        self.root.geometry("1400x720") #tamaño de la interfaz

        self.df = None
        self.df_filtrado = None
        self.dark = False 
        
        #-----------Panel derecho-----------
        self.sidebar = Frame(root, width=320, bg="#ffffff")
        self.sidebar.pack(side=LEFT, fill=Y)

        Label(self.sidebar, text="Visualizador Solarimétrico",
              font=("Segoe UI", 16, "bold"), bg="#ffffff").pack(pady=15)

        ttk.Button(self.sidebar, text="Cargar CSV", command=self.cargar_csv)\
            .pack(padx=15, pady=5)

        ttk.Label(self.sidebar, text="Grupo de variables").pack(anchor="w", padx=15)
        self.combo_grupo = ttk.Combobox(
            self.sidebar, values=list(groups.keys()), state="readonly", width=30
        )
        self.combo_grupo.pack(padx=15, pady=3)
        self.combo_grupo.bind("<<ComboboxSelected>>", self.actualizar_variables)

        ttk.Label(self.sidebar, text="Variables").pack(anchor="w", padx=15)
        self.listbox_vars = Listbox(self.sidebar, selectmode=MULTIPLE, height=6, width=32)
        self.listbox_vars.pack(padx=15, pady=5)
        self.listbox_vars.bind("<<ListboxSelect>>", lambda e: self.previsualizar())

        #-----------Fechas------

        ttk.Label(self.sidebar, text="Fecha inicio").pack(anchor="w", padx=15)
        self.fecha_inicio = DateEntry(self.sidebar, width=12)
        self.fecha_inicio.pack(anchor="w", padx=15)
        self.fecha_inicio.bind("<<DateEntrySelected>>", lambda e: self.previsualizar())

        frame_ini = Frame(self.sidebar, bg="#ffffff")
        frame_ini.pack(anchor="w", padx=15)

        self.hora_ini = Spinbox(frame_ini, from_=0, to=23, width=3,
                                format="%02.0f", command=self.previsualizar)
        self.min_ini = Spinbox(frame_ini, from_=0, to=59, width=3,
                               format="%02.0f", command=self.previsualizar)

        self.hora_ini.pack(side=LEFT)
        Label(frame_ini, text=":", bg="#ffffff").pack(side=LEFT)
        self.min_ini.pack(side=LEFT)

        ttk.Label(self.sidebar, text="Fecha fin").pack(anchor="w", padx=15, pady=(10,0))
        self.fecha_fin = DateEntry(self.sidebar, width=12)
        self.fecha_fin.pack(anchor="w", padx=15)
        self.fecha_fin.bind("<<DateEntrySelected>>", lambda e: self.previsualizar())

        frame_fin = Frame(self.sidebar, bg="#ffffff")
        frame_fin.pack(anchor="w", padx=15)

        self.hora_fin = Spinbox(frame_fin, from_=0, to=23, width=3,
                                format="%02.0f", command=self.previsualizar)
        self.min_fin = Spinbox(frame_fin, from_=0, to=59, width=3,
                               format="%02.0f", command=self.previsualizar)

        self.hora_fin.pack(side=LEFT)
        Label(frame_fin, text=":", bg="#ffffff").pack(side=LEFT)
        self.min_fin.pack(side=LEFT)

        ttk.Button(self.sidebar, text="Graficar", command=self.grafica_plotly)\
            .pack(pady=20)

        ttk.Button(self.sidebar, text="Exportar CSV", command=self.exportar_csv)\
            .pack()     
        #---------Configuracion----------
 
        self.main = Frame(root, bg="#eef2f7")
        self.main.pack(side=LEFT, fill=BOTH, expand=True)

        Button(self.main, text="🌙", command=self.toggle_dark)\
            .pack(anchor="ne", padx=10, pady=5)

        self.fig, self.ax = plt.subplots(figsize=(8, 3))
        self.canvas = FigureCanvasTkAgg(self.fig, master=self.main)
        self.canvas.get_tk_widget().pack(fill=X, padx=10, pady=10)

        self.tree = ttk.Treeview(self.main, show="headings")
        self.tree.pack(fill=BOTH, expand=True, padx=10, pady=10)

     #-------------------Funcionamiento-----

    def cargar_csv(self):
        df = seleccion_datos()
        if df is None:
            return
        self.df = preprocesamiento(df)
        messagebox.showinfo("OK", "Datos cargados correctamente")

    def actualizar_variables(self, event):
        seleccionadas = self.listbox_vars.curselection()
        self.listbox_vars.delete(0, END)
        for v in groups[self.combo_grupo.get()]:
            self.listbox_vars.insert(END, v)
        for i in seleccionadas:
            if i < self.listbox_vars.size():
                self.listbox_vars.selection_set(i)

    def obtener_filtro(self):
        inicio = datetime.combine(
            self.fecha_inicio.get_date(),
            datetime.strptime(f"{self.hora_ini.get()}:{self.min_ini.get()}", "%H:%M").time()
        )
        fin = datetime.combine(
            self.fecha_fin.get_date(),
            datetime.strptime(f"{self.hora_fin.get()}:{self.min_fin.get()}", "%H:%M").time()
        )
        return self.df[(self.df["TIMESTAMP"] >= inicio) &
                       (self.df["TIMESTAMP"] <= fin)]

    def previsualizar(self):
        if self.df is None:
            return

        vars_sel = [self.listbox_vars.get(i) for i in self.listbox_vars.curselection()]
        if not vars_sel:
            return

        self.df_filtrado = self.obtener_filtro()
        if self.df_filtrado.empty:
            return

        self.ax.clear()
        for v in vars_sel:
            self.ax.plot(self.df_filtrado["TIMESTAMP"],
                         self.df_filtrado[v], label=v)

        self.ax.legend(fontsize=8)
        self.fig.autofmt_xdate()
        self.canvas.draw()

        self.actualizar_tabla(self.df_filtrado[["TIMESTAMP"] + vars_sel].head(200))

    def grafica_plotly(self):
        if self.df_filtrado is None or self.df_filtrado.empty:
            messagebox.showwarning("Aviso", "No hay datos para graficar")
            return

        vars_sel = [self.listbox_vars.get(i) for i in self.listbox_vars.curselection()]
        fig = px.line(self.df_filtrado, x="TIMESTAMP", y=vars_sel)
        fig.show()

    def actualizar_tabla(self, df):
        self.tree.delete(*self.tree.get_children())
        self.tree["columns"] = list(df.columns)
        for col in df.columns:
            self.tree.heading(col, text=col)
            self.tree.column(col, width=120)
        for _, row in df.iterrows():
            self.tree.insert("", END, values=list(row))

    def exportar_csv(self):
        if self.df_filtrado is None:
            messagebox.showwarning("Aviso", "No hay datos filtrados")
            return
        file = asksaveasfilename(defaultextension=".csv")
        if file:
            self.df_filtrado.to_csv(file, index=False)
            messagebox.showinfo("Exportado", "CSV guardado correctamente")

    def toggle_dark(self):
        self.dark_mode = not self.dark_mode
        bg = "#2e2e2e" if self.dark_mode else "#ffffff"
        self.sidebar.configure(bg=bg)
        self.main.configure(bg=bg)
        self.root.configure(bg=bg)

#--------------------Inicio aplicacion----------

root = Tk()
app = App(root)
root.mainloop()

