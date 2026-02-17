# HarveyCarrol_Pangolin ---------------------------------------------------
# This data needed IDs to be taken form the file names

# Variables ---------------------------------------------------------------
sample_rate <- 50
output_path <- "Data/HarveyCarrol_Pangolin/HarveyCarrol_Pangolin_formatted.csv"

# Read in and rename the data ---------------------------------------------
if(!file.exists(output_path)){
  
  files <- list.files(
    path = "Data/HarveyCarrol_Pangolin/raw",
    recursive = TRUE,
    pattern = "\\.csv$",
    full.names = TRUE)
  
  data <- lapply(files, function(x){
    df <- fread(x)
    # Take the IDs from the file names
    df$ID <- str_split(basename(x), "_")[[1]][1]
    return(df)
  })
  data <- bind_rows(data)
  data <- data %>%
    rename(Time = time,
           Activity = Behavior) %>%
    select(ID, Time, Activity, X, Y, Z)
  
  # Reclustering the behaviours ---------------------------------------------
  data <- data %>%
    mutate(FuncActivity = case_when(
      
      Activity %in% c(
        "pause",
        "grooming"
      ) ~ "Stationary",
      
      Activity %in% c(
        "back",
        "roll",
        "crash",
        "turn",
        "fall",
        "poop",
        "get_up"
      ) ~ "Other",
      Activity == "walk" ~ "Walking",
      Activity %in% c("investigate_groung", "upright_sensing", "dig", "feeding") ~ "Foraging"
      
    ))
  # not enough to group more broadly than that
 
  # Save the file -----------------------------------------------------------
  fwrite(data, output_path)  
  
} else {
  print("data already formatted")
} 








