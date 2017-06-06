##
source('make_xfile.R')
source('make_settings.R')
source('functions_xfile.R')
source('make_wth.R')
source('executing_dssat.R')

## make dssat run


extract_number <- function(x){
  
  x <- str_match_all(basename(x), "[0-9]+") %>% 
    unlist %>% 
    unique %>% 
    as.numeric
  
  return(x)
}



## make x-file
suppressMessages(library(tidyverse))
suppressMessages(library(stringr))
suppressMessages(library(magrittr))
suppressMessages(library(purrr))



crop_mgmt <- read_csv(file = "./data/results/mgmt_colombia.csv", locale =  locale(encoding = "latin1"))
dir_runs <- 'Runs/'


climate_files <- paste0('data/climate/') %>%
  list.files(full.names = T) %>%
  data_frame(climate = .) %>%
  mutate(pixel = map(climate, extract_number)) %>%
  unnest() %>%
  mutate(data = map(climate, read_csv))


crop_mgmt_climate <- left_join(crop_mgmt, climate_files, by = c('Coincidencias' = 'pixel')) 
dir_parameters <- './data/parameters'



run_dssat(crop_mgmt_climate, dir_runs, dir_parameters, 2)




