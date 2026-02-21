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