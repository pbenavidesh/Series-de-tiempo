Modelos de regresión dinámica
================

  - [Introducción](#introducción)
  - [Regresión con errores ARIMA en **R** con
    `fable`](#regresión-con-errores-arima-en-r-con-fable)
      - [Ejemplo: Consumo personal e ingreso en
        EEUU](#ejemplo-consumo-personal-e-ingreso-en-eeuu)
  - [Pronóstico](#pronóstico)
      - [Continuación ejemplo: Consumo personal e ingreso en
        EEUU](#continuación-ejemplo-consumo-personal-e-ingreso-en-eeuu)

``` r
library(easypackages)
libraries("tidyverse","fpp3")
```

# Introducción

Los modelos de pronóstico de suavización exponencial y ARIMAs son
estimdos **a través de observaciones pasadas**, pero **no permiten
incluir información exógena** a la serie (otras variables).

Por ejemplo, para pronosticar la demanda de energía eléctrica, podemos
implementar un ARIMA estacional. Sin embargo, cuánta energía se consume
en los hogares se ve afectada fuertemente por la temperatura ambiental
en ese momento. Con el SARIMA solo podríamos obtener la dinámica de la
propia serie, pero tal vez sería bueno incluir también como predictora a
la temperatura.

Recordando, un modelo de regresión tiene la forma general

\[y_{t}=\beta_{0}+\beta_{1} x_{1, t}+\cdots+\beta_{k} x_{k, t}+\varepsilon_{t}\]

donde \(y_t\) es la variable que queremos pronosticar, \(x_{k, t}\) son
las variables independientes que utilizábamos para explicar a \(y_t\) y
\(\varepsilon_{t}\) es el término de error no correlacionado (ruido
blanco).

Para extender ese modelo, ahora permitiremos que el término de error sí
esté autocorrelacionado, por lo que lo sustituimos por \(\eta_t\), que
asumimos que sigue un proceso ARIMA:

\[\begin{array}{c}
y_{t}=\beta_{0}+\beta_{1} x_{1, t}+\cdots+\beta_{k} x_{k, t}+\eta_{t} \\
\left(1-\phi_{1} B\right)(1-B) \eta_{t}=\left(1+\theta_{1} B\right) \varepsilon_{t}
\end{array}\]

Este modelo tiene dos términos de error: \(eta_t\) (el error de la
regresión) y \(\varepsilon_{t}\) (el error del proceso ARIMA). Sólo
\(\varepsilon_{t}\) se asume que es ruido blanco.

**NOTA:** Cuando se quiere realizar un modelo de regresión dinámica, es
necesario que **todas las variables sean estacionarias**, por lo que
primero se debe verificar que se cumpla eso, o que se conviertan en
estacionarias. De hecho, si una variable requiere primeras diferencias,
es conveniente aplicar las primeras diferencias a todas las variables. A
esto se le conoce como un *modelo en diferencias*. A un modelo que toma
los datos originales se le conoce como *modelo en niveles*.

# Regresión con errores ARIMA en **R** con `fable`

Podemos estimar un modelo de regresion que incluya errores ARIMA a
través de la misma función utilizada antes, `ARIMA`. Si definimos el
argumento especial `pdq()` con primeras diferencias (`pdq(d=1)`), **R**
aplicará las primeras diferencias a todas las variables.

Para incluir a las variables independientes, basta con agregarlas del
lado derecho de la fórmula. P. ej:

    ARIMA(y ~ x + pdq(1,1,0))

estimará un modelo en diferencias
\(y_{t}^{\prime}=\beta_{1} x_{t}^{\prime}+\eta_{t}^{\prime}\), donde
\(\eta_{t}^{\prime}=\phi_{1} \eta_{t-1}^{\prime}+\varepsilon_{t}\) es un
error que sigue un proceso AR(1).

Adicionalmente, la función `ARIMA()` puede encontrar de manera
automática el orden del modelo, al simplemente **no especificar el
argumento especial `pdq()`**.

## Ejemplo: Consumo personal e ingreso en EEUU

Se pretende analizar y pronosticar los cambios en el consumo personal a
través de el ingreso disponible, utilizando datos de 1970 a 2016.

Cargamos los datos:

``` r
us_change <- read_csv("https://otexts.com/fpp3/extrafiles/us_change.csv") %>%
  mutate(Time = yearquarter(Time)) %>%
  as_tsibble(index = Time)
```

    ## Parsed with column specification:
    ## cols(
    ##   Time = col_date(format = ""),
    ##   Consumption = col_double(),
    ##   Income = col_double(),
    ##   Production = col_double(),
    ##   Savings = col_double(),
    ##   Unemployment = col_double()
    ## )

Graficamos ambas series:

``` r
us_change %>%
  gather("var", "value", Consumption, Income) %>%
  ggplot(aes(x = Time, y = value)) +
  geom_line() +
  facet_grid(vars(var), scales = "free_y") +
  xlab("Year") + ylab(NULL) +
  ggtitle("Quarterly changes in US consumption and personal income")
```

![](09_Dynamic_regression_files/figure-gfm/us_change%20plot-1.jpeg)<!-- -->

Las series se ven estacionarias a simple vista. Ajustamos un modelo
permitiendo errores ARIMA (calculados automáticamente):

``` r
fit <- us_change %>%
  model(ARIMA(Consumption ~ Income))
report(fit)
```

    ## Series: Consumption 
    ## Model: LM w/ ARIMA(1,0,2) errors 
    ## 
    ## Coefficients:
    ##          ar1      ma1     ma2  Income  intercept
    ##       0.6922  -0.5758  0.1984  0.2028     0.5990
    ## s.e.  0.1159   0.1301  0.0756  0.0461     0.0884
    ## 
    ## sigma^2 estimated as 0.3219:  log likelihood=-156.95
    ## AIC=325.91   AICc=326.37   BIC=345.29

El modelo ajustado tiene entonces la forma:

\[\begin{array}{l}
y_{t}=0.599+0.203 x_{t}+\eta_{t} \\
\eta_{t}=0.692 \eta_{t-1}+\varepsilon_{t}-0.576 \varepsilon_{t-1}+0.198 \varepsilon_{t-2} \\
\varepsilon_{t} \sim \mathrm{NID}(0,0.322)
\end{array}\]

Podemos obtener los estimadores de las series \(eta_t\) y
\(\varepsilon_{t}\) con la función `residuals()`, especificando el tipo
como `type = "regression"` para los errores de la regresión y `type =
"innovations"` para los errores ARIMA.

``` r
bind_rows(
  `Regression Errors` = residuals(fit, type="regression"),
  `ARIMA Errors` = residuals(fit, type="innovation"),
  .id = "type"
) %>%
  ggplot(aes(x = Time, y = .resid)) +
  geom_line() +
  facet_grid(vars(type), scales = "free_y") +
  xlab("Year") + ylab(NULL)
```

![](09_Dynamic_regression_files/figure-gfm/us_change%20residuals%20plot-1.jpeg)<!-- -->

Solo debemos asegurarnos de que los errores ARIMA sean ruido blanco:

``` r
fit %>% gg_tsresiduals()
```

![](09_Dynamic_regression_files/figure-gfm/us_change%20arima%20errors%20diagnostics-1.jpeg)<!-- -->
La prueba de Ljung-Box:

``` r
augment(fit) %>%
  features(.resid, ljung_box, dof = 5, lag = 8)
```

    ## # A tibble: 1 x 3
    ##   .model                      lb_stat lb_pvalue
    ##   <chr>                         <dbl>     <dbl>
    ## 1 ARIMA(Consumption ~ Income)    5.89     0.117

# Pronóstico

Para llevar a cabo pronósticos de modelos de regresión con errores
ARIMA, se necesita realizar el pronóstico de

  - la parte de la regresión
  - la parte de los errores ARIMA

y combinar los resultados.

Una característica con estos modelos, es que necesitamos pronósticos de
las variables independientes \(x_t\) o predictoras para poder
pronosticar nuestra variable de interés, \(y_t\). Cuando las predictoras
son conocidas en el futuro, como variables de calendario (tiempo, día de
la semana, mes, etc.), no hay mayor problema. Pero, cuando son
desconocidas, tenemos que o modelarlas por separado, o asumir valores
futuros para cada una.

## Continuación ejemplo: Consumo personal e ingreso en EEUU

Obtenemos pronósticos para los siguientes dos años (8 trimestres),
asumiendo que los cambios porcentuales en el ingreso serán iguales a el
cambio promedio porcentual de los últimos 40 años:

``` r
us_change_future <- new_data(us_change, 8) %>% mutate(Income = mean(us_change$Income))
forecast(fit, new_data = us_change_future) %>%
  autoplot(slice(us_change, (n()-80):n())) + xlab("Year") +
  ylab("Percentage change") + ggtitle("Pronóstico de regresión con errores ARIMA")
```

![](09_Dynamic_regression_files/figure-gfm/us_change%20fcst-1.jpeg)<!-- -->

Cuando vimos los modelos ARIMA no estacionales, habíamos analizado esta
misma serie. Recordando, el pronóstico resultaba:

``` r
fit_prev <- us_change %>%
  model(ARIMA(Consumption ~ PDQ(0,0,0)))

fit_prev %>% forecast(h=10) %>% autoplot(slice(us_change, (n()-80):n())) + ggtitle("Pronóstico con modelo ARIMA")
```

![](09_Dynamic_regression_files/figure-gfm/unnamed-chunk-1-1.jpeg)<!-- -->

La principal diferencia entre ambas es que, con nuestro nuevo modelo,
logramos capturar más información y, por lo tanto, los intervalos de
predicción se reducen.

**NOTA:** Los intervalos de predicción de modelos de regresión
(regresión lineal múltiple o modelos con errores ARIMA), no toman en
cuenta la incertidumbre de las predictoras. Así, el modelo *asume* que
esas predicciones son correctas. En otras palabras, los intervalos de
predicción son condicionales al cumplimiento de los valores de las
predictoras.
