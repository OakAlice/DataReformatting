# HarveyCarrol_Pangolin ---------------------------------------------------
# This data needed IDs to be taken form the file names

# Variables ---------------------------------------------------------------
sample_rate <- 50
output_path <- "Data/HarveyCarrol_Pangolin/HarveyCarrol_Pangolin_formatted.csv"

# Read in and rename the data ---------------------------------------------
if(!file.exists(output_path)){
  
  files <- list.files(
    path = "Data/HarveyCarrol_Pangolin/raw",
    recursive = TRUE,
    pattern = "\\.csv$",
    full.names = TRUE)
  
  data <- lapply(files, function(x){
    df <- fread(x)
    # Take the IDs from the file names
    df$ID <- str_split(basename(x), "_")[[1]][1]
    return(df)
  })
  data <- bind_rows(data)
  data <- data %>%
    rename(Time = time,
           Activity = Behavior) %>%
    select(ID, Time, Activity, X, Y, Z)
 
  # Save the file -----------------------------------------------------------
  fwrite(data, output_path)  
  
} else {
  print("data already formatted")
} 








