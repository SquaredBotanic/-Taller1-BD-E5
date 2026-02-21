
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

#5. Graficas de distribucion generales ----------------------------------------

#i. Ingreso MENSUAL
media_ingreso <- mean(data_webs$Ingreso_total_imp_win, na.rm = TRUE)
density_plot_ing <- ggplot(data = data_webs, aes(x = Ingreso_total_imp_win)) +
  geom_density(fill = "grey", alpha = 0.5) +  # Rellena la curva de densidad
  labs(title = "Gráfico de Densidad Ingreso Mensual", x = "Ingreso Mensual", y = "Densidad") +
  geom_vline(aes(xintercept = media_ingreso), 
             color = "red", linetype = "dashed", size = 1) +
  theme_minimal() +
  theme(
    plot.title = element_text(size = 10, face = "bold")  # Cambia el tamaño y estilo del título
  )
density_plot_ing


# ii. Edad
media_edad <- mean(data_webs$Edad_win, na.rm = TRUE)
density_plot_edad <- ggplot(data = data_webs, aes(x = Edad_win)) +
  geom_density(fill = "grey", alpha = 0.5) +  # Rellena la curva de densidad
  labs(title = "Gráfico de Densidad Edad", x = "Edad", y = "Densidad") +
  geom_vline(aes(xintercept = media_edad), 
             color = "red", linetype = "dashed", size = 1) +
  theme_minimal() +
  theme(
    plot.title = element_text(size = 10, face = "bold")  # Cambia el tamaño y estilo del título
  )
density_plot_edad

#iii. Horas trabajadas
media_h <- mean(data_webs$Horas_trabajadas_win, na.rm = TRUE)
density_plot_h <- ggplot(data = data_webs, aes(x = Horas_trabajadas_win)) +
  geom_density(fill = "grey", alpha = 0.5) +  # Rellena la curva de densidad
  labs(title = "Gráfico de Densidad Horas trabajadas", x = "Horas trabajadas", y = "Densidad") +
  geom_vline(aes(xintercept = media_h), 
             color = "red", linetype = "dashed", size = 1) +
  theme_minimal() +
  theme(
    plot.title = element_text(size = 10, face = "bold")  # Cambia el tamaño y estilo del título
  )
density_plot_h
