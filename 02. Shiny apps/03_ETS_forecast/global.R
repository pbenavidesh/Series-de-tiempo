# Configuración global
# Cálculos previos

library(shiny)
library(shinythemes)
library(tidyverse)
library(tsibble)
library(feasts)
library(fable)
library(tsibbledata)
library(fpp3)

empleo <- us_employment

economia <- global_economy %>% 
  pivot_longer(cols = c(GDP:Population),
               names_to = "Indicador", values_to = "Valor")

paises <- key_data(global_economy) %>% pull(Country)

