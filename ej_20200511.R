library(tidyverse)
library(fpp3)

# Ejercicio 1: viajeros internacionales en Australia ####
#Datos
turistas <- fpp2::austa
turistas <- turistas %>% 
  as_tsibble(index = zoo::index(turistas))
# Gráfica de tiempo
autoplot(turistas)
# Descomposición para revisar si tiene estacionalidad
turistas %>% 
  model(STL(value)) %>% 
  components() %>% 
  autoplot() # no muestra un componente estacional
# Datos de entrenamiento
tur_train <- turistas %>% 
  filter(index <=2010)
# Revisar cuántas veces se tiene que diferenciar la serie
tur_train %>% 
  features(value, unitroot_ndiffs) # primeras diferencias es sufic.
# Para graficar la ACF y PACF de la serie en diferencias
tur_train %>% 
  gg_tsdisplay(difference(value), plot_type='partial')

tur_train %>% 
  features(difference(value),ljung_box,lag = 10,dof = 0)
# Ajuste y entrenamiento de modelos
tur_fit <- tur_train %>% 
  model(Drift = NAIVE(value ~ drift()),
        ETS = ETS(value ~ error("A") + trend("A") +
                    season("N")),
        `ETS amortiguado` = ETS(value ~ error("A") + trend("Ad") +
                                  season("N")),
        ARIMA010 = ARIMA(value ~ pdq(0,1,0) + PDQ(0,0,0)),
        ARIMAauto = ARIMA(value ~ PDQ(0,0,0), stepwise = F, 
                          approximation = F)
        )
# Revisar el ajuste de los modelos
glance(tur_fit)
# Ver específicamente el modelo de Drift
report(tur_fit %>% select(Drift))
# Ver específicamente el modelo de ARIMA automático
report(tur_fit %>% select(ARIMAauto))
# Pronóstico
tur_fcst <- tur_fit %>% 
  forecast(h = "5 years")
# Gráfica de los pronósticos
tur_fcst %>% 
  # filter(.model %in% c("Drift","ETS")) %>% 
  autoplot(turistas, level = NULL) + 
  coord_cartesian(xlim = c(2010,2015),ylim = c(5,7))

# tur_fcst %>% 
#   filter(.model %in% c("Drift","ETS")) %>%
#   autoplot(turistas, level = NULL)

# Desempeño de los modelos
accuracy(tur_fcst,turistas)
# Gráfica del mejor modelo, con intervalos de predicción
tur_fcst %>% 
  filter(.model == "Drift") %>%
  autoplot(turistas)

turistas %>% 
  model(ARIMA = ARIMA(value ~ PDQ(0,0,0)),
        Drift = RW(value ~ drift()),
        ETS = ETS(value ~ error("A") + trend("A") + season("N"))
        ) %>% 
  forecast(h = "5 years") %>% 
  autoplot(turistas, level = NULL) + 
  coord_cartesian(xlim = c(2010,2020), ylim = c(5,8))

turistas %>% 
  model(ARIMA = ARIMA(value ~ PDQ(0,0,0))
  ) %>% report()

# Ejercicio 2: Generación neta de energía en EEUU ####
# Datos
us_elec <- fpp2::usmelec
class(us_elec)
us_elec <- us_elec %>% 
  as_tsibble(index = zoo::index(us_elec))
class(us_elec)
# Gráfica
autoplot(us_elec)
# Gráfica de los datos en logaritmos
autoplot(us_elec,log(value))
# Revisar qué lambda utilizar par transformación de box-cox
(lambda <- us_elec %>%
    features(value, features = guerrero) %>%
    pull(lambda_guerrero))
# Gráfica de los datos con transf. box-cox
autoplot(us_elec,box_cox(value, lambda = lambda))
# Descomposición de la serie transformada
us_elec %>% 
  model(STL(box_cox(value,lambda = lambda))) %>% 
  components() %>% 
  autoplot()
# Datos entrenamiento
us_elec_train <- us_elec %>% 
  slice(1:(n()-60))
# Revisar las diferencias estacionales necesarias
us_elec_train %>% 
  features(value %>% box_cox(lambda), unitroot_nsdiffs)
# Revisar si requiere diferencias no estacionales
us_elec_train %>% 
  features(value %>% box_cox(lambda) %>% difference(12),
           unitroot_ndiffs)
# Para graficar la ACF y PACF de la serie transf. en diferencias
us_elec_train %>% 
  gg_tsdisplay(value %>% box_cox(lambda) %>% difference(12), 
               plot_type = "partial", lag_max = 48)
us_elec_train %>% 
  gg_tsdisplay(value %>% box_cox(lambda), 
               plot_type = "season")
# Ajuste de los modelos
us_elec_fit <- us_elec_train %>% 
  model(SNAIVE = SNAIVE(box_cox(value, lambda = lambda)),
        ETS = ETS(value ~ error("M") + trend("Ad") + season("M")),
        ARIMA = ARIMA(box_cox(value, lambda) ~ pdq(0:3,0,0:5) + 
                        PDQ(1:3,1,0:1))
        )
# Revisar el orden del modelo ARIMA seleccionado
report(us_elec_fit %>% select(ARIMA))
# Diagnóstico de residuos para los tres modelos
us_elec_fit %>% 
  select(SNAIVE) %>% 
  gg_tsresiduals() + ggtitle("Diagnóstico de residuos de SNAIVE")

us_elec_fit %>% 
  select(ETS) %>% 
  gg_tsresiduals() + ggtitle("Diagnóstico de residuos de ETS")

us_elec_fit %>% 
  select(ARIMA) %>% 
  gg_tsresiduals() + ggtitle("Diagnóstico de residuos de ARIMA")

us_elec_fit %>% augment() %>% 
  features(.resid, ljung_box, lag = 24, dof = 6)

# for (i in 1:3){
#   us_elec_fit %>% 
#     select(i) %>% 
#     gg_tsresiduals() + ggtitle(
#       "Diagnóstico de residuos del modelo")
# }


us_elec_fcst <- us_elec_fit %>% 
  forecast(h = "5 years")

us_elec_fcst %>% 
  autoplot(us_elec, level = NULL)

us_elec_fcst %>% 
  autoplot(us_elec, level = NULL) + 
  tidyquant::coord_x_date(xlim = c("2008-01-01","2014-01-01"))

accuracy(us_elec_fcst,us_elec)

us_elec_fcst %>%
  filter(.model == "ETS") %>% 
  autoplot(us_elec)+ 
  tidyquant::coord_x_date(xlim = c("2008-01-01","2014-01-01"))

