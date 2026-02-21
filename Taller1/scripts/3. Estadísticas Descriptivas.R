
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


#4. Tablas de variables principales POR SEPARADO -------------------------------

# Definir variables de interés (Excluyendo "Mujer" ya que filtramos por ella)
des_vars <- c("Ingreso_total_imp_win", "Edad_win", 
              "Trabajo_informal", "Horas_trabajadas_win", 
              "Experiencia_win", "Independiente", "dummy_jefe")

nuevos_nombres <- c("Ingreso Mensual", "Edad", 
                    "Trabajo Informal", "Horas Trabajadas", 
                    "Experiencia", "Independiente", "Jefe de hogar")

# Crear subconjuntos
data_hombres <- subset(data_webs, Mujer == 0)
data_mujeres <- subset(data_webs, Mujer == 1)


# --- TABLA 1: HOMBRES ---
stargazer(data_hombres[des_vars], 
          type = "text", 
          title = "Estadísticas Descriptivas - Hombres", 
          digits = 1, 
          out = "Tabla_Est_descriptivas_Hombres.txt",
          covariate.labels = nuevos_nombres)

# Codigo latex Hombres
stargazer(data_hombres[des_vars], 
          type = "latex",
          title = "Estadísticas Descriptivas - Hombres", 
          digits = 1,
          covariate.labels = nuevos_nombres,
          out = "Tabla_Est_descriptivas_Hombres.tex")


# --- TABLA 2: MUJERES ---
stargazer(data_mujeres[des_vars], 
          type = "text", 
          title = "Estadísticas Descriptivas - Mujeres", 
          digits = 1, 
          out = "Tabla_Est_descriptivas_Mujeres.txt",
          covariate.labels = nuevos_nombres)

# Codigo latex Mujeres
stargazer(data_mujeres[des_vars], 
          type = "latex",
          title = "Estadísticas Descriptivas - Mujeres", 
          digits = 1,
          covariate.labels = nuevos_nombres,
          out = "Tabla_Est_descriptivas_Mujeres.tex")
