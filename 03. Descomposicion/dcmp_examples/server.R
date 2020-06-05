#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
# Transformaciones matemáticas ####
    output$boxcox <- renderPlotly({
          aus_production %>%
            autoplot(box_cox(Gas,lambda = input$lambda)) + 
            labs(title =  "Producción de gas en Australia",
                 x = "Año", y = "(petajoules)")
        })
    gdp_vars <- reactive({
        glob_econ %>% 
            select(Country, Year, gdp = input$gdp_var)
    })

    output$gdp <- renderPlotly({
        ge <- gdp_vars() %>% 
            filter(Country %in% input$countries) 
            gg <- ggplot(ge) + 
                aes(x = Year, y = gdp, color = Country) +
                geom_line() + ylab("$USD") + xlab("Año") +
                guides(color = FALSE) +
                theme(legend.position = "top") +
                ggtitle(paste("Comparación del", input$gdp_var,
                              "entre países", sep = " "))
            if (input$logscale == TRUE) {
                gg + scale_y_log10()
                
            } else {
                gg
            }
                    
                    
    })
})
