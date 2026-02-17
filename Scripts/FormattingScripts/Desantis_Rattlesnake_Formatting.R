# Desantis_Rattlesnake ----------------------------------------------------

# Variables ---------------------------------------------------------------
sample_rate <- 1
output_path <- "Data/Desantis_Rattlesnake/Desantis_Rattlesnake_formatted.csv"

# Read in and format the data ---------------------------------------------
if(!file.exists(output_path)){
  
  data <- fread(file.path("Data", "Desantis_Rattlesnake", "raw", "CRAT_ACT_TrainingDataset_2016-2018IMRS.csv")) %>%
    mutate(Time = as.POSIXct(paste(Date, Time), 
                             format = "%m/%d/%y %H:%M:%S", 
                             tz = "UTC")) %>%
    rename(ID = TagID,
           Y = Ydyn,
           Activity = Behavior) %>%
    select("ID", "Time", "Activity", "X", "Y", "Z")
  

  # Re-code the misspelled variable --------------------------------------
  data$Activity <- as.factor(data$Activity)
  data <- data %>% 
    mutate(Activity = fct_recode(Activity, 'Not moving' = "Not Moving"))

  # Save the file -----------------------------------------------------------
  fwrite(data, output_path) 
  
} else {
  print("file already exists")
}
