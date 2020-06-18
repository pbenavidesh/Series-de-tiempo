library(shiny)
library(tidyverse)
library(fpp3)

paises <- global_economy %>% distinct(Country) %>% pull() %>%
    as.character()

indicadores <- names(global_economy)[-c(1:3)]

ui <- fluidPage(
  titlePanel("Economía global"),
  
  sidebarLayout(
      sidebarPanel(
          selectInput(inputId = "pais",
                      label = "Selecciona el país",
                      choices = paises,
                      selected = "Germany"
                      ),
          selectInput(inputId = "indicador",
                      label = "Selecciona el indicador",
                      choices = indicadores,
                      selected = "GDP"
          )
      ),
      mainPanel(
          plotOutput(outputId = "plot")
      )
  )
)

server <- function(input, output, session) {
    
    output$plot <- renderPlot({
        global_economy %>% 
            filter(Country == input$pais) %>% 
            ggplot(aes_string(x = "Year", y = input$indicador)) +
            geom_line(size = 1, color = "orchid3")
    })
  
}

shinyApp(ui, server)