# Workshop en Big Data - Universidad del Rosario
# H. Achicanoy, J. Mesa
# CIAT, 2017

# R options
g <- gc(); rm(list = ls()); options(warn = -1); options(scipen = 999)

# Load packages
suppressMessages(library(tidyverse))
suppressMessages(library(modelr))
suppressMessages(library(dplyr))
suppressMessages(library(purrr))
suppressMessages(library(broom))
suppressMessages(library(tidyr))
suppressMessages(library(ggplot2))
suppressMessages(library(lubridate))

# Load management matrix for maize crop
load("//dapadfs/workspace_cluster_3/bid-cc-agricultural-sector/08-Cells_toRun/matrices_cultivo/version2017/_rice_crop_mgmt_secano.RDat")

# Filter coordinates just for Colombia
crop_mgmt <- crop_mgmt %>% filter(country == "Colombia"); rownames(crop_mgmt) <- 1:nrow(crop_mgmt)
plot(crop_mgmt$x, crop_mgmt$y)

# Extract daily climate data for Colombia
load("//dapadfs/workspace_cluster_3/bid-cc-agricultural-sector/14-ObjectsR/wfd/WDF_all_new.Rdat")

yList <- 1971:2000

lapply(1:length(Prec), function(i){
  df <- data.frame(Prec[[i]][crop_mgmt$Coincidencias,])
  colnames(df) <- as.character(seq(as.Date(paste(yList[i], '-01-01', sep='')), as.Date(paste(yList[i], '-12-31', sep='')), by=1))
  df$Coincidencias <- crop_mgmt$Coincidencias
  df <- df %>% tidyr::gather(key = Date, value = Prec, 1:(ncol(df)-1))
  df$Day <- lubridate::day(as.Date(df$Date))
  df$Month <- lubridate::month(as.Date(df$Date))
  df$Year <- lubridate::year(as.Date(df$Date))
  
  df
  
})


