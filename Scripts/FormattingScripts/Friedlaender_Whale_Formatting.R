# Formatting the whale data ------------------------------------------------
# the information needed to explain this file is spread over many different files and need to be combined
# multistage process

# set up
pacman::p_load(R.matlab)

sample_rate <- 5


# Start times -------------------------------------------------------------
dates_files <- list.files(file.path("Friedlaender_Whale", "raw"), 
                        full.names = TRUE, 
                        pattern = "*tagon.mat",
                        recursive = TRUE)
dates <- lapply(dates_files, function(x){
  dat <- readMat(x)
  firsttime <- paste0(dat$TAGON[1], "-", dat$TAGON[2], "-", dat$TAGON[3], " ",
                 dat$TAGON[4], ":", dat$TAGON[5], ":", dat$TAGON[6])
  firsttime <- as.POSIXct(firsttime, format = "%Y-%m-%d %H:%M:%S")
  ID <- basename(dirname(x))
  
})
dates <- rbindlist(dates)

raw_files <- list.files(file.path("Friedlaender_Whale", "raw"), 
                        full.names = TRUE, 
                        pattern = "*bprh.mat",
                        recursive = TRUE)

annotations <- list.files(file.path("Friedlaender_Whale", "raw", "annotations"), 
                          full.names = TRUE, 
                          recursive = TRUE)


fread(annotations[1])

x <- raw_files[1]
# opening the raw files
data <- lapply(raw_files, function(x){
  dat <- readMat(x)
  accel <- dat$A
  
  date <- 
  
  
})





