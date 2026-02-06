# Formatting for bear dataset ---------------------------------------------
library(data.table)
library(dplyr)

# variables
species <- "Pagano_Bear"
sample_rate <- 16 #

if (file.exists(file.path(base_path, "Data", species, "Formatted_raw_data.csv"))){
  print("data already formatted")
} else {
    
  accel <- fread(file.path(species, "raw", "PolarBear_archival_logger_data_southernBeaufortSea_2014_2016_revised.csv"))
  behs <- fread(file.path(species,"raw", "PolarBear_video-derived_behaviors_southernBeaufortSea_2014_2016_revised.csv"))
  
  # theyre big, so going to use table instead of frame conventions
  setDT(behs)
  setDT(accel)
  
  # Convert dattime to POSIXct for easy manuipulation
  behs[, Datetime_behavior_starts := as.POSIXct(Datetime_behavior_starts, format = "%m/%d/%Y %H:%M:%S", tz = "UTC")]
  behs[, Datetime_behavior_ends   := as.POSIXct(Datetime_behavior_ends,   format = "%m/%d/%Y %H:%M:%S", tz = "UTC")]
  accel[, Datetime := as.POSIXct(Datetime, tz = "UTC")]
  
  # this is what they'll goin by
  setkey(behs, Bear, Datetime_behavior_starts, Datetime_behavior_ends)
  
  # join them togetehr based on the datetimes
  accel_beh <- foverlaps(
    accel[, .(Bear, Datetime, Int_aX, Int_aY, Int_aZ, end = Datetime)],
    behs[, .(Bear, Datetime_behavior_starts, Datetime_behavior_ends, Behavior)],
    by.x = c("Bear", "Datetime", "end"),
    by.y = c("Bear", "Datetime_behavior_starts", "Datetime_behavior_ends"),
    type = "within",
    nomatch = NULL
  )
  
  # format the labelled data
  fomatted_accel_beh <- accel_beh %>%
    rename(Time = Datetime,
           X = Int_aX,
           Y = Int_aY,
           Z = Int_aZ,
           ID = Bear,
           Activity = Behavior) %>%
    select(ID, Time, Activity, X, Y, Z) %>%
    filter(!Activity == "unknown")
  
  # subset to a reasonable volume of data
  data  <- fomatted_accel_beh %>%
    group_by(ID, Activity) %>%
    arrange(Time) %>%
    slice(1:20000) %>%
    ungroup() %>%
    arrange(ID, Time)
  
  data <- data %>%
    group_by(ID) %>%
    arrange(Time) %>%
    mutate(time_diff = difftime(Time, data.table::shift(Time)), # had to define package or errored
           break_point = ifelse(time_diff > 2 | time_diff < 0 , 1, 0),
           break_point = replace_na(break_point, 0),
           sequence = cumsum(break_point)) %>%
    select(-break_point, -time_diff)
  
  # save that
  fwrite(data, file.path(species, "Pagano_Bear_formatted.csv"))
} 
