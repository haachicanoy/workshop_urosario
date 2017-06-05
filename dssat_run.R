##
source('make_xfile.R')
source('make_settings.R')
source('functions_xfile.R')
source('make_wth.R')

## make dssat run
library(stringr)

extract_number <- function(x){
  
  x <- str_match_all(basename(x), "[0-9]+") %>% 
    unlist %>% 
    unique %>% 
    as.numeric
  
  return(x)
}



## make x-file
suppressMessages(library(tidyverse))
crop_mgmt <- read_csv(file = "./data/results/mgmt_colombia.csv", locale =  locale(encoding = "latin1"))
dir_runs <- 'Runs/'


climate_files <- paste0('data/climate/') %>%
  list.files(full.names = T) %>%
  data_frame(climate = .) %>%
  mutate(pixel = map(climate, extract_number)) %>%
  unnest() %>%
  mutate(data = map(climate, read_csv))


crop_mgmt_climate <- left_join(crop_mgmt, climate_files, by = c('Coincidencias' = 'pixel')) 


run_dssat <- function(crop_mgmt, dir_runs, pixel){
  
  
  # crop_mgmt <- crop_mgmt_climate
  # pixel <- 1
  
  dir_run <- paste0(dir_runs, pixel)
  mkdirs(dir_run)
  make_xfile(crop_mgmt, dir_run, pixel)
  make_wth(crop_mgmt, dir_run, pixel)
  
}






# crop_mgmt[1, ]
# pixel <- 1


