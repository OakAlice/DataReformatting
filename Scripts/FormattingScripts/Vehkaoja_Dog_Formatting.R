# Vehkaoja_Dog ------------------------------------------------------------
# Dataset originally contained 3 behavioural labels for every instance
# This created too many unique combinations to be directly concatenated
# Instead, the behaviours as included in the associated publication were included and the others removed

# Variables ---------------------------------------------------------------
sample_rate <- 100
outputpath <-  "Data/Vehkaoja_Dog/Vehkaoja_Dog_formatted.csv"
# behaviours I want to retain from the 3 columns
accepted_behaviours <- c("Walking", "Sniffing", "Sitting", "Trotting", "Lying chest", "Standing", "Galloping")

# Reading in and relabeling data -----------------------------------------

if(!file.exists(file.path(file.path("Vehkaoja_Dog"), "Formatted_raw_data.csv"))){
  
data <- fread("Data/Vehkaoja_Dog/raw/DogMoveData.csv") %>%
    mutate(
      Activity = case_when(
        Behavior_1 %in% accepted_behaviours ~ Behavior_1,
        Behavior_2 %in% accepted_behaviours ~ Behavior_2,
        Behavior_3 %in% accepted_behaviours ~ Behavior_3,
        TRUE                                ~ Behavior_1
      )
    ) %>%
    mutate(DogID = paste(DogID, TestNum, sep = "_")) %>%
    select(DogID, t_sec, ANeck_x, ANeck_y, ANeck_z, Activity) %>%
    rename(ID = DogID,
           X = ANeck_x,
           Y = ANeck_y,
           Z = ANeck_z
           )

# Adding a timestamp based on the fractional time -------------------------
# data was originally collected as T-sec (seconds from beginning) but we want to convert to POSIXct
# we add a generic start date and then calculate seconds from there
data <- data %>%
  arrange(ID, t_sec) %>%
  mutate(
    # technically these first 2 lines are redundant but better safe than sorry
    time_diff = t_sec - lag(t_sec),
    time_diff = if_else(is.na(time_diff), 0, time_diff),  # replace first NA with 0
    cumtime = cumsum(time_diff),
    start_time = as.POSIXct("1970-01-01 00:00:00", tz = "UTC"),
    Time = start_time + cumtime
  ) %>%
  ungroup() %>%
  select(-time_diff, -start_time, -cumtime)

# Updating the behaviours -------------------------------------------------
# changing from 20 original behaviours to the groupings as seen in the paper
data <- data %>%
  mutate(
    GeneralisedActivity = case_when(
      is.na(Activity) ~ NA_character_,
      Activity %in% c("<undefined>", "Synchronization", "Extra_Synchronization") ~ NA_character_,
      Activity %in% c("Walking", "Pacing") ~ "Walking",
      Activity == "Sniffing" ~ "Sniffing",
      Activity == "Sitting" ~ "Sitting",
      Activity == "Trotting" ~ "Trotting",
      Activity == "Lying chest" ~ "Lying chest",
      Activity %in% c("Shaking", "Playing", "Panting", "Carrying object",
                      "Tugging", "Jumping", "Bowing") ~ "Active",
      Activity == "Standing" ~ "Standing",
      Activity == "Eating" ~ "Eating",
      Activity == "Drinking" ~ "Drinking",
      Activity == "Galloping" ~ "Galloping",
      TRUE ~ Activity
    )
  )

} else {
  print("data already created")
}


# Save the file -----------------------------------------------------------
fwrite(data, outputpath)  



