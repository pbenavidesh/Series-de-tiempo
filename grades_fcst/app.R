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
                 plotOutput("res_glob")#,
                 # plotOutput("res_glob_fin")
                 ),
        tabPanel("Calificaciones individuales",
                 sidebarLayout(
                     sidebarPanel(
                         numericInput(inputId = "Exp",
                                      label = "Expediente",
                                      min = 0,step = 1,
                                      value = 0)#,
                         # numericInput(inputId = "Ex3",
                         #              label = "Calificación examen 3 (del 0 al 10)",
                         #              min = 0, max = 10,
                         #              step = 0.1,
                         #              value = 10),
                         # numericInput(inputId = "Proy",
                         #              label = "Calificación del proyecto final (del 0 al 10)",
                         #              min = 0, max = 10,
                         #              step = 0.1,
                         #              value = 10)
                     ),
                     
                     # Show a plot of the generated distribution
                     mainPanel(
                         splitLayout(cellWidths = c("60%", "40%"),
                             tableOutput("c_final"),
                             htmlOutput("c_boleta"),
                             tags$head(tags$style("#c_boleta{color: blue;
                                    font-size: 20px;
                                    font-style: bold;
                                    text-align: center;
                                    }"
                             )
                             )
                         ), 
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
    
    calif_previa <- reactive({
        c_previa <- Data() %>% 
            group_by(Grupo, Sexo, Exp, Rubro) %>%
            summarise(Calificación = mean(Calificación))
        examenes <- c_previa %>%
            filter(Rubro == "Examen")
        examenes <- examenes$Calificación
        # examenes <- (examenes$Calificación * 2 +
        #                  input$Ex3) / 3 # previo
        tareas <- c_previa %>%
            filter(Rubro == "Tarea")
        tareas <- tareas$Calificación
        # proyecto <- input$Proy # previo
        proyecto <- c_previa %>% 
            filter(Rubro == "Proyecto")
        proyecto <- proyecto$Calificación
        tibble(Exámenes = examenes,
                                Tareas = tareas,
                                Proyecto = proyecto,
                                `Calificación final` = examenes * 0.6 +
                                    tareas * 0.2 + proyecto * 0.2) 
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
        # calif_previa <- Data() %>% 
        #     group_by(Grupo, Sexo, Exp, Rubro) %>%
        #     summarise(Calificación = mean(Calificación))
        # examenes <- calif_previa %>%
        #     filter(Rubro == "Examen")
        # examenes <- examenes$Calificación
        # # examenes <- (examenes$Calificación * 2 +
        # #                  input$Ex3) / 3 # previo
        # tareas <- calif_previa %>%
        #     filter(Rubro == "Tarea")
        # tareas <- tareas$Calificación
        # # proyecto <- input$Proy # previo
        # proyecto <- calif_previa %>% 
        #     filter(Rubro == "Proyecto")
        # proyecto <- proyecto$Calificación
        # tibble(Exámenes = examenes,
        #        Tareas = tareas,
        #        Proyecto = proyecto,
        #        `Calificación final` = examenes * 0.6 +
        #            tareas * 0.2 + proyecto * 0.2)
    calif_previa()    
    })
    
    output$c_boleta <- renderText({
        paste("Calificación final del semestre:", "<br>", round(c(calif_previa()$`Calificación final`))
        )
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