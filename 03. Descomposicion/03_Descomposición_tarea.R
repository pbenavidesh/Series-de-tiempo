# Tarea Descomposición de series de tiempo


# pkgs --------------------------------------------------------------------

library(tidyverse)
library(lubridate)
library(tsibble)
library(feasts)
library(fable)
library(fpp3)
library(plotly)

# Problema 1- global_economy--------------------------------------------

global_economy

global_economy %>% 
  as_tibble() %>% 
  as_tsibble(index = Year, key = Country)

ge <- global_economy %>% 
  mutate(`GDP per capita` = GDP / Population)
ge

# Primer intento
p <- ge %>% 
  ggplot(aes(x = Year,y = `GDP per capita`, color = Country)) +
  geom_line()

# Segundo intento
p + theme(legend.position = "none")

p2 <- ge %>% 
  filter(Country %in% c("Mexico","Brazil","Canada", "Germany")) %>% 
  ggplot(aes(x = Year,y = `GDP per capita`, color = Country)) +
  geom_line()

p2

p2 + theme(legend.position = "top")

p2 + theme(legend.position = "bottom")

p2 + theme(legend.position = "left")

max_gdp <- ge %>% 
  filter(Year == 2014) %>% 
  slice_max(`GDP per capita`, n = 5) # funciona con dplyr 1.0.0

ge %>% 
  filter(Year == 2014) %>% 
  arrange(desc(`GDP per capita`)) %>% # versiones anteriores de dplyr
  slice(1:5)

max_gdp

p3 <- p + theme(legend.position = "none") +
  geom_label(data = max_gdp, aes(x = Year, y = `GDP per capita`,
                                 label = Country),
             check_overlap = TRUE)#+
  # coord_cartesian(xlim = c(2000,2017), ylim = c(50000,125000))
p3

ggplotly(p + theme(legend.position = "none"))




# Problema 4 - Plastics ---------------------------------------------------

plastico <- fma::plastics

class(plastico)

plastico

plastico <- plastico %>% 
  as_tsibble()

plastico

# i)
autoplot(plastico)

# ii)
plastico %>% 
  model(classical_decomposition(value, type = "multiplicative")) %>% 
  components()

# iv)
plastico_componentes <- plastico %>% 
  model(classical_decomposition(value, type = "multiplicative")) %>% 
  components() 
  
plastico_componentes %>% 
  ggplot(aes(x = index, y = season_adjust)) +
  geom_line()

# Gráfica de la descomposición
plastico_componentes %>% autoplot()

# v)
plastico2 <- plastico
# Cambiando manualmente un valor
plastico2$value[25] <- 896+500
# Volviendo a hacer la descomposición
plastico_componentes2 <- plastico2 %>% 
  model(classical_decomposition(value, type = "multiplicative")) %>% 
  components() 
# Gráfica de los datos desestacionalizados
plastico_componentes2 %>% 
  ggplot(aes(x = index, y = season_adjust)) +
  geom_line()

# Gráfica de la descomposición
plastico_componentes2 %>% autoplot()

# vi)
plastico3 <- plastico
plastico3$value[3] <- 776 + 500

