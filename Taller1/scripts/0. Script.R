#------------------------------------------------------------------------------#
#------------------------ CODIGO BASE - PROBLEM SET 1 -------------------------#
#------------------------------------------------------------------------------#

# El presente codigo permite:
# 1: Cambiar el directorio entre cada uno de los colaboradores del proyecto
# 2: Correr cada uno de los scripts utilizados en la resolucion del problem set 1.
# Se borra la memoria y se cargan los paquetes ------------------------------
rm(list = ls())   # Borra la memoria

# Se cargan los paquetes de interes

library(pacman)
p_load(rio,              # Importacion y exportacion sencilla de datos
       tidyverse,        # Coleccion de paquetes para datos ordenados y graficos (incluye ggplot2).
       skimr,            # Resumen compacto y descriptivo de datos
       visdat,           # Visualizacion de datos faltantes
       corrplot,         # Graficos de matrices de correlacion
       stargazer,        # Generacion de tablas en formatos de salida como LaTeX, HTML o texto
       rvest,            # Herramientas para web scraping
       readxl,           # Importar archivos Excel
       writexl,          # Exportar archivos Excel
       boot,             # Aplicacion de m?todos de remuestreo (bootstrapping)
       patchwork,        # Combinacion y organizacion de graficos
       gridExtra,        # Disposicion de graficos en cuadr?cula
       ggplot2,          # Creacion de graficos mediante gramatica de graficos
       caret,            # Evaluacion y entrenamiento de modelos predictivos
       visdat,           # Visualizar missings
       patchwork,        # Dise?o de graficos
       data.table,       # Manipulacion eficiente de grandes conjuntos de datos
       MASS,             # For post regression calculations
       dplyr)            # For post regression calculations      

getwd() #Mirar directorio
