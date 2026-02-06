# Formatting the duck data ------------------------------------------------

# variables
sample_rate <- 25
species <- "Yu_Duck"
output_path <- "Yu_Duck_formatted.csv"


files <- list.files(file.path(species, "raw"), full.names = TRUE)

if (file.exists(file.path(base_path, "Data", species, "Formatted_raw_data.csv"))){
  print("data already formatted")
} else {
    
    
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
  
  data <- data %>%
    group_by(ID) %>%
    arrange(Time) %>%
    mutate(time_diff = difftime(Time, data.table::shift(Time)), # had to define package or errored
           break_point = ifelse(time_diff > 2 | time_diff < 0 , 1, 0),
           break_point = replace_na(break_point, 0),
           sequence = cumsum(break_point)) %>%
    select(-break_point, -time_diff)
  
  
  
  fwrite(data, file.path(species, "Yu_Duck_formatted.csv"))
}
