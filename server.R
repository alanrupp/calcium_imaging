library(shiny)

# Define server logic required to draw a histogram
shinyServer(function(input, output, session) {

  # set up reactive values to stash data
  values <- reactiveValues()

  observeEvent(input$dataset, {

    # read in data
    values[["df"]] <- read_data(input$dataset$datapath)

    # make data point number into time
    values$df <- make_time(values$df, input$freq)

    # plot raw data
    output$raw_plot <- renderPlot({
      rawplot(values$df, baseline = input$baseline, data_window = input$time,
              show_legend = input$legend)
    })

    # update selected baseline
    updateSliderInput(session, "baseline", label = "Baseline window:",
                      value = c(min(values$df$Time),
                                (max(values$df$Time)-min(values$df$Time))*0.1 +
                                  min(values$df$Time)
                                ),
                      min = min(values$df$Time), max = max(values$df$Time))

    # update slider values
    updateSliderInput(session, "time", label = "Data window:",
                      value = c(min(min(values$df$Time), input$baseline[2]),
                                max(values$df$Time)),
                      min = min(values$df$Time), max = max(values$df$Time))

    # update cell checkbox options
    cell_list <- list("Cells" = sort(unique(values$df$Cell)))
    updateCheckboxGroupInput(session, "cells", "Cells:",
                             choices = sort(unique(values$df$Cell)),
                             selected = sort(unique(values$df$Cell)))

    # plot data
    output$data_plot <- renderPlot({

      if (input$plottype == "lineplot") {
        lineplot(values$df, baseline = input$baseline,
                 data_window = input$time,
                 input$grouped, cells = input$cells,
                 show_legend = input$legend)
      } else if (input$plottype == "heatmap") {
        heatmap(values$df, baseline = input$baseline,
                data_window = input$time,
                grouped = input$grouped, cells = input$cells)
      }

    })

    # download
    output$download <- downloadHandler(
      filename = function() {
        "download.xlsx"
      },
      content = function(file) {
        writexl::write_xlsx(
          summarize_data(values$df, baseline = input$baseline,
                         data_window = input$time,
                         input$grouped, cells = input$cells),
          file)
      }
    )

  })

})
