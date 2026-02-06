# Formatting the cat data -------------------------------------------------

sample_rate <- 40
output_path <- "Dunford_Cat/Dunford_Cat_formatted.csv"

if(!file.exists(file.path(species, "Dunford_Cat_formatted.csv"))){

   data <- fread(paste0("Dunford_Cat/raw/Dunford_et_al._Cats_calibrated_data.csv"))
  
  data <- data %>%
    group_by(ID) %>%
    mutate(
      time_sec = as.numeric(
        strptime(Time, format = "%H:%M:%S", tz = "UTC")
      ),
      day_offset = cumsum(c(0, diff(time_sec) < 0)),
      numeric_datetime = day_offset * 86400 + time_sec,
      Time = as.POSIXct(
        numeric_datetime,
        origin = "1970-01-01",
        tz = "UTC"
      )
    ) %>% 
    ungroup() %>%
    select(-time_sec, -day_offset, -numeric_datetime) %>% 
    rename(X = AccX,
           Y = AccY,
           Z = AccZ,
           Activity = Behaviour)
  
  
  
  # Adding the sequencing ---------------------------------------------------
  data <- data %>%
    group_by(ID) %>%
    arrange(Time) %>%
    mutate(time_diff = difftime(Time, data.table::shift(Time)), # had to define package or errored
           break_point = ifelse(time_diff > 2 | time_diff < 0 , 1, 0),
           break_point = replace_na(break_point, 0),
           sequence = cumsum(break_point)) %>%
    select(-break_point, -time_diff)
  
} else {
  print("data already created")
}

fwrite(data, "Dunford_Cat/Dunford_Cat_formatted.csv")

