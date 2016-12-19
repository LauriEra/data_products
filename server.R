#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
library(XML)
## Set that strings will not be read in as factors
options(stringsAsFactors = FALSE)
## Define a function for trimming leading and trailing whitespaces
trim <- function (x){  gsub("^\\s+|\\s+$", "",  x)}

## Download weather data from my town
## Get the current time expressed in the local timezone
chosen_tz <- "Europe/Helsinki"
time_current <- Sys.time()
time_current <- as.POSIXlt(time_current,tz=chosen_tz)

## Create the url for fecthing data, based on the current time
urli <- paste("https://www.wunderground.com/history/airport/EFTP/20",(time_current$year-100),"/",
              (time_current$mon+1),"/",time_current$mday,"/DailyHistory.html?req_city=Tampere&req_state=&req_statename=Finland",
             sep = "")
## Read the data from www.wunderground.com
weather <- readHTMLTable(
    readLines(urli)
)
## Select from only the observation data
weather <- weather$obsTable
## Get the temperature as a numeric feature
weather$temp <- as.numeric( 
    sapply(weather[,"Temp."], FUN=function(x)strsplit(x,"\\s")[[1]][1]) 
)
## Get the humidity as a numeric feature
weather$humid <- as.numeric( 
    trim( sub("%","",weather$Humidity,fixed = T) ) 
)
## Get the timestamp as a date.time format understood by R
weather$timestamp <- strptime(weather$`Time (EET)`, format="%H:%M %p")
## Order the observations by time
weather <- weather[order(weather$timestamp),]

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
    
    observeEvent(input$action,{
        showNotification("There can be several measurements for the same timepoint",type="default")
    })
    output$text <- renderText({
        paste("This aplication shows\nthe weather data\nfrom Tampere between\n",
        weather$timestamp[1],"\nand\n",weather$timestamp[nrow(weather)],"\nData from:\nwww.wunderground.com",collapse="  ")
    })
    
    output$humidPlot <- renderPlot({
        limit <- input$hours- 1
        if(limit>=nrow(weather)) limit <- nrow(weather)-1
        limit <- nrow(weather)-limit
        plot(weather$timestamp[limit:nrow(weather)], weather$humid[limit:nrow(weather)],
             xlab="Time", ylab="Humidity %",type="b", col=rgb(0.3,0.8,0.3))
        title(paste("Humidity From",weather$timestamp[nrow(weather)-limit],
                    "\nTo",weather$timestamp[nrow(weather)],collapse = "  "))
    })
    output$tempPlot <- renderPlot({
        limit <- input$hours - 1
        if(limit>=nrow(weather)) limit <- nrow(weather)-1
        limit <- nrow(weather)-limit
        if(sum(!is.na(weather$temp))==0) weather$temp <- rnorm(nrow(weather)) ## A hack in case there are problems
        plot(weather$timestamp[limit:nrow(weather)], weather$temp[limit:nrow(weather)], 
             xlab="Time", ylab="Temperature in degrees Celsius",type="b",col=rgb(0.8,0.3,0.3))
        title(paste("Temperature From",weather$timestamp[nrow(weather)-limit],
                    "\nTo",weather$timestamp[nrow(weather)],collapse = "  "))
    })
})
