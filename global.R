library(ggplot2)
library(dplyr)
library(tidyr)

# read data in
read_data <- function(file) {
  df <- readxl::read_xlsx(file)
  df <- gather(df, -Time, key = "Cell", value = "Ca")
  return(df)
}

# turn data points into times based on frequency
make_time <- function(df, freq) {
  df <- mutate(df, Time = Time / freq)
  df <- mutate(df, Time = Time - min(Time))
  return(df)
}

# set up default parameters
cell_list <- NULL

# plot the raw data
rawplot <- function(df, baseline = c(0, 0), data_window = c(0, 0)) {
  p <- ggplot(df, aes(x = Time, y = Ca, color = Cell)) +
    geom_line() +
    theme_classic() +
    xlab("Time (s)") +
    ylab("Fluorescence") +
    scale_x_continuous(expand = c(0, 0)) +
    scale_y_continuous(expand = c(0, 0)) +
    theme(axis.text = element_text(color = "black"),
          plot.title = element_text(hjust = 0.5)) +
    ggtitle("Raw data")
  # add baseline
  p <- p + 
    annotate("text", x = mean(baseline), y = max(df$Ca), 
             label = "Baseline", vjust = 1) +
    annotate("rect", xmin = baseline[1], xmax = baseline[2],
             ymin = min(df$Ca), ymax = max(df$Ca),
             fill = alpha('gray', 0.3)) +
    annotate("text", x = mean(data_window), y = max(df$Ca), 
             label = "Data", vjust = 1) +
    annotate("rect", xmin = data_window[1], xmax = data_window[2],
             ymin = min(df$Ca), ymax = max(df$Ca),
             fill = alpha('gray', 0.3))
  return(p)
}

summarize_data <- function(df, baseline = c(0, 0), data_window = c(0, 0), 
                           grouped = FALSE, cells = NULL) {
  # calculate dF/F
  F0 <- filter(df, Time >= baseline[1] & Time <= baseline[2]) %>%
    group_by(Cell) %>%
    summarize("F0" = mean(Ca))
  df <- left_join(df, F0, by = "Cell") %>% mutate(dF_F = (Ca - F0)/F0)
  # only keep data window and re-normalize to 0
  df <- filter(df, Time >= data_window[1] & Time <= data_window[2])
  df <- mutate(df, Time = Time - min(Time))
  # only keep selected cells
  if (!is.null(cells)) df <- filter(df, Cell %in% cells)
  # remove unnecessary columns
  df <- select(df, -Ca, -F0)
  # get max value
  maximal <- df %>%
    group_by(Cell) %>%
    summarize("max" = max(dF_F, na.rm = TRUE))
  if (grouped == "Average") {
    df <- df %>% group_by(Time) %>%
      summarize("avg" = mean(dF_F), "sem" = sd(dF_F)/sqrt(n())) %>%
      rename("dF_F" = avg)
  }
  return(list("timecourse" = df, "max" = maximal))
}

# plot line
lineplot <- function(df, baseline = c(0, 0), data_window = c(0, 0), 
                     grouped = FALSE, cells = NULL) {
  df <- summarize_data(df, baseline, data_window, grouped, cells)[["timecourse"]]
  # plot
  p <- ggplot(df, aes(x = Time, y = dF_F)) +
    theme_classic() +
    xlab("Time (s)") + ylab("dF/F0") +
    scale_x_continuous(expand = c(0, 0)) +
    scale_y_continuous(expand = c(0, 0)) +
    ggtitle("Processed data") +
    theme(axis.text = element_text(color = "black"),
          plot.title = element_text(hjust = 0.5))
  if ("sem" %in% colnames(df)) {
    p <- p + 
      geom_line(color = "black") +
      geom_ribbon(aes(ymin = dF_F - sem, ymax = dF_F + sem), alpha = 0.4,
                  fill = "black")
  } else {
    p <- p + geom_line(aes(color = Cell))
  }
  return(p)
}

# plot heatmap
heatmap <- function(df, baseline = c(0, 0), data_window = c(0, 0), 
                     grouped = FALSE, cells = NULL) {
  df <- summarize_data(df, baseline, data_window, grouped, cells)[["timecourse"]]
  # plot
  p <- ggplot(df, aes(x = Time, fill = dF_F)) +
    theme_classic() +
    xlab("Time (s)") + ylab(NULL) +
    scale_x_continuous(expand = c(0, 0)) +
    scale_fill_gradient2(name = "dF/F0") +
    theme(axis.text = element_text(color = "black"))
  if ("sem" %in% colnames(df)) {
    p <- p + geom_tile(aes(y = "Average"))
  } else {
    p <- p + geom_tile(aes(y = Cell))
  }
  return(p)
}