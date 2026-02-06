# Formatting the gull data ------------------------------------------------
species <- "Maekawa_Gull"

if (file.exists(file.path(base_path, "Data", species, "Formatted_raw_data.csv"))){

  
  data <- fread(file.path(species, "raw/raw_data.csv"))
  labels <- fread(file.path(species, "raw/labels.csv"))
  
  sample_rate <- 25
  
  # Stitch together ---------------------------------------------------------
  # get the range and give the labels
  data[, timestamp := as.POSIXct(timestamp)]
  labels[, stt_timestamp := as.POSIXct(stt_timestamp)]
  labels[, stp_timestamp := as.POSIXct(stp_timestamp)]
  
  # Prepare for overlaps:
  # 1. Add 'start' and 'end' to data 
  
  setDT(labels)
  setDT(data)
  
  
  setkey(labels, animal_tag, stt_timestamp, stp_timestamp)
  
  data <- labels [
    data,
    on = .(
      animal_tag,
      stt_timestamp <= timestamp,
      stp_timestamp >= timestamp
    ),
    nomatch = 0,
    .(
      animal_tag,
      timestamp,
      acc_x, acc_y, acc_z,
      stt_timestamp,
      stp_timestamp,
      activity
    )
  ]
}

data <- data %>%
  select(animal_tag, timestamp, acc_x, acc_y, acc_z, activity,
         stp_timestamp, stt_timestamp) %>%
  rename(Time = timestamp,
         X = acc_x,
         Y = acc_y,
         Z = acc_z,
         Activity = activity,
         Start_Time = stt_timestamp,
         Stop_Time = stp_timestamp,
         ID = animal_tag)


data <- data %>%
  group_by(ID) %>%
  arrange(Time) %>%
  mutate(time_diff = difftime(Time, data.table::shift(Time)), # had to define package or errored
         break_point = ifelse(time_diff > 2 | time_diff < 0 , 1, 0),
         break_point = replace_na(break_point, 0),
         sequence = cumsum(break_point)) %>%
  select(-break_point, -time_diff)

  fwrite(data, "Maekawa_Gull/Maekawa_Gull_formatted.csv")

  print("data already formatted")

