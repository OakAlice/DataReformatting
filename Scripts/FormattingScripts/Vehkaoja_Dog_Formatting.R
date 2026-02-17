# Vehkaoja_Dog ------------------------------------------------------------
# Dataset originally contained 3 behavioural labels for every instance
# This created too many unique combinations to be directly concatenated
# these were filtered down in the next steps of behavioural clustering
# Quite complicated and a bit arbitrary... potentially worth revisiting in a more nuanced way

# Variables ---------------------------------------------------------------
sample_rate <- 100
output_path <-  "Data/Vehkaoja_Dog/Vehkaoja_Dog_formatted.csv"

if(!file.exists(output_path)){
  
  data <- fread("Data/Vehkaoja_Dog/raw/DogMoveData.csv") %>%
      mutate(DogID = paste(DogID, TestNum, sep = "_")) %>%
      select(DogID, t_sec, ANeck_x, ANeck_y, ANeck_z, Behavior_1, Behavior_2, Behavior_3) %>%
      dplyr::rename(ID = DogID,
             X = ANeck_x,
             Y = ANeck_y,
             Z = ANeck_z
             )
  
  # Adding a timestamp based on the fractional time -------------------------
  # data was originally collected as T-sec (seconds from beginning) but we want to convert to POSIXct
  # we add a generic start date and then calculate seconds from there
  data <- data %>%
    group_by(ID) %>% 
    mutate(
      start_time = as.POSIXct("1970-01-01 00:00:00", tz = "UTC"),
      Time = start_time + t_sec
    ) %>%
    ungroup() %>%
    select(-start_time)
  
  setDT(data)
  
  # Updating the behaviours -------------------------------------------------
  # this is a bit of a mission as there isn't a definite clear guide on how to do this
  
  # all unique behaviours that appear in the dataset:
  # "Bowing","Carrying object", "Drinking", "Eating", "Galloping", Jumping", "Lying chest"    
  # "Pacing", "Panting", "Playing", "Shaking", "Sitting", Sniffing", Standing"       
  # "Trotting", Tugging", "Walking" 
  # Note that the behavioural order can differ... so the same label (Playing) can appear in any of the columns
  # these then combine to over 50 combinations... which is a bit too much
  # therefore this is my attempt to simplify it
  
  # Set all "<undefined>", "Synchronization", "Extra_Synchronization" values to NA
  # Then remove rows where all three behaviour columns are NA
  irrelevant <- c("<undefined>", "Synchronization", "Extra_Synchronization")
  data[, c("Behavior_1", "Behavior_2", "Behavior_3") :=
         lapply(.SD, function(x) fifelse(x %in% irrelevant, NA_character_, x)),
       .SDcols = c("Behavior_1", "Behavior_2", "Behavior_3")]
  data <- data[!(is.na(Behavior_1) & is.na(Behavior_2) & is.na(Behavior_3))]

  # Define "dominant" behaviour groups 
  # These categories were inferred from looking and inspecting the data
  postural <- c(
    "Walking", "Trotting", "Standing",
    "Lying chest", "Sitting",
    "Jumping", "Galloping", "Bowing", "Pacing"
  )
  
  activity <- c(
    "Eating", "Tugging", "Sniffing", "Drinking", "Shaking", "Panting"
  )
  
  details <- c(
    "Carrying object", "Playing"
  )
  
  # Sort these into the right columns
  # Row-wise assignment into postural_col, activity_col, details_col
  data[, c("postural_col", "activity_col", "details_col") := {
    
    vals <- c(Behavior_1, Behavior_2, Behavior_3)
    
    # Select first value from each group, if it exists
    postural_val <- vals[vals %in% postural][1L]
    activity_val <- vals[vals %in% activity][1L]
    details_val  <- vals[vals %in% details][1L]
    list(postural_val, activity_val, details_val)
    
  }, by = .I]
  
  # Now recombine them in order so they're simplified
  # Remove details unless it is the only non-NA value
  data[, Activity := apply(.SD, 1, function(x) {
    postural <- x[1]
    activity <- x[2]
    details  <- x[3]
    
    # If postural or activity exists, exclude details (this is just a context column)
    if (!is.na(postural) | !is.na(activity)) {
      vals <- c(activity, postural)
    } else {
      vals <- c(details)
    }
    
    # Remove any remaining NA and collapse into a single string
    vals <- vals[!is.na(vals)]
    if(length(vals) == 0) NA_character_ else paste(vals, collapse = "_")
    
  }), .SDcols = c("postural_col", "activity_col", "details_col")]
  
  # this gets us down to 29 behaviours. Still overly complex but reducing any further
  # not possible without assumptions and deviations from dataset information
  # will now group down into the two clustering levels I've been using 
  data$FuncActivity <- str_split(data$Activity, "_", simplify = TRUE)[, 1]
  # and simplify further
  data <- data %>%
    mutate(BroadActivity = case_when(
      
      FuncActivity %in% c(
        "Walking",
        "Trotting",
        "Pacing",
        "Galloping",
        "Jumping"
      ) ~ "Locomotion",
      
      FuncActivity %in% c(
        "Sitting",
        "Lying chest",
        "Standing"
      ) ~ "Stationary",
      
      FuncActivity %in% c(
        "Shaking",
        "Tugging",
        "Playing",
        "Bowing"
      ) ~ "Play",
      
      FuncActivity %in% c(
        "Sniffing",
        "Drinking",
        "Eating"
      ) ~ "Foraging",
      
      FuncActivity == "Panting" ~ "Other"
      
    ))

  # Save the file -----------------------------------------------------------
  fwrite(data, output_path)  
  
} else {
  print("data already created")
}
