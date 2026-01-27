# Vehkaoja_Dog ------------------------------------------------------------

# loading in data, assigning Activity and renaming columns
# behaviours I want to retain from the 3 columns
accepted_behaviours <- c("Walking", "Sniffing", "Sitting", "Trotting", "Lying chest", "Standing", "Galloping")
data <- fread("Vehkaoja_Dog/raw/DogMoveData.csv") %>%
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
           Time = t_sec,
           X = ANeck_x,
           Y = ANeck_y,
           Z = ANeck_z
           )

# Adding the sequencing ---------------------------------------------------
data <- data %>%
    group_by(ID) %>%
    arrange(Time) %>%
    mutate(time_diff = difftime(Time, data.table::shift(Time)), # had to define package or errored
           break_point = ifelse(time_diff > 0.02 | time_diff < 0 , 1, 0),
           break_point = replace_na(break_point, 0),
           sequence = cumsum(break_point)) %>%
    select(-break_point, -time_diff)

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

# save this 
fwrite(data, file.path("Vehkaoja_Dog/Vehkaoja_Dog_formatted.csv"))
