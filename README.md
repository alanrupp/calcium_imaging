# Calcium imaging

This is a `shiny` app for analyzing calcium imaging data coming from the MetaMorph software. It allows the user to upload an file, parse the data to calculate dF/F0, find the maximal calcium excursion for a given time window, and save the result.

## Requirements
This app has been tested on Linux machines running R 3.4.3 – 3.6.3. Required R libaries:
* **shiny** versions 0.14.2 – 1.5.0
* **ggplot2** versions 2.2.1 – 3.3.2
* **dplyr** versions 0.7.4 – 1.0.2
* **tidyr** versions 0.8.0 – 1.1.2

## Usage
1. Upload a file. This needs to be an XLSX file with one column called "Time" and other column names corresponding to the cell names
2. Change the sampling frequency, baseline and data windows, if necessary
3. Save the resulting dF/F0 timecourse or maximal dF/F0 as CSV files
