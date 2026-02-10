import streamlit as st
import pandas as pd
import numpy as np
import plotly.express as px
from datetime import datetime, time

# Configuración de la página para que sea más ancha
st.set_page_config(layout="wide")

# Inicializar variables de estado de sesión
if 'theme' not in st.session_state:
    st.session_state.theme = 'light'  # Cambiado 'default' por 'light'
if 'view' not in st.session_state:
    st.session_state.view = 'Gráfico'
if 'logged_in' not in st.session_state:
    st.session_state.logged_in = False

def clean_data(df):
    """
    Reemplaza los valores -999.9 y -999.0 con NaN en todo el DataFrame.
    """
    return df.replace([-999.9, -999.0], np.nan)

# Función para mostrar la página de inicio de sesión
def login():
    st.title("Inicio de Sesión")
    username = st.text_input("Nombre de usuario")
    password = st.text_input("Contraseña", type="password")

    if st.button("Iniciar Sesión"):
        if username == "admin" and password == "admin":
            st.session_state.logged_in = True
            st.experimental_rerun()
        else:
            st.error("Nombre de usuario o contraseña incorrectos")

# Función para aplicar el tema
def apply_theme(theme, light_config=None):
    if light_config is None:
        light_config = {
            'bg_color': '#FFFFFF',        # Blanco para el fondo
            'text_color': '#333333',      # Gris oscuro para el texto principal
            'input_bg_color': '#F8F8F8',  # Gris muy claro para el fondo de los inputs
            'input_border_color': '#E0E0E0',  # Gris claro para los bordes
            'button_bg_color': '#F0F0F0', # Gris claro para los botones
            'link_color': '#1A73E8',      # Azul para los enlaces
            'header_color': '#212121'     # Gris muy oscuro para los encabezados
        }
    
    if theme == 'dark':
        st.markdown("""
        <style>
        .stApp {
            background-color: #1E1E1E;
            color: #FFFFFF;
        }
        .stSelectbox, .stMultiSelect, .stDateInput, .stTimeInput, .stTextInput > div > div > input {
            background-color: #2E2E2E;
            color: #FFFFFF;
        }
        .stButton > button {
            background-color: #4A4A4A;
            color: #FFFFFF;
        }
        .stTextInput > label, .stSelectbox > label, .stMultiSelect > label, .stDateInput > label, .stTimeInput > label {
            color: #FFFFFF !important;
        }
        div[data-baseweb="select"] > div {
            background-color: #2E2E2E;
            color: #FFFFFF;
        }
        div[data-baseweb="base-input"] {
            background-color: #2E2E2E;
        }
        </style>
        """, unsafe_allow_html=True)
    elif theme == 'warm':
        st.markdown("""
        <style>
        .stApp, .stApp * {
            color: #5D4037;
        }
        .stApp {
            background-color: #FFF5E6;
        }
        .stSelectbox, .stMultiSelect, .stDateInput, .stTimeInput, .stTextInput > div > div > input {
            background-color: #FFE4B5;
        }
        .stButton > button {
            background-color: #DEB887;
        }
        .stTextInput > label, .stSelectbox > label, .stMultiSelect > label, .stDateInput > label, .stTimeInput > label {
            color: #5D4037 !important;
        }
        div[data-baseweb="select"] > div {
            background-color: #FFE4B5;
            color: #5D4037;
        }
        div[data-baseweb="base-input"] {
            background-color: #FFE4B5;
        }
        /* Asegurarse de que todo el texto sea del color deseado */
        .stApp p, .stApp span, .stApp div, .stApp label, .stApp input, .stApp select, .stApp button {
            color: #5D4037 !important;
        }
        </style>
        """, unsafe_allow_html=True)
    elif theme == 'dracula':
        st.markdown("""
        <style>
        .stApp {
            background-color: #282a36;
            color: #f8f8f2;
        }
        .stSelectbox, .stMultiSelect, .stDateInput, .stTimeInput, .stTextInput > div > div > input {
            background-color: #44475a;
            color: #f8f8f2;
            border: 1px solid #6272a4;
        }
        .stButton > button {
            background-color: #44475a;
            color: #f8f8f2;
            border: 1px solid #6272a4;
        }
        .stTextInput > label, .stSelectbox > label, .stMultiSelect > label, .stDateInput > label, .stTimeInput > label {
            color: #f8f8f2 !important;
        }
        div[data-baseweb="select"] > div {
            background-color: #44475a;
            color: #f8f8f2;
        }
        div[data-baseweb="base-input"] {
            background-color: #44475a;
        }
        .stApp a {
            color: #8be9fd !important;
        }
        .stApp h1, .stApp h2, .stApp h3, .stApp h4, .stApp h5, .stApp h6 {
            color: #bd93f9 !important;
        }
        </style>
        """, unsafe_allow_html=True)
    elif theme == 'solarized_light':
        st.markdown("""
        <style>
        .stApp {
            background-color: #fdf6e3;
            color: #657b83;
        }
        .stSelectbox, .stMultiSelect, .stDateInput, .stTimeInput, .stTextInput > div > div > input {
            background-color: #eee8d5;
            color: #657b83;
            border: 1px solid #93a1a1;
        }
        .stButton > button {
            background-color: #eee8d5;
            color: #657b83;
            border: 1px solid #93a1a1;
        }
        .stTextInput > label, .stSelectbox > label, .stMultiSelect > label, .stDateInput > label, .stTimeInput > label {
            color: #657b83 !important;
        }
        div[data-baseweb="select"] > div {
            background-color: #eee8d5;
            color: #657b83;
        }
        div[data-baseweb="base-input"] {
            background-color: #eee8d5;
        }
        .stApp a {
            color: #268bd2 !important;
        }
        .stApp h1, .stApp h2, .stApp h3, .stApp h4, .stApp h5, .stApp h6 {
            color: #cb4b16 !important;
        }
        </style>
        """, unsafe_allow_html=True)
    elif theme == 'solarized_dark':
        st.markdown("""
        <style>
        .stApp {
            background-color: #002b36;
            color: #839496;
        }
        .stSelectbox, .stMultiSelect, .stDateInput, .stTimeInput, .stTextInput > div > div > input {
            background-color: #073642;
            color: #839496;
            border: 1px solid #586e75;
        }
        .stButton > button {
            background-color: #073642;
            color: #839496;
            border: 1px solid #586e75;
        }
        .stTextInput > label, .stSelectbox > label, .stMultiSelect > label, .stDateInput > label, .stTimeInput > label {
            color: #839496 !important;
        }
        div[data-baseweb="select"] > div {
            background-color: #073642;
            color: #839496;
        }
        div[data-baseweb="base-input"] {
            background-color: #073642;
        }
        .stApp a {
            color: #268bd2 !important;
        }
        .stApp h1, .stApp h2, .stApp h3, .stApp h4, .stApp h5, .stApp h6 {
            color: #cb4b16 !important;
        }
        </style>
        """, unsafe_allow_html=True)
    elif theme == 'light':
        st.markdown(f"""
        <style>
        .stApp {{
            background-color: {light_config['bg_color']};
            color: {light_config['text_color']};
        }}
        .stSelectbox, .stMultiSelect, .stDateInput, .stTimeInput, .stTextInput > div > div > input {{
            background-color: {light_config['input_bg_color']};
            color: {light_config['text_color']};
            border: 1px solid {light_config['input_border_color']};
        }}
        .stButton > button {{
            background-color: {light_config['button_bg_color']};
            color: {light_config['text_color']};
            border: 1px solid {light_config['input_border_color']};
        }}
        .stTextInput > label, .stSelectbox > label, .stMultiSelect > label, .stDateInput > label, .stTimeInput > label {{
            color: {light_config['text_color']} !important;
            font-weight: 600;
        }}
        div[data-baseweb="select"] > div {{
            background-color: {light_config['input_bg_color']};
            color: {light_config['text_color']};
        }}
        div[data-baseweb="base-input"] {{
            background-color: {light_config['input_bg_color']};
        }}
        .stApp p, .stApp span, .stApp div, .stApp label, .stApp input, .stApp select, .stApp button {{
            color: {light_config['text_color']} !important;
        }}
        .stApp a {{
            color: {light_config['link_color']} !important;
        }}
        .stApp h1, .stApp h2, .stApp h3, .stApp h4, .stApp h5, .stApp h6 {{
            color: {light_config['header_color']} !important;
            font-weight: 700;
        }}
        .stDataFrame {{
            color: {light_config['text_color']};
        }}
        .stDataFrame td, .stDataFrame th {{
            border-color: {light_config['input_border_color']} !important;
        }}
        </style>
        """, unsafe_allow_html=True)
    else:
        # Tema por defecto (light)
        st.markdown(f"""
        <style>
        .stApp {{
            background-color: {light_config['bg_color']};
            color: {light_config['text_color']};
        }}
        /* Resto de los estilos por defecto */
        </style>
        """, unsafe_allow_html=True)

# Función para mostrar la página principal
def main():
    # Aplicar el tema actual
    apply_theme(st.session_state.theme)

    # Definir las opciones de tema
    theme_options = ["light", "dark", "warm", "dracula", "solarized_light", "solarized_dark"]

    # Inicializar el índice del tema si no existe
    if 'theme_index' not in st.session_state:
        st.session_state.theme_index = theme_options.index(st.session_state.theme)

    # Agregar estilos CSS para posicionar el botón en la esquina superior derecha
    st.markdown("""
        <style>
        #theme-selector {
            position: fixed;
            top: 14px;
            right: 10px;
            z-index: 9999;
        }
        #theme-selector .stButton button {
            min-width: 30px;
            max-width: 30px;
            font-size: 1.2em;
            padding: 2px 5px;
            background: none;
            border: none;
            cursor: pointer;
        }
        </style>
    """, unsafe_allow_html=True)

    # Crear un contenedor para el botón y posicionarlo usando el ID personalizado
    st.markdown('<div id="theme-selector">', unsafe_allow_html=True)
    if st.button('🎨', key='theme_button'):
        # Cambiar al siguiente tema
        st.session_state.theme_index = (st.session_state.theme_index + 1) % len(theme_options)
        st.session_state.theme = theme_options[st.session_state.theme_index]
        st.experimental_rerun()
    st.markdown('</div>', unsafe_allow_html=True)

    # Definir la ruta del archivo CSV
    file_path = "BSRN_2023_ene.csv"

    # Leer datos desde el archivo CSV y convertir TIMESTAMP a datetime
    data = pd.read_csv(file_path)
    data['TIMESTAMP'] = pd.to_datetime(data['TIMESTAMP'])

    # Limpiar los datos
    data = clean_data(data)

    # Convertir todas las columnas excepto 'TIMESTAMP' a numéricas
    numeric_columns = data.columns.drop('TIMESTAMP')
    data[numeric_columns] = data[numeric_columns].apply(pd.to_numeric, errors='coerce')

    # Pretratamiento de datos
    data['CRPTemp_Avg'] = data['CRPTemp_Avg'] + 273.15
    data['UVTEMP_Avg'] = data['UVTEMP_Avg'] + 273.15
    data['DEW_POINT_Avg'] = data['DEW_POINT_Avg'] + 273.15

    data['dif_GH_CALC_GLOBAL'] = data['GH_CALC_Avg'] - data['GLOBAL_Avg']
    data['ratio_GH_CALC_GLOBAL'] = data['GH_CALC_Avg'] / data['GLOBAL_Avg']
    data['sum_SW'] = data['DIFFUSE_Avg'] + data['DIRECT_Avg'] * np.cos(np.radians(data['ZenDeg']))
    data["percent"] = 0.01 * data['sum_SW']

    # Definir grupos de variables
    groups = {
        "Parametros Basicos": ["GLOBAL", "DIRECT", "DIFFUSE", "GH_CALC", "percent"],
        "Balance de onda corta": ["GLOBAL", "UPWARD_SW"],
        "Balance de onda larga": ["DOWNWARD", "UPWARD_LW", "DWIRTEMP", "UWIRTEMP", "CRPTemp"],
        "Meteorologia": ["CRPTemp", "RELATIVE_HUMIDITY", "PRESSURE", "DEW_POINT"],
        "Ultravioleta": ["UVB", "UVTEMP", "UVSIGNAL"],
        "Dispersion": ["dif_GH_CALC_GLOBAL", "ratio_GH_CALC_GLOBAL", "sum_SW"],
        "Otros": [],  # Esta lista se llenará con las variables que no estén en otras categorías
        "Todas las variables": []  # Esta lista se llenará con todas las variables excepto 'TIMESTAMP'
    }

    # Ajustar los grupos para incluir '_Avg' cuando sea necesario
    for group, vars in groups.items():
        groups[group] = [var + '_Avg' if var + '_Avg' in data.columns and var not in data.columns else var for var in vars]

    # Obtener todas las columnas excepto 'TIMESTAMP'
    all_columns = set(data.columns) - {'TIMESTAMP'}
    groups["Todas las variables"] = list(all_columns)

    # Para llenar "Otros"
    categorized_vars = set([item for sublist in groups.values() for item in sublist if sublist])
    groups["Otros"] = list(all_columns - categorized_vars)

    st.title("BSRN Visualización Outliers")

    # Crear dos columnas con diferentes anchos
    col1, col2 = st.columns([1, 2])

    with col1:
        st.header("Selección de Datos")

        # Selección de fecha y hora de inicio
        start_date = st.date_input(
            "Fecha de inicio",
            min_value=data['TIMESTAMP'].min().date(),
            max_value=data['TIMESTAMP'].max().date(),
            value=data['TIMESTAMP'].min().date(),
            key="start_date"
        )
        start_time = st.time_input(
            "Hora de inicio",
            value=time(0, 0),
            step=60,  # Paso en segundos
            key="start_time"
        )

        # Selección de fecha y hora de fin
        end_date = st.date_input(
            "Fecha de fin",
            min_value=data['TIMESTAMP'].min().date(),
            max_value=data['TIMESTAMP'].max().date(),
            value=data['TIMESTAMP'].max().date(),
            key="end_date"
        )
        end_time = st.time_input(
            "Hora de fin",
            value=time(23, 59),
            step=60,
            key="end_time"
        )

        # Combinar fecha y hora
        start_datetime = datetime.combine(start_date, start_time)
        end_datetime = datetime.combine(end_date, end_time)

        # Filtrar datos basados en el rango de fechas seleccionado
        data_to_plot = data[(data['TIMESTAMP'] >= start_datetime) & (data['TIMESTAMP'] <= end_datetime)].copy()

        # Seleccionar grupo y variables
        selected_group = st.selectbox("Seleccionar grupo", list(groups.keys()))

        if selected_group == "Todas las variables":
            selected_vars = groups["Todas las variables"]
        else:
            selected_vars = st.multiselect(
                "Seleccionar variables",
                options=groups[selected_group],
                default=groups[selected_group]
            )

        valid_vars = [var for var in selected_vars if var in data_to_plot.columns]

        # Checkbox para aplicar censura
        apply_censorship = st.checkbox("Aplicar censura", value=False)

        if apply_censorship:
            st.subheader("Censura de Datos")
            # Selección de fecha y hora para censura
            censor_start_date = st.date_input(
                "Fecha de inicio de censura",
                min_value=start_date,
                max_value=end_date,
                value=start_date,
                key="censor_start_date"
            )
            censor_start_time = st.time_input(
                "Hora de inicio de censura",
                value=start_time,
                step=60,
                key="censor_start_time"
            )

            censor_end_date = st.date_input(
                "Fecha de fin de censura",
                min_value=start_date,
                max_value=end_date,
                value=end_date,
                key="censor_end_date"
            )
            censor_end_time = st.time_input(
                "Hora de fin de censura",
                value=end_time,
                step=60,
                key="censor_end_time"
            )

            # Combinar fecha y hora para censura
            censor_start_datetime = datetime.combine(censor_start_date, censor_start_time)
            censor_end_datetime = datetime.combine(censor_end_date, censor_end_time)

            # Aplicar censura en el rango de censura
            data_to_plot.loc[
                (data_to_plot['TIMESTAMP'] >= censor_start_datetime) & 
                (data_to_plot['TIMESTAMP'] <= censor_end_datetime), 
                valid_vars
            ] = np.nan

        file_name = st.text_input("Nombre del archivo a descargar", "datos.csv")

    with col2:
        st.header("Vista de Datos")

        if 'view' not in st.session_state:
            st.session_state.view = 'Gráfico'  # Puedes establecer 'Tabla' como valor predeterminado si lo prefieres

        if st.button('Cambiar vista'):
            st.session_state.view = 'Tabla' if st.session_state.view == 'Gráfico' else 'Gráfico'

        if st.session_state.view == 'Gráfico':
            if valid_vars:
                title = f"Gráfico de Multilínea\n"
                fig = px.scatter(data_to_plot, x='TIMESTAMP', y=valid_vars, title=title)
                
                # Configurar el tema del gráfico según el tema seleccionado
                if st.session_state.theme == 'dark':
                    fig.update_layout(
                        plot_bgcolor='#1E1E1E',
                        paper_bgcolor='#1E1E1E',
                        font_color='#FFFFFF',
                        title_font_color='#FFFFFF',
                        legend_title_font_color='#FFFFFF',
                        xaxis=dict(title_font_color='#FFFFFF', tickfont_color='#FFFFFF', gridcolor='#4A4A4A'),
                        yaxis=dict(title_font_color='#FFFFFF', tickfont_color='#FFFFFF', gridcolor='#4A4A4A')
                    )
                elif st.session_state.theme == 'warm':
                    fig.update_layout(
                        plot_bgcolor='#FFF5E6',
                        paper_bgcolor='#FFF5E6',
                        font_color='#5D4037',
                        title_font_color='#5D4037',
                        legend_title_font_color='#5D4037',
                        xaxis=dict(title_font_color='#5D4037', tickfont_color='#5D4037', gridcolor='#DEB887'),
                        yaxis=dict(title_font_color='#5D4037', tickfont_color='#5D4037', gridcolor='#DEB887')
                    )
                elif st.session_state.theme == 'dracula':
                    fig.update_layout(
                        plot_bgcolor='#282a36',
                        paper_bgcolor='#282a36',
                        font_color='#f8f8f2',
                        title_font_color='#bd93f9',
                        legend_title_font_color='#f8f8f2',
                        xaxis=dict(title_font_color='#f8f8f2', tickfont_color='#f8f8f2', gridcolor='#44475a'),
                        yaxis=dict(title_font_color='#f8f8f2', tickfont_color='#f8f8f2', gridcolor='#44475a')
                    )
                elif st.session_state.theme == 'solarized_light':
                    fig.update_layout(
                        plot_bgcolor='#fdf6e3',
                        paper_bgcolor='#fdf6e3',
                        font_color='#657b83',
                        title_font_color='#cb4b16',
                        legend_title_font_color='#657b83',
                        xaxis=dict(title_font_color='#657b83', tickfont_color='#657b83', gridcolor='#eee8d5'),
                        yaxis=dict(title_font_color='#657b83', tickfont_color='#657b83', gridcolor='#eee8d5')
                    )
                elif st.session_state.theme == 'solarized_dark':
                    fig.update_layout(
                        plot_bgcolor='#002b36',
                        paper_bgcolor='#002b36',
                        font_color='#839496',
                        title_font_color='#cb4b16',
                        legend_title_font_color='#839496',
                        xaxis=dict(title_font_color='#839496', tickfont_color='#839496', gridcolor='#073642'),
                        yaxis=dict(title_font_color='#839496', tickfont_color='#839496', gridcolor='#073642')
                    )
                else:  # light theme (default)
                    fig.update_layout(
                        plot_bgcolor='#FFFFFF',
                        paper_bgcolor='#FFFFFF',
                        font_color='#333333',
                        title_font_color='#333333',
                        legend_title_font_color='#333333',
                        xaxis=dict(title_font_color='#333333', tickfont_color='#333333', gridcolor='#E0E0E0'),
                        yaxis=dict(title_font_color='#333333', tickfont_color='#333333', gridcolor='#E0E0E0')
                    )

                # Actualizar las líneas del gráfico para que sean más visibles
                for trace in fig.data:
                    trace.update(line=dict(width=2))  # Hacer las líneas más gruesas

                st.plotly_chart(fig, use_container_width=True)
            else:
                st.warning("Ninguna de las variables seleccionadas está presente en los datos.")

        else:
            st.write("Datos:")
            st.dataframe(data_to_plot[['TIMESTAMP'] + valid_vars].head(10), height=400)

            # Descargar datos
            csv = data_to_plot.to_csv(index=False).encode('utf-8')
            st.download_button(
                label="Descargar datos como CSV",
                data=csv,
                file_name=file_name,
                mime='text/csv',
            )

# Ejecución principal
if 'logged_in' not in st.session_state:
    st.session_state.logged_in = False

if st.session_state.logged_in:
    main()
else:
    login()