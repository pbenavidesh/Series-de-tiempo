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
    sidebarLayout(position = "left",
        sidebarPanel(
            selectInput(inputId = "pais",
                        label = "Selecciona el país",
                        choices = paises,
                        selected = "Mexico"),
            checkboxGroupInput(inputId = "indicadores",
                               label = "Selecciona los indicadores a graficar",
                               choices = levels(economia$Indicador),
                               selected = levels(economia$Indicador),
                               inline = TRUE),
            radioButtons(inputId = "modelo",
                        label = "Selecciona el modelo a ajustar",
                        choices = names(modelos),
                        selected = "Drift",
                        inline = TRUE)
        ), # sidebarPanel

        # Show a plot of the generated distribution
        mainPanel(
            tabsetPanel( type = "tabs",
                         tabPanel(title = "Gráfica de tiempo",
                                  plotlyOutput(outputId = "time_plot")
                             
                         ),
                         tabPanel(title = "Ajuste del modelo",
                                  verbatimTextOutput(outputId = "report"),
                                  plotlyOutput(outputId = "fit"),
                                  tableOutput(outputId = "fit_accuracy")
                             
                         ),
                         tabPanel(title = "Diagnóstico de residuos",
                                  h3("Análisis gráfico"),
                                  plotOutput(outputId = "resid_plot"),
                                  h3("Tests de Portmanteau"),
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
