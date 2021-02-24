library(shiny)

# Define UI for application that draws a histogram
shinyUI(fluidPage(

  # Application title
  titlePanel(expression("Calcium imaging analysis")),

  # Sidebar with a slider input for number of bins
  sidebarLayout(
    sidebarPanel(
       fileInput("dataset", "File:"),
       numericInput("freq", "Sampling freq (Hz):", value = 0.5),
       sliderInput("baseline", "Baseline window:",
                   min = 0, max = Inf, value = c(0, Inf)),
       sliderInput("time", "Data window:", min = 0, max = Inf, value = c(0, Inf)),
       checkboxInput("legend", "Show legend", value = TRUE),
       radioButtons("plottype", "dF/F0 plot type:",
                    choices = c("Line" = "lineplot", "Heatmap" = "heatmap"),
                    selected = "lineplot", inline = TRUE),
       radioButtons("grouped", "Data presentation:",
                    choices = c("Individual", "Average"),
                    selected = "Individual", inline = TRUE),
       checkboxGroupInput("cells", "Cells:", choices = NULL)
    ),

    # Show a plot of the generated distribution
    mainPanel(
       plotOutput("raw_plot"),
       plotOutput("data_plot"),
       downloadButton("download", "Download")
    )
  )
))
