#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(colourpicker)

# Define UI for application that draws a histogram
ui <- fluidPage(

    # Application title
    titlePanel("Mi primera app"),

    # Sidebar with a slider input for number of bins 
    sidebarLayout(
        sidebarPanel(
            sliderInput(inputId =  "bins",
                        label = "Número de bins:",
                        min = 1,
                        max = 50,
                        value = 30),
            
            colourInput(inputId = "color",
                        label = "Selecciona el color del gráfico",
                        value = "#1988E3",
                        showColour = "background")
        ),
        # Show a plot of the generated distribution
        mainPanel(
           plotOutput(outputId = "distPlot")
        )
    )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
    
    output$distPlot <- renderPlot({
       geyser <- faithful %>% 
           as_tibble()
       
       bins <- seq(min(geyser$waiting), max(geyser$waiting),
                   length.out = input$bins)
       
       geyser %>% ggplot(aes(x = waiting)) +
           geom_histogram(breaks = bins, fill = input$color)
        
    })

    # output$distPlot <- renderPlot({
    #     # generate bins based on input$bins from ui.R
    #     x    <- faithful[, 2]
    #     bins <- seq(min(x), max(x), length.out = input$bins + 1)
    # 
    #     # draw the histogram with the specified number of bins
    #     hist(x, breaks = bins, col = 'darkgray', border = 'white')
    # })
}

# Run the application 
shinyApp(ui = ui, server = server)
