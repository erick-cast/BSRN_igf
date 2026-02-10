#Tomamos la funciones previamente creadas y agregamos una interfaz con tkinter
import pandas as pd 
import numpy as np 
import matplotlib.pyplot as plt
from matplotlib.backends.backend_tkagg import FigureCanvasTkAgg,NavigationToolbar2Tk
import plotly.express as px 
from tkinter import *
from tkinter import ttk
from tkinter.filedialog import askopenfilename,asksaveasfilename
from datetime import datetime
import tkinter.messagebox as messagebox
from tkcalendar import DateEntry
import matplotlib.dates as mdates

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
        self.root.geometry("1700x950") #tamaño de la interfaz
        self.root.minsize(1600,850)

        self.df = None
        self.df_filtrado = None
        self.dark_mode = False 
        
        self.pagina = 0
        self.filas_por_pagina = 500


        #-----------Panel derecho-----------
        self.sidebar = Frame(root, width=320, bg="#ffffff")
        self.sidebar.pack(side=LEFT, fill=Y)

        Label(self.sidebar, text="Visualizador Solarimétrico",
              font=("Segoe UI", 14, "bold"), bg="#ffffff").pack(pady=15)

        ttk.Button(self.sidebar, text="Cargar CSV", command=self.cargar_csv)\
            .pack(padx=15, pady=5)

        self.combo = ttk.Combobox(
            self.sidebar, values=list(groups.keys()),
            state="readonly", width=30
        )
        self.combo.pack(padx=10)
        self.combo.bind("<<ComboboxSelected>>", self.actualizar_variables)

        ttk.Label(self.sidebar, text="Variables").pack(anchor="w", padx=15)
        self.listbox_vars = Listbox(self.sidebar, selectmode=MULTIPLE, height=6)
        self.listbox_vars.pack(padx=10, pady=5)
        self.listbox_vars.bind("<<ListboxSelect>>", lambda e: self.previsualizar())

        #-----------Fechas------
        ttk.Label(self.sidebar,text="Fecha inicio").pack(anchor="w",padx=10)
        frame_ini = Frame(self.sidebar, bg="#ffffff")
        frame_ini.pack(anchor="w",padx=10)

        self.fecha_inicio = DateEntry(frame_ini,width=12)
        self.fecha_inicio.pack(side=LEFT)
        self.hora_ini = Spinbox(frame_ini,from_=0,to=23,width=3,format="%02.0f",
                                command=self.previsualizar)
        self.min_ini = Spinbox(frame_ini,from_=0,to=59,width=3,format="%02.0f",
                               command=self.previsualizar)
        self.hora_ini.pack(side=LEFT,padx=2)
        self.min_ini.pack(side=LEFT)

        ttk.Label(self.sidebar, text="Fecha fin").pack(anchor="w",padx=10,pady=(8,0))
        frame_fin = Frame(self.sidebar,bg="#ffffff")
        frame_fin.pack(anchor="w",padx=10)

        self.fecha_fin = DateEntry(frame_fin,width=12)
        self.fecha_fin.pack(side=LEFT)
        self.hora_fin = Spinbox(frame_fin, from_=0,to=23,width=3,format="%02.0f",
                                command=self.previsualizar)
        self.min_fin = Spinbox(frame_fin,from_=0,to=59,width=3,format="%02.0f",
                               command=self.previsualizar)
        self.hora_fin.pack(side=LEFT,padx=2)
        self.min_fin.pack(side=LEFT)

        ttk.Button(self.sidebar,text="Consultar tabla", command=self.consultar_tabla).pack(pady=5)
        ttk.Button(self.sidebar,text="Graficar", command=self.grafica_plotly).pack(pady=8)
        ttk.Button(self.sidebar,text="Exportar CSV", command=self.exportar_csv).pack(pady=5) 
        #---------Configuracion----------
 
        self.main = Frame(root, bg="#eef2f7")
        self.main.pack(side=LEFT, fill=BOTH, expand=True)

        Button(self.main, text="🌙", command=self.toggle_dark).pack(anchor="ne", padx=8, pady=4)
        
        frame_plot = Frame(self.main)
        frame_plot.pack(fill=X,padx=10, pady=(10,0))
        
        self.fig, self.ax = plt.subplots(figsize=(12,5))
        self.canvas = FigureCanvasTkAgg(self.fig, master=frame_plot)
        self.canvas.draw()
        self.canvas.get_tk_widget().pack(fill=X, padx=10, pady=10)

       # --- PUNTO INTELIGENTE ---
        self.hover_point, = self.ax.plot([], [], "o", color="red", markersize=6, zorder=5)
        self.hover_annot = self.ax.annotate(
        "",
        xy=(0, 0),
        xytext=(15, 15),
        textcoords="offset points",
        bbox=dict(boxstyle="round", fc="w"),
        arrowprops=dict(arrowstyle="->")
        )   
        self.hover_annot.set_visible(False)

        self.canvas.mpl_connect("motion_notify_event", self.on_hover)


        frame_toolbar= Frame(self.main)
        frame_toolbar.pack(fill=X, padx=10)

        self.toolbar = NavigationToolbar2Tk(self.canvas,frame_toolbar)
        self.toolbar.update()

        self.tree=ttk.Treeview(self.main,show="headings")
        self.tree.pack(fill=BOTH,expand=True,padx=10,pady=5)

        self.nav = Frame(self.main)
        self.nav.pack(pady=5)
        Button(self.nav,text="◀ Anterior", command=self.prev_page).pack(side=LEFT,padx=5)
        Button(self.nav, text="Siguiente ▶", command=self.next_page).pack(side=LEFT,padx=5)

     #-------------------Funcionamiento-----

    def cargar_csv(self):
        df = seleccion_datos()
        if df is None:
            return
        self.df = preprocesamiento(limpieza(df))
        messagebox.showinfo("OK", "Datos cargados correctamente")

    def actualizar_variables(self, _):
        self.listbox_vars.delete(0, END)
        for v in groups[self.combo.get()]:
            self.listbox_vars.insert(END, v)

    def obtener_filtro(self):
        inicio = datetime(
            self.fecha_inicio.get_date().year,
            self.fecha_inicio.get_date().month,
            self.fecha_inicio.get_date().day,
            int(self.hora_ini.get()), int(self.min_ini.get()),0
        )
        fin = datetime(
            self.fecha_fin.get_date().year,
            self.fecha_fin.get_date().month,
            self.fecha_fin.get_date().day,
            int(self.hora_fin.get()), int(self.min_fin.get()),59
        )

        if fin < inicio:
            messagebox.showerror("Error","La fecha fin no puede ser menor")
            return None

        return self.df.loc[
            (self.df["TIMESTAMP"] >= inicio) &
            (self.df["TIMESTAMP"] <= fin)
        ].copy()
    
    def on_hover(self, event):
        if self.df_filtrado is None or event.xdata is None or event.ydata is None:
            self.hover_annot.set_visible(False)
            self.canvas.draw_idle()
            return

        vars_sel = [self.listbox_vars.get(i) for i in self.listbox_vars.curselection()]
        if not vars_sel:
            return

    # Convertir TIMESTAMP a formato matplotlib
        xdata = self.df_filtrado["TIMESTAMP"]
        x_num = mdates.date2num(xdata)

        mouse_x = event.xdata
        idx = np.abs(x_num - mouse_x).argmin()

        x = xdata.iloc[idx]
        y = self.df_filtrado[vars_sel[0]].iloc[idx]

    # Actualizar punto
        self.hover_point.set_data(x, y)

    # Texto tipo Plotly
        texto = x.strftime('%Y-%m-%d %H:%M')
        for v in vars_sel:
            val = self.df_filtrado[v].iloc[idx]
            texto += f"\n{v}: {val:.2f}"

        self.hover_annot.xy = (x, y)
        self.hover_annot.set_text(texto)
        self.hover_annot.set_visible(True)

        self.canvas.draw_idle()


    def previsualizar(self):
        if self.df is None:
            return
        vars_sel = [self.listbox_vars.get(i) for i in self.listbox_vars.curselection()]
        if not vars_sel:
            return

        df_f = self.obtener_filtro()
        if df_f is None or df_f.empty:
            return

        self.df_filtrado = df_f

        self.ax.clear()
        self.hover_point.set_data([], [])
        self.hover_annot.set_visible(False)

        for v in vars_sel:
            self.ax.plot(
            self.df_filtrado["TIMESTAMP"],
            self.df_filtrado[v],
            label=v
            )

        self.ax.legend(
            loc="upper left",
            bbox_to_anchor=(1.02, 1),
            borderaxespad=0,
            fontsize=9
            )

        self.fig.autofmt_xdate()
        self.fig.tight_layout()
        self.canvas.draw()

    def consultar_tabla(self):
        if self.df is None:
            messagebox.showwarning("Aviso", "No hay datos cargados")
            return

        vars_sel = [self.listbox_vars.get(i) for i in self.listbox_vars.curselection()]
        if not vars_sel:
            messagebox.showwarning("Aviso", "Selecciona al menos una variable")
            return

        df_f = self.obtener_filtro()
        if df_f is None or df_f.empty:
            messagebox.showwarning("Aviso", "No hay datos para mostrar")
            return

        self.df_filtrado = df_f[["TIMESTAMP"] + vars_sel].copy()

        self.pagina = 0
        self.actualizar_tabla()

    def actualizar_tabla(self):
        self.tree.delete(*self.tree.get_children())

        inicio = self.pagina * self.filas_por_pagina
        fin = inicio + self.filas_por_pagina
        df_page = self.df_filtrado.iloc[inicio:fin]

        self.tree["columns"] = list(df_page.columns)
        for col in df_page.columns:
            self.tree.heading(col, text=col)
            self.tree.column(col, width=140)

        for _, row in df_page.iterrows():
            self.tree.insert("", END, values=list(row))

    def next_page(self):
        if (self.pagina + 1) * self.filas_por_pagina < len(self.df_filtrado):
            self.pagina += 1
            self.actualizar_tabla()

    def prev_page(self):
        if self.pagina > 0:
            self.pagina -= 1
            self.actualizar_tabla()        

    def grafica_plotly(self):
        if self.df_filtrado is not None:
            px.line(self.df_filtrado,x="TIMESTAMP",
                    y=[self.listbox_vars.get(i) for i in self.listbox_vars.curselection()]).show()

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
        bg = "#2b2b2b" if self.dark_mode else "#ffffff"
        fg = "#ffffff" if self.dark_mode else "#000000"

        self.sidebar.configure(bg=bg)
        self.main.configure(bg=bg)
        self.root.configure(bg=bg)

#--------------------Inicio aplicacion----------

root = Tk()
App(root)
root.mainloop()

