# Galea_Cat ---------------------------------------------------------------
# This data set was already formatted


# Variables ---------------------------------------------------------------
sample_rate <- 50
outputpath <- "Data/Galea_Cat/galea_Cat_formatted.csv"

# Read in and rename the data ---------------------------------------------
if(!file.exists(file.path(file.path("Galea_Cat"), "Formatted_raw_data.csv"))){
  
  data <- fread(paste0("Data/Galea_Cat/raw/all_labelled.csv"))
  
  data <- data %>% 
  rename(Time = time,
         X = x,
         Y = y,
         Z = z,
         Activity = activity)

} else {
  print("data already created")
  

}

# Save the file -----------------------------------------------------------
fwrite(data, outputpath)  




