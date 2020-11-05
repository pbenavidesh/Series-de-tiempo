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
library(patchwork)

# data --------------------------------------------------------------------

medicamentos <- PBS %>%
  filter(ATC2 == "H02") %>%
  summarise(Cost = sum(Cost)/1e6) %>%
  transmute(
    `Sales ($million)` = Cost,
    `Log sales` = log(Cost),
    Dif_estacionales = difference(log(Cost), lag = 12),
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

# aus_total_retail --------------------------------------------------------

aus_total_retail <- aus_retail %>%
  summarise(Turnover = sum(Turnover))

autoplot(aus_total_retail) + ggtitle("Serie en niveles")

aus_total_retail %>% 
  features(Turnover, unitroot_kpss)


aus_total_retail %>% 
  autoplot(log(Turnover)) + ggtitle("Serie en logaritmos")

aus_total_retail %>% 
  features(log(Turnover), unitroot_nsdiffs)

aus_total_retail %>% 
  autoplot(log(Turnover) %>% difference(lag = 12)) + 
  ggtitle("Serie log con dif. estacionales")

aus_total_retail %>% 
  features(log(Turnover) %>% difference(lag = 12), unitroot_ndiffs)

aus_total_retail %>% 
  features(log(Turnover) %>% difference(lag = 12), unitroot_kpss)


aus_total_retail %>% 
  autoplot(log(Turnover) %>% difference(lag = 12) %>% difference(lag = 1)) + 
  ggtitle("Serie log con dif. estacionales y primeras dif.")

aus_total_retail %>% 
  features(log(Turnover) %>% difference(lag = 12) %>% difference(lag = 1), unitroot_kpss)


mex <- global_economy %>% 
  filter(Country == "Mexico") 


p1 <- mex %>% 
  autoplot(GDP) + ggtitle("Serie en niveles")

p2 <- mex %>% 
  autoplot(log(GDP)) + ggtitle("Serie en logaritmos")

mex %>% 
  features(GDP, unitroot_ndiffs)

p3 <- mex %>% 
  autoplot(GDP %>% difference(lag = 1)) + ggtitle("Serie en prim. diferencias")

mex %>% 
  features(log(GDP), unitroot_ndiffs)

p4 <- mex %>% 
  autoplot(log(GDP) %>% difference(lag = 1)) + ggtitle("Serie log. en prim. diferencias")

(p1 | p2) / (p3 | p4)  

mex %>% 
  features(GDP %>% difference(lag = 1), unitroot_kpss)

mex %>% 
  features(log(GDP) %>% difference(lag = 1), unitroot_kpss)



# ACF PACF ----------------------------------------------------------------
google_stock <- gafa_stock %>%
  filter(Symbol == "GOOG") %>%
  mutate(day = row_number()) %>%
  update_tsibble(index = day, regular = TRUE) %>% 
  mutate(diff_close = difference(Close))

google_2015 <- google_stock %>% filter(year(Date) == 2015)

google_2015 %>% ACF(Close) %>% autoplot()

google_2015 %>% PACF(Close) %>% autoplot()


us_change %>% autoplot(Consumption) +
  labs(x = "Year", y = "Quarterly percentage change", title = "US consumption")

us_change %>% 
  features(Consumption, unitroot_kpss)

us_change %>% PACF(Consumption) %>% autoplot()
# La PACF sugiere un modelo ARIMA(p = 3,d = 0,q = 0)


fit <- us_change %>%
  model(ARIMA(Consumption ~ pdq(3,0,0) + PDQ(0,0,0)))

report(fit)


us_change %>% ACF(Consumption) %>% autoplot()

fit <- us_change %>%
  model(ARIMA(Consumption ~ pdq(0,0,3) + PDQ(0,0,0)))

report(fit)

fit2 <- us_change %>%
  model(ARIMA(Consumption ~ PDQ(0,0,0)))

report(fit2)

fit3 <- us_change %>%
  model(ARIMA(Consumption ~ pdq(1,0,0) + PDQ(0,0,0)))

report(fit3)

fit4 <- us_change %>%
  model(ARIMA(Consumption ~ PDQ(0,0,0),
              stepwise = FALSE, approximation = FALSE))
report(fit4)


# Box-Jenkins -------------------------------------------------------------

elec_equip <- as_tsibble(fpp2::elecequip)

elec_dcmp <- elec_equip %>%
  model(STL(value ~ season(window="periodic"))) %>%
  components() %>%
  select(-.model) %>%
  as_tsibble()
elec_dcmp %>%
  autoplot(season_adjust)

fit <- elec_dcmp %>%
  model(
    arima310 = ARIMA(season_adjust ~ pdq(3,1,0) + PDQ(0,0,0)),
    arima410 = ARIMA(season_adjust ~ pdq(4,1,0) + PDQ(0,0,0)),
    arima210 = ARIMA(season_adjust ~ pdq(2,1,0) + PDQ(0,0,0)),
    arima311 = ARIMA(season_adjust ~ pdq(3,1,1) + PDQ(0,0,0))
    
  )

glance(fit) %>% 
  arrange(AICc)

glance(fit) %>% arrange(AICc) %>% pull(AICc)

fit %>% select(arima311) %>% report()


# agregar tiempo ----------------------------------------------------------

medicamentos %>% 
  autoplot(`Sales ($million)`)

# Con la función summarise_by_time

library(timetk)

medicamentos %>% 
  as_tibble() %>% 
  mutate(Month = as.Date(Month)) %>% 
  summarise_by_time(
    .date_var = Month,
    .by = "year",
    Sales = sum(`Sales ($million)`)
  ) %>% 
  mutate(year = year(Month)) %>% 
  as_tsibble(index = year) %>% 
  select(year, Sales)

# con index_by y summarise
med <- medicamentos %>% 
  index_by(Year = year(Month)) %>% 
  summarise(Sales = sum(`Sales ($million)`))

med2 <- med %>% 
  mutate(Sales2 = Sales *2/1.5,
         fecha = Year)

med %>% 
  ggplot(aes(x = Year, y = Sales)) + 
  geom_line() +
  geom_line(data = med2, aes(x = fecha, y = Sales2))

df %>% 
  ggplot(aes(x = desempleo, y = inflacion)) +
  geom_point()+
  geom_smooth()