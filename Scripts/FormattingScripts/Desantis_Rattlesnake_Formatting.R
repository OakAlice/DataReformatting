# Desantis_Rattlesnake ----------------------------------------------------
# 

# Variables ---------------------------------------------------------------
sample_rate <- 1
outputpath <- "Data/Desantis_Rattlesnake/Desantis_Rattlesnake_formatted.csv"

# Read in and format the data ---------------------------------------------
if(!file.exists(file.path(file.path("Desantis_Rattlesnake"), "Formatted_raw_data.csv"))){
  
  data <- fread(file.path("Data", "Desantis_Rattlesnake", "raw", "CRAT_ACT_TrainingDataset_2016-2018IMRS.csv")) %>%
    mutate(Time = as.POSIXct(paste(Date, Time), 
                             format = "%m/%d/%y %H:%M:%S", 
                             tz = "UTC")) %>%
    rename(ID = TagID,
           Y = Ydyn,
           Activity = Behavior) %>%
    select("ID", "Time", "Activity", "X", "Y", "Z")
  

# # Re-code the misspelled variable   --------------------------------------
  data$Activity <- as.factor(data$Activity)
  data <- data %>% 
    mutate(Activity = fct_recode(Activity, 'Not moving' = "Not Moving"))
  
  data <- data %>%
    group_by(ID) %>%
    arrange(Time) %>%
    mutate(time_diff = difftime(Time, data.table::shift(Time)), # had to define package or errored
           break_point = ifelse(time_diff > 2 | time_diff < 0 , 1, 0),
           break_point = replace_na(break_point, 0),
           sequence = cumsum(break_point)) %>%
    select(-break_point, -time_diff)
  
} else {
  print("file already exists")

}

# Save the file -----------------------------------------------------------
fwrite(data, outputpath) 
  