# Series de tiempo
# Script para instalar las paqueterías necesarias
# 
# 
# NOTA: Puede tardar varios minutos en concluir la instalación.
# 
# Solo es necesario correr el documento completo una vez.

# paqueterías necesarias
pkgs <- c("vctrs", "tidyverse", "lubridate", "easypackages",
          "tsibble", "fable", "feasts", "tsibbledata", "fpp2", "fpp3",
          "plotly", "gganimate", "png", "patchwork", "gifski",
          "tidymodels", "tidyquant", "learnr", "gapminder", "nycflights13",
          "timetk", "seasonal", "modeltime", "prophet", "remotes",  
          "shiny", "shinythemes", "shinydashboard", "shinyWidgets", 
          "colourpicker", "GGally", "ggthemes", "moderndive" 
          )


install.packages(pkgs)


# instalar desde github estas paquetería
remotes::install_github("mitchelloharawild/fable.prophet")
devtools::install_github("FinYang/tsdl")

pkgs <- c(pkgs,"fable.prophet","tsdl")

# comprobar si están todas las paqueterías instaladas (debe salir TRUE para 
# cada una) 
instalados <- pkgs %in% installed.packages()
names(instalados) <- pkgs
instalados

# Filtrar los no instalados
instalados[FALSE]

# Si alguna paquetería aparece como no instalada, pueden intentar instalarla 
# individualmente con install.packages("nombre")
