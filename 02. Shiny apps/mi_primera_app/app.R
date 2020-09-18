# Mi primera app con Shiny y R

# pkgs --------------------------------------------------------------------

library(shiny)
library(tidyverse)
library(gapminder)


# data --------------------------------------------------------------------

paises <- gapminder %>% 
  distinct(country)

indicadores <- names(gapminder)[4:6]

# otras maneras de obtener los nombres de las variables deseadas:
# names(gapminder)[-c(1:3)]
# 
# gapminder %>%
#     select(4:6) %>%
#     names()
# 
# gapminder %>%
#     select(lifeExp:gdpPercap) %>%
#     names()
# 
# gapminder %>%
#     select(-c(country:year)) %>%
#     names()



# Interfaz del usuario ----------------------------------------------------

# En la interfaz de usuario (UI) se define cómo queremos que se
# presente la app para el usuario final. Aquí se agregan títulos,
# textos, botones, casillas, listas (inputs) y tablas, gráficas, 
# resultados (outputs)

ui <- fluidPage(
  titlePanel("Mi primera app - Gapminder"),
  
  selectInput(
    inputId = "pais",
    label = "Selecciona el país",
    choices = paises,
    selected = "New Zealand"
    
  ),
  
  
  radioButtons(
    inputId = "variable",
    label = "Escoge la variable a graficar",
    choices = indicadores,
    selected = "gdpPercap",
    inline = TRUE
  ),
  
  tableOutput(outputId = "tabla1"),
  
  plotOutput(outputId = "grafica1")
  
  
  
) # fluidPage



# Servidor ----------------------------------------------------------------
# En el servidor se llevan a cabo todos los cálculos, gráficas, tablas,
# etc.
server <- function(input, output, session) {
  # voy a crear una variable con los datos, que se esté filtrando de
  # manera interactiva de acuerdo a los inputs seleccionados
  
  # df <- reactive({
  #     gapminder %>% 
  #         filter(country == input$pais) %>% 
  #         select(country, continent, year, input$variable)
  # })
  
  output$tabla1 <- renderTable({
    gapminder %>% 
      filter(country == input$pais) %>% 
      select(country, continent, year, input$variable)
    
  })
  
  output$grafica1 <- renderPlot({
    gapminder %>% 
      filter(country == input$pais) %>% 
      select(country, continent, year, input$variable) %>% 
      ggplot(aes(x = year)) +
      geom_line(aes_string(y = input$variable))
  })
  
  
  
  
}

shinyApp(ui, server)