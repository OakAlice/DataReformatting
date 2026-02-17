# Dunford_Cat -------------------------------------------------------------
# This data set needed time to be managed recordings occurred over midnight
# A generic date was also generated 

# Variables ---------------------------------------------------------------
sample_rate <- 40
output_path <- "Data/Dunford_Cat/Dunford_Cat_formatted.csv"

# Read in and rename the data ---------------------------------------------
if(!file.exists(output_path)){

  data <- fread("Data/Dunford_Cat/raw/Dunford_et_al._Cats_calibrated_data.csv")
  
  data <- data %>%
    group_by(ID) %>%
    mutate(
      time_sec = as.numeric(
        strptime(Time, format = "%H:%M:%S", tz = "UTC")
      ), # Add the day offset and generate a date
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
  
  # Save File ---------------------------------------------------------------
  fwrite(data, output_path)
  
} else {
  print("data already created")
}
