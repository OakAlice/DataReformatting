# Pagano_bear ---------------------------------------------
# This data set had two files for acc data and behaviours


# Variables ---------------------------------------------------------------
sample_rate <- 16 
outputpath <- "Data/Pagano_bear/Pagano_bearformatted.csv"

# Read in both the acc data and behaviours --------------------------------
if(!file.exists(file.path(file.path("Pagano_bear"), "Formatted_raw_data.csv"))){
 
  accel <- fread(file.path("Data/Pagano_Bear/raw/PolarBear_archival_logger_data_southernBeaufortSea_2014_2016_revised.csv"))
  behs <- fread(file.path("Data/Pagano_Bear/raw/PolarBear_video-derived_behaviors_southernBeaufortSea_2014_2016_revised.csv"))
  

# Change to data table due to size ----------------------------------------
  setDT(behs)
  setDT(accel)
  
# Change time to a POSIXct ------------------------------------------------
  behs[, Datetime_behavior_starts := as.POSIXct(Datetime_behavior_starts, format = "%m/%d/%Y %H:%M:%S", tz = "UTC")]
  behs[, Datetime_behavior_ends   := as.POSIXct(Datetime_behavior_ends,   format = "%m/%d/%Y %H:%M:%S", tz = "UTC")]
  accel[, Datetime := as.POSIXct(Datetime, tz = "UTC")]

  # this is what they'll goin by
  setkey(behs, Bear, Datetime_behavior_starts, Datetime_behavior_ends)
  
# Bind on the basis of date time ------------------------------------------
  accel_beh <- foverlaps(
    accel[, .(Bear, Datetime, Int_aX, Int_aY, Int_aZ, end = Datetime)],
    behs[, .(Bear, Datetime_behavior_starts, Datetime_behavior_ends, Behavior)],
    by.x = c("Bear", "Datetime", "end"),
    by.y = c("Bear", "Datetime_behavior_starts", "Datetime_behavior_ends"),
    type = "within",
    nomatch = NULL
  )

# Subset and format the remaining data ------------------------------------
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
  

} 
# Save the file -----------------------------------------------------------
fwrite(data, outputpath)  



