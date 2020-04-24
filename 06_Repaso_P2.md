Repaso parcial 2
================

  - [Repaso teórico](#repaso-teórico)
      - [1. Preparación de los datos
        (limpieza)](#preparación-de-los-datos-limpieza)
      - [2. Análisis exploratorio y gráfica de los datos
        (visualización)](#análisis-exploratorio-y-gráfica-de-los-datos-visualización)
          - [Gráfica de tiempo](#gráfica-de-tiempo)
          - [Gráficos estacionales](#gráficos-estacionales)
      - [3 y 4. Definición y entrenamiento del modelo (especificación y
        estimación)](#y-4.-definición-y-entrenamiento-del-modelo-especificación-y-estimación)
      - [5. Revisar el desempeño del modelo
        (evaluación)](#revisar-el-desempeño-del-modelo-evaluación)
      - [6. Producir pronósticos](#producir-pronósticos)
  - [Tarea](#tarea)
      - [Ejercicios](#ejercicios)
          - [Problema 1](#problema-1)
          - [Problema 2](#problema-2)
          - [Problema 3](#problema-3)
          - [Problema 4](#problema-4)
          - [Problema 5](#problema-5)
          - [Problema 6](#problema-6)

**NOTA:** El pseudo-código que se presenta en este documento no genera
tal cual las gráficas o tablas resultantes. Los campos que se muestran
rodeados con \< \> son *“placeholders”* para que sepan cuáles son las
variables o argumentos que deben modificar. Por ejemplo, el primer
pseudo-código mostrado

``` r
train <- <dataframe> %>% 
  filter(<condición para filtro>)
```

se sustituiría por algo como:

``` r
train <- df %>% 
  filter(Year <= 2019)
```

Bajo el supuesto de que sus datos estuvieran contenidos en la variable
`df` y ésta tuviera una variable de tiempo llamada `Year`.

-----

# Repaso teórico

Existen tres factores a considerar para ver qué tan bien se puede
pronosticar una serie de tiempo:

1.  Qué tan bien conocemos los factores o elementos que influyen en él.
2.  Qué tantos datos tenemos disponibles.
3.  Si el pronóstico que vamos a realizar puede influir en el resultado
    de la variable a predecir.

Si se determina que cumple con esas características, los pasos para
llevar a cabo un proyecto de pronóstico, pueden enumerarse en los
siguientes:

1.  Preparación de los datos (limpieza)
2.  Análisis exploratorio y gráfica de los datos (visualización)
3.  Definición del modelo (especificación)
4.  Entrenamiento del modelo (estimación)
5.  Revisar el desempeño del modelo (evaluación)
6.  Producir pronósticos

**NOTA**: Siempre que quieran revisar cómo funciona alguna función en
particular, pueden consultar la documentación con el comando
`help(<"función">)`.

## 1\. Preparación de los datos (limpieza)

``` r
library(easypackages)
packages("tidyverse","fpp3")
```

El `tidyverse` cuenta con paqueterías necesarias para la ciencia de
datos. Por lo que, al cargar esta paquetería, podemos:

  - **Importar datos**
      - Podemos utilizar las funciones dentro de la paquetería `readr`,
        como `read_csv()`, `read_delim()`, etc.
      - La paquetería `readxl` sirve para importar datos de Excel (.xls
        y .xlsx).
      - La paquetería `haven` cuenta con funiones para importar datos de
        SPSS, Stata, y SAS.
  - **Manipulación de datos**
      - `tidyr`, `dplyr` tienen funciones para llevar a cabo la
        limplieza de datos.
      - `stringr` permite manipular variables de texto.
      - `forcats` ayuda a solucionar problemas con variables categóricas
        (factors).
      - `lubridate` a hacer transformaciones y operaciones con fechas.
      - `hms` sirve para valores de la hora del día.
  - **Programación**
      - Para llevar a cabo iteraciones en objetos de **R**, es
        conveniente utilizar funciones de la paquetería `purrr`.

Siempre que queramos hacer pronósticos de una variable, debemos separar
nuestros datos en dos conjuntos: datos de **entrenamiento** y datos de
**prueba o pronóstico**. Para el ejemplo, nombraremos `train` al dataset
filtrado que usaremos para el conjunto de entrenamiento.

Se recomienda que el tamaño del conjunto de prueba sea del 20% de la
muestra, o del horizonte máximo de pronóstico que se requiere.

Para segmentar los datos podemos usar varias funciones como, de `dplyr`:
`filter()`, `slice()`, y de `tsibble`: `filter_index()`.

Con `filter()`, las observaciones deben cumplir alguna condición:

``` r
train <- <dataframe> %>% 
  filter(<condición para filtro>)
```

Con `slice()`, se toman ciertas observaciones, de acuerdo a su posición
en la tabla (índice):

``` r
train <- <dataframe> %>% 
  slice(<índice>)
```

`filter_index()` requiere que los datos sean un objeto `tsibble` y se
especifica una fecha:

``` r
train <- <dataframe> %>% 
  filter_index(<fecha inicial> ~ <fecha final>)
```

Se puede definir usar todas las fechas desde el inicio hasta cierto
punto o vice versa sustituyendo la `<fecha>` con un punto; `.`. P. ej.,
tomando como entrenamiento las fechas desde el inicio hasta cierta
`<fecha final>`:

``` r
train <- <dataframe> %>% 
  filter_index(. ~ <fecha final>)
```

## 2\. Análisis exploratorio y gráfica de los datos (visualización)

Se pueden hacer varios tipos de gráficas para el análisis exploratorio,
siendo la elemental la gráfica de tiempo. Utilizamos la paquetería
`ggplot2` para crear gráficos con diseño y capacidad muy amplia de
personalización. La estructura básica para graficar con `ggplot2` se
basa en la gramática de los gráficos, la cual consiste en:

  - Llamar la función `ggplot()` para especificar el conjunto de datos a
    utilizar (*dataframe*).

  - Definir la estética de la gráfica, en `aes()`. Esto es, las
    variables para los ejes (`x = <variable>`, `y = <variable>`), el
    color (`color = <variable>`), tamaño (`size = <variable>`), forma
    (`shape = <variable>`), relleno (`fill = <variable>`),etc.

  - Establecer qué tipo o tipos de `geom` se van a utilizar para el
    gráfico (líneas, puntos, histogramas, boxplots, violín, etc.) con
    `geom_*`, donde el `*` puede ser `line`, `point`, `hist`, `boxplot`,
    `violin`, respectivamente.

  - Se puede, opcionalmente, agregar más personalización al gráfico,
    como definir el título (con `ggtitle(<título>)`), títulos de ejes,
    escalas, entre otros.

**NOTA**: La estética se puede definir dentro de `ggplot(aes())`, lo que
haría que esa estética aplique para todos los `geom` definidos, o dentro
de cada `geom`, para que la estética cambie con cada uno.

Este ejemplo tomaría las mismas variables para las líneas y puntos:

``` r
<dataframe> %>% 
  ggplot(aes(x = <variable>, y = <variable>,
                          color = <variable>, size = <variable>,
                          shape = <variable>, fill = <variable>)) +
         geom_line() +
         geom_point()
```

![](06_Repaso_P2_files/figure-gfm/country%20gdp%20plot%20all%20black-1.jpeg)<!-- -->

Este ejemplo tomaría distintas variables las líneas y puntos:

``` r
<dataframe> %>% 
  ggplot() +
         geom_line(aes(x = <variable>, y = <variable>,
                          color = <variable>, size = <variable>,
                          shape = <variable>, fill = <variable>)) +
         geom_point(aes(x = <variable>, y = <variable>,
                          color = <variable>, size = <variable>,
                          shape = <variable>, fill = <variable>))
```

![](06_Repaso_P2_files/figure-gfm/country%20gdp%20plot%20colors-1.jpeg)<!-- -->

### Gráfica de tiempo

Así una gráfica de tiempo tendría la estructura básica:

``` r
<dataframe> %>% 
  ggplot(aes(x = <variable de tiempo>, y = <variable>) +
         geom_line()
```

![](06_Repaso_P2_files/figure-gfm/time%20plot-1.jpeg)<!-- -->

Si se quieren analizar los patrones de dos variables simultáneamente, se
podría hacer algo como:

``` r
<dataframe> %>% 
  ggplot(<dataframe>, aes(x = <variable de tiempo>) +
           geom_line(aes(y = <variable1>), color = <color1>) +
           geom_line(aes(y = <variable2>), color = <color2>)
```

### Gráficos estacionales

``` r
<dataframe> %>% 
  gg_season()
```

    ## Plot variable not specified, automatically selected `y = Employed`

![](06_Repaso_P2_files/figure-gfm/season%20plot-1.jpeg)<!-- -->

## 3 y 4. Definición y entrenamiento del modelo (especificación y estimación)

Hasta ahora, hemos visto solo los modelos de pronóstico que usaremos de
referencia para evaluar los modelos más complejos. Estos son los métodos
de:

  - La Media; `MEAN()`.
  - Ingenuo o Naïve; `NAIVE()`.
  - Ingenuo estacional; `SNAIVE()`.
  - Drift; `NAIVE(<var. dependiente> ~ drift())`.

Con la paquetería `fable` y `fabletools`, podemos estimar uno o más
modelos de manera simultánea muy fácilmente. Para este ejemplo,
guardaremos los modelos estimados en la variable `modelos` y
utilizaremos los datos de entrenamiento para el ajuste:

``` r
modelos <- <train> %>% 
  model("nombre a darle al modelo1" = <modelo1>(<características del modelo1>,
        "nombre a darle al modelo2" = <modelo2>(<características del modelo2>)
```

Vimos también que se pueden ajustar modelos a variables transformadas
matemáticamente, como con una transformación de Box-Cox. Si se realiza
alguna transformación, debemos especificarla dentro del modelo:

``` r
modelos <- <train> %>% 
  model("nombre a darle al modelo1" = <modelo1>(<transformación>(<variable>))
```

## 5\. Revisar el desempeño del modelo (evaluación)

Una vez ajustado el modelo, debemos asegurarnos de que hayamos logrado
un buen ajuste. Esto lo podemos ver gráficamente y a través de pruebas
estadísticas, al realizar diagnósticos de los residuos.

Primero, podemos graficar el ajuste del modelo a los datos (de
entrenamiento). El ajuste de los datos lo podemos obtener con
`augment()`, que nos arroja los datos ajustados `.fitted` y los residuos
del modelo `.resid`. Guardaremos esto en la variable `aug`:

``` r
<aug> <- modelos %>% augment()
```

Para graficar los datos de entrenamiento vs. el ajuste del modelo:

``` r
<train> %>% 
  ggplot(aes(x = <var. de tiempo>, y = <var. dependiente>))+
  geom_line(color = <color_datos_entrenamiento>)+
  geom_line(aes(y = <aug$.fitted>), color = <color_ajuste_modelo>)+
  ggtitle(<"título">)
```

![](06_Repaso_P2_files/figure-gfm/mex%20GDP%20train%20vs.%20fitted%20plot-1.jpeg)<!-- -->

Para realizar el diagnóstico de residuales:

``` r
<modelos> %>% gg_tsresiduals() + 
  ggtitle(<"título">)
```

![](06_Repaso_P2_files/figure-gfm/mex%20gdp%20residual%20diagnostics-1.jpeg)<!-- -->

Lo que buscamos en estas gráficas es:

  - Que en la primera no se perciba ningún patrón marcado, tendencia,
    etc., sino que los residuos se vean **aleatorios** y con **media
    cero**.

  - Que la ACF muestre rezagos **no significativos**.

  - Que el histograma muestre una distribución aproximadamente
    **normal**.

Para realizar las pruebas estadísticas de Box-Pierce y/o Ljung-Box:

``` r
<aug> %>% features(.resid, box_pierce, lag=<10>, dof=<0>)
<aug> %>% features(.resid, ljung_box, lag=<10>, dof=<0>)
```

Lo sugerido para el valor del rezago en estas pruebas es:

  - `lag = 10` cuando los datos son **no estacionales**.
  - `lag = 2m` cuando son **estacionales**, donde \(m\) es el periodo
    estacional.
  - El valor de `dof` depende de los parámetros que se estén evaluando
    en el modelo. Para los modelos de referencia, al no tener parámetros
    a estimar, se utiliza `dof = 0`.

<!-- end list -->

    ## # A tibble: 1 x 4
    ##   Country .model              lb_stat lb_pvalue
    ##   <fct>   <chr>                 <dbl>     <dbl>
    ## 1 Mexico  TSLM(GDP ~ trend())    182.         0

Si el p-value \(< \alpha\), se rechaza la \(H_0\) de la prueba (\(H_0:\)
*“Los residuos no están autocorrelacionados; los residuos son ruido
blanco”*), por lo que, un modelo bien ajustado tendrá residuos que son
ruido blanco y su prueba de Ljung-Box tendrá un p-value alto (mayor a
\(\alpha\)).

## 6\. Producir pronósticos

Generamos los pronósticos con la función `forecast()`. En ella debemos
especificar algunos argumentos:

  - `h`, o el horizonte de pronóstico.
  - Si queremos que **R** realice el ajuste por sesgo (cuando se realiza
    una transformación matemática). Por defaúlt está marcado que **sí
    realice el ajuste por sesgo**, `bias_adjust = TRUE`.
  - Si queremos que el pronóstico genere intervalos de predicción
    normales o mediante **bootstrap**. Por defáult no genera intervalos
    con bootstrap, hay que especificarlo: `bootstrap = TRUE`.

Guardamos el pronostico en la variable `fc` para los siguientes `h`
periodos:

``` r
<fc> <- modelos %>% 
  forecast( h = <h>)

<fc> %>% 
  autoplot(<dataframe>, level = NULL)
```

![](06_Repaso_P2_files/figure-gfm/beer%20production%20forecast-1.jpeg)<!-- -->
Y para medir la precisión del pronóstico, calculamos los errores con
`accuracy()`. El modelo que obtenga el menor error será el mejor:

``` r
accuracy(<fc>, <dataframe>)
```

    ## # A tibble: 4 x 9
    ##   .model         .type    ME  RMSE   MAE    MPE  MAPE  MASE    ACF1
    ##   <chr>          <chr> <dbl> <dbl> <dbl>  <dbl> <dbl> <dbl>   <dbl>
    ## 1 Drift          Test  -54.0  64.9  58.9 -13.6  14.6  4.12  -0.0741
    ## 2 Mean           Test  -13.8  38.4  34.8  -3.97  8.28 2.44  -0.0691
    ## 3 Naïve          Test  -51.4  62.7  57.4 -13.0  14.2  4.01  -0.0691
    ## 4 Seasonal naïve Test    5.2  14.3  13.4   1.15  3.17 0.937  0.132

# Tarea

## Ejercicios

### Problema 1

*Produzcan pronósticos de las siguientes series de tiempo, utilizando el
modelo que consideren más apropiado para cada caso entre `NAIVE()`,
`SNAIVE()` o `RW( ~ drift())`:*

#### \* Población australiana (`global_economy`)

``` r
aus_pop <- global_economy %>% 
  filter(Country == "Australia") 

aus_pop %>% 
  ggplot(aes(x = Year, y = Population))+
  geom_line() + ggtitle("Población australiana")
```

![](06_Repaso_P2_files/figure-gfm/aus_pop%20plot-1.jpeg)<!-- --> Como la
población parece aumentar de manera bastante lineal, probamos con el
método del **drift**.

``` r
# Separar los datos en entrenamiento y prueba
aus_pop_train <- aus_pop %>% 
  slice(1:trunc(n()*.8,0))

# Ajuste del modelo
aus_pop_model <- aus_pop_train %>% 
  model(RW(Population ~ drift()))

# Obtener residuales y valores ajustados
aus_pop_aug <- aus_pop_model %>% augment()

aus_pop_aug
```

    ## # A tsibble: 46 x 6 [1Y]
    ## # Key:       Country, .model [1]
    ##    Country   .model                    Year Population   .fitted  .resid
    ##    <fct>     <chr>                    <dbl>      <dbl>     <dbl>   <dbl>
    ##  1 Australia RW(Population ~ drift())  1960   10276477       NA      NA 
    ##  2 Australia RW(Population ~ drift())  1961   10483000 10501329. -18329.
    ##  3 Australia RW(Population ~ drift())  1962   10742000 10707852.  34148.
    ##  4 Australia RW(Population ~ drift())  1963   10950000 10966852. -16852.
    ##  5 Australia RW(Population ~ drift())  1964   11167000 11174852.  -7852.
    ##  6 Australia RW(Population ~ drift())  1965   11388000 11391852.  -3852.
    ##  7 Australia RW(Population ~ drift())  1966   11651000 11612852.  38148.
    ##  8 Australia RW(Population ~ drift())  1967   11799000 11875852. -76852.
    ##  9 Australia RW(Population ~ drift())  1968   12009000 12023852. -14852.
    ## 10 Australia RW(Population ~ drift())  1969   12263000 12233852.  29148.
    ## # ... with 36 more rows

``` r
# Gráfica 
aus_pop_train %>% 
  ggplot(aes(x = Year, y = Population))+
  geom_line()+
  geom_line(aes(y = aus_pop_aug$.fitted),color = "firebrick")+
  ggtitle("Ajuste del modelo vs. datos históricos (entrenamiento)")
```

    ## Warning: Removed 1 row(s) containing missing values (geom_path).

![](06_Repaso_P2_files/figure-gfm/aus_pop%20drift%20fcst-1.jpeg)<!-- -->
El pronóstico:

``` r
aus_pop_fc <- aus_pop_model %>% 
  forecast(h = length(aus_pop$Year)-length(aus_pop_train$Year))
aus_pop_fc
```

    ## # A fable: 12 x 5 [1Y]
    ## # Key:     Country, .model [1]
    ##    Country   .model                    Year Population .distribution      
    ##    <fct>     <chr>                    <dbl>      <dbl> <dist>             
    ##  1 Australia RW(Population ~ drift())  2006  20619652. N(2.1e+07, 2.6e+09)
    ##  2 Australia RW(Population ~ drift())  2007  20844503. N(2.1e+07, 5.3e+09)
    ##  3 Australia RW(Population ~ drift())  2008  21069355. N(2.1e+07, 8.1e+09)
    ##  4 Australia RW(Population ~ drift())  2009  21294206. N(2.1e+07, 1.1e+10)
    ##  5 Australia RW(Population ~ drift())  2010  21519058. N(2.2e+07, 1.4e+10)
    ##  6 Australia RW(Population ~ drift())  2011  21743910. N(2.2e+07, 1.7e+10)
    ##  7 Australia RW(Population ~ drift())  2012  21968761. N(2.2e+07, 2.1e+10)
    ##  8 Australia RW(Population ~ drift())  2013  22193613. N(2.2e+07, 2.4e+10)
    ##  9 Australia RW(Population ~ drift())  2014  22418465. N(2.2e+07, 2.7e+10)
    ## 10 Australia RW(Population ~ drift())  2015  22643316. N(2.3e+07, 3.1e+10)
    ## 11 Australia RW(Population ~ drift())  2016  22868168. N(2.3e+07, 3.5e+10)
    ## 12 Australia RW(Population ~ drift())  2017  23093019. N(2.3e+07, 3.9e+10)

``` r
aus_pop_fc %>% 
  autoplot(aus_pop) + ggtitle("Pronóstico de la pob. australiana con el método del drift")
```

![](06_Repaso_P2_files/figure-gfm/aus_pop%20fcst-1.jpeg)<!-- -->

#### \* Producción de ladrillos (Bricks de `aus_production`)

``` r
bricks <- aus_production %>% 
  select(Quarter, Bricks) %>% 
  na.omit() %>%  # para quitar los NAs que tiene la serie al final
  as_tsibble()
```

    ## Using `Quarter` as index variable.

``` r
# Gráfica de los datos

ggplot(bricks, aes(x = Quarter, y = Bricks)) +
  geom_line()
```

![](06_Repaso_P2_files/figure-gfm/bricks%20model-1.jpeg)<!-- -->

``` r
# Separar los datos en entrenamiento y prueba
bricks_train <- bricks %>% 
  slice(1:trunc(n()*.8,0))

# Ajuste del modelo
bricks_model <- bricks_train %>% 
  model(seasonal_naive = SNAIVE(Bricks))

# Obtener residuales y valores ajustados
bricks_aug <- bricks_model %>% augment()

bricks_aug
```

    ## # A tsibble: 158 x 5 [1Q]
    ## # Key:       .model [1]
    ##    .model         Quarter Bricks .fitted .resid
    ##    <chr>            <qtr>  <dbl>   <dbl>  <dbl>
    ##  1 seasonal_naive 1956 Q1    189      NA     NA
    ##  2 seasonal_naive 1956 Q2    204      NA     NA
    ##  3 seasonal_naive 1956 Q3    208      NA     NA
    ##  4 seasonal_naive 1956 Q4    197      NA     NA
    ##  5 seasonal_naive 1957 Q1    187     189     -2
    ##  6 seasonal_naive 1957 Q2    214     204     10
    ##  7 seasonal_naive 1957 Q3    227     208     19
    ##  8 seasonal_naive 1957 Q4    222     197     25
    ##  9 seasonal_naive 1958 Q1    199     187     12
    ## 10 seasonal_naive 1958 Q2    229     214     15
    ## # ... with 148 more rows

``` r
# Gráfica 
bricks_train %>% 
  ggplot(aes(x = Quarter, y = Bricks))+
  geom_line()+
  geom_line(aes(y = bricks_aug$.fitted),color = "firebrick")+
  ggtitle("Ajuste del modelo vs. datos históricos (entrenamiento)")
```

    ## Warning: Removed 4 row(s) containing missing values (geom_path).

![](06_Repaso_P2_files/figure-gfm/bricks%20model-2.jpeg)<!-- -->

El pronóstico:

``` r
bricks_fc <- bricks_model %>% 
  forecast(h = length(bricks$Quarter)-length(bricks_train$Quarter))
bricks_fc
```

    ## # A fable: 40 x 4 [1Q]
    ## # Key:     .model [1]
    ##    .model         Quarter Bricks .distribution
    ##    <chr>            <qtr>  <dbl> <dist>       
    ##  1 seasonal_naive 1995 Q3    497 N(497, 2319) 
    ##  2 seasonal_naive 1995 Q4    476 N(476, 2319) 
    ##  3 seasonal_naive 1996 Q1    430 N(430, 2319) 
    ##  4 seasonal_naive 1996 Q2    457 N(457, 2319) 
    ##  5 seasonal_naive 1996 Q3    497 N(497, 4639) 
    ##  6 seasonal_naive 1996 Q4    476 N(476, 4639) 
    ##  7 seasonal_naive 1997 Q1    430 N(430, 4639) 
    ##  8 seasonal_naive 1997 Q2    457 N(457, 4639) 
    ##  9 seasonal_naive 1997 Q3    497 N(497, 6958) 
    ## 10 seasonal_naive 1997 Q4    476 N(476, 6958) 
    ## # ... with 30 more rows

``` r
bricks_fc %>% 
  autoplot(bricks) + ggtitle("Pronóstico de producción de ladrillos con Seasonal Naïve")
```

![](06_Repaso_P2_files/figure-gfm/bricks%20fcst-1.jpeg)<!-- -->

#### \* Corderos de New South Wales (NSW en `aus_livestock`)

``` r
lamb <- aus_livestock %>% 
  filter(Animal == "Lambs",
         State == "New South Wales") %>% 
  select(Month, Count) 
  
  

# Gráfica de los datos

ggplot(lamb, aes(x = Month, y = Count)) +
  geom_line()
```

![](06_Repaso_P2_files/figure-gfm/lamb%20model-1.jpeg)<!-- -->

``` r
# Separar los datos en entrenamiento y prueba
lamb_train <- lamb %>% 
  slice(1:trunc(n()*.8,0))

# Ajuste del modelo
lamb_model <- lamb_train %>% 
  model(seasonal_naive = SNAIVE(Count))

# Obtener residuales y valores ajustados
lamb_aug <- lamb_model %>% augment()

lamb_aug
```

    ## # A tsibble: 446 x 5 [1M]
    ## # Key:       .model [1]
    ##    .model             Month  Count .fitted .resid
    ##    <chr>              <mth>  <dbl>   <dbl>  <dbl>
    ##  1 seasonal_naive 1972 jul. 587600      NA     NA
    ##  2 seasonal_naive 1972 ago. 553700      NA     NA
    ##  3 seasonal_naive 1972 sep. 494900      NA     NA
    ##  4 seasonal_naive 1972 oct. 533500      NA     NA
    ##  5 seasonal_naive 1972 nov. 574300      NA     NA
    ##  6 seasonal_naive 1972 dic. 517500      NA     NA
    ##  7 seasonal_naive 1973 ene. 562600      NA     NA
    ##  8 seasonal_naive 1973 feb. 426900      NA     NA
    ##  9 seasonal_naive 1973 mar. 496300      NA     NA
    ## 10 seasonal_naive 1973 abr. 496000      NA     NA
    ## # ... with 436 more rows

``` r
# Gráfica 
lamb_train %>% 
  ggplot(aes(x = Month, y = Count))+
  geom_line()+
  geom_line(aes(y = lamb_aug$.fitted),color = "firebrick")+
  ggtitle("Ajuste del modelo vs. datos históricos (entrenamiento)")
```

    ## Warning: Removed 12 row(s) containing missing values (geom_path).

![](06_Repaso_P2_files/figure-gfm/lamb%20model-2.jpeg)<!-- -->

El pronóstico:

``` r
lamb_fc <- lamb_model %>% 
  forecast(h = length(lamb$Month)-length(lamb_train$Month))
lamb_fc
```

    ## # A fable: 112 x 4 [1M]
    ## # Key:     .model [1]
    ##    .model             Month  Count .distribution     
    ##    <chr>              <mth>  <dbl> <dist>            
    ##  1 seasonal_naive 2009 sep. 381800 N(381800, 3.3e+09)
    ##  2 seasonal_naive 2009 oct. 457400 N(457400, 3.3e+09)
    ##  3 seasonal_naive 2009 nov. 374800 N(374800, 3.3e+09)
    ##  4 seasonal_naive 2009 dic. 382000 N(382000, 3.3e+09)
    ##  5 seasonal_naive 2010 ene. 380900 N(380900, 3.3e+09)
    ##  6 seasonal_naive 2010 feb. 379100 N(379100, 3.3e+09)
    ##  7 seasonal_naive 2010 mar. 407400 N(407400, 3.3e+09)
    ##  8 seasonal_naive 2010 abr. 404100 N(404100, 3.3e+09)
    ##  9 seasonal_naive 2010 may. 376500 N(376500, 3.3e+09)
    ## 10 seasonal_naive 2010 jun. 355200 N(355200, 3.3e+09)
    ## # ... with 102 more rows

``` r
lamb_fc %>% 
  autoplot(lamb) + ggtitle("Pronóstico de producción de ladrillos con Seasonal Naïve")
```

![](06_Repaso_P2_files/figure-gfm/lamb%20fcst-1.jpeg)<!-- -->

#### \* Riqueza de los hogares (`hh_budget`)

``` r
usa_riq <- hh_budget %>% 
  filter(Country == "USA") %>% 
  select(Year, Wealth)

# Gráfica de los datos

ggplot(usa_riq, aes(x = Year, y = Wealth)) +
  geom_line()
```

![](06_Repaso_P2_files/figure-gfm/wealth%20model-1.jpeg)<!-- -->

``` r
# Separar los datos en entrenamiento y prueba
usa_riq_train <- usa_riq %>% 
  slice(1:trunc(n()*.8,0))

# Ajuste del modelo
usa_riq_model <- usa_riq_train %>% 
  model(naive = RW(Wealth))

# Obtener residuales y valores ajustados
usa_riq_aug <- usa_riq_model %>% augment()

usa_riq_aug
```

    ## # A tsibble: 17 x 5 [1Y]
    ## # Key:       .model [1]
    ##    .model  Year Wealth .fitted .resid
    ##    <chr>  <dbl>  <dbl>   <dbl>  <dbl>
    ##  1 naive   1995   472.     NA   NA   
    ##  2 naive   1996   485.    472.  12.5 
    ##  3 naive   1997   510.    485.  25.4 
    ##  4 naive   1998   527.    510.  16.9 
    ##  5 naive   1999   563.    527.  35.7 
    ##  6 naive   2000   521.    563. -42.2 
    ##  7 naive   2001   499.    521. -21.6 
    ##  8 naive   2002   461.    499. -37.7 
    ##  9 naive   2003   492.    461.  30.9 
    ## 10 naive   2004   525.    492.  33.0 
    ## 11 naive   2005   550.    525.  25.3 
    ## 12 naive   2006   563.    550.  13.0 
    ## 13 naive   2007   561.    563.  -2.93
    ## 14 naive   2008   479.    561. -81.3 
    ## 15 naive   2009   500.    479.  20.6 
    ## 16 naive   2010   520.    500.  20.3 
    ## 17 naive   2011   503.    520. -17.1

``` r
# Gráfica 
usa_riq_train %>% 
  ggplot(aes(x = Year, y = Wealth))+
  geom_line()+
  geom_line(aes(y = usa_riq_aug$.fitted),color = "firebrick")+
  ggtitle("Ajuste del modelo vs. datos históricos (entrenamiento)")
```

    ## Warning: Removed 1 row(s) containing missing values (geom_path).

![](06_Repaso_P2_files/figure-gfm/wealth%20model-2.jpeg)<!-- --> El
pronóstico:

``` r
usa_riq_fc <- usa_riq_model %>% 
  forecast(h = length(usa_riq$Year)-length(usa_riq_train$Year))
usa_riq_fc
```

    ## # A fable: 5 x 4 [1Y]
    ## # Key:     .model [1]
    ##   .model  Year Wealth .distribution
    ##   <chr>  <dbl>  <dbl> <dist>       
    ## 1 naive   2012   503. N(503, 1039) 
    ## 2 naive   2013   503. N(503, 2079) 
    ## 3 naive   2014   503. N(503, 3118) 
    ## 4 naive   2015   503. N(503, 4157) 
    ## 5 naive   2016   503. N(503, 5196)

``` r
usa_riq_fc %>% 
  autoplot(usa_riq) + ggtitle("Pronóstico de la riqueza en EEUU con Naïve")
```

![](06_Repaso_P2_files/figure-gfm/wealth%20fcst-1.jpeg)<!-- -->

### Problema 2

*De los precios de la acción de Facebook (en el data set `gafa_stock`),
hacer lo siguiente:*

1.  Gráfica de tiempo de la serie

<!-- end list -->

``` r
fb_stock <- gafa_stock %>%
  filter(Symbol == "FB") %>%
  mutate(day = row_number()) %>%
  update_tsibble(index = day, regular = TRUE)

fb_stock %>% 
  ggplot(aes(x = Date, y = Close))+ 
  geom_line()
```

![](06_Repaso_P2_files/figure-gfm/fb%20time%20plot-1.jpeg)<!-- -->

2.  Producir pronósticos con el método del drift y grafíquelos.

<!-- end list -->

``` r
# Separar los datos en entrenamiento y prueba
fb_train <- fb_stock %>% 
  slice(1:trunc(n()*.8,0))

# Ajustar el modelo
fb_model <- fb_train %>% 
  model(RW(Close ~ drift()))

# Obtener residuales y valores ajustados
fb_aug <- fb_model %>% augment()

# Gráfica del ajuste
fb_train %>% 
  ggplot(aes(x = Date, y = Close))+
  geom_line()+
  geom_line(aes(y = fb_aug$.fitted),color = "firebrick")+
  ggtitle("Ajuste del modelo vs. datos históricos (entrenamiento)")
```

    ## Warning: Removed 1 row(s) containing missing values (geom_path).

![](06_Repaso_P2_files/figure-gfm/fb%20model-1.jpeg)<!-- -->

``` r
# El pronóstico
fb_fc <- fb_model %>% 
  forecast(h = length(fb_stock$Date)-length(fb_train$Date))


fb_fc %>% 
  autoplot(fb_stock) + ggtitle("Pronóstico del precio de Facebook con drift")
```

![](06_Repaso_P2_files/figure-gfm/fb%20model-2.jpeg)<!-- -->

3.  Pruebe que el pronóstico es idéntico a extender una línea recta
    entre la primera y última observación de los datos de entrenamiento.

La ecuación de una recta cualquiera está dada por $ y = m x + b$, siendo
\(m\) la pendiente y \(b\) el intercepto u ordenada al origen. Si
tomamos el punto inicial \((x_1,y_1)\) de la serie y el final de los
datos de entrenamiento \((x_2,y_2)\), podemos calcular la pendiente
utilizando \(m = \frac{y_2-y_1}{x_2-x_1}\). Posteriormente, sustituimos
en la ecuación de la recta, sustituyendo el valor de cualquiera de los
puntos para obtener el valor del intercepto, \(b = y - m x\).

``` r
x1 <- 1
y1 <- head(fb_train$Close,1)

x2 <- length(fb_train$Date)
y2 <- tail(fb_train$Close,1)

m <- (y2-y1)/(x2-x1)

b <- y1 - m * x1

fb_fc %>% 
  autoplot(fb_stock) + ggtitle("Comprobación") + 
  geom_abline(slope = m, intercept = b, linetype = "dashed",
              color = "red")
```

![](06_Repaso_P2_files/figure-gfm/line%20from%20first%20and%20last%20observation-1.jpeg)<!-- -->

4.  Utilice otro método de benchmark (referencia) para realizar el
    pronóstico. ¿Cuál cree que sea mejor? ¿Por qué?

<!-- end list -->

``` r
# Ajustar el modelo
fb_model2 <- fb_train %>% 
  model(RW(Close))

# Obtener residuales y valores ajustados
fb_aug2 <- fb_model2 %>% augment()

# El pronóstico
fb_fc2 <- fb_model2 %>% 
  forecast(h = length(fb_stock$Date)-length(fb_train$Date))


fb_fc2 %>% 
  autoplot(fb_stock) + ggtitle("Pronóstico del precio de Facebook con drift")
```

![](06_Repaso_P2_files/figure-gfm/fb%20other%20benchmark%20model-1.jpeg)<!-- -->

Se utilizó el método Naïve para comparar, ya que se dice que éste es el
modelo óptimo para series que siguen una caminata aleatoria.

Ante la caída del precio de Facebook, parece que se ajusta de mejor
manera este segundo modelo, los datos reales se mantienen más cerca de
la estimación puntual, así como dentro de los intervalos de predicción.
Sin embargo, en el tiempo atrás, el modelo de drift parece que se
hubiera ajustado mejor.

### Problema 3

*Genere pronósticos para todas los animales del estado de Victoria en
`aus_livestock` utilizando `SNAIVE()`. Grafique los pronósticos
resultantes junto con los datos históricos. ¿Este método es una
referencia adecuada para los datos?*

``` r
victoria <- aus_livestock %>% 
  filter(State == "Victoria") %>% 
  select(-c(State))

victoria %>% 
  ggplot(aes(x = Month, y = Count, color = Animal)) + 
  geom_line()
```

![](06_Repaso_P2_files/figure-gfm/victorian%20animals-1.jpeg)<!-- -->

Los pronósticos:

``` r
victoria_train <- victoria %>% 
  filter(Month <"2016-01-01")

# Ajuste del modelo SNAIVE
victoria_model <- victoria_train %>% 
  model(snaive = SNAIVE(Count))

# Obtener residuales y valores ajustados
victoria_aug <- victoria_model %>% augment()

# El pronóstico

victoria_fc <- victoria_model %>% 
  forecast(h = 36) # pronóstico de 3 años

# Gráfica de los pronósticos
victoria_fc %>% 
  autoplot(victoria) + ggtitle("Pronóstico de la producción de animales en Victoria")
```

![](06_Repaso_P2_files/figure-gfm/victorian%20animals%20fcst-1.jpeg)<!-- -->
Para revisar la precisión del modelo en cada animal:

``` r
accuracy(victoria_fc, victoria)
```

    ## # A tibble: 7 x 10
    ##   .model Animal           .type      ME   RMSE    MAE     MPE  MAPE  MASE   ACF1
    ##   <chr>  <fct>            <chr>   <dbl>  <dbl>  <dbl>   <dbl> <dbl> <dbl>  <dbl>
    ## 1 snaive Bulls, bullocks~ Test  -14772. 1.66e4 14839. -32.1   32.3  1.77   0.557
    ## 2 snaive Calves           Test   -8428. 1.06e4  8450  -47.5   47.6  0.903  0.735
    ## 3 snaive Cattle (excl. c~ Test  -29000  3.52e4 30522. -26.6   27.7  1.63   0.703
    ## 4 snaive Cows and heifers Test  -14225  2.05e4 17947. -23.9   27.9  1.42   0.720
    ## 5 snaive Lambs            Test   56306. 1.19e5 93878.   5.04   9.82 1.46   0.447
    ## 6 snaive Pigs             Test    1233. 7.69e3  6356.   0.832  6.61 0.666 -0.260
    ## 7 snaive Sheep            Test  -14133. 7.51e4 60622. -10.8   23.4  0.796  0.589

### Problema 4

*Calcule los residuos del pronóstico naïve estacional aplicados a la
producción trimestral de cerveza australiana a partir de 1992. El
siguiente código puede serles útil. ¿Qué puede concluir al respecto?*

``` r
# Extraer los datos de interés
recent_production <- aus_production %>%
  filter(year(Quarter) >= 1992)

# Definir y estimar el modelo
fit <- recent_production %>% model(SNAIVE(Beer))

# Ver los residuales
fit %>% gg_tsresiduals()

# Ver el pronóstico resultante
fit %>% forecast() %>% autoplot(recent_production)
```

### Problema 5

*Repita el ejercicio anterior utilizando las exportaciones mexicanas de
`global_economy` y la serie de tiempo de ladrillos (Bricks) de
`aus_production`. Utilice cualquiera entre `NAIVE()` o `SNAIVE()`
dependiendo cuál sea más conveniente en cada caso.*

### Problema 6

*Explique si los siguientes enunciados son verdaderos o falsos y por
qué:*

1.  Buenos métodos de pronóstico deben tener residuos normalmente
    distribuidos.
2.  Un modelo con residuos pequeños va a producir buenos pronósticos.
3.  La mejor medida de precisión del pronóstico es el MAPE.
4.  Si el modelo no pronostica bien, debería hacerlo más complicado.
5.  Siempre hay que escoger el modelo con la mejor precisión en el
    pronóstico, medido a través del conjunto de prueba (pronóstico).
