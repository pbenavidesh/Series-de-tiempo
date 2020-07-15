# Forecasting mobility trends in the COVID-19 pandemic

# pkgs --------------------------------------------------------------------

library(shiny)
library(shinythemes)
library(urca)
library(tidyverse)
library(tsibble)
library(feasts)
library(fable)
library(plotly)
library(patchwork)
library(lubridate)
library(fable.prophet)

# google data -------------------------------------------------------------

google_df <- read_csv("Global_Mobility_Report.csv", 
                      col_types = cols(sub_region_2 = 
                                           col_character(),
                                       census_fips_code = 
                                           col_character()))

google <- google_df %>%
    select(-c(sub_region_2:census_fips_code)) %>%
    pivot_longer(cols = -c(country_region_code:date)) %>%
    mutate(name = str_replace(name, 
                              pattern = 
                                  "_percent_change_from_baseline",
                              ""),
           sub_region_1 = if_else(is.na(sub_region_1),
                                  country_region,
                                  sub_region_1),
           value = value / 100,
           date = dmy(date)) %>%
    mutate_if(is.character,as_factor) %>% 
    mutate(name_label = sprintf("%.2f%%", value * 100)) %>% 
    as_tsibble(index = date, key = c(country_region, 
                                     sub_region_1,
                                     name))

# modelos a utilizar

models <- c("SNAIVE", "ETS", "ARIMA",
            "Prophet", "Regression","Harmonic reg.",
            "Piecewise reg.")

# user interface ----------------------------------------------------------

ui <- fluidPage(theme = shinytheme("superhero"),
    titlePanel(tags$div(HTML('<i class="fa fa-biohazard" style = "color:#FF7B00;"></i>
    Pronósticos de la movilidad en tiempos de COVID-19 
                             <i class="fa fa-head-side-cough" style = "color:#FF7B00;"></i>')),
               windowTitle = "Pronósticos de la movilidad en tiempos de COVID-19"),
    sidebarLayout(
        sidebarPanel(
            selectInput(inputId = "pais",
                        label = "Selecciona el país",
                        choices = levels(google$country_region),
                        selected = "Mexico"
            ),
            uiOutput(outputId = "region"),
            
            checkboxGroupInput(inputId = "sector",
                label = "Selecciona los sectores deseados",
                choices = levels(google$name),
                selected = levels(google$name),
                inline = TRUE
            ),
            
            checkboxGroupInput(inputId = "modelos",
              label = "Escoge los modelos a estimar",
              choices = models,
              selected = models[1],
              inline = TRUE
            )
            
        ),
        mainPanel(
            navbarPage(title = "Análisis",
                # tab 1 - Gráficas ####
                tabPanel("Gráficas", icon = icon("chart-line"),
                         plotlyOutput(outputId = "time_plot")
                ),
                # tab 2 - Modelos ####
                tabPanel("Modelos", icon = icon("space-shuttle"),
                         wellPanel(
                           uiOutput(outputId = "output_sector"),
                           uiOutput(outputId = "output_radio")
                         ),
                         tabsetPanel(type = "pills",
                           tabPanel("Reporte", icon = icon("galactic-republic"),
                              verbatimTextOutput(outputId = "report")
                           ),
                           tabPanel("Ajuste vs. entrenamiento", icon = icon("old-republic"), 
                              dataTableOutput("fit_accuracy")
                           ),
                           tabPanel("Diagnóstico de residuos", icon = icon("mandalorian"),
                             plotOutput("resid")
                           )
                         )
                ),
                # tab 3 - Pronósticos ####
                tabPanel("Pronósticos", icon = icon("jedi"),
                         sliderInput(inputId = "horizonte",
                           label = "Selecciona el horizonte de pronóstico",
                           min = 1, max = 60, value = 14
                         ),
                         plotOutput("forecast", width = "100%")
                )
            ) # navbarPage
            
        ) # main Panel
        
        
        ) # sidebarLayout
    ) # fluidPage
# server ------------------------------------------------------------------

server <- function(input, output, session) {
  output$region <- renderUI({
      selectInput(inputId = "estado",
                  label = "Selecciona el estado/región",
                  choices = google %>% filter(country_region == input$pais) %>% 
                      distinct(sub_region_1) %>% pull(),
                  selected = "Jalisco"
                  )
  })
  
  df <- reactive({
      google %>% 
          filter(
              country_region == input$pais,
              sub_region_1 == input$estado,
              name %in% c(input$sector)
          )
  })
  
  fit <- reactive({
    df() %>% 
      model(
        SNAIVE = SNAIVE(value),
        ETS = ETS(value),
        ARIMA = ARIMA(value),
        Prophet = prophet(value),
        Regression = TSLM(value ~ trend() + season()),
        `Harmonic reg.` = ARIMA(value ~ fourier(K = 2) + PDQ(0,0,0)),
        `Piecewise reg.` = TSLM(value ~ trend(knots = c(ymd("2020-03-18"), 
                                                        ymd("2020-05-03"))) + 
                                  season())
      )
  })
  
  forecast <- reactive({
    fit() %>% 
      fabletools::forecast(h = input$horizonte)
  })

  # tab 1- Gráficas ####
  output$time_plot <- renderPlotly({
      p <- df() %>% 
          ggplot(aes(x = date, y = value,
                     color = name,
                     label = name_label)) +
          geom_line() +
          geom_hline(yintercept = 0,
                     linetype = "dashed",
                     color = "firebrick") +
          annotate("text", label = "Línea base", 
                   x = last(google$date)-5, y = 0.05, 
                   size = 3, color = "firebrick") + 
          guides(color = guide_legend(title = NULL)) +
          scale_y_continuous(labels = scales::percent )+
          ggtitle(paste0("Tendencias de movilidad en ",input$estado,
                        ", ", input$pais))
      
      ggplotly(p, tooltip = c("x", "label", "color"))
  })
  
  # tab 2 - Modelos ####
  output$output_sector <- renderUI({
    radioButtons(inputId = "radio_series",
                 label = "La serie a reportar",
                 choices = input$sector,
                 selected = input$sector[1],
                 inline = TRUE
    )
  })
  
  output$output_radio <- renderUI({
    radioButtons(inputId = "radio_models",
                 label = "El modelo a reportar",
                 choices = input$modelos,
                 selected = input$modelos[1],
                 inline = TRUE
    )
  })
  
  output$report <- renderPrint({
    fit() %>% 
      select(input$radio_models) %>%
      filter(name == input$radio_series) %>% 
      report()
  })
  
  output$fit_accuracy <- renderDataTable({
    fit() %>% 
      select(1:3,input$modelos) %>% 
      accuracy()
  })
  
  output$resid <- renderPlot({
    fit() %>% 
      select(input$radio_models) %>% 
      filter(name == input$radio_series) %>% 
      gg_tsresiduals() +
      ggtitle(paste0("Diagnóstico de residuos para el modelo ", input$radio_models, 
                     " de la serie ", input$radio_series, " en ", 
                     input$estado, ", ", input$pais))
  })
  
  # tab 3 - Pronósticos ####
  
  output$forecast <- renderPlot({
    forecast() %>% 
      filter(.model %in% input$modelos) %>% 
      autoplot(df(), size = 1,
               level = if (length(input$modelos) == 1) {c(80,95)} else {NULL}
                 ) +
      geom_hline(yintercept = 0,
                 linetype = "dashed", 
                 color = "firebrick") +
      annotate("text", label = "Línea base", 
               x = last(google$date)-5, y = 0.05, 
               size = 3, color = "firebrick") +
      scale_y_continuous(labels = scales::percent)+
      labs(x = "Fecha", y = "Cambio %")
      
      
  }, height = function(){300* length(input$sector)})
  
}

shinyApp(ui, server)