#------------------------------------------------------------------------------#
#-------------------- Script 2. Filtro y seleccion de variables----------------#
#------------------------------------------------------------------------------#

# 1. Cargar base de datos  -----------------------------------------------------

setwd(paste0(wd,"/Base de datos")) #Directorio
data_webs = import(file = "Tabla_Final_GEIH.csv")

names(data_webs)                     # Mirar nombres de las variables
str(data_webs)                       # Mirar tipo de variables
unique(data_webs$dominio)            # corroborando que sea Bogota
table(data_webs$ocu)                 # La base tiene ocupados (1) y no ocupados (0)
skim(data_webs) %>% head()           # Se observa que desde un principio existen variables con muchos missing

# 2. Filtrar la base de datos ---------------------------------------------------

# Como menciona el enunciado, filtrar la base para utilizar solo los ocupados mayores de 18 anios
data_webs <- data_webs %>%
  filter(age>=18 & ## Mayores de edad
           ocu==1) ## Empleados
nrow(data_webs) 

# 3. Seleccion de las variables de interes --------------------------------------

data_webs <- data_webs %>%
  dplyr::select(
    directorio,   # Llave de vivienda
    secuencia_p,  # Llave de hogar
    orden,        # Llave de persona
    age,          # Edad
    sex,          # Sexo  
    oficio,       # Ocupacion 
    estrato1,     # Estrato
    p6050,        # Parentezco con jefe de hogar
    maxEducLevel, # Maximo nivel de eduacion  
    relab,        # Tipo de ocupacion
    cuentaPropia, # 1 si trabaja por  cuenta propia; 0 otro caso
    totalHoursWorked, # Horas trabajadas la semana pasada
    sizeFirm,         # Tam?o de la firma
    hoursWorkUsual,   # Horas semanales trabajadas usualmente en ocuapcion principal  
    y_otros_m,        # Ingreso laboral en especie (otros) - nominal mensual - ocupaci?n principal
    y_total_m,        # Ingreso total de asalariados + independientes - nominal mensual
    y_total_m_ha,     # Ingreso total de asalariados + independientes - nominal por hora
    fex_c,            # Factor de expansi?n anualizado
    formal,           # Trabajo formal de acuerdo a seguridad social (1), otro caso (0)
    informal,         # Trabajo informal de acuerdo a seguridad social (1), otro caso (0)
    p6426,            # Tiempo trabajando en la empresa
    ingtot,           # Ingreso total 
    ingtotes,         # Ingreso total imputado  
    ingtotob,         # Ingreso total observado  
    y_salary_m,       # Salario - nominal mensual - ocupaci?n principal (incluye propinas y comisiones)
    regSalud,         # Regimen de salud
    cotPension        # El trabajador cotiza a pension
    
  )%>%
  rename(
    Direccion = directorio,
    Secuencia = secuencia_p,
    Orden = orden,
    Edad = age,
    Sexo = sex,
    Profesion = oficio,
    Estrato = estrato1,
    Posicion_hogar = p6050,
    Tipo_ocupacion = relab,
    Independiente = cuentaPropia,
    Horas_trabajadas = totalHoursWorked,
    Horas_trabajadas_sem = hoursWorkUsual,
    Tamanio_empresa = sizeFirm,
    Ingreso_total = y_total_m,       # ESTE ES EL INGRESO MENSUAL
    Ingreso_hora = y_total_m_ha,
    Otros_ingresos = y_otros_m,
    Nivel_educ = maxEducLevel,
    Experiencia = p6426,
    Factor_expansion = fex_c,
    Trabajo_formal = formal,
    Trabajo_informal = informal,
    Ingreso_total_2 = ingtot,
    Ingreso_total_imputado = ingtotes,
    Ingreso_total_observado = ingtotob,
    Salario_ocupacion_principal_mensual = y_salary_m,
    Regimen_salud = regSalud,
    Cotiza_pension = cotPension,
  )

#Crear la variable dummy jefe de hogar y experiencia en anios

data_webs$dummy_jefe <- ifelse(data_webs$Posicion_hogar == 1, 1, 0)
data_webs <- data_webs %>% 
  mutate(Experiencia_anios = Experiencia/12)