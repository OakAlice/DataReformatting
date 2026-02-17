# Yu_Duck ------------------------------------------------

# Variables ---------------------------------------------------------------
sample_rate <- 25
output_path <- "Data/Yu_Duck/Yu_Duck_formatted.csv"

if(!file.exists(output_path)){
  # Read in the data --------------------------------------------------------

  files <- list.files(file.path("Data/Yu_Duck/raw"), full.names = TRUE)
    
  # read them toggether 
  data <- lapply(files, function(x){
    df <- fread(x)
    name <- strsplit(basename(x), "_")[[1]][1]
    df$name <- name
    df$timestamp2 <- as.POSIXct(df$timestamp, format = "%d/%m/%y %H:%M", tz = "UTC")
    df <- df[, c("x", "y", "z", "timestamp2", "behaviour", "name")]
  }
  )
  data <- bind_rows(data)
  
  # format that
  data <- data %>%
    rename(ID = name,
           Activity = behaviour,
           X = x,
           Y = y,
           Z = z,
           Time = timestamp2)
  
  # only keep the labelled data
  data <- data %>% filter(!Activity == "")
  
  # Regroup the behaviours --------------------------------------------------
  # this is based on the groupings seen in the paper
  data <- data %>%
    mutate(FuncActivity = case_when(
      
      Activity %in% c(
        "swimming",
        "dabbling",
        "dabbling_deep"
      ) ~ "Swimming",
      
      Activity %in% c(
        "wader_foraging",
        "feeding",
        "drinking",
        "pecking",
        "wader_feeding",
        "edge_feeding"
      ) ~ "Feeding",
      
      Activity %in% c(
        "wing_flapping",
        "jumping",
        "nodding",
        "water_escaping"
      ) ~ "Other",
      
      Activity %in% c(
        "stretching",
        "preening",
        "tail_shaking",
        "foot_scratching",
        "shaking",
        "head_shaking"
      ) ~ "Preening",
      
      Activity %in% c(
        "resting",
        "resting_head_moving",
        "standing"
      ) ~ "Resting",
      
      Activity %in% c(
        "rush_to_water",
        "running"
      ) ~ "Running",
      
      Activity %in% c(
        "walking",
        "steps",
        "step"
      ) ~ "Walking",
      
      Activity == "flying" ~ "Flying"
      
    ))
  
  # and then even further grouping
  data <- data %>%
    mutate(BroadActivity = case_when(
      
      FuncActivity %in% c(
        "Walking",
        "Running"
      ) ~ "Locomotion",
      
      FuncActivity %in% c(
        "Preening",
        "Other"
      ) ~ "Other",
      
      FuncActivity == "Flying" ~ "Flying",
      FuncActivity == "Swimming" ~ "Swimming",
      FuncActivity == "Resting" ~ "Resting",
      FuncActivity == "Feeding" ~ "Feeding"
      
    ))
  # Save the file -----------------------------------------------------------
  fwrite(data, output_path)

} else {
  print("data already created")
}
