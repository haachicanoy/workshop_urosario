# Crop modeling application for Maize: DDSAT run
# J. Mesa, J. Ramirez & H. Achicanoy
# Workshop en Big data, U. del Rosario, 2017

# R options
options(warn = -1); options(scipen = 999); g <- gc(); rm(list = ls())

# Load packages
suppressMessages(library(tidyverse))
suppressMessages(library(stringr))
suppressMessages(library(magrittr))
suppressMessages(library(purrr))
suppressMessages(library(foreach))
suppressMessages(library(doParallel))

# Source main scripts
source('make_xfile.R')
source('make_settings.R')
source('functions_xfile.R')
source('make_wth.R')
source('executing_dssat.R')

# Define directories
dir_runs <- 'Runs/'
dir_parameters <- './data/parameters'

# Load crop management matrix
crop_mgmt <- read_csv(file = "./data/results/mgmt_colombia.csv", locale =  locale(encoding = "latin1"))

extract_number <- function(x){
  
  x <- str_match_all(basename(x), "[0-9]+") %>% 
    unlist %>% 
    unique %>% 
    as.numeric
  
  return(x)
}

# Load climate data
climate_files <- paste0('data/climate/') %>%
  list.files(full.names = T) %>%
  data_frame(climate = .) %>%
  mutate(pixel = map(climate, extract_number)) %>%
  unnest() %>%
  mutate(data = map(climate, read_csv))

# Merge crop management and climate data
crop_mgmt_climate <- left_join(crop_mgmt, climate_files, by = c('Coincidencias' = 'pixel')) 

# Just run one pixel
run_dssat(crop_mgmt_climate, dir_runs, dir_parameters, 2)

# Parallelize the stuff
cores <- detectCores()
cl    <- makeCluster(cores[1]-1); rm(cores)
registerDoParallel(cl)

Run <- foreach(i = 1:nrow(crop_mgmt_climate)) %dopar% { # .combine=cbind
  run_dssat(crop_mgmt_climate, dir_runs, dir_parameters, pixel = i)
}
stopCluster(cl); rm(cl)

saveRDS(Run, 'data/results/crop_modeling_runs.RDS')

crop_mgmt_climate$dssat_runs <- Run

if(!file.exists('data/results/Integrated_results.RDS')){
  saveRDS(crop_mgmt_climate, 'data/results/Integrated_results.RDS')
} else {
  crop_mgmt_climate <- readRDS('data/results/Integrated_results.RDS')
}
