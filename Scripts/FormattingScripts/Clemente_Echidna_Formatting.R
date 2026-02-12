# Clemente_Echidna ---------------------------------------------
# This data set needed a generic date generated

# Variables ---------------------------------------------------------------
sample_rate <- 10
outputpath <- "Data/Clemente_Echidna/Clemente_Echidna_formatted.csv"

# Read in data and format the non-aggregate ones together ----------------------------------
if(!file.exists(file.path(file.path("Clemente_Echidna"), "Formatted_raw_data.csv"))){
  files <- list.files(file.path("Data","Clemente_Echidna", "raw"), 
                      pattern = "\\corrected_Scored_Extracted.csv$", 
                      full.names = TRUE)
  
  data <- lapply(files, function(x){
    df <- fread(x)
    df$ID <- paste(str_split(basename(x), pattern = "_")[[1]][1], 
                   gsub("corrected", "", str_split(basename(x), pattern = "_")[[1]][2]), sep ="_")
    
    df <- df %>%
      select(V1, V2, V3, V4, V13, ID) %>%
      mutate(start_time = as.POSIXct("1970-01-01 00:00:00", tz = "UTC"), # the time is already in sec so just add to a base time
             Time = start_time + V1) %>%
      rename(X = V2,
             Y = V3,
             Z = V4,
             Activity = V13) %>%
      select(-V1, -start_time)
      df
  })
  
  data <- bind_rows(data)
  
  # Separate labelled and unlabelled data -----------------------------------
  data <- data %>% filter(!Activity == "0")
  
  
} else {
  print("data already created")  
   

}  


# Save the file -----------------------------------------------------------
fwrite(data, outputpath)  
 

