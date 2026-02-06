# Ladds_Seal --------------------------------------------------------------
sample_rate <- 25
if(!file.exists(file.path(species, "Ladds_Seal_formatted.csv"))){

  raw_files <- list.files(
    path = "Ladds_Seal/raw",
    recursive = TRUE,
    pattern = "\\.csv$",
    full.names = TRUE)
  
  # Basic Formatting --------------------------------------------------------
  # add column for ID
  raw_data <- lapply(raw_files, function(file) {
    df <- read.csv(file)
    id <- basename(dirname(file))  # get the lowest folder name
    df$ID <- id
    return(df)
  })
  raw_data <- bind_rows(raw_data)
  
  
  # Ensure time & dates are combined --------------------------------------  
  raw_data$time <- as.POSIXct(raw_data$time, 
                              format = "%Y-%m-%d %H:%M:%S")
  raw_data$Time <- format(raw_data$time, 
                          format = "%H:%M:%S")
  raw_data$DateTime <- paste(raw_data$doe, raw_data$Time) 
  raw_data$DateTime <- as.POSIXct(raw_data$DateTime, 
                                  format = "%d-%m-%y %H:%M:%S")
  
  # format
  raw_data <- raw_data %>%
    select(ID, DateTime, x, y, z, behaviour, type, location) %>%
    rename(Time = DateTime,
           X = x,
           Y = y,
           Z = z,
           Activity = behaviour,
           GeneralisedActivity = type,
           Context = location)
  
  # Add sequencing 
  data <- raw_data %>%
    group_by(ID) %>%
    arrange(Time) %>%
    mutate(time_diff = difftime(Time, data.table::shift(Time)), # had to define package or errored
           break_point = ifelse(time_diff > 2 | time_diff < 0 , 1, 0),
           break_point = replace_na(break_point, 0),
           sequence = cumsum(break_point)) %>%
    select(-break_point, -time_diff)
  
}
fwrite(data, "Ladds_Seal/Ladds_Seal_formatted.csv")


