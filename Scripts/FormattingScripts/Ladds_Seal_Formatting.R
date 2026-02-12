# Ladds_Seal --------------------------------------------------------------
# This data had to have its dates and times combined to one datetime column

# Variables ---------------------------------------------------------------
sample_rate <- 25
outputpath <-  "Data/Ladds_Seal/Ladds_Seal_formatted.csv"


# Read in the data ---------------------------------------------
if(!file.exists(file.path(file.path("Ladds_Seal"), "Formatted_raw_data.csv"))){
  
  raw_files <- list.files(
    path = "Data/Ladds_Seal/raw",
    recursive = TRUE,
    pattern = "\\.csv$",
    full.names = TRUE)
  

# Formatting and finding ID -----------------------------------------------
raw_data <- lapply(raw_files, function(file) {
    df <- read.csv(file)
    id <- basename(dirname(file))  # get the lowest folder name
    df$ID <- id
    return(df)
  })
  raw_data <- bind_rows(raw_data)
  
# Ensure the date in time is formatted ------------------------------------
  raw_data$time <- as.POSIXct(raw_data$time, format = "%Y-%m-%d %H:%M:%S")
    raw_data$Time <- format(raw_data$time, format = "%H:%M:%S")
    raw_data$DateTime <- paste(raw_data$doe, raw_data$Time) 
    raw_data$DateTime <- as.POSIXct(raw_data$DateTime, format = "%d-%m-%y %H:%M:%S")
  

# Formatting and renaming -------------------------------------------------
  data <- raw_data %>%
    select(ID, DateTime, x, y, z, behaviour, type, location) %>%
    rename(Time = DateTime,
           X = x,
           Y = y,
           Z = z,
           Activity = behaviour,
           GeneralisedActivity = type,
           Context = location)

} else {
  print("data already created")
  
}

# Save the file -----------------------------------------------------------
fwrite(data, outputpath)  



