            # # # # # # # # # # # # # # # # #
            #     Introducción a R          #
            # - - - - - - - - - - - - - - - #
            #     Series de tiempo          #
            #     Pablo Benavides-Herrera   #
            #     2020-05-25                #
            #                               #
            # # # # # # # # # # # # # # # # #

# Introducción -------------------------------------------------

# Cuando se trabaja en RStudio, podemos crear proyectos
# (Rproj) que nos permiten organizar nuestro análisis de datos,
# junto con las tablas originales, los resultados, etc., de 
# tal manera que es muy fácil de compartir y replicar por otras
# personas o en otros equipos.
#
# Este es un Rscript. Aquí se pueden almacenar funciones,
# comandos y demás procedimientos que se quieran realizar,
# para que sean replicables. (También existen RNotebooks,
# presentaciones, Shiny apps, entre otras que veremos
# más adelante).
# 
# Para escribir comentarios, se escribe un "#" al inicio 
# de la línea. Los comentarios son ignorados por R al 
# ejecutar las funciones.
# 
# Para dar claridad al código, se puede separar por secciones,
# agregando un título a la sección y posteriormente incluyendo
# al menos 4 "#" consecutivos. (También funciona con 4 guiones
# seguidos "----"). Otra manera de agregar secciones es con el
# atajo de teclado (CTRL + Shift + R / Cmd + Shift + R). 
# 
# Otra ventaja de incluir secciones en su código es que eso te
# permite navegar de manera rápida entre ellas.
# 
# Otro atajo del teclado que es muy útil es (CTRL + Enter), que
# sirve para correr la línea de código seleccionada. P. ej.

print("¡Hola, mundo!")

# Carga de paqueterías ----------------------------------------
# Una buena práctica es cargar todas las paqueterías necesarias
# al inicio del código, junto con variables que se especifiquen
# manualmente. Esto permite ser más claros sobre prerrequisitos
# o consideraciones que se realizan.

# Cargamos las paqueterías necesarias
library(tidyverse)
library(lubridate)
library(patchwork)

# variables manuales
x <- 3
y <- 8
z <- x + y


# Datos --------------------------------------------------------

# Utilizaremos un dataset precargado en R llamado "mpg".
# Este dataset ya viene con una estructura de tibble y
# parecen estar limpios los datos.

data(mpg)

mpg

# Después de analizar cada variable, vemos que las vars.
# categóricas (factores) están marcadas como "chr"
# (character o texto), por lo cual sería conveniente cambiar
# algunas de ellas a factores.

# Si queremos cambiar el fabricante a factor y hwy (que está
# medida en "millas por galón" a "km por litro"), podemos usar
# mutate():

mpg <- mpg %>% 
  mutate(manufacturer = as_factor(manufacturer),
         hwy = hwy * 1.609 / 3.785)

mpg

# Si queremos aplicar la misma transformación a varias vars.
# podemos usar mutate_at() para escoger las variables, o
# mutate_if() para que, con base en una condición, R escoja
# las variables a modificar:

mpg <- mpg %>% 
  mutate_at(.vars = c("class",
                      "drv",
                      "cyl"), .funs = as_factor) %>% 
  mutate(trans = fct_lump_min(trans, 5, other_level = "Otros"))
mpg


# Gráficas con ggplot2 ----------------------------------------

# Teniendo nuestros datos ya limpios, podemos proceder a 
# graficarlos y conocer varios tipos de gráficas que se 
# pueden hacer con ggplot2.

# Graficaaremos la var. displ en el eje x y la variable
# hwy en el eje y. Haremos un diagrama de dispersión
ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy))

# Un gráfico de ggplot siempre comenzará con la función
# ggplot(), que genera un sistema de coordenadas, al que
# agregamos capas. En este caso, agregamos una capa de 
# "puntos", mapeando, a traves de aes() las variables x ^ y.
# 

# Modificar el color, forma y tamaño --------------------------

# Ahora queremos cambiar el color de los puntos, de acuerdo
# a una tercera variable, la clase de auto.

ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy, color = class))

# De forma alternativa, pudimos haber cambiado la forma 
# de los puntos, dependiendo la clase (en vez del color),
# con shape

ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy, shape = class))

# O la transparencia de los mismos con alpha:

ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy, alpha = class))

# O el tamaño con size

ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy, size = class))

# Si, por otro lado, se quisiera cambiar alguno de esos
# atributos por default, sin que éstos dependan de alguna 
# variable, se puede hacer si se especifican fuera del aes()

ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy), color = "blue")


# Cuidado, porque si se pone dentro del aes() no va a dar el 
# resultado que buscamos:

ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy, color = "blue"))


# También se pueden juntar varios de estos atributos al mismo
# tiempo, si eso se deseara

ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, 
                           y = hwy,
                           color = class,
                           shape = drv,
                           size = cyl),
             alpha = 0.7)


# Varios gráficos en la misma imagen con patchwork -----------

# Los gráficos que recién creamos pueden ser almacenados en 
# variables. La paquetería patchwork nos permite juntar
# dos o más gráficas de ggplot en una sola imagen. Retomemos
# algunas de las gráficas anteriores.

# el nombre se escoge arbitrariamente
g1 <- ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy))+
  ggtitle("La gráfica más básica")

g2 <- ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy, color = class))+
  ggtitle("Color variable")

g3 <- ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy), color = "blue")+
  ggtitle("Color fijo")

g4 <- ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, 
                           y = hwy,
                           color = class,
                           shape = drv,
                           size = cyl),
             alpha = 0.7) + 
  ggtitle("Col, forma y tam var, alpha fija")

# El acomodo se puede guardar en una variable también:
fig1 <- g1 /
  (g2 + g3) /
  g4

fig1

# Se pueden agregar títulos y subtítulos globales

fig1 + 
  plot_annotation(title = "Gráficas con ggplot2",
                  subtitle = "Cambiando la estética de varias maneras")

(g1 + plot_spacer()) /
  (g4) /
  (g2 + g3) 
  plot_annotation(title = "Gráficas con ggplot2",
                  subtitle = "Otro acomodo distinto")

# Otra opción para personalizar gráficas es utilizar
# facetas (facets)

ggplot(data = mpg) + 
    geom_point(mapping = aes(x = displ, 
                             y = hwy,
                             color = class,
                             shape = drv),
               alpha = 0.7) + 
    ggtitle("Col, forma y tam var, alpha fija") +
  facet_wrap(~ cyl)

# Las facetas se pueden poner en ambos ejes también con
# facet_grid()

ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, 
                           y = hwy,
                           color = class),
             alpha = 0.5) + 
  ggtitle("Color variable, alpha fija y facetas por tracción y cilindraje") +
  facet_grid(cyl ~ drv)


# Gráficas de líneas --------------------------------------------

# Otro tipo de gráfico muy utilizado es el de líneas.
data("economics")

economics # para ver los datos en la consola. Se puede ver 
# la tabla completa con view(economics), o haciendo clic en
# los datos en el panel del lado derecho "Environment".

help("economics") # para ver la documentación de los datos
# funciona también para todas las funciones.

# Ver algunas diferencias entre un objeto tibble y un 
# data.frame tradiciona
as.data.frame(economics)

# Graficar el desempleo a lo largo del tiempo
ggplot(economics,
       aes(x = date, y = unemploy)) + 
  geom_line()


ggplot(economics %>% filter(date>=ymd("2006-01-01")),
       aes(x = date, y = unemploy)) + 
  geom_line() + geom_point(size = 1)

