# Vehkaoja_Dog ------------------------------------------------------------
sample_rate <- 100

# behaviours I want to retain from the 3 columns
accepted_behaviours <- c("Walking", "Sniffing", "Sitting", "Trotting", "Lying chest", "Standing", "Galloping")

# loading in data, assigning Activity and renaming columns
data <- fread("Vehkaoja_Dog/raw/DogMoveData.csv") %>%
    mutate(
      Activity = case_when(
        Behavior_1 %in% accepted_behaviours ~ Behavior_1,
        Behavior_2 %in% accepted_behaviours ~ Behavior_2,
        Behavior_3 %in% accepted_behaviours ~ Behavior_3,
        TRUE                                ~ Behavior_1
      )
    ) %>%
    select(DogID, t_sec, ANeck_x, ANeck_y, ANeck_z, Activity) %>%
    rename(ID = DogID,
           Time = t_sec,
           X = ANeck_x,
           Y = ANeck_y,
           Z = ANeck_z
           )

# save this 
fwrite(data, file.path("Vehkaoja_Dog/Vehkaoja_Dog_formatted.csv"))
