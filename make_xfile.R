
mkdirs <- function(fp) {
  
  if(!file.exists(fp)) {
    mkdirs(dirname(fp))
    dir.create(fp)
  }
  
} 


make_xfile <- function(mgmt_df, dir_run, pixel){
  
  
  require(tidyverse)
  require(magrittr)
  require(stringr)
  ## sowing window a data frame that contain both start and end julian day
  ## N_app amount of nitrogen fertilizacion 
  ## day_N_app day of fertilization
  
  # proof
  # pixel  <- 1
  # mgmt_df <- crop_mgmt[pixel, ]
 
  start <- magrittr::extract2(mgmt_df, 'mirca.start') 
  
  end <- magrittr::extract2(mgmt_df, 'mirca.end')
  
  N_app_0 <- magrittr::extract2(mgmt_df, 'N.app.0d')
  N_app_40 <- magrittr::extract2(mgmt_df, 'N.app.40d')
  
  day_app_0 <- 0
  day_app_40 <- 40
  cultivar <-  magrittr::extract2(mgmt_df, 'variedad.1') %>%
    str_sub(start = 0, end = 6)
  
  
  
  
  # out_file <- './proof.MZX'    
  overwrite <- F
  details <- '*Workshop Big Data '
  people <- "Harold Achicanoy, Jeison Mesa and Julian Ramirez"
  
  
  IC <- 0  # Inital conditions
  MI <- 0  # input if you are going to use a irrigation, 1 = TRUE, 0 = FALSe 
  MF <- 0 # Fertilization field, 1 = TRUE, 0 = FALSE
  MH <- 0 # its necessary to include harvest date when you turn on this parameter

  
  CR <- 'MZ'    # Crop Code, you need to search this parameter for de manual DSSAT (its different by crop)
  INGENO <- cultivar # Cultivar indentifier, this is the code for cultivar to run depend of crop
  CNAME <- 'FM6'  # Whatever code to identify the cultivar to run, maybe no too long string
  WSTA <- 'USAID001'
  ID_SOIL <- 'CORD870001'
  
  input_pDetails <- list()
  input_pDetails$PDATE <- start %>%
    + 15 %>%
    sprintf("%.3d", .) %>%
    paste0(71, .)
  
  input_pDetails$SDATE <- start
  input_pDetails$plant <- 'R'  # R = planting on reporting date
  input_pDetails$EDATE <- -99
  input_pDetails$PPOP <- 6.25
  input_pDetails$PPOE <- 6.25
  input_pDetails$PLME <- 'S'
  input_pDetails$PLDS <- 'R'
  input_pDetails$PLRS <- 80
  input_pDetails$PLRD <- 90
  input_pDetails$PLDP <- 4
  
  ## Simulation Controls
  input_sControls <- list()
  input_sControls$NYERS <- 1 ## Years for simulation
  input_sControls$SMODEL <- 'MZCER046' # model to use
  input_sControls$WATER <- 'N'   ## Y = Utiliza balance Hidrico, N = No utiliza balance hidrico
  input_sControls$NITRO <-  'N'  ## Y = utiliza balance nitrogeno, N =  no utiliza balance nitrogeno
  input_sControls$PLANT <- 'R'  # R = planting on reporting date ## Add the other options
  input_sControls$IRRIG <- 'A'  ##  R =  on reporting date, A automatically irragated, N Nothing, add the other options
  input_sControls$FERTI = 'N' ## add more options
  input_sControls$SDATE <- start %>%
    sprintf("%.3d", .) %>%
    paste0(71, .)
  
  

  
  
  proof <- make_archive(paste0(dir_run, '/proof.MZX'), overwrite = F,  encoding = "UTF-8") 
  
  write_details(proof, make_details(details, people))
  write_treatments(proof, make_treatments(IC, MI, MF, MH))  ## the parameter FL its to identify the run with a specific .WTH
  write_cultivars(proof, make_cultivars(CR, INGENO, CNAME))
  write_fields(proof, make_fields(WSTA, ID_SOIL))
  # Las corridas serán entonces de acuerdo al potencial en rendimiento que puedan alcanzar las plantas
  # write_IC(proof, make_IC(ICBL, SH20, SNH4, SNO3)) # posiblemente este campo no se necesite durante la corrida de los pronosticos
  # write_MF(proof, make_MF(input_fertilizer))         # sin requerimientos por fertilizantes dejarlo con potencial
  write_pDetails(proof, make_pDetails(input_pDetails))     
  write__sControls(proof, make_sControls(input_sControls))
  write_Amgmt(proof, make_Amgmt(-99, -99))
  close(proof)
}
