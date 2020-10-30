# Series de tiempo
# Series estacionarias, transformaciones matemáticas y diferenciación
# Pablo Benavides-Herrera
# 2020-10-30

# pkgs --------------------------------------------------------------------

library(tidyverse)
library(tsibble)
library(feasts)
library(fable)
library(tsibbledata)
library(fpp3)

# data --------------------------------------------------------------------

medicamentos <- PBS %>%
  filter(ATC2 == "H02") %>%
  summarise(Cost = sum(Cost)/1e6) %>%
  transmute(
    `Sales ($million)` = Cost,
    `Log sales` = log(Cost),
    Dif_estacionales = difference(log(Cost), 12),
    Dif_estacionales_y_primeras = log(Cost) %>% difference(lag = 12) %>% difference(lag = 1)
  ) 

# medicamentos %>% 
#   mutate(prim_diferencias = difference(Cost, lag = 1),
#          dif_estacionales = difference(Cost, lag = 12),
#          dif_estac_y_primeras = Cost %>% difference(lag = 12) %>% difference(lag = 1),
#          prim_dif_y_estacionales = Cost %>% difference(lag = 1) %>% difference(lag = 12)) %>% view()

medicamentos

medicamentos %>% 
  features(`Log sales`, unitroot_kpss)
# Log sales no es estacionaria porque el p-value es menor a alpha (0.05)

medicamentos %>% 
  features(Dif_estacionales, unitroot_kpss)
# La serie con únicamente diferencias estacionales parece no ser estacionaria.

medicamentos %>% 
  features(Dif_estacionales_y_primeras, unitroot_kpss)
# Esta serie ya es estacionaria, de acuerdo a la prueba KPSS

medicamentos %>% 
  features(`Log sales`, unitroot_nsdiffs)
# Esta prueba dice que se requiere una diferencia estacional

medicamentos %>% 
  features(`Log sales` %>% difference(lag = 12), unitroot_nsdiffs)



# Vamos a validar si se requieren diferencias estacionales y primeras diferencias
medicamentos %>% 
  features(`Log sales` %>% difference(lag = 12), unitroot_ndiffs)
# Dice que efectivamente requiere diferencias no estacionales también

medicamentos %>% 
  features(`Log sales` %>% difference(lag = 12) %>% difference(lag = 1), unitroot_ndiffs)

aus_total_retail <- aus_retail %>%
  summarise(Turnover = sum(Turnover))
autoplot(aus_total_retail) + ggtitle("Serie en niveles")

aus_total_retail %>% 
  autoplot(log(Turnover)) + ggtitle("Serie en logaritmos")

aus_total_retail %>% 
  autoplot(log(Turnover) %>% difference(lag = 12)) + 
  ggtitle("Serie log con dif. estacionales")

aus_total_retail %>% 
  features(log(Turnover) %>% difference(lag = 12), unitroot_kpss)

aus_total_retail %>% 
  autoplot(log(Turnover) %>% difference(lag = 12) %>% difference(lag = 1)) + 
  ggtitle("Serie log con dif. estacionales")


mex <- global_economy %>% 
  filter(Country == "Mexico") 
library(patchwork)
p1 <- mex %>% 
  autoplot(GDP) + ggtitle("Serie en niveles")

p2 <- mex %>% 
  autoplot(log(GDP)) + ggtitle("Serie en logaritmos")

mex %>% 
  features(GDP, unitroot_ndiffs)

p3 <- mex %>% 
  autoplot(GDP %>% difference(lag = 1)) + ggtitle("Serie en prim. diferencias")

p4 <- mex %>% 
  autoplot(log(GDP) %>% difference(lag = 1)) + ggtitle("Serie log. en prim. diferencias")

(p1 | p2) / (p3 | p4)  

mex %>% 
  features(log(GDP) %>% difference(lag = 1), unitroot_ndiffs)
