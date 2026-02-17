# Galea_Cat ---------------------------------------------------------------
# This data set was already formatted in the expected way

# Variables ---------------------------------------------------------------
sample_rate <- 50
output_path <- "Data/Galea_Cat/Galea_Cat_formatted.csv"

# Read in and rename the data ---------------------------------------------
if(!file.exists(output_path)){
  
  data <- fread(paste0("Data/Galea_Cat/raw/all_labelled.csv"))
  
  data <- data %>% 
    rename(Time = time,
           X = x,
           Y = y,
           Z = z,
           Activity = activity)
  
  # Save the file -----------------------------------------------------------
  fwrite(data, output_path)  

} else {
  print("data already created")
}
