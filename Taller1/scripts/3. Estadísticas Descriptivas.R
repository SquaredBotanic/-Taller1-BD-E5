
#------------------------------------------------------------------------------#
#--------------Script 3. Estadisticas descriptivas ----------------------------#
#------------------------------------------------------------------------------#

#1. Cargar base de datos -------------------------------------------------------

setwd(paste0(wd,"/Base de datos"))
data_webs <- import(file = "base_final.rds")
data_webs <- as.data.frame(data_webs)
names(data_webs)

#2. Grafico de correlacion de las variables continuas -------------------------

subset_data <- data_webs[, c("log_ing_m_win", "Edad_win", 
                             "Mujer", "dummy_jefe", 
                             "Trabajo_informal", "Horas_trabajadas_win", 
                             "Experiencia_win", "Independiente")]

#3. Calcular la matriz de correlación para esas variables
setwd(paste0(wd,"/Graficas"))
png("graf_corr.png") # Formato grafica
cor_matrix <- cor(subset_data, use="complete.obs")
print(cor_matrix)
corrplot(cor_matrix,
         tl.cex = 0.8,               # Tamaño de los labels
         tl.col = "black",           # Color de los labels (negro en este caso)
         tl.srt = 90,                # Rotar las etiquetas 45 grados
         addCoef.col = "black",      # Color de los coeficientes numéricos
         number.cex = 0.7)           # Tamaño de los números que muestran los coeficientes
cor_matrix
dev.off() # Cierra la grafica

