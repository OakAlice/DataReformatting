# Baglione_Crow ----------------------------------------------------------
# challenging because there is not a 1-1 match between annotations and raw data
# the ID names for these files don't quite match - had to edit the names of the annotations

# Variables ---------------------------------------------------------------
sample_rate <- 50
output_path <- "Data/Baglione_Crow/Baglione_Crow_formatted.csv"

# Reading in and relabelling data  -----------------------------------------
if(!file.exists(file.path(file.path("Baglione_Crow"), "Formatted_raw_data.csv"))){
  
raw_files <- list.files(
  path = "Data/Baglione_Crow/raw",
  recursive = FALSE,
  pattern = "\\.csv$",
  full.names = TRUE)

data <- lapply(raw_files, function(x){
  Id <- gsub("_acc.csv", "", gsub("19_", "", basename(x)))
  
  d <- fread(x) %>%
    rename(X = V1,
           Y = V2,
           Z = V3) %>%
    mutate(ID = Id,
           time = row_number()) %>%
    na.omit()
  
  d
})
data <- rbindlist(data)

# Loading in the annotation files -----------------------------------------
anno_files <- list.files(
  path = "Data/Baglione_Crow/raw/Behavior_annotations",
  recursive = FALSE,
  pattern = "\\.csv$",
  full.names = TRUE)

anno <- lapply(anno_files, function(x){
  Id <- gsub("selections_", "", tools::file_path_sans_ext(basename(x)))
  Id_edited <- sub("(\\d{2})", "", Id) # remove first 2 digits so matches with the other file
  
  d <- fread(x) %>%
    select(start_sec, end_sec, label) %>%
    mutate(ID = Id_edited,
           start_row = start_sec * sample_rate, # convert seconds to rows of the accel
           end_row = end_sec * sample_rate
           ) %>%
    na.omit()
  
  d
})
anno <- rbindlist(anno)

# Stitching annotations and accelerarions ---------------------------------
# check that this is actually doing what I think it is...
# some how creates more rows than in the original data which seems wrong...
data_labelled <- anno[data, 
                     on = .(ID, start_row <= time, end_row >= time),
                     .(X, Y, Z, ID, time, label)]
data_labelled <- data_labelled %>% na.omit()

# Convert the time to a POSIXct of some kind ------------------------------
# Generating a generic strat time and date as a POSIXct and calculate time from there
data <- data_labelled %>%
  group_by(ID) %>%
  arrange(time, .by_group = TRUE) %>% 
  mutate(
    time_diff = (time - lag(time))/sample_rate, # divide by the sample rate to get from row into seconds
    time_diff = if_else(is.na(time_diff), 0, time_diff),  # replace first NA with 0
    cumtime = cumsum(time_diff),
    start_time = as.POSIXct("1970-01-01 00:00:00", tz = "UTC"),
    Time = start_time + cumtime
  ) %>%
  ungroup() %>%
  select(-time, -time_diff, -start_time, -cumtime) %>%
  rename(Activity = label)

} else {
  print("data already created")
    
}


# Save the file ------------------------------------------------------------
fwrite(data, output_path) 
