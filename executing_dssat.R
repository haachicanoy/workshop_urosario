## make batch

# to test
# its necessary to add dir_run into a funtion than is goint to run DSSAT with all specification and run into a particular folder
# dir_run <- 'D:/CIAT/USAID/DSSAT/multiple_runs/R-DSSATv4.6/Proof_run/'
# crop <- "MAIZE"
# name <- "proof.MZX"  # for linux ./proof.MZX, for windows proof.MZX USAID
# filename <- "DSSBatch.v46"  # filename
# filename <- "D:/CIAT/USAID/DSSAT/multiple_runs/R-DSSATv4.6/Proof_run/LaUnion/1/LaUnion/1/"

# CSMbatch(crop, name, paste0(dir_run, filename))

CSMbatch <- function(crop, name, our_dir) {
  
  outbatch <- rbind(
    rbind(
      # Batchfile headers            
      paste0("$BATCH(", crop, ")"),            
      "!",            
      cbind(sprintf("%6s %92s %6s %6s %6s %6s", "@FILEX", "TRTNO", "RP", "SQ", "OP", 
                    "CO"))),            
    cbind(sprintf("%6s %89s %6i %6i %6i %6i",            
                  paste0(name),
                  1,  # Variable for treatment number            
                  1,  # Default value for RP element            
                  0,  # Default value for SQ element            
                  1,  # Default value for OP element            
                  0)))  # Default value for CO element 
  
  # Write the batch file to the selected folder  
  write(outbatch, file = paste0(our_dir, '/DSSBatch.v46'), append = F)
  
}


execute_dssat <- function(dir_run){
  
  setwd(dir_run)
  system(paste0("DSCSM046.EXE " , "MZCER046"," B ", "DSSBatch.v46"), ignore.stdout = T, show.output.on.console = F)
  setwd('..')
  setwd('..')
  
}


read_summary <- function(dir_run){
  
  summary_out <- read_table(paste0(dir_run, '/summary.OUT'), skip = 3 , na = "*******")
  
  
  return(summary_out)
}



run_dssat <- function(crop_mgmt, dir_runs, dir_parameters, pixel){
  
  
  # crop_mgmt <- crop_mgmt_climate
  # pixel <- 1
  
  dir_run <- paste0(dir_runs, pixel)
  mkdirs(dir_run)
  
  make_xfile(crop_mgmt, dir_run, pixel)
  make_wth(crop_mgmt, dir_run, pixel)
  CSMbatch('MAIZE', 'proof.MZX', dir_run)
  
  files_dssat <- list.files(dir_parameters, full.names = T)
  file.copy(files_dssat, dir_run)
  
  ## execute dssat
  execute_dssat(dir_run)
  summary_out <- read_summary(dir_run)
  return(summary_out)
  
}
