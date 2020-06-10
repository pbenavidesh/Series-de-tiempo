Características de las series de tiempo
================

  - [Características estadísticas
    básicas](#características-estadísticas-básicas)
  - [Características de la función de autocorrelación,
    ACF](#características-de-la-función-de-autocorrelación-acf)
  - [Características STL](#características-stl)

En el pasado, ya hemos revisado varias características de las series de
tiempo. La paquetería `feasts` *(**FE**atures **A**nd **S**tatistics
from **T**ime **S**eries)* incluye varias funciones para calcular varias
características. Cualquier tipo de resumen que le podamos realizar a una
serie de tiempo se consideraría una característica.

### Características estadísticas básicas

Algunas de las más sencillas son la media, mínimo, máximo, … y las
podemos calcular utilizando la función `features()`. Tomemos de ejemplo
los datos del turismo en Australia, `tourism`.

``` r
if (!require("easypackages")) install.packages("easypackages")
library("easypackages")
packages("tidyverse","lubridate", "patchwork", "fpp2","fpp3","scales")
glimpse(tourism)
```

    ## Rows: 24,320
    ## Columns: 5
    ## Key: Region, State, Purpose [304]
    ## $ Quarter <qtr> 1998 Q1, 1998 Q2, 1998 Q3, 1998 Q4, 1999 Q1, 1999 Q2, 1999 ...
    ## $ Region  <chr> "Adelaide", "Adelaide", "Adelaide", "Adelaide", "Adelaide",...
    ## $ State   <chr> "South Australia", "South Australia", "South Australia", "S...
    ## $ Purpose <chr> "Business", "Business", "Business", "Business", "Business",...
    ## $ Trips   <dbl> 135.0777, 109.9873, 166.0347, 127.1605, 137.4485, 199.9126,...

``` r
tourism %>% features(Trips, mean)
```

    ## # A tibble: 304 x 4
    ##    Region         State              Purpose      V1
    ##    <chr>          <chr>              <chr>     <dbl>
    ##  1 Adelaide       South Australia    Business 156.  
    ##  2 Adelaide       South Australia    Holiday  157.  
    ##  3 Adelaide       South Australia    Other     56.6 
    ##  4 Adelaide       South Australia    Visiting 205.  
    ##  5 Adelaide Hills South Australia    Business   2.66
    ##  6 Adelaide Hills South Australia    Holiday   10.5 
    ##  7 Adelaide Hills South Australia    Other      1.40
    ##  8 Adelaide Hills South Australia    Visiting  14.2 
    ##  9 Alice Springs  Northern Territory Business  14.6 
    ## 10 Alice Springs  Northern Territory Holiday   31.9 
    ## # ... with 294 more rows

Calculamos la característica de la media y se muestra en la columna
`V1`. Si queremos calcular varias características y nombrarlas, lo
podemos hacer así:

``` r
tourism %>% features(Trips, list(media = mean, 
                                 min = min,
                                 max = max)) %>% arrange(media)
```

    ## # A tibble: 304 x 6
    ##    Region          State              Purpose  media   min   max
    ##    <chr>           <chr>              <chr>    <dbl> <dbl> <dbl>
    ##  1 Kangaroo Island South Australia    Other    0.340     0  3.97
    ##  2 MacDonnell      Northern Territory Other    0.449     0  4.54
    ##  3 Wilderness West Tasmania           Other    0.478     0 10.3 
    ##  4 Barkly          Northern Territory Other    0.632     0  7.35
    ##  5 Clare Valley    South Australia    Other    0.898     0  6.82
    ##  6 Barossa         South Australia    Other    1.02      0 10.4 
    ##  7 Kakadu Arnhem   Northern Territory Other    1.04      0  8.57
    ##  8 Lasseter        Northern Territory Other    1.14      0  5.99
    ##  9 Wimmera         Victoria           Other    1.15      0 11.4 
    ## 10 MacDonnell      Northern Territory Visiting 1.18      0  6.09
    ## # ... with 294 more rows

Como hemos visto anteriormente, existen 5 estadísticas básicas que se
deben analizar: el mínimo, primer cuartil, mediana, tercer cuartil y
máximo. La función `quantile()` nos ayuda a calcularlas de manera
sencilla:

``` r
tourism %>% features(Trips, quantile, prob=seq(0,1,by=0.25))
```

    ## # A tibble: 304 x 8
    ##    Region         State             Purpose    `0%`  `25%`   `50%`  `75%` `100%`
    ##    <chr>          <chr>             <chr>     <dbl>  <dbl>   <dbl>  <dbl>  <dbl>
    ##  1 Adelaide       South Australia   Busine~  68.7   134.   153.    177.   242.  
    ##  2 Adelaide       South Australia   Holiday 108.    135.   154.    172.   224.  
    ##  3 Adelaide       South Australia   Other    25.9    43.9   53.8    62.5  107.  
    ##  4 Adelaide       South Australia   Visiti~ 137.    179.   206.    229.   270.  
    ##  5 Adelaide Hills South Australia   Busine~   0       0      1.26    3.92  28.6 
    ##  6 Adelaide Hills South Australia   Holiday   0       5.77   8.52   14.1   35.8 
    ##  7 Adelaide Hills South Australia   Other     0       0      0.908   2.09   8.95
    ##  8 Adelaide Hills South Australia   Visiti~   0.778   8.91  12.2    16.8   81.1 
    ##  9 Alice Springs  Northern Territo~ Busine~   1.01    9.13  13.3    18.5   34.1 
    ## 10 Alice Springs  Northern Territo~ Holiday   2.81   16.9   31.5    44.8   76.5 
    ## # ... with 294 more rows

### Características de la función de autocorrelación, ACF

La función `feat_acf()` provee características interesantes acerca de
una serie de tiempo:

  - El primer coeficiente de autocorrelación de los datos originales,
    `acf1`.
  - La suma del cuadrado de los primeros 10 coeficientes de
    autocorrelación, de los datos originales, `acf10`. Este coeficiente
    nos dice qué tanta autocorrelación tiene la serie, sin importar el
    rezago.
  - El primer coeficiente de autocorrelación de las primeras
    diferencias, `diff1_acf1`.
  - La suma del cuadrado de los primeros 10 coeficientes de
    autocorrelación, de las primeras diferencias, `diff1_acf10`.
  - El primer coeficiente de autocorrelación de las segundas
    diferencias, `diff2_acf1`.
  - La suma del cuadrado de los primeros 10 coeficientes de
    autocorrelación, de las segundas diferencias, `diff2_acf10`.
  - Para datos estacionales, también se obtiene el coeficiente de
    autocorrelación en el primer rezago estacional.

<!-- end list -->

``` r
tourism %>% features(Trips, feat_acf)
```

    ## # A tibble: 304 x 10
    ##    Region State Purpose     acf1 acf10 diff1_acf1 diff1_acf10 diff2_acf1
    ##    <chr>  <chr> <chr>      <dbl> <dbl>      <dbl>       <dbl>      <dbl>
    ##  1 Adela~ Sout~ Busine~  0.0333  0.131     -0.520       0.463     -0.676
    ##  2 Adela~ Sout~ Holiday  0.0456  0.372     -0.343       0.614     -0.487
    ##  3 Adela~ Sout~ Other    0.517   1.15      -0.409       0.383     -0.675
    ##  4 Adela~ Sout~ Visiti~  0.0684  0.294     -0.394       0.452     -0.518
    ##  5 Adela~ Sout~ Busine~  0.0709  0.134     -0.580       0.415     -0.750
    ##  6 Adela~ Sout~ Holiday  0.131   0.313     -0.536       0.500     -0.716
    ##  7 Adela~ Sout~ Other    0.261   0.330     -0.253       0.317     -0.457
    ##  8 Adela~ Sout~ Visiti~  0.139   0.117     -0.472       0.239     -0.626
    ##  9 Alice~ Nort~ Busine~  0.217   0.367     -0.500       0.381     -0.658
    ## 10 Alice~ Nort~ Holiday -0.00660 2.11      -0.153       2.11      -0.274
    ## # ... with 294 more rows, and 2 more variables: diff2_acf10 <dbl>,
    ## #   season_acf1 <dbl>

### Características STL

Se puede definir la **fuerza del componente de tendencia o estacional**
de la siguiente manera:

\[
F_{T} = \max \left(0,1-\frac{\operatorname{Var}\left(R_{t}\right)}{\operatorname{Var}\left(T_{t}+R_{t}\right)}\right)
\] Esto para el caso de la tendencia. Similarmente, para medir la fuerza
del componente estacional:

\[
F_{S} = \max \left(0,1-\frac{\operatorname{Var}\left(R_{t}\right)}{\operatorname{Var}\left(S_{t}+R_{t}\right)}\right)
\] En ambos casos, lo que indican las ecuaciones es que la fuerza está
medida entre cero y uno, siendo cero el indicador de nula o muy pequeña
tendencia y/o estacionalidad, y valores cercanos a uno indicando una
fuerte tendencia y/o estacionalidad.

Esto es útil cuando se quiere discernir cuáles series de tiempo tienen
la mayor estacionalidad o tendencia. Otras características interesantes
son las del tiempo de los picos y valles; qué mes o trimestre es el de
mayor estacionalidad y cuál el de menor, p. ej.

Podemos obtener todas estas características con la función `feat_stl()`.

``` r
tourism %>%
  features(Trips, feat_stl)
```

    ## # A tibble: 304 x 12
    ##    Region State Purpose trend_strength seasonal_streng~ seasonal_peak_y~
    ##    <chr>  <chr> <chr>            <dbl>            <dbl>            <dbl>
    ##  1 Adela~ Sout~ Busine~          0.451            0.380                3
    ##  2 Adela~ Sout~ Holiday          0.541            0.601                1
    ##  3 Adela~ Sout~ Other            0.743            0.189                2
    ##  4 Adela~ Sout~ Visiti~          0.433            0.446                1
    ##  5 Adela~ Sout~ Busine~          0.453            0.140                3
    ##  6 Adela~ Sout~ Holiday          0.512            0.244                2
    ##  7 Adela~ Sout~ Other            0.584            0.374                2
    ##  8 Adela~ Sout~ Visiti~          0.481            0.228                0
    ##  9 Alice~ Nort~ Busine~          0.526            0.224                0
    ## 10 Alice~ Nort~ Holiday          0.377            0.827                3
    ## # ... with 294 more rows, and 6 more variables: seasonal_trough_year <dbl>,
    ## #   spikiness <dbl>, linearity <dbl>, curvature <dbl>, stl_e_acf1 <dbl>,
    ## #   stl_e_acf10 <dbl>
