# Maekawa_Gull ------------------------------------------------------------
# This data set had data files and label files
# It had to be converted to data table due to size


# Variables ---------------------------------------------------------------
sample_rate <- 25
outputpath <-  "Data/Maekawa_Gull/Maekawa_Gull_formatted.csv"



# Read in both the data and labels  ---------------------------------------
if(!file.exists(file.path(file.path("Maekawa_Gull"), "Formatted_raw_data.csv"))){
  
  data <- fread(file.path("Data/Maekawa_Gull/raw/raw_data.csv"))
  labels <- fread(file.path("Data/Maekawa_Gull/raw/labels.csv"))
  
# Stitch together ---------------------------------------------------------
  # get the range and give the labels
  data[, timestamp := as.POSIXct(timestamp)]
  labels[, stt_timestamp := as.POSIXct(stt_timestamp)]
  labels[, stp_timestamp := as.POSIXct(stp_timestamp)]
  

# Prepare for overlaps: -----------------------------------------------
  #Add 'start' and 'end' to data 
  
  setDT(labels)
  setDT(data)
  setkey(labels, animal_tag, stt_timestamp, stp_timestamp)
  data <- labels [
    data,
    on = .(
      animal_tag,
      stt_timestamp <= timestamp,
      stp_timestamp >= timestamp
    ),
    nomatch = 0,
    .(animal_tag, timestamp,acc_x, acc_y, acc_z, stt_timestamp, stp_timestamp, activity
    )
  ]


# Group and rename the data -----------------------------------------------
data <- data %>%
  select(animal_tag, timestamp, acc_x, acc_y, acc_z, activity,
         stp_timestamp, stt_timestamp) %>%
  rename(Time = timestamp,
         X = acc_x,
         Y = acc_y,
         Z = acc_z,
         Activity = activity,
         Start_Time = stt_timestamp,
         Stop_Time = stp_timestamp,
         ID = animal_tag)

} else {
  print("data already created")
  

  
}
# Save the file -----------------------------------------------------------
fwrite(data, outputpath)


 

