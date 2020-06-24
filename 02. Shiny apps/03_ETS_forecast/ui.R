#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)

# Define UI for application that draws a histogram
shinyUI(fluidPage( theme = shinytheme("spacelab"),
                   # themeSelector(),

    # Application title
    titlePanel("Pronósticos con suavización exponencial"),

    # Sidebar with a slider input for number of bins
    sidebarLayout(position = "right",
        sidebarPanel(
            selectInput(inputId = "pais",
                        label = "Selecciona el país",
                        choices = paises,
                        selected = "Mexico")
        ), # sidebarPanel

        # Show a plot of the generated distribution
        mainPanel(
            tabsetPanel( type = "tabs",
                         tabPanel(title = "Gráfica de tiempo",
                                  plotOutput(outputId = "time_plot")
                             
                         ),
                         tabPanel(title = "Ajuste del modelo",
                                  plotOutput(outputId = "fit"),
                                  verbatimTextOutput(outputId = "report"),
                                  tableOutput(outputId = "fit_accuracy")
                             
                         ),
                         tabPanel(title = "Diagnóstico de residuos",
                                  plotOutput(outputId = "resid_plot"),
                                  verbatimTextOutput(outputId = "portmanteau")
                         ),
                         tabPanel(title = "Pronóstico",
                                  plotOutput(outputId = "fcst"),
                                  tableOutput(outputId = "fcst_accuracy")
                             
                         )
                
            )
            
        )
    )
))
