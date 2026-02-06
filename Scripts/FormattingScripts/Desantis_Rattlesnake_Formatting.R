# Formatting for the rattlesnake data -------------------------------------

sample_rate <- 1
output_path <- "Desantis_Rattlesnake/Desantis_Rattlesnake_formatted.csv"


#---------------------------------------------------------------------------
if(!file.exists(file.path(species, "Desantis_Rattlesnake_formatted.csv"))){
  
  data <- fread(file.path(species, "raw", "CRAT_ACT_TrainingDataset_2016-2018IMRS.csv")) %>%
    mutate(Time = as.POSIXct(paste(Date, Time), format = "%m/%d/%y %H:%M:%S", tz = "UTC")) %>%
    rename(ID = TagID,
           Y = Ydyn,
           Activity = Behavior) %>%
    select("ID", "Time", "Activity", "X", "Y", "Z")
  
# Recode the miss spelt variable  
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

fwrite(data,"Desantis_Rattlesnake/Desantis_Rattlesnake_formatted.csv" ) 

  