# Wanja_fox ------------------------------------
# appears to be already complete but in fact the times are not as expected
# the time is actually the start time of the burst
# bursts are 10 seconds at 33 Hz (I think - though am not sure, need to reread paper)


# Variables ---------------------------------------------------------------
sample_rate <- 33
outputpath <-  "Data/Wanja_fox/Wanja_fox_formatted.csv"


# Read in and rename the data ---------------------------------------------
if(!file.exists(file.path(file.path("wanja_Fox"), "Formatted_raw_data.csv"))){

data <- fread(file.path("Data", "Wanja_Fox", "raw", "wanja_fox.csv")) %>%
  rename(Time = timestamp,
         Activity = Bev) %>%
  mutate(firsttime = as.POSIXct(Time, format = "%d.%m.%Y %H:%M:%S", tz = "UTC")) %>%
  group_by(firsttime) %>%
  mutate(frac_time = row_number()/33,
         Time = firsttime + frac_time,
         ID = "A" ) %>% #unknown ID so just generate a false one
  select(c(ID, Time, X, Y, Z, Activity)) %>%
  ungroup()

} else {
  print("data already created")
}


# Save the file -----------------------------------------------------------
fwrite(data, outputpath)
