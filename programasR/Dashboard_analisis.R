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

## conexion<- dbConnect(MySQL(), host="localhost", user="root", password="C0tz1to1*", dbname="BSRN_2023", port=3306)

##  aqui creamos un data frame con todos los datos de nuestra bd sin nungun cambio
## (solo corresponden a un mes porque lo seccionamos)
##  SE PUEDE CAMBIAR LA FECHA MODIFICANDO LOS RANGOS(FECHAS) DENTRO DE BETWEEN 
DataFrame<- dbGetQuery(conexion, statement = "SELECT TIMESTAMP,ZenDeg,GLOBAL_Avg,GLOBAL_Std,GLOBAL_Min,
        GLOBAL_Max,DIRECT_Avg,DIRECT_Std,DIRECT_Min,DIRECT_Max,DIFFUSE_Avg,
        DIFFUSE_Std,DIFFUSE_Min,DIFFUSE_Max,GH_CALC_Avg,UPWARD_SW_Avg,
        UPWARD_SW_Std,UPWARD_SW_Min,UPWARD_SW_Max,DOWNWARD_Avg,DOWNWARD_Std,
        DOWNWARD_Min,DOWNWARD_Max,UPWARD_LW_Avg,UPWARD_LW_Std,UPWARD_LW_Min,
        UPWARD_LW_Max,AIR_TEMPERATURE_Avg,RELATIVE_HUMIDITY_Avg,PRESSURE_Avg, 
        UVBw_Avg, UVBw_Std, UVBw_Min, UVBw_Max, UVSIGNAL_Avg, DWIRTEMPC_Avg, UWIRTEMPC_Avg, DWTERMO_Avg, UWTERMO_Avg
        FROM bsrn_2023 WHERE TIMESTAMP BETWEEN 
        '2023-06-01 00:00:00'AND '2023-06-30 23:59:00' ")

## este segundo data frame nos servira para modificar los datos de la bd a nulos o hacer cambios 
## correspondientes sin alterar el data frame original que contiene los valores originales 
## SE PUEDE CAMBIAR LA FECHA MODIFICANDO LOS RANGOS(FECHAS) DENTRO DE BETWEEN  

## Tratamiento de timestamp en R para tener una mejor estructura y que no 
## se amontonen los datos a los que corresponden los puntos en el eje x
DataFrame$TIMESTAMP <- ymd_hms(DataFrame$TIMESTAMP)
#-------------------------------------------------------------------------------------------#
##Operaciones para obtener los rangos maximo y minimo de los parametros basicos
##en esta variable hacemos la conversion de grados a radianes
Conv_Ang_Zen_A_Radianes <- (DataFrame$ZenDeg*pi/180)

## En estas variables se guardan los datos obtenidos de las operaciones establecidad en el test 
## Para la obtencion de valores maximos extremadamente raros en parametros basicos
MAXGLOBALRARO <- (1361/.9^2)*1.2*(cos(Conv_Ang_Zen_A_Radianes)^1.2)+50
MAXDIFFUSERARO <- (1361/.9^2)*0.95*(cos(Conv_Ang_Zen_A_Radianes)^1.2)+10
MAXDIRECRARO <- (1361/(.9)^2)*0.95*(cos(Conv_Ang_Zen_A_Radianes)^0.2)+10

## En estas variables se guardan los datos obtenidos de las operaciones establecidad en el test 
## Para la obtencion de valores maximos fisicamente imposibles en parametros basicos
MAXGLOBAL_IMPOSIBLE <- (1361/.9^2)*1.5*(cos(Conv_Ang_Zen_A_Radianes)^1.2)+100
MAXDIFFUSE_IMPOSIBLE <- (1361/.9^2)*0.95*(cos(Conv_Ang_Zen_A_Radianes)^1.2)+50
MAXDIREC_IMPOSIBLE <- (1361/(.9)^2)

## GRAFICAS CON DATOS ORIGINALES 
## seccion de parametros 1
ParametrosBasicos <- plot_ly(DataFrame, x = ~TIMESTAMP, y = ~GLOBAL_Avg, name = 'GLOBAL_AVG', type = 'scatter', mode = 'lines', line = list( color = 'black'))%>% 
  add_trace(y = ~GLOBAL_Min, name = 'GLOBAL_Min', visible="legendonly" )%>% 
  add_trace(y = ~GLOBAL_Max, name = 'GLOBAL_Max', visible="legendonly" )%>% 
  add_trace(x = ~TIMESTAMP, y =~MAXGLOBALRARO,type = 'scatter', name = 'MAX_Ext_Raro_Global',  mode = 'markeds', line = list(dash = "dash", color = 'green'), inherit = FALSE,
            text = paste("<br>LIMITE MAXIMO EXTREMADAMENTE RARO DE GLOBAL"), hoverinfo = 'text',visible="legendonly")%>%
  add_trace(x = ~TIMESTAMP, y =~MAXGLOBAL_IMPOSIBLE,type = 'scatter',name = 'MAX_Fis_Imp_Global', mode = 'markeds', line = list(dash = "dash", color = 'red'), inherit = FALSE,
            text = paste("<br>LIMITE MAXIMO FISICAMENTE IMPOSIBLE DE GLOBAL"), hoverinfo = 'text',visible="legendonly")%>%
  
  add_trace(y = ~DIRECT_Avg, name = 'DIRECT_AVG', line = list( color = 'blue'))%>% 
  add_trace(y = ~DIRECT_Min, name = 'DIRECT_Min', visible="legendonly" )%>% 
  add_trace(y = ~DIRECT_Max, name = 'DIRECT_Max', visible="legendonly" )%>% 
  add_trace(x = ~TIMESTAMP, y =~MAXDIRECRARO, type = 'scatter', name = 'MAX_Ext_Raro_Directa', mode = 'markeds', line = list(dash = "dash", color = 'green'), inherit = FALSE,
            text = paste("<br>LIMITE MAXIMO EXTREMADAMENTE RARO DE DIRECTA"), hoverinfo = 'text',visible="legendonly")%>%
  add_trace(x = ~TIMESTAMP, y =~MAXDIREC_IMPOSIBLE  ,type = 'scatter',name = 'MAX_Fis_Imp_Directa', mode = 'markeds', line = list(dash = "dash", color = 'red'), inherit = FALSE,
            text = paste("<br>LIMITE MAXIMO FISICAMENTE IMPOSIBLE DE DIRECTA"), hoverinfo = 'text',visible="legendonly")%>%
  
  add_trace(y = ~DIFFUSE_Avg, name = 'DIFFUSE_AVG', line = list( color = 'yellow'))%>% 
  add_trace(y = ~DIFFUSE_Min, name = 'DIFFUSE_Min', visible="legendonly" )%>% 
  add_trace(y = ~DIFFUSE_Max, name = 'DIFFUSE_Max', visible="legendonly" )%>% 
  add_trace(x = ~TIMESTAMP, y =~MAXDIFFUSERARO ,type = 'scatter', name = 'MAX_Ext_Raro_Difusa', mode = 'markeds', line = list(dash = "dash", color = 'green'), inherit = FALSE,
            text = paste("<br>LIMITE MAXIMO EXTREMADAMENTE RARO DE DIFUSA"), hoverinfo = 'text',visible="legendonly")%>%
  add_trace(x = ~TIMESTAMP, y =~MAXDIFFUSE_IMPOSIBLE ,type = 'scatter',name = 'MAX_Fis_Imp_Difusa', mode = 'markeds', line = list(dash = "dash", color = 'red'), inherit = FALSE,
            text = paste("<br>LIMITE MAXIMO FISICAMENTE IMPOSIBLE DE DIFUSA"), hoverinfo = 'text',visible="legendonly")%>%
  
  add_trace(y = ~GH_CALC_Avg, name = 'GH_CALC_AVG', line = list( color = 'purple'))%>%
  add_trace(x = ~TIMESTAMP, y = -2,type = 'scatter', name = 'MIN_Ext_Raro', mode = 'markeds', line = list(dash = "dash", color = 'green'), inherit = FALSE, 
            text = paste("<br>LIMITE EXTREMADAMENTE RARO"), hoverinfo = 'text',visible="legendonly")%>%
  add_trace(x = ~TIMESTAMP, y = -4,type = 'scatter', name = 'MIN_Fis_Imp', mode = 'markeds', line = list(dash = "dash", color = 'red'), inherit = FALSE,
            text = paste("<br>LIMITE FISICAMENTE IMPOSIBLE"), hoverinfo = 'text',visible="legendonly")%>%
  
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


## GRAFICAS CON DATOS ORIGINALES 
## Graficas de dispersion entre blobal y calculada
Gdisp <- plot_ly(DataFrame, x = ~GLOBAL_Avg, y = ~GH_CALC_Avg, type = 'scatter', mode = 'markers',
                 text = paste("Fecha: ", DataFrame$TIMESTAMP,
                              "<br>GLOBAL: ", DataFrame$GLOBAL_Avg,
                              "<br>CALCULADA: ", DataFrame$GH_CALC_Avg,
                              "<br>DIRECTA: ", DataFrame$DIRECT_Avg,
                              "<br>DIFUSA: ", DataFrame$DIFFUSE_Avg,
                              "<br>Diferencia: ", DataFrame$GLOBAL_Avg-DataFrame$GH_CALC_Avg,
                              "<br>Porcentaje: ", (DataFrame$GH_CALC_Avg-DataFrame$GLOBAL_Avg)/DataFrame$GLOBAL_Avg,
                              "<br>Cociente: ", DataFrame$GLOBAL_Avg/DataFrame$GH_CALC_Avg ),
                 hoverinfo = 'text')%>%
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
         
         
         showlegend = FALSE,
         legend = list(orientation = 'v'))


#-------------------------------------------------------------------------------------------#

## GRAFICAS CON DATOS ORIGINALES 
## Grafica de Diferencia
diferencia <- DataFrame$GLOBAL_Avg-DataFrame$GH_CALC_Avg

Gdiferencia <- plot_ly(DataFrame, x = ~TIMESTAMP , y = diferencia, type = 'scatter', mode = 'line',
                       text = paste("Fecha: ", DataFrame$TIMESTAMP,
                                    "<br>GLOBAL: ", DataFrame$GLOBAL_Avg,
                                    "<br>CALCULADA: ", DataFrame$GH_CALC_Avg,
                                    "<br>DIRECTA: ", DataFrame$DIRECT_Avg,
                                    "<br>DIFUSA: ", DataFrame$DIFFUSE_Avg,
                                    "<br>Diferencia: ", DataFrame$GLOBAL_Avg-DataFrame$GH_CALC_Avg,
                                    "<br>Porcentaje: ", (DataFrame$GH_CALC_Avg-DataFrame$GLOBAL_Avg)/DataFrame$GLOBAL_Avg,
                                    "<br>Cociente: ", DataFrame$GLOBAL_Avg/DataFrame$GH_CALC_Avg ),
                       hoverinfo = 'text')%>%
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
         
         
         showlegend = FALSE,
         legend = list(orientation = 'v'))


#-------------------------------------------------------------------------------------------#

## GRAFICAS CON DATOS ORIGINALES 
## Grafica de Porcentaje
porcentaje <- (DataFrame$GH_CALC_Avg-DataFrame$GLOBAL_Avg)/DataFrame$GLOBAL_Avg

Gporcentaje <- plot_ly(DataFrame, x = ~TIMESTAMP, y = ~porcentaje, 
                       type = 'scatter', mode = 'line', 
                       text = paste("<br>FECHA: ", DataFrame$TIMESTAMP,
                                    "<br>GLOBAL: ", DataFrame$GLOBAL_Avg,
                                    "<br>CALCULADA: ", DataFrame$GH_CALC_Avg,
                                    "<br>DIRECTA: ", DataFrame$DIRECT_Avg,
                                    "<br>DIFUSA: ", DataFrame$DIFFUSE_Avg,
                                    "<br>Diferencia: ", DataFrame$GLOBAL_Avg-DataFrame$GH_CALC_Avg,
                                    "<br>PORCENTAJE: ", (DataFrame$GH_CALC_Avg-DataFrame$GLOBAL_Avg)/DataFrame$GLOBAL_Avg,
                                    "<br>COCIENTE: ", DataFrame$GLOBAL_Avg/DataFrame$GH_CALC_Avg),
                       hoverinfo = 'text')%>%
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
         
         
         showlegend = FALSE,
         legend = list(orientation = 'v'))


#-------------------------------------------------------------------------------------------#

## GRAFICAS CON DATOS ORIGINALES 
## Grafica de Cociente
cociente <- DataFrame$GLOBAL_Avg/DataFrame$GH_CALC_Avg
Gcociente <- plot_ly(DataFrame, x = ~TIMESTAMP, y = ~cociente, type = 'scatter', mode = 'line', 
                     text = paste("<br>FECHA: ", DataFrame$TIMESTAMP,
                                  "<br>GLOBAL: ", DataFrame$GLOBAL_Avg,
                                  "<br>CALCULADA: ", DataFrame$GH_CALC_Avg,
                                  "<br>DIRECTA: ", DataFrame$DIRECT_Avg,
                                  "<br>DIFUSA: ", DataFrame$DIFFUSE_Avg,
                                  "<br>Diferencia: ", DataFrame$GLOBAL_Avg-DataFrame$GH_CALC_Avg,
                                  "<br>PORCENTAJE: ", (DataFrame$GH_CALC_Avg-DataFrame$GLOBAL_Avg)/DataFrame$GLOBAL_Avg,
                                  "<br>COCIENTE: ", DataFrame$GLOBAL_Avg/DataFrame$GH_CALC_Avg),
                     hoverinfo = 'text')%>%
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
         showlegend = FALSE,
         legend = list(orientation = 'v'))



#-------------------------------------------------------------------------------------------#

## GRAFICAS CON DATOS ORIGINALES 
## Parametros 2 balance de onda corta
BalanceDeOndaCorta <- plot_ly(DataFrame, x = ~TIMESTAMP, y = ~GLOBAL_Avg, name = 'GLOBAL_AVG', type = 'scatter', mode = 'lines')%>% 
  add_trace(y = ~GLOBAL_Min, name = 'GLOBAL_Min', visible="legendonly" )%>% 
  add_trace(y = ~GLOBAL_Max, name = 'GLOBAL_Max', visible="legendonly" )%>% 
  
  add_trace(y = ~UPWARD_SW_Avg, name = 'UPWARD_SW_Avg' )%>% 
  add_trace(y = ~UPWARD_SW_Min, name = 'UPWARD_SW_Min', visible="legendonly" )%>% 
  add_trace(y = ~UPWARD_SW_Max, name = 'UPWARD_SW_Max', visible="legendonly" )%>% 
  layout(title = 'Parametros 2 balance de onda corta',
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



#######parametros 3 uvb
#-------------------------------------------------------------------------------------------#

## GRAFICAS CON DATOS ORIGINALES 
## Parametro 4 onda larga
BalanceDeOndaLarga <-  plot_ly(DataFrame,x = ~TIMESTAMP, y = ~AIR_TEMPERATURE_Avg, name = "TEMPERATURA DE AIRE", mode = "lines", type = "scatter")

valor <- list(
  tickfont = list(color = "red"),
  overlaying = "y",
  side = "right",
  title = "W/M^2" )

BalanceDeOndaLarga <- BalanceDeOndaLarga %>% add_trace( x = ~TIMESTAMP, y = ~DOWNWARD_Avg, yaxis = "y2", name = 'DOWNWARD_Avg', type = 'scatter', mode = 'lines')
BalanceDeOndaLarga <- BalanceDeOndaLarga %>%  add_trace(y = ~DOWNWARD_Min, yaxis = "y2", name = 'DOWNWARD_Min', visible="legendonly" )
BalanceDeOndaLarga <- BalanceDeOndaLarga %>%  add_trace(y = ~DOWNWARD_Max, yaxis = "y2", name = 'DOWNWARD_Max', visible="legendonly" ) 

BalanceDeOndaLarga <- BalanceDeOndaLarga %>%  add_trace(y = ~UPWARD_LW_Avg, yaxis = "y2", name = 'UPWARD_LW_Avg' )
BalanceDeOndaLarga <- BalanceDeOndaLarga %>%  add_trace(y = ~UPWARD_LW_Min, yaxis = "y2", name = 'UPWARD_LW_Min', visible="legendonly" ) 
BalanceDeOndaLarga <- BalanceDeOndaLarga %>%  add_trace(y = ~UPWARD_LW_Max, yaxis = "y2", name = 'UPWARD_LW_Max', visible="legendonly" )


BalanceDeOndaLarga <- BalanceDeOndaLarga %>%  layout(
  title = 'Parametros 4 balance de onda larga',
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
## GRAFICAS CON DATOS ORIGINALES 
## Parametros 2 balance de onda larga Temperatura en centrigrados
TemperaturaOndaLarga <- plot_ly(DataFrame, x = ~TIMESTAMP, y = ~DWIRTEMPC_Avg, name = 'DWIRTEMPC_Avg', type = 'scatter', mode = 'lines')%>% 
  
  add_trace(y = ~UWIRTEMPC_Avg, name = 'UWIRTEMPC_Avg' )%>% 
  
  layout(title = 'Parametros Temperatura onda laraga en centigrados',
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

## -------------------------------------------------------------------------------------------------------------------------------
#-------------------------------------------------------------------------------------------#
## GRAFICAS CON DATOS ORIGINALES 
## Parametros 2 balance de onda larga TERMOPILA
TermopilaOndaLarga <- plot_ly(DataFrame, x = ~TIMESTAMP, y = ~DWTERMO_Avg, name = 'DWTERMO_Avg', type = 'scatter', mode = 'lines')%>% 
  
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

## -------------------------------------------------------------------------------------------------------------------------------
## GRAFICAS CON DATOS ORIGINALES 
## Parametros Metereologicos
## AIR_TEMPERATURE_Avg-Grados cent
## RELATIVE_HUMIDITY_Avg-Porcentaje
Metereologia1 <- plot_ly(DataFrame)
Metereologia1 <- Metereologia1 %>% add_trace(x = ~TIMESTAMP, y = ~AIR_TEMPERATURE_Avg, name = "TEMPERATURA DE AIRE", mode = "lines", type = "scatter")
ay <- list(
  range=c(0,100),
  tickfont = list(color = "red"),
  overlaying = "y",
  side = "right",
  title = "<b>PORCENTAJE</b> %" )
Metereologia1 <- Metereologia1 %>% add_trace(x = ~TIMESTAMP, y = ~RELATIVE_HUMIDITY_Avg, name = "Humedad relativa",yaxis = "y2", mode = "lines", type = "scatter")
Metereologia1 <- Metereologia1 %>%layout(title = "----", yaxis2 = ay,
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
## GRAFICAS CON DATOS ORIGINALES 
## RELATIVE_HUMIDITY_Avg-Porcentaje
## PRESSURE_Avg-milibares
Metereologia2 <- plot_ly(DataFrame, x = ~TIMESTAMP, y = ~PRESSURE_Avg, name = "Presion", mode = "lines", type = "scatter")
secondY<- list(
  tickfont = list(color = "red"),
  overlaying = "y",
  side = "right",
  range=c(0,100),
  title = "<b>PORCENTAJE</b> %")
Metereologia2 <- Metereologia2 %>% add_trace( y = ~RELATIVE_HUMIDITY_Avg, name = "Humedad relativa",yaxis = "y2", mode = "lines", type = "scatter")
Metereologia2 <- Metereologia2 %>% layout(title = "----", 
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
GraficaUVB <- plot_ly(DataFrame, x = ~TIMESTAMP, y = ~UVBw_Avg, name = 'UVBw_Avg', type = 'scatter', mode = 'lines')%>% 
  add_trace(y = ~UVBw_Min, name = 'UVBw_Min', visible="legendonly" )%>% 
  add_trace(y = ~UVBw_Max, name = 'UVBw_Max', visible="legendonly" )%>%
  layout(title = 'GRAFICA UVB',
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
## GRAFICAS CON DATOS ORIGINALES 
## UVB data and SIGNAL
## UVB wats/mw 
## UVSIGNAL mvolts
UVB_SIG <- plot_ly(DataFrame, x = ~TIMESTAMP, y = ~UVBw_Avg, name = "UVB", mode = "lines", type = "scatter")
secondY <- list(
  range=c(0,1.2),
  tickfont = list(color = "red"),
  overlaying = "y",
  side = "right",
  title = "<b>MV</b> %" )
UVB_SIG <- UVB_SIG %>% add_trace(x = ~TIMESTAMP, y = ~UVSIGNAL_Avg, name = "UVBSignal",yaxis = "y2", mode = "lines", type = "scatter")
UVB_SIG <- UVB_SIG %>%layout(title = "----", yaxis2 = secondY,
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
