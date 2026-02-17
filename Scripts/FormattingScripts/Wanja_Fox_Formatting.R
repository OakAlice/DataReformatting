# Wanja_fox ------------------------------------
# appears to be already complete but in fact the times are not as expected
# the time is actually the start time of the burst
# bursts are 10 seconds at 33 Hz

# Variables ---------------------------------------------------------------
sample_rate <- 33
output_path <-  "Data/Wanja_fox/Wanja_fox_formatted.csv"

if(!file.exists(output_path)){
  # Read in and rename the data ---------------------------------------------
  data <- fread(file.path("Data", "Wanja_Fox", "raw", "wanja_fox.csv")) %>%
    rename(Time = timestamp,
           Activity = Bev) %>%
    mutate(firsttime = as.POSIXct(Time, format = "%d.%m.%Y %H:%M:%S", tz = "UTC")) %>%
    group_by(firsttime) %>%
    mutate(frac_time = row_number()/33,
           Time = firsttime + frac_time,
           ID = "A" ) %>% #unknown ID so just generate a false one
    ungroup() %>%
    select(c(ID, Time, X, Y, Z, Activity), -firsttime)
  
  # Relabelling the behaviours ----------------------------------------------
  # not many behaviours to begin with, so not major changes
  data <- data %>%
    mutate(FuncActivity = case_when(
      Activity %in% c("trotting", "walking") ~ "Locomotion",
      # I think stocking is a typo of "stalking"
      Activity %in% c("stocking", "foraging") ~ "Foraging",
      Activity == "grooming" ~ "Grooming",
      Activity == "resting" ~ "Resting"
    ))
  
  # Save the file -----------------------------------------------------------
  fwrite(data, output_path)
    
} else {
  print("data already created")
}
