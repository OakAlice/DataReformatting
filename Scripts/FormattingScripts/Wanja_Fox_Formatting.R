# Formatting for the Wanja Fox Dataset ------------------------------------
# appears to be already complete but in fact the times are not as expected
# the time is actually the start time of the burst
# bursts are 10 seconds at 33 Hz (I think - though am not sure, need to reread paper)

sample_rate <- 33

data <- fread(file.path("wanja_Fox", "raw", "wanja_fox.csv")) %>%
  rename(Time = timestamp,
         Activity = Bev) %>%
  mutate(firsttime = as.POSIXct(Time, format = "%d.%m.%Y %H:%M:%S", tz = "UTC")) %>%
  group_by(firsttime) %>%
  mutate(frac_time = row_number()/33,
         Time = firsttime + frac_time,
         ID = "A" ) %>% #unknown ID so just generate a false one
  select(c(ID, Time, X, Y, Z, Activity)) %>%
  ungroup()

data <- data %>%
  group_by(ID) %>%
  arrange(Time) %>%
  mutate(time_diff = difftime(Time, data.table::shift(Time)), # had to define package or errored
         break_point = ifelse(time_diff > 2 | time_diff < 0 , 1, 0),
         break_point = replace_na(break_point, 0),
         sequence = cumsum(break_point)) %>%
  select(-break_point, -time_diff)

fwrite(data, file.path("Wanja_Fox", "Wanja_Fox_formatted.csv"))
