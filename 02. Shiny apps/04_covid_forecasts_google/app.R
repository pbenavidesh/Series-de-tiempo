# Forecasting mobility trends in the COVID-19 pandemic

# pkgs --------------------------------------------------------------------

library(shiny)
library(shinythemes)
library(tidyverse)
library(tsibble)
library(feasts)
library(fable)
library(plotly)
library(patchwork)

# google data -------------------------------------------------------------

google_df <- read_csv("Global_Mobility_Report.csv", 
                      col_types = cols(sub_region_2 = 
                                           col_character(),
                                       census_fips_code = 
                                           col_character()))

google <- google_df %>%
    select(-c(iso_3166_2_code:census_fips_code)) %>%
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
                                     sub_region_2,
                                     name))


# user interface ----------------------------------------------------------

ui <- fluidPage(theme = shinytheme("superhero"),
    titlePanel("Pronósticos de la movilidad en tiempos de COVID-19"),
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
                selected = levels(google$name)
            )
            
        ),
        mainPanel(
            navbarPage(title = "Análisis",
                # tab 1 - Gráficas ####
                tabPanel("Gráficas", icon = icon("chart-line"),
                         plotlyOutput(outputId = "time_plot")
                ),
                # tab 2 - Modelos ####
                tabPanel("Modelos",
                         
                ),
                # tab 3 - Residuos ####
                tabPanel("Diagnóstico de residuos",
                         
                ),
                # tab 4 - Pronósticos ####
                tabPanel("Pronósticos",
                         
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
}

shinyApp(ui, server)