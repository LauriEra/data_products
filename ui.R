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
shinyUI(fluidPage(
    
    # Application title
    titlePanel("My towns weather"),
    
    # Sidebar with a slider input for number of bins 
    sidebarLayout(
        sidebarPanel(
            numericInput("hours",
                         "How many latest points of data:",
                         min = 1,
                         max = 26,
                         value = 26),
            #submitButton("Update"),
            actionButton("action","Info"),
            verbatimTextOutput("text")
        ),
        # Show a plot of the generated distribution
        mainPanel(
            tabsetPanel(
                tabPanel(
                    "Humidity",plotOutput("humidPlot")
                ),
                tabPanel(
                    "Temperature",plotOutput("tempPlot")
                )
                
            ))
    )
))
