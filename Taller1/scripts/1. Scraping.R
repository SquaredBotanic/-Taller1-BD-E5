
#------------------------------------------------------------------------------#
#----------------------------- Script 1. Scraping -----------------------------#
#------------------------------------------------------------------------------#

# El presente codigo carga la informacion de la Gran Encuesta Integrada de Hogares 
# (GEIH) del repositorio del docente de la materia Ignacio Sarmiento 

# 0. Se define el directorio de extraccion de informacion ----------------------
url <- 'https://ignaciomsarmiento.github.io/GEIH2018_sample/'
browseURL(url)     # Podemos ingresar a la pagina y observar como se encuentra la pagina
vignette("rvest")  # Se carga la explicacion de "rvest"

# 1. Extraccion y manejo de la base de datos -----------------------------------
my_html = read_html(url)  # Lectura del enlace

# 1.1. Se extrae la informacion -------------------------------------------------
# Extraemos una lista que contenga el atributo href de cada uno de los nodos <a> de en los elementos <li>
links <- my_html%>%
  html_elements("li")%>%
  html_nodes("a")%>%
  html_attr("href")
print(links)

# Observamos que esta lista contiene solo las extensiones finales y no el link completo. Ademas es necesario
# omitir el primer elemento de la lista correpondiente al index. Por tanto es necesario completar el link

links <- paste0('https://ignaciomsarmiento.github.io/GEIH2018_sample/', links[-1])