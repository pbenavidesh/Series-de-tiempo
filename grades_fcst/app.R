# Calificaciones Series de tiempo P2020
# 
#
# pkgs
library(shiny)
library(tidyverse)
# data
df <- read_csv("grades.csv")
df <- df %>% 
    filter(Estatus == "Activo") %>% 
    select(-c("Estatus")) %>% 
    pivot_longer(cols = `Examen 1`:`Tarea 12`,
                 names_to = c("Rubro"),
                 values_to = "Calificación",
                 values_drop_na = T) %>%
    mutate(Rubro =
           str_replace(Rubro,"Puntos extra", "Tarea 0")
           ) %>% 
    separate(Rubro,into = c("Rubro", "Num"),sep = " ") %>% 
    mutate(Num = as.numeric(Num))

# UI
    # Define UI for application that draws a histogram
ui <- fluidPage(

    # Application title
    titlePanel("Calificaciones Series de tiempo P2020"),
    tabsetPanel(
        tabPanel("Calificaciones globales",
                 plotOutput("res_glob")
                 ),
        tabPanel("Calificaciones individuales",
                 sidebarLayout(
                     sidebarPanel(
                         numericInput(inputId = "Exp",
                                      label = "Expediente",
                                      min = 0,step = 1,
                                      value = 0),
                         numericInput(inputId = "Ex3",
                                      label = "Calificación examen 3 (del 0 al 10)",
                                      min = 0, max = 10,
                                      step = 0.1,
                                      value = 10),
                         numericInput(inputId = "Proy",
                                      label = "Calificación del proyecto final (del 0 al 10)",
                                      min = 0, max = 10,
                                      step = 0.1,
                                      value = 10)
                     ),
                     
                     # Show a plot of the generated distribution
                     mainPanel(
                         tableOutput("c_final"),
                         tableOutput("califs")
                         
                         
                     )
                 )

        )
    )

)
# server
# Define server logic required to draw a histogram
server <- function(input, output) {
    Data <- reactive({
        df %>% 
            filter(Exp == input$Exp)
    })
    
    output$res_glob <- renderPlot({
        grupo <- c("lunes-jueves","martes-viernes")
        names(grupo) <- c("MAF3074A","MAF3074B")
        df %>%
            group_by(Grupo,Sexo,Exp,Rubro) %>%
            summarise(Calificación = mean(Calificación)) %>% 
            ggplot(aes(x = Rubro, y = Calificación, color = Sexo)) + 
            geom_boxplot() + 
            facet_wrap(~ Grupo, scales = "free",
                       labeller = labeller(Grupo = grupo)) +
            theme(strip.text = element_text(size = 14,
                                            face = "bold"),
                  text = element_text(size = 16))+
            xlab("")
        
    })
    
    output$c_final <- renderTable({
        calif_previa <- Data() %>% 
            group_by(Grupo, Sexo, Exp, Rubro) %>%
            summarise(Calificación = mean(Calificación))
        examenes <- calif_previa %>%
            filter(Rubro == "Examen") 
        examenes <- (examenes$Calificación * 2 +
                         input$Ex3) / 3
        tareas <- calif_previa %>%
            filter(Rubro == "Tarea")
        tareas <- tareas$Calificación
        proyecto <- input$Proy
        tibble(Exámenes = examenes,
               Tareas = tareas,
               Proyecto = proyecto,
               `Calificación final` = examenes * 0.6 +
                   tareas * 0.2 + proyecto * 0.2)
        
    })

    output$califs <- renderTable({
        Data() 
            
    })
}

# Run the application 
shinyApp(ui = ui, server = server)

# to deploy the app:
# options(encoding = "UTF-8")
# rsconnect::deployApp(appDir = "grades_fcst")