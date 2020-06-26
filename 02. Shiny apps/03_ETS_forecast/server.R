# Server
library(shiny)

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
    # Datos reactivos ####
    econ <- reactive({
        economia %>% 
            filter(Country == input$pais,
                   Indicador %in% c(input$indicadores))
    })
    
    econ_fit <- reactive({
        econ() %>% 
            model(modelos[[input$modelo]]
            )
    })

    # Tab 1 - Gráfica de tiempo ####
    output$time_plot <- renderPlotly({
        econ() %>% 
            ggplot(aes(x = Year, y = Valor, color = Indicador)) +
            geom_line(size = 1) +
            facet_wrap(~ Indicador, scales = "free_y") +
            theme(legend.position = "none")
    })
    
    # Tab 2 - Ajuste del modelo ####
    output$report <- renderPrint({
        econ_fit() %>% 
            report()
    })
    
    output$fit <- renderPlotly({
        econ() %>% 
            ggplot(aes(x = Year, y = Valor, color = Indicador)) +
            geom_line(size = 1) +
            geom_line(aes(y = .fitted), linetype = "dashed", size = 1, data = augment(econ_fit())) +
            facet_wrap(~ Indicador, scales = "free_y") +
            theme(legend.position = "none")
    })
    
    output$fit_accuracy <- renderTable({
        accuracy(econ_fit())
    })
    
    # Tab 3 - Diagnóstico de residuos ####
    output$resid_plot <- renderPlot({
        econ_fit() %>% 
            gg_tsresiduals() + 
            ggtitle(paste("Diagnóstico de residuos para el modelo",
                          input$modelo, sep = " "))
    })
    
    output$portmanteau <- renderPrint({
        augment(econ_fit()) %>% 
            features(.resid, ljung_box, lag = 10, dof = 0)
    })
    
        

})
