library(tidyverse)
library(fpp3)

# Producción de cerveza ####
# Datos
recent_production <- aus_production %>% filter(year(Quarter) >= 1992)
beer_train <- recent_production %>% filter(year(Quarter) <= 2007)

autoplot(recent_production, Beer)

# Entrenamiento
beer_fit <- beer_train %>%
  model(
    `Seasonal naïve` = SNAIVE(Beer),
    `Damped Holt Winters` = ETS(Beer ~ error("M") + trend("Ad") + 
                                  season("M"))
    )

# Pronóstico
beer_fc <- beer_fit %>%
  forecast(h = 10)

beer_fc %>%
  autoplot(filter(aus_production, year(Quarter) >= 1992), level = NULL) +
  xlab("Year") + ylab("Megalitres") +
  ggtitle("Forecasts for quarterly beer production") +
  guides(colour=guide_legend(title="Forecast"))

# Precisión
accuracy(beer_fc, recent_production)

# ARIMA
recent_production %>% 
  gg_tsdisplay(difference(Beer, 4), plot_type='partial')
# Prueba de KPSS
recent_production %>%  
  features(Beer %>%  difference(4), unitroot_kpss)

recent_production %>%  
  features(Beer %>% difference(4), unitroot_ndiffs)

# Con base en la gráfica, podemos proponer los modelos:
# ARIMA(1,0,1)(2,1,1)_4
# ARIMA(0,0,0)(2,1,1)_4
# ARIMA(1,0,0)(2,1,1)_4
# ARIMA(0,0,1)(2,1,1)_4
# ARIMA(1,0,1)(2,1,0)_4
# Entrenamiento
beer_fit_arima <- beer_train %>%
  model(
    `ARIMA(1,0,1)(2,1,1)_4` = ARIMA(Beer ~ pdq(1,0,1) + PDQ(2,1,1)),
    `ARIMA(0,0,0)(2,1,1)_4` = ARIMA(Beer ~ pdq(0,0,0) + PDQ(2,1,1)),
    `ARIMA(1,0,0)(2,1,1)_4` = ARIMA(Beer ~ pdq(1,0,0) + PDQ(2,1,1)),
    `ARIMA(0,0,1)(2,1,1)_4` = ARIMA(Beer ~ pdq(0,0,1) + PDQ(2,1,1)),
    `ARIMA(1,0,1)(2,1,0)_4` = ARIMA(Beer ~ pdq(1,0,1) + PDQ(2,1,0))
  )

for (i in 1:5){
  report(beer_fit_arima %>% dplyr::select(all_of(i)))
}

# Agregar el modelo ARIMA(1,0,0)(2,1,1)_4 escogido
#  a la comparación de modelos


# Entrenamiento
beer_fit <- beer_train %>%
  model(
    `Seasonal naïve` = SNAIVE(Beer),
    `Damped Holt Winters` = ETS(Beer ~ error("M") + trend("Ad") + 
                                  season("M")),
    `ARIMA(1,0,0)(2,1,1)_4` = ARIMA(Beer ~ pdq(1,0,0) + PDQ(2,1,1))
  )

# Pronóstico
beer_fc <- beer_fit %>%
  forecast(h = 10)

beer_fc %>%
  autoplot(filter(aus_production, year(Quarter) >= 1992), level = NULL) +
  xlab("Year") + ylab("Megalitres") +
  ggtitle("Forecasts for quarterly beer production") +
  guides(colour=guide_legend(title="Forecast"))

# Precisión
accuracy(beer_fc, recent_production)
# en este caso, el modelo que tiene mayor capacidad de pronóstico
# es el de suavización exponencial


#
# US Retail employment ####
# Datos
us_retail_employment <- us_employment %>%
  filter(year(Month) >= 1990, Title == "Retail Trade")
us_retail_train <- us_retail_employment %>% 
  filter(year(Month) <=2017)

autoplot(us_retail_employment, Employed)

# ARIMA
us_retail_train %>% 
  features(Employed, unitroot_nsdiffs)

us_retail_train %>% 
  features(Employed %>% difference(12), unitroot_ndiffs)

us_retail_train %>% 
  gg_tsdisplay(difference(Employed, 12), plot_type='partial')
# Prueba de KPSS
us_retail_train %>%  
  features(Employed %>%  difference(12), unitroot_kpss)
# Para ver cuántas veces tenemos que diferenciar estacionalmente
# la serie
us_retail_train %>%  
  features(Employed, unitroot_nsdiffs)

us_retail_train %>%  
  features(Employed, unitroot_ndiffs)

us_retail_train %>% 
  gg_tsdisplay(difference(difference(Employed, 12)),
               plot_type='partial', lag_max = 36)

us_retail_train %>%  
  features(Employed %>%  difference(12) %>% difference(),
           unitroot_kpss)

# Con base en la gráfica, podemos proponer los modelos:
# ARIMA(3,1,4)(2,1,1)_12
# auto ARIMA
us_retail_fit_arima <- us_retail_train %>%
  model(
    `auto ARIMA` = ARIMA(Employed, stepwise=FALSE,
                         approximation=FALSE)
  )

report(us_retail_fit_arima)



# Ajuste de modelos
us_retail_fit <- us_retail_train %>%
  model(
    `SNaïve` = SNAIVE(Employed),
    `Decomp + SE` = decomposition_model(
      STL(Employed ~ trend(), robust = TRUE),
      ETS(season_adjust ~ error("A") + trend("N") + season("N"))
    ),
    ARIMA = ARIMA(Employed ~ pdq(2,0,1) + PDQ(0,1,1)),
    `Decomp + ARIMA` = decomposition_model(
      STL(Employed ~ trend(), robust = TRUE),
      ARIMA(season_adjust)
    )
    )

# Pronóstico
us_retail_fc <- us_retail_fit %>%
  forecast(h = 21)

us_retail_fc %>%
  autoplot(us_retail_employment, level = NULL) +
  xlab("Year") + ylab("Employed") +
  ggtitle("Forecasts for US Retail Employment") +
  guides(colour=guide_legend(title="Forecast"))

# Precisión de modelos
accuracy(us_retail_fc, us_retail_employment)



# Feminicidios en EEUU por cada 100,000 hab. ####
# Datos
feminicidios <- fpp2::wmurders
feminicidios <- feminicidios %>% 
  as_tsibble(index = zoo::index(feminicidios))

fem_train <- feminicidios %>% 
  filter(index <=1998)

autoplot(feminicidios)

feminicidios %>% 
  model(STL(value)) %>% 
  components() %>% 
  autoplot()

fem_train %>% 
  gg_tsdisplay(value, plot_type='partial')

fem_train %>% 
  features(value, unitroot_nsdiffs)

feminicidios %>% 
  features(value, unitroot_ndiffs)

fem_train %>% 
  gg_tsdisplay(difference(difference(value,1)), plot_type='partial')

fem_fit <- fem_train %>% 
  model(ARIMA023 = ARIMA(value ~ pdq(0,2,3) + PDQ(0,0,0)),
        ARIMA123 = ARIMA(value ~ pdq(1,2,3) + PDQ(0,0,0)),
        ARIMA121 = ARIMA(value ~ pdq(1,2,1) + PDQ(0,0,0)),
        ARIMA2auto = ARIMA(value ~ pdq(d = 2) + PDQ(0,0,0)),
        ARIMA = ARIMA(value ~ PDQ(0,0,0))
  )

glance(fem_fit)


report(fem_fit %>% select(5))


fem_fit <- fem_train %>% 
  model(
    NAIVE = NAIVE(value),
    ETS = ETS(value ~ error("A") + trend("Ad") +
                                  season("N")),
    ARIMA023 = ARIMA(value ~ pdq(0,2,3))
  )

fem_fcst <- fem_fit %>% 
  forecast(h = "7 years")

fem_fcst %>% 
  autoplot(feminicidios, level = NULL)

accuracy(fem_fcst,feminicidios)

# ####

eu_retail <- as_tsibble(fpp2::euretail)
eu_retail %>% autoplot(value) + ylab("Retail index") + xlab("Year") 

fit <- eu_retail %>%
  model(arima = ARIMA(value ~ pdq(0,1,1) + PDQ(0,1,1)))

fit %>% gg_tsresiduals()