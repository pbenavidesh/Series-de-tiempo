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
shinyUI(fluidPage( shinythemes::themeSelector(),

    # Application title
    titlePanel("Ajustes, transformaciones y descomposición de series de tiempo"),
    
    tabsetPanel(
        tabPanel("Transformaciones matemáticas",
                 fluidRow(
                     column(12,
                            h1("Transformaciones de Box-Cox"))
                 ),
                 fluidRow(
                     column(4,
                            wellPanel(sliderInput("lambda",
                                        "Valor de lambda:",
                                        min = -1,
                                        max = 2,
                                        value = 0, step = 0.01))),
                     column(8,
                            plotlyOutput("boxcox"))
                 ),
                 hr(),
                 fluidRow(
                   column(12,
                          h1("Escalas logarítmicas en gráficas"))  
                 ),
                 fluidRow(
                     column(4,
                            wellPanel(
                                selectInput("gdp_var",
                                            label = "Variable a graficar",
                                            choices = c("PIB", "PIB per cápita")),
                                checkboxInput("logscale",
                                          label = "Utilizar escala logarítmica",
                                          value = FALSE),
                                checkboxGroupInput("countries",
                                                   label = "Selecciona los países a graficar",
                                                   choices = c("Mexico", "Iceland","Australia",
                                                               "Brazil", "Canada", "China",
                                                               "Germany", "United States"),
                                                   selected = c("Mexico", "Iceland",
                                                                "Australia"))
                                      )
                            ),
                     column(8,
                            plotlyOutput("gdp"))
                 )
                 # , sidebarLayout(
                 #     sidebarPanel(
                 #         sliderInput("lambda",
                 #                     "Valor de lambda:",
                 #                     min = -1,
                 #                     max = 2,
                 #                     value = 0, step = 0.01)
                 #     ),
                 #     
                 #     mainPanel(
                 #         plotOutput("boxcox")
                 #     )
                 # ) # sidebarLayout
        ) # tabPanel
        ) # tabsetPanel
                 ) # fluidPage
    ) #shiny ui

    
