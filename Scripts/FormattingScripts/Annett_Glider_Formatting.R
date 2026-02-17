# Annett_Glider -----------------------------------------------------------
# This data set needed IDs to be taken from file names
# This data set has a key for the names of each behavior
# the data needed dates and start times to be generated

# Variables ---------------------------------------------------------------
sample_rate <- 50
output_path <-  "Data/Annett_Glider/Annett_Glider_formatted.csv"

# Reading in and relabeling data -----------------------------------------
if(!file.exists(output_path)){

  raw_files <- list.files(
      path = "Data/Annett_Glider/raw",
    recursive = TRUE,
    pattern = "\\.txt$",
    full.names = TRUE)
  
  alldata <- lapply(raw_files, function(x){
    data <- fread(x)
    ind <- ifelse(grepl("Flip", x), "Flip", "Gilberta") # Take ID names from files
    data <- data %>% 
     # Generating a generic time stamp for the start time
       mutate(
        time=as.POSIXct((V1 - 719529)*86400, origin = "1970-01-01", tz = "UTC"))
    
    data <- data %>% 
      select(V2, V3, V4, V5, time) %>% 
      rename(X = V2,
             Y = V3,
             Z = V4,
             Activity = V5,
             Time = time) %>%
      mutate(ID = ind) 
    
    data <- filter(data, Activity != 0) 
    data
  })
  data <- rbindlist(alldata)
  
  # Save the file -----------------------------------------------------------
  fwrite(data, output_path)
  
} else {
  print("data already created")
}
