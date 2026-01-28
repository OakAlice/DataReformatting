# Formatting the cat data -------------------------------------------------

sample_rate <- 40

if(!file.exists(file.path(base_path, "Data", species, "Formatted_raw_data.csv"))){

   data <- fread(paste0("Data/", species, "/raw/Dunford_et_al._Cats_calibrated_data.csv"))
  
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
} else {
  print("data already created")
}
