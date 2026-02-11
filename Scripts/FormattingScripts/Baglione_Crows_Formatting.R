# Formatting the Baglione Crows dataset -----------------------------------
# challenging because there is not a 1-1 match between annotations and raw data
# the ID names for these files don't quite match - had to edit the names of the annotations

sample_rate <- 50

# Loading in the raw data -------------------------------------------------
raw_files <- list.files(
  path = "Baglione_Crow/raw",
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
  path = "Baglione_Crow/raw/Behavior_annotations/",
  recursive = FALSE,
  pattern = "\\.csv$",
  full.names = TRUE)

anno <- lapply(anno_files, function(x){
  Id <- gsub("selections_", "", tools::file_path_sans_ext(basename(x)))
  Id_edited <- sub("(\\d{2})", "", Id)
  
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

# Convert the time to a posixct of some kind ------------------------------
# unless the true start times can be found in the document somehwere, I am just going to generate generic time
data_labelled <- data_labelled %>%
  group_by(ID) %>%
  arrange(time, .by_group = TRUE) %>% 
  mutate(
    time_diff = (time - lag(time))/sample_rate, # divide by the sampkle rate to get from row into seconds
    time_diff = if_else(is.na(time_diff), 0, time_diff),  # replace first NA with 0
    cumtime = cumsum(time_diff),
    start_time = as.POSIXct("2000-01-01 00:00:00", tz = "UTC"),
    Time = start_time + cumtime
  ) %>%
  ungroup() %>%
  select(-time, -time_diff, -start_time, -cumtime) %>%
  rename(Activity = label)

# Add sequencing ----------------------------------------------------------
data_labelled <- data_labelled %>%
  group_by(ID) %>%
  arrange(Time) %>%
  mutate(time_diff = difftime(Time, data.table::shift(Time)), # had to define package or errored
         break_point = ifelse(time_diff > 2 | time_diff < 0 , 1, 0),
         break_point = replace_na(break_point, 0),
         sequence = cumsum(break_point)) %>%
  select(-break_point, -time_diff)

# Save to file ------------------------------------------------------------
fwrite(data_labelled, "Baglione_Crow/Baglione_Crow_formatted.csv")    
