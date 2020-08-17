# Series de tiempo
# Script para instalar las paqueterías necesarias
# 
# 
# NOTA: Puede tardar varios minutos en concluir la instalación.
# 
# Solo es necesario correr el documento completo.

# paqueterías necesarias
pkgs <- c("tidyverse", "lubridate", "easypackages",
          "tsibble", "fable", "feasts", "tsibbledata", "fpp2", "fpp3",
          "plotly", "gganimate", "png", "patchwork",
          "tidymodels", "tidyquant", "learnr", "gapminder", "nycflights13",
          "timetk", "seasonal", "modeltime", "prophet", "remotes",  
          "shiny", "shinythemes", "shinydashboard", "shinyWidgets", 
          "colourpicker", "GGally", "ggthemes", "moderndive" 
          )

# comprobar si están instaladas, de lo contrario instalarlas
for (i in seq_along(pkgs)) {
  if (! require(pkgs[i])) install.packages(pkgs[i])
  
}

# instalar desde github estas paquetería
if (! require(fable.prophet)) remotes::install_github("mitchelloharawild/fable.prophet")
if (! require(tsdl)) devtools::install_github("FinYang/tsdl")

# comprobar si están todas las paqueterías instaladas (debe salir TRUE para 
# cada una, como esto:)
# [1] TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE
# [16] TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE
pkgs %in% installed.packages()
