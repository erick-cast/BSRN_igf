##  INSTALACION DE PAQUETES NECESARIOS PARA LA GRAFICACION
install.packages('tidyverse')
install.packages('plotly')
install.packages('RMySQL')
install.packages('lubridate')

##  AQUI ACTIVAMOS LAS LIBRERIAS PREVIAMENTE CARGADAS
library(tidyverse)
library(plotly)
library(RMySQL)
library(lubridate) 

##  linea para la concexion de la bd con R, para cambiar a una diferente hay 
##  que cambiar donde dice dbname al nombre de tu bd, tambien hay que cambiar tu usuario y contrasena 
##  en caso de tener algo diferente
conexion<- dbConnect(MySQL(), user="root", host="132.248.182.174", password="C0tz1to1*", dbname="BSRN_2023", port=3306)


## Este segundo data frame nos servira para modificar los datos de la bd a nulos o hacer cambios 
## correspondientes sin alterar el data frame original que contiene los valores originales 
## SE PUEDE CAMBIAR LA FECHA MODIFICANDO LOS RANGOS(FECHAS) DENTRO DE BETWEEN  

DataFrameCorregido<- dbGetQuery(conexion, statement = "SELECT TIMESTAMP,ZenDeg, GLOBAL_Avg,GLOBAL_Std,GLOBAL_Min,
                   GLOBAL_Max,DIRECT_Avg,DIRECT_Std,DIRECT_Min,DIRECT_Max,DIFFUSE_Avg,
                   DIFFUSE_Std,DIFFUSE_Min,DIFFUSE_Max,GH_CALC_Avg,UPWARD_SW_Avg,
                   UPWARD_SW_Std,UPWARD_SW_Min,UPWARD_SW_Max,DOWNWARD_Avg,DOWNWARD_Std,
                   DOWNWARD_Min,DOWNWARD_Max,UPWARD_LW_Avg,UPWARD_LW_Std,UPWARD_LW_Min,
                   UPWARD_LW_Max,AIR_TEMPERATURE_Avg,RELATIVE_HUMIDITY_Avg,PRESSURE_Avg, 
                   UVBw_Avg,UVBw_Std,UVBw_Min,UVBw_Max, UVSIGNAL_Avg,
                   DWIRTEMPC_Avg, UWIRTEMPC_Avg, DWTERMO_Avg, UWTERMO_Avg, ZenDeg
                   FROM bsrn_2023_null WHERE TIMESTAMP BETWEEN 
                   '2023-07-31 00:00:00'AND '2022-07-31 23:59:00' ")

## Tratamiento de timestamp en R para tener una mejor estructura y que no 
## se amontonen los datos a los que corresponden los puntos en el eje x
DataFrameCorregido$TIMESTAMP <- ymd_hms(DataFrameCorregido$TIMESTAMP)

## TRATAMIENTO DE DATOS;
## LOS DATOS CON VALORES -999 Y -99.9
## SON COVERTIDOS A NaN (NOT A NUMBER)
## SIN ALTERAR LA  BASE DE DATOS REAL
DataFrameCorregido[DataFrameCorregido ==-999] <- NaN
DataFrameCorregido[DataFrameCorregido ==-99.9] <- NaN
DataFrameCorregido[DataFrameCorregido ==-99.99] <- NaN

## Hacemos una nueva calculada para los cambios correspondientes

Calculada_Nueva <- DataFrameCorregido$DIRECT_Avg*cos(pi/180*DataFrameCorregido$ZenDeg)+DataFrameCorregido$DIFFUSE_Avg


#-------------------------------------------------------------------------------------------#
##Operaciones para obtener los rangos maximo y minimo de los parametros basicos
##en esta variable hacemos la conversion de grados a radianes
Conv_Ang_Zen_A_Radianes <- (DataFrameCorregido$ZenDeg*pi/180)

## En estas variables se guardan los datos obtenidos de las operaciones establecidad en el test 
## Para la obtencion de valores maximos extremadamente raros en parametros basicos
MAXGLOBALRAROCorregido <- (1361/.9^2)*1.2*(cos(Conv_Ang_Zen_A_Radianes)^1.2)+50
MAXDIFFUSERAROCorregido <- (1361/.9^2)*0.95*(cos(Conv_Ang_Zen_A_Radianes)^1.2)+10
MAXDIRECRAROCorregido <- (1361/(.9)^2)*0.95*(cos(Conv_Ang_Zen_A_Radianes)^0.2)+10

## En estas variables se guardan los datos obtenidos de las operaciones establecidad en el test 
## Para la obtencion de valores maximos fisicamente imposibles en parametros basicos
MAXGLOBAL_IMPOSIBLECorregido <- (1361/.9^2)*1.5*(cos(Conv_Ang_Zen_A_Radianes)^1.2)+100
MAXDIFFUSE_IMPOSIBLECorregido <- (1361/.9^2)*0.95*(cos(Conv_Ang_Zen_A_Radianes)^1.2)+50
MAXDIREC_IMPOSIBLECorregido <- (1361/(.9)^2)

## GRAFICA CON DATOS CORREGIDOS
## seccion de parametros 1
ParametrosBasicosCorregidos <- plot_ly(DataFrameCorregido, x = ~TIMESTAMP, y = ~GLOBAL_Avg, name = 'GLOBAL_AVG', type = 'scatter', mode = 'lines', line = list( color = 'black'))%>% 
  add_trace(y = ~GLOBAL_Min, name = 'GLOBAL_Min', visible="legendonly" )%>% 
  add_trace(y = ~GLOBAL_Max, name = 'GLOBAL_Max', visible="legendonly" )%>% 
  add_trace(x = ~TIMESTAMP, y =~MAXGLOBALRAROCorregido, type = 'scatter', name = 'MAX_Ext_Raro_Global',  mode = 'markeds', line = list(dash = "dash", color = 'green'), inherit = FALSE,
            text = paste("<br>LIMITE MAXIMO EXTREMADAMENTE RARO DE GLOBAL"), hoverinfo = 'text', visible="legendonly")%>%
  add_trace(x = ~TIMESTAMP, y =~MAXGLOBAL_IMPOSIBLECorregido, type = 'scatter',name = 'MAX_Fis_Imp_Global', mode = 'markeds', line = list(dash = "dash", color = 'red'), inherit = FALSE,
            text = paste("<br>LIMITE MAXIMO FISICAMENTE IMPOSIBLE DE GLOBAL"), hoverinfo = 'text', visible="legendonly")%>%
  
  add_trace(y = ~DIRECT_Avg, name = 'DIRECT_AVG', line = list( color = 'blue'))%>% 
  add_trace(y = ~DIRECT_Min, name = 'DIRECT_Min', visible="legendonly" )%>% 
  add_trace(y = ~DIRECT_Max, name = 'DIRECT_Max', visible="legendonly" )%>% 
  add_trace(x = ~TIMESTAMP, y =~MAXDIRECRAROCorregido, type = 'scatter', name = 'MAX_Ext_Raro_Directa', mode = 'markeds', line = list(dash = "dash", color = 'green'), inherit = FALSE,
            text = paste("<br>LIMITE MAXIMO EXTREMADAMENTE RARO DE DIRECTA"), hoverinfo = 'text', visible="legendonly")%>%
  add_trace(x = ~TIMESTAMP, y =~MAXDIREC_IMPOSIBLECorregido, type = 'scatter',name = 'MAX_Fis_Imp_Directa', mode = 'markeds', line = list(dash = "dash", color = 'red'), inherit = FALSE,
            text = paste("<br>LIMITE MAXIMO FISICAMENTE IMPOSIBLE DE DIRECTA"), hoverinfo = 'text', visible="legendonly")%>%
  
  add_trace(y = ~DIFFUSE_Avg, name = 'DIFFUSE_AVG', line = list( color = 'yellow'))%>% 
  add_trace(y = ~DIFFUSE_Min, name = 'DIFFUSE_Min', visible="legendonly" )%>% 
  add_trace(y = ~DIFFUSE_Max, name = 'DIFFUSE_Max', visible="legendonly" )%>% 
  add_trace(x = ~TIMESTAMP, y =~MAXDIFFUSERAROCorregido, type = 'scatter', name = 'MAX_Ext_Raro_Difusa', mode = 'markeds', line = list(dash = "dash", color = 'green'), inherit = FALSE,
            text = paste("<br>LIMITE MAXIMO EXTREMADAMENTE RARO DE DIFUSA"), hoverinfo = 'text', visible="legendonly")%>%
  add_trace(x = ~TIMESTAMP, y =~MAXDIFFUSE_IMPOSIBLECorregido, type = 'scatter',name = 'MAX_Fis_Imp_Difusa', mode = 'markeds', line = list(dash = "dash", color = 'red'), inherit = FALSE,
            text = paste("<br>LIMITE MAXIMO FISICAMENTE IMPOSIBLE DE DIFUSA"), hoverinfo = 'text', visible="legendonly")%>%
  
  add_trace(y = ~Calculada_Nueva, name = 'Calculada Nueva', line = list( color = 'purple'))%>%
  add_trace(x = ~TIMESTAMP, y = -2,type = 'scatter', name = 'MIN_Ext_Raro', mode = 'markeds', line = list(dash = "dash", color = 'green'), inherit = FALSE, 
            text = paste("<br>LIMITE EXTREMADAMENTE RARO"), hoverinfo = 'text', visible="legendonly")%>%
  add_trace(x = ~TIMESTAMP, y = -4,type = 'scatter', name = 'MIN_Fis_Imp', mode = 'markeds', line = list(dash = "dash", color = 'red'), inherit = FALSE,
            text = paste("<br>LIMITE FISICAMENTE IMPOSIBLE"), hoverinfo = 'text', visible="legendonly")%>%
  
  layout(title = 'Parametros 1',
         xaxis = list(zerolinecolor = '#ffff',
                      zerolinewidth = 2,
                      gridcolor = 'ffff',
                      title='TIEMPO'),
         yaxis = list(range=c(-5,1500),
                      zerolinecolor = '#ffff',
                      zerolinewidth = 2,
                      gridcolor = 'ffff',
                      title='W/M^2'),
         plot_bgcolor='#e5ecf6',
         showlegend = TRUE,
         legend = list(orientation = 'v'))
#-------------------------------------------------------------------------------------------#


## GRAFICAS CON DATOS CORREGIDOS
## Graficas de dispersion entre blobal y calculada
GdispCorregido <- plot_ly(DataFrameCorregido, x = ~GLOBAL_Avg, y = ~Calculada_Nueva, name="Corregido",type = 'scatter', mode = 'markers',
                 text = paste("Fecha: ", DataFrameCorregido$TIMESTAMP,
                              "<br>GLOBAL: ", DataFrameCorregido$GLOBAL_Avg,
                              "<br>CALCULADA: ", Calculada_Nueva,
                              "<br>DIRECTA: ", DataFrameCorregido$DIRECT_Avg,
                              "<br>DIFUSA: ", DataFrameCorregido$DIFFUSE_Avg,
                              "<br>Diferencia: ", DataFrameCorregido$GLOBAL_Avg-Calculada_Nueva,
                              "<br>Porcentaje: ", (Calculada_Nueva-DataFrameCorregido$GLOBAL_Avg)/DataFrameCorregido$GLOBAL_Avg,
                              "<br>Cociente: ", DataFrameCorregido$GLOBAL_Avg/Calculada_Nueva ),
                 hoverinfo = 'text')%>%
  add_trace(DataFrame, x = ~GLOBAL_Avg, y = ~GH_CALC_Avg, name="Original", type = 'scatter', mode = 'markers',
            text = paste("Fecha: ", DataFrame$TIMESTAMP,
                         "<br>GLOBAL: ", DataFrame$GLOBAL_Avg,
                         "<br>CALCULADA: ", DataFrame$GH_CALC_Avg,
                         "<br>DIRECTA: ", DataFrame$DIRECT_Avg,
                         "<br>DIFUSA: ", DataFrame$DIFFUSE_Avg,
                         "<br>Diferencia: ", DataFrame$GLOBAL_Avg-DataFrame$GH_CALC_Avg,
                         "<br>Porcentaje: ", (DataFrame$GH_CALC_Avg-DataFrame$GLOBAL_Avg)/DataFrame$GLOBAL_Avg,
                         "<br>Cociente: ", DataFrame$GLOBAL_Avg/DataFrame$GH_CALC_Avg ),
            hoverinfo = 'text',visible="legendonly")%>%
  layout(title = 'Grafica de dispersion entre global y calculada',
         xaxis = list(zerolinecolor = '#ffff',
                      zerolinewidth = 2,
                      gridcolor = 'ffff',
                      title='global'),
         yaxis = list(zerolinecolor = '#ffff',
                      zerolinewidth = 2,
                      gridcolor = 'ffff',
                      title='calculada'),
         plot_bgcolor='#e5ecf6',
         showlegend = TRUE,
         legend = list(orientation = 'v'))
#-------------------------------------------------------------------------------------------#


## GRAFICAS CON DATOS CORREGIDOS
## Grafica de Diferencia
diferenciaCorregido <- DataFrameCorregido$GLOBAL_Avg-Calculada_Nueva
diferencia <- DataFrame$GLOBAL_Avg-DataFrame$GH_CALC_Avg
GdiferenciaCorregido <- plot_ly(DataFrameCorregido, x = ~TIMESTAMP , y = diferencia, type = 'scatter',name="Corregido", mode = 'line',
                      text = paste("Fecha: ", DataFrameCorregido$TIMESTAMP,
                                   "<br>GLOBAL: ", DataFrameCorregido$GLOBAL_Avg,
                                   "<br>CALCULADA: ", Calculada_Nueva,
                                   "<br>DIRECTA: ", DataFrameCorregido$DIRECT_Avg,
                                   "<br>DIFUSA: ", DataFrameCorregido$DIFFUSE_Avg,
                                   "<br>Diferencia: ", DataFrameCorregido$GLOBAL_Avg-Calculada_Nueva,
                                   "<br>Porcentaje: ", (Calculada_Nueva-DataFrameCorregido$GLOBAL_Avg)/DataFrameCorregido$GLOBAL_Avg,
                                   "<br>Cociente: ", DataFrameCorregido$GLOBAL_Avg/Calculada_Nueva ),
                    hoverinfo = 'text')%>%
  add_trace(DataFrame, x = ~TIMESTAMP , y = diferencia, type = 'scatter',name="Original", mode = 'line',
            text = paste("Fecha: ", DataFrame$TIMESTAMP,
                         "<br>GLOBAL: ", DataFrame$GLOBAL_Avg,
                         "<br>CALCULADA: ", DataFrame$GH_CALC_Avg,
                         "<br>DIRECTA: ", DataFrame$DIRECT_Avg,
                         "<br>DIFUSA: ", DataFrame$DIFFUSE_Avg,
                         "<br>Diferencia: ", DataFrame$GLOBAL_Avg-DataFrame$GH_CALC_Avg,
                         "<br>Porcentaje: ", (DataFrame$GH_CALC_Avg-DataFrame$GLOBAL_Avg)/DataFrame$GLOBAL_Avg,
                         "<br>Cociente: ", DataFrame$GLOBAL_Avg/DataFrame$GH_CALC_Avg ),
            hoverinfo = 'text', visible="legendonly")%>%
        layout(title = 'Grafica de Diferencia entre global y calculada',
               xaxis = list(zerolinecolor = '#ffff',
                            zerolinewidth = 2,
                            gridcolor = 'ffff',
                            title='global'),
               yaxis = list(zerolinecolor = '#ffff',
                            zerolinewidth = 2,
                            gridcolor = 'ffff',
                            title='diferencia'),
               plot_bgcolor='#e5ecf6',
               showlegend = TRUE,
               legend = list(orientation = 'v'))

#-------------------------------------------------------------------------------------------#
## GRAFICAS CON DATOS CORREGIDOS
## Grafica de Porcentaje
porcentajeCorregido <- (Calculada_Nueva-DataFrameCorregido$GLOBAL_Avg)/DataFrameCorregido$GLOBAL_Avg
porcentaje <- (DataFrame$GH_CALC_Avg-DataFrame$GLOBAL_Avg)/DataFrame$GLOBAL_Avg
GporcentajeCorregido <- plot_ly(DataFrameCorregido, x = ~TIMESTAMP, y = ~porcentajeCorregido, name="Corregido",
                       type = 'scatter', mode = 'line', 
                       text = paste("Fecha: ", DataFrameCorregido$TIMESTAMP,
                                    "<br>GLOBAL: ", DataFrameCorregido$GLOBAL_Avg,
                                    "<br>CALCULADA: ", Calculada_Nueva,
                                    "<br>DIRECTA: ", DataFrameCorregido$DIRECT_Avg,
                                    "<br>DIFUSA: ", DataFrameCorregido$DIFFUSE_Avg,
                                    "<br>Diferencia: ", DataFrameCorregido$GLOBAL_Avg-Calculada_Nueva,
                                    "<br>Porcentaje: ", (Calculada_Nueva-DataFrameCorregido$GLOBAL_Avg)/DataFrameCorregido$GLOBAL_Avg,
                                    "<br>Cociente: ", DataFrameCorregido$GLOBAL_Avg/Calculada_Nueva ),
                       hoverinfo = 'text')%>%
  add_trace(DataFrame, x = ~TIMESTAMP, y = ~porcentaje, type = 'scatter', name="Original",mode = 'line', 
            text = paste("<br>FECHA: ", DataFrame$TIMESTAMP,
                         "<br>GLOBAL: ", DataFrame$GLOBAL_Avg,
                         "<br>CALCULADA: ", DataFrame$GH_CALC_Avg,
                         "<br>DIRECTA: ", DataFrame$DIRECT_Avg,
                         "<br>DIFUSA: ", DataFrame$DIFFUSE_Avg,
                         "<br>Diferencia: ", DataFrame$GLOBAL_Avg-DataFrame$GH_CALC_Avg,
                         "<br>PORCENTAJE: ", (DataFrame$GH_CALC_Avg-DataFrame$GLOBAL_Avg)/DataFrame$GLOBAL_Avg,
                         "<br>COCIENTE: ", DataFrame$GLOBAL_Avg/DataFrame$GH_CALC_Avg),
            hoverinfo = 'text', visible="legendonly" )%>%
      layout(title = 'Grafica de porcentaje entre global y calculada',
             xaxis = list(zerolinecolor = '#ffff',
                          zerolinewidth = 2,
                          gridcolor = 'ffff',
                          title='global'),
             yaxis = list(zerolinecolor = '#ffff',
                          zerolinewidth = 2,
                          gridcolor = 'ffff',
                          title='porcentaje'),
             plot_bgcolor='#e5ecf6',
             showlegend = TRUE,
             legend = list(orientation = 'v'))
  
#-------------------------------------------------------------------------------------------#

## GRAFICAS CON DATOS CORREGIDOS
## Grafica de Cociente
cocienteCorregido <- DataFrameCorregido$GLOBAL_Avg/Calculada_Nueva
cociente <- DataFrame$GLOBAL_Avg/DataFrame$GH_CALC_Avg
GcocienteCorregido <- plot_ly(DataFrameCorregido, x = ~TIMESTAMP, y = ~cocienteCorregido, type = 'scatter',name="Corregido", mode = 'line', 
                              text = paste("Fecha: ", DataFrameCorregido$TIMESTAMP,
                                           "<br>GLOBAL: ", DataFrameCorregido$GLOBAL_Avg,
                                           "<br>CALCULADA: ", Calculada_Nueva,
                                           "<br>DIRECTA: ", DataFrameCorregido$DIRECT_Avg,
                                           "<br>DIFUSA: ", DataFrameCorregido$DIFFUSE_Avg,
                                           "<br>Diferencia: ", DataFrameCorregido$GLOBAL_Avg-Calculada_Nueva,
                                           "<br>Porcentaje: ", (Calculada_Nueva-DataFrameCorregido$GLOBAL_Avg)/DataFrameCorregido$GLOBAL_Avg,
                                           "<br>Cociente: ", DataFrameCorregido$GLOBAL_Avg/Calculada_Nueva ),
                              hoverinfo = 'text')%>%
  add_trace(DataFrame, x = ~TIMESTAMP, y = ~cociente, type = 'scatter',name="Original", mode = 'line', 
            text = paste("<br>FECHA: ", DataFrame$TIMESTAMP,
                         "<br>GLOBAL: ", DataFrame$GLOBAL_Avg,
                         "<br>CALCULADA: ", DataFrame$GH_CALC_Avg,
                         "<br>DIRECTA: ", DataFrame$DIRECT_Avg,
                         "<br>DIFUSA: ", DataFrame$DIFFUSE_Avg,
                         "<br>Diferencia: ", DataFrame$GLOBAL_Avg-DataFrame$GH_CALC_Avg,
                         "<br>PORCENTAJE: ", DataFrame$GH_CALC_Avg-DataFrame$GLOBAL_Avg/DataFrame$GLOBAL_Avg,
                         "<br>COCIENTE: ", DataFrame$GLOBAL_Avg/DataFrame$GH_CALC_Avg),
            hoverinfo = 'text',visible="legendonly")%>%
  layout(title = 'Grafica de cociente entre global y calculada',
         xaxis = list(zerolinecolor = '#ffff',
                      zerolinewidth = 2,
                      gridcolor = 'ffff',
                      title='global'),
         yaxis = list(zerolinecolor = '#ffff',
                      zerolinewidth = 2,
                      gridcolor = 'ffff',
                      title='cociente'),
         plot_bgcolor='#e5ecf6',
         showlegend = TRUE,
         legend = list(orientation = 'v'))

#-------------------------------------------------------------------------------------------#
## GRAFICAS CON DATOS CORREGIDOS
## Parametros 2 balance de onda corta

BalanceDeOndaCortaCorregido <- plot_ly(DataFrameCorregido, x = ~TIMESTAMP, y = ~GLOBAL_Avg, name = 'GLOBAL_AVG', type = 'scatter', mode = 'lines')%>% 
  add_trace(y = ~GLOBAL_Min, name = 'GLOBAL_Min', visible="legendonly" )%>% 
  add_trace(y = ~GLOBAL_Max, name = 'GLOBAL_Max', visible="legendonly" )%>% 
  
  add_trace(y = ~UPWARD_SW_Avg, name = 'UPWARD_SW_Avg' )%>% 
  add_trace(y = ~UPWARD_SW_Min, name = 'UPWARD_SW_Min', visible="legendonly" )%>% 
  add_trace(y = ~UPWARD_SW_Max, name = 'UPWARD_SW_Max', visible="legendonly" )%>% 
  layout(
    title = 'Parametros 2 balance de onda corta',
    xaxis = list(zerolinecolor = '#ffff',
                 zerolinewidth = 2,
                 gridcolor = 'ffff',
                 title='TIEMPO'),
    yaxis = list(
      zerolinecolor = '#ffff',
      zerolinewidth = 2,
      gridcolor = 'ffff',
      title='W/M^2'),
    plot_bgcolor='#e5ecf6',
    showlegend = TRUE,
    legend = list(orientation = 'v'))


## GRAFICAS CON DATOS CORREGIDOS
## Parametro 4 onda larga
BalanceDeOndaLargaCorregido <-  plot_ly(DataFrameCorregido,x = ~TIMESTAMP, y = ~AIR_TEMPERATURE_Avg, name = "TEMPERATURA DE AIRE", mode = "lines", type = "scatter")
valor <- list(
  tickfont = list(color = "red"),
  overlaying = "y",
  side = "right",
  title = "W/M^2" )

BalanceDeOndaLargaCorregido <- BalanceDeOndaLargaCorregido %>% add_trace( x = ~TIMESTAMP, y = ~DOWNWARD_Avg, yaxis = "y2", name = 'DOWNWARD_Avg', type = 'scatter', mode = 'lines')
BalanceDeOndaLargaCorregido <- BalanceDeOndaLargaCorregido %>%  add_trace(y = ~DOWNWARD_Min, yaxis = "y2", name = 'DOWNWARD_Min', visible="legendonly" )
BalanceDeOndaLargaCorregido <- BalanceDeOndaLargaCorregido %>%  add_trace(y = ~DOWNWARD_Max, yaxis = "y2", name = 'DOWNWARD_Max', visible="legendonly" ) 

BalanceDeOndaLargaCorregido <- BalanceDeOndaLargaCorregido %>%  add_trace(y = ~UPWARD_LW_Avg, yaxis = "y2", name = 'UPWARD_LW_Avg' )
BalanceDeOndaLargaCorregido <- BalanceDeOndaLargaCorregido %>%  add_trace(y = ~UPWARD_LW_Min, yaxis = "y2", name = 'UPWARD_LW_Min', visible="legendonly" ) 
BalanceDeOndaLargaCorregido <- BalanceDeOndaLargaCorregido %>%  add_trace(y = ~UPWARD_LW_Max, yaxis = "y2", name = 'UPWARD_LW_Max', visible="legendonly" )


BalanceDeOndaLargaCorregido <- BalanceDeOndaLargaCorregido %>%  layout(title = 'Parametros 4 balance de onda larga',
            yaxis2 = valor,
            xaxis = list(zerolinecolor = '#ffff',
                         zerolinewidth = 2,
                         gridcolor = 'ffff',
                         title='TIEMPO'),
            yaxis = list(
              range=c(0,50),
              zerolinecolor = '#ffff',
              zerolinewidth = 2,
              gridcolor = 'ffff',
              title='grados centigrados'),
            plot_bgcolor='#e5ecf6',
            showlegend = TRUE,
            legend = list(orientation = 'v'))
#-------------------------------------------------------------------------------------------#
## GRAFICAS CON DATOS CORREGIDOS
## Parametros 2 balance de onda larga Temperatura en centrigrados
TemperaturaOndaLargac <- plot_ly(DataFrameCorregido, x = ~TIMESTAMP, y = ~UWIRTEMPC_Avg, name = 'UWIRTEMPC_Avg', type = 'scatter', mode = 'lines')%>% 
  
  add_trace(y = ~DWIRTEMPC_Avg, name = 'DWIRTEMPC_Avg' )%>% 
  
  layout(title = 'Parametros TEMPERATURA ONDA LARGA CENTIGRADOS',
         xaxis = list(zerolinecolor = '#ffff',
                      zerolinewidth = 2,
                      gridcolor = 'ffff',
                      title='TIEMPO'),
         yaxis = list(
           zerolinecolor = '#ffff',
           zerolinewidth = 2,
           gridcolor = 'ffff',
           title='W/M^2'),
         plot_bgcolor='#e5ecf6',
         showlegend = TRUE,
         legend = list(orientation = 'v'))
#-------------------------------------------------------------------------------------------#
## GRAFICAS CON DATOS ORIGINALES 
## Parametros 2 balance de onda larga TERMOPILA
TermopilaOndaLargac <- plot_ly(DataFrameCorregido, x = ~TIMESTAMP, y = ~DWTERMO_Avg, name = 'DWTERMO_Avg', type = 'scatter', mode = 'lines')%>% 
  
  add_trace(y = ~UWTERMO_Avg, name = 'UWTERMo_Avg' )%>% 
  
  layout(title = 'Parametros Señal de la TERMOPILA',
         xaxis = list(zerolinecolor = '#ffff',
                      zerolinewidth = 2,
                      gridcolor = 'ffff',
                      title='TIEMPO'),
         yaxis = list(
           zerolinecolor = '#ffff',
           zerolinewidth = 2,
           gridcolor = 'ffff',
           title='W/M^2'),
         plot_bgcolor='#e5ecf6',
         showlegend = TRUE,
         legend = list(orientation = 'v'))
#-------------------------------------------------------------------------------------------#
## GRAFICAS CON DATOS CORREGIDOS
## Parametros Metereologicos
## AIR_TEMPERATURE_Avg-Grados cent
## RELATIVE_HUMIDITY_Avg-Porcentaje
Metereologia1Corregido <- plot_ly(DataFrameCorregido)
Metereologia1Corregido <- Metereologia1Corregido %>% add_trace(x = ~TIMESTAMP, y = ~AIR_TEMPERATURE_Avg, name = "TEMPERATURA DE AIRE", mode = "lines", type = "scatter")
ay <- list(
  range=c(0,100),
  tickfont = list(color = "red"),
  overlaying = "y",
  side = "right",
  title = "<b>PORCENTAJE</b> %" )
Metereologia1Corregido <- Metereologia1Corregido %>% add_trace(x = ~TIMESTAMP, y = ~RELATIVE_HUMIDITY_Avg, name = "Humedad relativa",yaxis = "y2", mode = "lines", type = "scatter")
Metereologia1Corregido <- Metereologia1Corregido %>%layout(title = "----", yaxis2 = ay,
                 plot_bgcolor='#e5ecf6',
                 xaxis = list(
                   xaxis = list(title="TIEMPO "),
                   zerolinecolor = '#ffff',
                   zerolinewidth = 2,
                   gridcolor = 'ffff'),
                 yaxis = list(
                   range=c(0,50),
                   title="<b>GRADOS CENTIGRADOS</b> C",
                   zerolinecolor = '#ffff',
                   zerolinewidth = 2,
                   gridcolor = 'ffff'))

#-------------------------------------------------------------------------------------------#

## GRAFICAS CON DATOS CORREGIDOS
## RELATIVE_HUMIDITY_Avg-Porcentaje
## PRESSURE_Avg-milibares
Metereologia2Corregido <- plot_ly(DataFrameCorregido, x = ~TIMESTAMP, y = ~PRESSURE_Avg, name = "Presion", mode = "lines", type = "scatter")
secondY<- list(
  tickfont = list(color = "red"),
  overlaying = "y",
  side = "right",
  range=c(0,100),
  title = "<b>PORCENTAJE</b> %")
Metereologia2Corregido <- Metereologia2Corregido %>% add_trace( y = ~RELATIVE_HUMIDITY_Avg, name = "Humedad relativa",yaxis = "y2", mode = "lines", type = "scatter")
Metereologia2Corregido <- Metereologia2Corregido %>% layout(title = "----", 
                                          plot_bgcolor='#e5ecf6',
                                          yaxis2 = secondY,
                                          xaxis = list(
                                            title="TIEMPO ",
                                            zerolinecolor = '#ffff',
                                            zerolinewidth = 2,
                                            gridcolor = 'ffff'),
                                          yaxis = list(
                                            ###range=c(0,50),
                                            title="<b>MILIBARES</b> MB",
                                            zerolinecolor = '#ffff',
                                            zerolinewidth = 2,
                                            gridcolor = 'ffff'))

#-------------------------------------------------------------------------------------------#

#######parametros 3 uvb
GraficaUVBCorregido <- plot_ly(DataFrameCorregido, x = ~TIMESTAMP, y = ~UVBw_Avg, name = 'UVBw_Avg', type = 'scatter', mode = 'lines')%>% 
  add_trace(y = ~UVBw_Min, name = 'UVBw_Min', visible="legendonly" )%>% 
  add_trace(y = ~UVBw_Max, name = 'UVBw_Max', visible="legendonly" )%>%
  layout(title = 'GRAFICA  UVBw',
         xaxis = list(zerolinecolor = '#ffff',
                      zerolinewidth = 2,
                      gridcolor = 'ffff',
                      title='TIEMPO'),
         yaxis = list(zerolinecolor = '#ffff',
                      zerolinewidth = 2,
                      gridcolor = 'ffff',
                      title='W/M^2'),
         plot_bgcolor='#e5ecf6',
         showlegend = TRUE,
         legend = list(orientation = 'v'))
#
## GRAFICAS CON DATOS ORIGINALES 
## UVB data and SIGNAL
## UVB wats/mw 
## UVSIGNAL mvolts
UVB_SIGc <- plot_ly(DataFrame, x = ~TIMESTAMP, y = ~UVBw_Avg, name = "UVBc", mode = "lines", type = "scatter")
secondY <- list(
  range=c(0,1.2),
  tickfont = list(color = "red"),
  overlaying = "y",
  side = "right",
  title = "<b>MV</b> %" )
UVB_SIGc <- UVB_SIG %>% add_trace(x = ~TIMESTAMP, y = ~UVSIGNAL_Avg, name = "UVBSignalc",yaxis = "y2", mode = "lines", type = "scatter")
UVB_SIGc <- UVB_SIG %>%layout(title = "----", yaxis2 = secondY,
                             plot_bgcolor='#e5ecf6',
                             xaxis = list(
                               xaxis = list(title="TIEMPO "),
                               zerolinecolor = '#ffff',
                               zerolinewidth = 2,
                               gridcolor = 'ffff'),
                             yaxis = list(
                               range=c(0,0.3),
                               title="<b>Wm/2</b> C",
                               zerolinecolor = '#ffff',
                               zerolinewidth = 2,
                               gridcolor = 'ffff'))



#-------------------------------------------------------------------------------------------#
#
## -------------------------------------------------------------------------------------------------------------------------------
#######Angulo Zenital
GraficaZenDeg <- plot_ly(DataFrame, x = ~TIMESTAMP, y = ~ZenDeg, name = 'ZenDeg', type = 'scatter', mode = 'lines')%>% 
  layout(title = 'GRAFICA ZenDeg',
         xaxis = list(zerolinecolor = '#ffff',
                      zerolinewidth = 2,
                      gridcolor = 'ffff',
                      title='TIEMPO'),
         yaxis = list(zerolinecolor = '#ffff',
                      zerolinewidth = 2,
                      gridcolor = 'ffff',
                      title='W/M^2'),
         plot_bgcolor='#e5ecf6',
         showlegend = TRUE,
         legend = list(orientation = 'v'))
## -------------------------------------------------------------------------------------------------------------------------------
#-------------------------------------------------------------------------------------------#
#

#dbDisconnect(conexion)
#
#############################################
###### TERMINE  #######
#############################################

