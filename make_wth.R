
make_wth <- function(crop_mgmt, out_dir, pixel){
  
  ## proof
  data <- magrittr::extract2(crop_mgmt, 'data') %>%
    magrittr::extract2(pixel)
 # 
  require(stringr)
  lat <- -99
  long <- -99
  
  Srad <- data$srad
  Tmax <- data$tmax
  Tmin <- data$tmin
  Prec <- data$prec
  date <- str_sub(data$date_dssat, start = 3)
  
  sink(paste0(out_dir, '/USAID001.WTH'), append = F)
  ## Agregar las siguientes Lineas
  
  ##cat(paste("*WEATHER DATA :"),paste(coordenadas[1,1]),paste(coordenadas[1,2]))
  cat(paste("*WEATHER DATA :"), paste("USAID"))
  cat("\n")
  cat("\n")
  cat(c("@ INSI      LAT     LONG  ELEV   TAV   AMP REFHT WNDHT"))
  cat("\n")
  cat(sprintf("%6s %8.3f %8.3f %5.0f %5.1f %5.1f %5.2f %5.2f", "USCI", lat, long, -99,-99, -99.0, 0, 0))
  cat("\n")
  cat(c('@DATE  SRAD  TMAX  TMIN  RAIN'))
  cat("\n")
  cat(cbind(sprintf("%5s %5.1f %5.1f %5.1f %5.1f", date, Srad, Tmax, Tmin, Prec)), sep = "\n")
  sink()
  
  
}

make_mult_wth <- function(scenarios, dir_run, filename){
  
  # scenarios <- climate_scenarios
  num_scenarios <- 1:length(scenarios)
  filename <- paste0(filename, sprintf("%.3d", num_scenarios))
  mapply(make_wth, scenarios, dir_run, -99, -99, filename) 
  
}