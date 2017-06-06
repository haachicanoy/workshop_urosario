# Workshop en Big Data - Universidad del Rosario
# H. Achicanoy, J. Mesa
# CIAT, 2017

# R options
g <- gc(); rm(list = ls()); options(warn = -1); options(scipen = 999)

mkdirs <- function(fp) {
  
  if(!file.exists(fp)) {
    mkdirs(dirname(fp))
    dir.create(fp)
  }
  
} 

# Load packages
suppressMessages(library(tidyverse))
suppressMessages(library(modelr))
suppressMessages(library(dplyr))
suppressMessages(library(purrr))
suppressMessages(library(broom))
suppressMessages(library(tidyr))
suppressMessages(library(ggplot2))
suppressMessages(library(lubridate))
suppressMessages(library(RCurl))
suppressMessages(library(purrrlyr))

# Load management matrix for maize crop in Colombia
crop_mgmt <- read_csv(file = "./data/results/mgmt_colombia.csv")
crop_mgmt$X1 <- NULL

# Extract daily climate data for Colombia
load("//dapadfs/workspace_cluster_3/bid-cc-agricultural-sector/14-ObjectsR/wfd/WDF_all_new.Rdat")

script <- getURL("https://raw.githubusercontent.com/Jeikosd/usaid_forecast_maize/master/main_functions.R", ssl.verifypeer = FALSE); eval(parse(text = script)); rm(script)

yList <- 1971:2000

yInfo <- lapply(1:length(Prec), function(i){
  
  # Defaul data.frame
  df <- data.frame(Prec[[i]][crop_mgmt$ID,])
  colnames(df) <- as.character(seq(as.Date(paste(yList[i], '-01-01', sep='')), as.Date(paste(yList[i], '-12-31', sep='')), by=1))
  df$ID <- crop_mgmt$ID
  df <- df %>% tidyr::gather(key = date, value = prec, 1:(ncol(df)-1))
  df$day <- lubridate::yday(as.Date(df$date))
  df$month <- lubridate::month(as.Date(df$date))
  df$year <- lubridate::year(as.Date(df$date))
  date_for_dssat <- Vectorize(date_for_dssat, vectorize.args = c("year", "day_year"))
  df$date_dssat <- date_for_dssat(year = df$year, day_year = df$day)
  
  # Tmax treatment
  df_tmax <- data.frame(Tmax[[i]][crop_mgmt$ID,])
  colnames(df_tmax) <- as.character(seq(as.Date(paste(yList[i], '-01-01', sep='')), as.Date(paste(yList[i], '-12-31', sep='')), by=1))
  df_tmax$ID <- crop_mgmt$ID
  df_tmax <- df_tmax %>% tidyr::gather(key = date, value = tmax, 1:(ncol(df_tmax)-1))
  df$tmax <- df_tmax$tmax; rm(df_tmax)
  
  # Tmin treatment
  df_tmin <- data.frame(Tmin[[i]][crop_mgmt$ID,])
  colnames(df_tmin) <- as.character(seq(as.Date(paste(yList[i], '-01-01', sep='')), as.Date(paste(yList[i], '-12-31', sep='')), by=1))
  df_tmin$ID <- crop_mgmt$ID
  df_tmin <- df_tmin %>% tidyr::gather(key = date, value = tmin, 1:(ncol(df_tmin)-1))
  df$tmin <- df_tmin$tmin; rm(df_tmin)
  
  # Srad treatment
  df_srad <- data.frame(Srad[[i]][crop_mgmt$ID,])
  colnames(df_srad) <- as.character(seq(as.Date(paste(yList[i], '-01-01', sep='')), as.Date(paste(yList[i], '-12-31', sep='')), by=1))
  df_srad$ID <- crop_mgmt$ID
  df_srad <- df_srad %>% tidyr::gather(key = date, value = srad, 1:(ncol(df_srad)-1))
  df$srad <- df_srad$srad; rm(df_srad)
  
  df <- df[,c("ID", "year", "day", "month", "date_dssat", "tmax", "tmin", "prec", "srad")]
  return(df)
  
})
yInfo <- do.call(rbind, yInfo)


climate_pixel <- yInfo %>% 
  slice_rows("ID") %>%
  nest(.key = climate)

crop_mgmt <- left_join(crop_mgmt, climate_pixel, by = c('Coincidencias' = 'ID'))

mkdirs("./data/climate/")

map2(climate_pixel$climate, paste0("./data/climate/pixel_", climate_pixel$ID, ".csv"),  write_csv)
