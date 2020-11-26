# Pronósticos a escala
# Empleo en EEUU
# Pablo Benavides Herrera
# 2020-11-13
# Series de tiempo


# pkgs --------------------------------------------------------------------

library(tidyverse)
library(tsibble)
library(feasts)
library(fable)
library(tsibbledata)
library(fpp3)
library(shiny)
library(shinythemes)
library(shinyWidgets)
library(plotly)


# DATA --------------------------------------------------------------------

empleo <- us_employment %>% 
    as_tsibble(key = Title) %>% 
    select(-Series_ID) %>% 
    drop_na()

sectores <- empleo %>% distinct(Title) %>% pull()

# UI ----------------------------------------------------------------------

ui <- fluidPage(
  # Agregar un tema a la app
  theme = shinytheme("yeti"),
  
  # título principal de la app
  titlePanel("Pronósticos a escala"),
  
  
  # * sidebarLayout --------------------------------------------------
  sidebarLayout(
      sidebarPanel(width = 2,
          pickerInput(
              inputId  = "sector",
              label    = "Escoge los sectores de la economía a analizar",
              choices  = sectores,
              multiple = TRUE,
              selected = "Retail Trade",
              options = list(
                  `actions-box` = TRUE,
                  size = 10,
                  `selected-text-format` = "count > 3"
              )
          ),
          switchInput(
              inputId = "log",
              label   = "Utilizar logaritmos" 
          )
      ),
      mainPanel(width = 10,
          # Separación de la app en páginas de navegación
          navbarPage(title = "Empleo en EEUU",
                     
                     # * tabPanel Datos --------------------------------------------------------
                     tabPanel(title = "Datos",
                              plotlyOutput(outputId = "timeplot")
                     ),
                     
                     # * tabPanel Modelos ------------------------------------------------------
                     tabPanel(title = "Modelos",
                              selectInput(
                                  inputId = "models",
                                  label   = "Escoge el modelo a mostrar",
                                  choices = c("Ingenuo estacional", 
                                              "Suavización exponencial",
                                              "ARIMA")
                              ),
                              verbatimTextOutput(outputId = "model_report"),
                              
                              h2("Ajuste de los datos de entrenamiento"),
                              tableOutput(outputId = "model_train_accuracy")
                     ),
                     
                     # * tabPanel Pronósticos --------------------------------------------------
                     tabPanel(title = "Pronósticos",
                              knobInput(
                                  inputId = "horizonte",
                                  label   = "Establece el horizonte de pronóstico (en meses)",
                                  value   = 24,
                                  min     = 1,
                                  max     = 120 
                              ),
                              plotOutput(outputId = "forecasts_plot")
                     )
                     
          ) # navbarPage
      ) # mainPanel
  ) # sidebarLayout
  
  
) # fluidPage


# SERVER ------------------------------------------------------------------

server <- function(input, output, session) {
  df <- reactive({
      empleo %>% 
          filter(Title %in% input$sector)
  })
  
  fit <- reactive({
      if(input$log) {
          df() %>% 
              model(
                  `Ingenuo estacional`      = SNAIVE(log(Employed)),
                  `Suavización exponencial` = ETS(log(Employed)),
                  ARIMA                     = ARIMA(log(Employed))
              )
      } else {
          df() %>% 
              model(
                  `Ingenuo estacional`      = SNAIVE(Employed),
                  `Suavización exponencial` = ETS(Employed),
                  ARIMA                     = ARIMA(Employed)
              )
      }
  })
  
  fcst <- reactive({
      fit() %>% 
          forecast(h = input$horizonte)
  })
  
  output$timeplot <- renderPlotly({
      df() %>% 
          ggplot(aes(x = Month, y = if(input$log){log(Employed)} else{Employed}, color = Title)) +
          geom_line() +
          ylab("Empleo") +
          theme(legend.position = "none")
  })
  
  output$model_report <- renderPrint({
      fit() %>% select(input$models) %>% report()
  })
  
  output$model_train_accuracy <- renderTable({
      fit() %>% accuracy()
  })
  
  output$forecasts_plot <- renderPlot({
      fcst() %>% 
          autoplot(empleo)
  })
}

shinyApp(ui, server)
