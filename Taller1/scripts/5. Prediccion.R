#------------------------------------------------------------------------------#
#--------------Script 5.Prediccion  -------------------------------------------#
#------------------------------------------------------------------------------#

# Inicializacion de la base ---------------------------------

setwd(paste0(wd,"/Base de datos")) #Directorio
nlsy <- import(file = "base_final.rds")

# Verificar que se cargó correctamente
# Asegúrate de que log_ing_m_win existe (creado en scripts anteriores)
summary(nlsy$log_ing_m_win) 

# -------------------------------------------------------------
# 1. PARTICION DE LA MUESTRA
# -------------------------------------------------------------
set.seed(40503)

# IMPORTANTE: No llamar a la variable "sample", usamos "in_train"
in_train <- sample(c(TRUE, FALSE), nrow(nlsy), replace=TRUE, prob=c(0.7,0.3))

train <- nlsy[in_train, ] 
test  <- nlsy[!in_train, ] 

dim(train)
dim(test)

# -------------------------------------------------------------
# 2. DEFINICION Y ENTRENAMIENTO DE MODELOS
# -------------------------------------------------------------
# CAMBIO GLOBAL: log_ing_m_win (Mensual) en lugar de log_ing_h_win

# Modelos simples
m1 <- lm(log_ing_m_win ~ Edad + Edad2, data = train)
m2 <- lm(log_ing_m_win ~ Sexo, data = train)
m3 <- lm(log_ing_m_win ~ Sexo + Edad + Edad2, data = train)

# Modelo complejo con controles
m3_1 <- lm(log_ing_m_win ~ Edad_win + Edad2 + Mujer + estrato_factor + dummy_jefe + 
             edu_factor + tfirma_factor + Trabajo_informal + oficio_factor + 
             Independiente + Horas_trabajadas_win + Experiencia_win, data = train)

# Modelos polinomiales (Asegurarse de usar variables continuas puras para poly)
# Nota: Experiencia_win o Experiencia (original) según prefieras, usaremos _win por consistencia

m4 <- lm(log_ing_m_win ~ poly(Edad,4,raw=TRUE)*Sexo, data = train) # Reduje grado a 4 para evitar overfitting extremo

m5 <- lm(log_ing_m_win ~ poly(Edad,4,raw=TRUE):poly(Experiencia_win,4,raw=TRUE) + Sexo, data = train)

m6 <- lm(log_ing_m_win ~ poly(Edad,4,raw=TRUE):poly(Experiencia_win,4,raw=TRUE) + 
           poly(Experiencia_win,4,raw=TRUE) + Nivel_educ, data = train)

m7 <- lm(log_ing_m_win ~ poly(Edad,4,raw=TRUE):poly(Experiencia_win,4,raw=TRUE) + 
           poly(Experiencia_win,4,raw=TRUE) + 
           poly(Experiencia_win,4,raw=TRUE):poly(Nivel_educ,raw=TRUE), data = train)

# m8: Modelo muy complejo interactuando polinomios
m8 <- lm(log_ing_m_win ~ poly(Edad,4,raw=TRUE):poly(Experiencia_win,4,raw=TRUE) + 
           poly(Experiencia_win,4,raw=TRUE) + 
           poly(Experiencia_win,4,raw=TRUE):poly(Nivel_educ,raw=TRUE) + 
           Independiente + Trabajo_informal, data = train)

summary(m8)

# -------------------------------------------------------------
# 3. PREDICCIONES (CORRECCION DE NIVELES DE FACTOR)
# -------------------------------------------------------------

# FIX: Limpiar niveles nuevos en TEST que no estaban en TRAIN para evitar errores
# Esto es crucial para m3_1 que tiene "oficio_factor"
variables_factor <- c("oficio_factor", "estrato_factor", "edu_factor", "tfirma_factor")

# Loop para filtrar filas con categorías desconocidas en variables categóricas
for(var in variables_factor){
  if(var %in% names(train)){
    known_levels <- unique(train[[var]])
    test <- test[test[[var]] %in% known_levels, ]
  }
}

# Ahora si, predecir
test$mp1 <- predict(m1, newdata = test)
test$mp2 <- predict(m2, newdata = test)
test$mp3 <- predict(m3, newdata = test)
test$mp3_1 <- predict(m3_1, newdata = test)
test$mp4 <- predict(m4, newdata = test)
test$mp5 <- predict(m5, newdata = test)
test$mp6 <- predict(m6, newdata = test)
test$mp7 <- predict(m7, newdata = test)
test$mp8 <- predict(m8, newdata = test)

# -------------------------------------------------------------
# 4. EVALUACION DE RMSE
# -------------------------------------------------------------

# Función auxiliar para calcular RMSE
calc_rmse <- function(actual, predicted) { sqrt(mean((actual - predicted)^2, na.rm = TRUE)) }

# CAMBIO: Usar log_ing_m_win para comparar
rmse_vals <- c(
  calc_rmse(test$log_ing_m_win, test$mp1),
  calc_rmse(test$log_ing_m_win, test$mp2),
  calc_rmse(test$log_ing_m_win, test$mp3),
  calc_rmse(test$log_ing_m_win, test$mp3_1),
  calc_rmse(test$log_ing_m_win, test$mp4),
  calc_rmse(test$log_ing_m_win, test$mp5),
  calc_rmse(test$log_ing_m_win, test$mp6),
  calc_rmse(test$log_ing_m_win, test$mp7),
  calc_rmse(test$log_ing_m_win, test$mp8)
)

# Numero de predictores (aprox)
num_predictores <- c(
  length(coef(m1))-1, length(coef(m2))-1, length(coef(m3))-1, length(coef(m3_1))-1,
  length(coef(m4))-1, length(coef(m5))-1, length(coef(m6))-1, length(coef(m7))-1, length(coef(m8))-1
)

resultados <- data.frame(
  Modelo = c("m1", "m2", "m3", "m3.1", "m4", "m5", "m6", "m7", "m8"),
  RMSE = round(rmse_vals, 4),
  Num_Predictores = num_predictores
)

print(resultados)

# Exportar a LaTeX
# install.packages("xtable")
library(xtable)
tabla_latex <- xtable(resultados)
print(tabla_latex, type = "latex", file = "tabla_resultados_prediccion.tex", include.rownames = FALSE)

# -------------------------------------------------------------
# 5. ANALISIS DE RESIDUALES (Outliers y Leverage)
# -------------------------------------------------------------
# Re-entrenamos el modelo m3_1 (el más completo lineal) con TODA la data
# CAMBIO: log_ing_m_win
m3_full <- lm(log_ing_m_win ~ Edad_win + Edad2 + Mujer + estrato_factor + dummy_jefe + 
                edu_factor + tfirma_factor + Trabajo_informal + Independiente + 
                Horas_trabajadas_win + Experiencia_win, data = nlsy)

# Calculamos métricas sobre nlsy
nlsy <- nlsy %>%
  mutate(
    leverage = hatvalues(m3_full),
    residuals = residuals(m3_full),
    std_residuals = studres(m3_full) # Requiere package MASS
  )

# Definir cutoff
p <- mean(nlsy$leverage, na.rm=T)
cutt <- 3 * p

# Identificar outliers
nlsy <- nlsy %>%
  mutate(outlier = ifelse(leverage > cutt & abs(residuals) > 3, "Outlier", "Not Outlier"))

# Graficar Leverage vs Residuals
plot_lev <- ggplot(nlsy, aes(x = residuals, y = leverage)) +
  geom_point(aes(color = outlier), size = 2) + 
  theme_bw() + 
  labs(title = "Leverage vs Residuals (Ingreso Mensual)") + 
  scale_color_manual(values = c("Not Outlier" = "black", "Outlier" = "red"))

setwd(paste0(wd,"/Graficas"))
png("Leverage_residuals.png") 
plot_lev
dev.off() 

# -------------------------------------------------------------
# 6. VALIDACION CRUZADA (LOOCV) - PARALELIZADA
# -------------------------------------------------------------

# Definir fórmulas (CAMBIO: log_ing_m_win)
formula_m6 <- log_ing_m_win ~ poly(Edad,4,raw=TRUE):poly(Experiencia_win,4,raw=TRUE)+ poly(Experiencia_win,4,raw=TRUE)+ Nivel_educ
formula_m3 <- log_ing_m_win ~ Edad_win + Edad2 + Mujer + estrato_factor + dummy_jefe + edu_factor + tfirma_factor + Trabajo_informal + oficio_factor + Independiente + Horas_trabajadas_win + Experiencia_win

# Muestra reducida para prueba (quitar si vas a correrlo con todo)
# LOOCV es muy pesado computacionalmente. Si tienes +10k observaciones, usa K-Fold (method="cv", number=10)
set.seed(123)
nlsy_sample <- nlsy[sample(nrow(nlsy), 2000), ] # Probamos con 2000 obs para rapidez

# Configuración de control para LOOCV
ctrl <- trainControl(method = "LOOCV", allowParallel = TRUE) # Cambiar "LOOCV" por "cv" y number=10 si es muy lento

# --- INICIO DEL CLUSTER ---
library(doParallel)
library(caret)

cores <- parallel::detectCores() - 1
cluster <- parallel::makeCluster(cores)
registerDoParallel(cluster)

message("Entrenando Modelo Polinomial (M6)...")
modelo_loocv_1 <- caret::train(formula_m6, data = nlsy_sample, method = 'lm', trControl = ctrl)

message("Entrenando Modelo Completo (M3_1)...")
modelo_loocv_3 <- caret::train(formula_m3, data = nlsy_sample, method = 'lm', trControl = ctrl)

# --- FIN DEL CLUSTER ---
stopCluster(cluster)
registerDoSEQ() # Volver a modo secuencial

# Resultados
print("Resultados LOOCV:")
print(modelo_loocv_1)
print(modelo_loocv_3)

# Comparar RMSE
rmse_loocv_1 <- modelo_loocv_1$results$RMSE
rmse_loocv_3 <- modelo_loocv_3$results$RMSE

cat("RMSE Modelo M6 (Polinomial):", rmse_loocv_1, "\n")
cat("RMSE Modelo M3 (Completo):", rmse_loocv_3, "\n")
