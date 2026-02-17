#Studd_Squirrel --------------------------------------------

# Variables ---------------------------------------------------------------
sample_rate <- 1
output_path <- "Data/Studd_Squirrel/Studd_Squirrel_formatted.csv"


# Read in and rename the data ---------------------------------------------
if(!file.exists(output_path)){
  
  data <- fread(file.path("Data/Studd_Squirrel/raw/Studd_2019.csv"))
  
  data <- data %>%
    select(TIME, BEHAV, X, Y, Z, LCOLOUR, RCOLOUR) %>%
    mutate(ID = paste0(LCOLOUR, RCOLOUR)) %>%
    dplyr::rename(Time = TIME,
           Activity = BEHAV) %>%
    select(!c(LCOLOUR, RCOLOUR)) 

# Recoding the behaviours into broader groups -----------------------------
  data <- data %>%
    mutate(FuncActivity = case_when(
      
      Activity %in% c(
        "CLIP",
        "CCONE",
        "DIGG"
      ) ~ "Foraging",
      
      Activity %in% c(
        "SlowMove",
        "RunningMove",
        "HorizMove"
      ) ~ "Locomotion",
      
      Activity %in% c(
        "StatMove",
        "VertMove"
      ) ~ "OtherMovement",
      
      Activity == "Feed" ~ "Feed",
      Activity == "notMoving" ~ "Stationary",
      Activity == "Nest" ~ "Nest"
    )) %>%
    mutate(BroadActivity = case_when(
      FuncActivity %in% c(
        "Foraging",
        "Feed"
      ) ~ "Foraging",
      FuncActivity %in% c(
        "Nest",
        "Stationary"
      ) ~ "Rest",
      FuncActivity == "Locomotion" ~ "Locomotion",
      FuncActivity == "OtherMovement" ~ "Other"
    ))
  
  # Save the file -----------------------------------------------------------
  fwrite(data, output_path)
  
} else {
  print("data already created")
}
