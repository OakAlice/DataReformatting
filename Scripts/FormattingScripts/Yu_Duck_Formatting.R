# Yu_Duck ------------------------------------------------


# Variables ---------------------------------------------------------------
sample_rate <- 25
outputpath <- "Data/Yu_Duck/Yu_Duck_formatted.csv"



# Read in the data --------------------------------------------------------

if(!file.exists(file.path(file.path("Yu_Duck"), "Formatted_raw_data.csv"))){

  files <- list.files(file.path("Data/Yu_Duck/raw"), full.names = TRUE)
    
  # read them toggether 
  data <- lapply(files, function(x){
    df <- fread(x)
    name <- strsplit(basename(x), "_")[[1]][1]
    df$name <- name
    df$timestamp2 <- as.POSIXct(df$timestamp, format = "%d/%m/%y %H:%M", tz = "UTC")
    df <- df[, c("x", "y", "z", "timestamp2", "behaviour", "name")]
  }
  )
  data <- bind_rows(data)
  
  # format that
  data <- data %>%
    rename(ID = name,
           Activity = behaviour,
           X = x,
           Y = y,
           Z = z,
           Time = timestamp2)
  
  # split labelled and unlabelled
  data <- data %>% filter(!Activity == "")
  unlabelled <- data %>% filter(Activity == "") # there isn't really enough of this to qualify as much??? just ignore it
 

} else {
  print("data already created")
  
}
# Save the file -----------------------------------------------------------
fwrite(data, outputpath)