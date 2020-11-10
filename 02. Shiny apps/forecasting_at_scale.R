# Ejemplo de pronósticos a escala

# pkgs --------------------------------------------------------------------

library(tidyverse)
library(tsibble)
library(feasts)
library(fable)
library(tsibbledata)
library(fpp3)

# DATA --------------------------------------------------------------------

empleo <- us_employment %>% 
  as_tsibble(key = Title) %>% 
  select(-Series_ID) %>% 
  filter_index("2001 Jan" ~ .) %>% 
  drop_na()

# plot --------------------------------------------------------------------

empleo %>% 
  ggplot(aes(x = Month, y = log(Employed), color = Title)) +
  geom_line() +
  theme(legend.position = "none")

# MODELOS -----------------------------------------------------------------

fit <- empleo %>% 
  model(
    `Ingenuo estacional`      = SNAIVE(Employed),
    `Suavización exponencial` = ETS(Employed),
    ARIMA                     = ARIMA(Employed)
  )

error_train <- accuracy(fit)

error_train %>% view()

fc <- fit %>% forecast(h = "2 years")

fc %>% 
  filter(Title %in% c("Construction", "Retail Trade", "Manufacturing", "Nondurable Goods")) %>% 
  autoplot(empleo %>% filter_index("2018 Jan" ~ .), level = NULL)
