# Formatting the pangolin data --------------------------------------------
sample_rate <- 50
output_path <- "HarveyCarroll_Pangolin/HarveyCarroll_Pangolin_formatted.csv"

if (file.exists(file.path(base_path, "Data", species, "Formatted_raw_data.csv"))){
  
   files <- list.files(
    path = "HarveyCarroll_Pangolin/raw",
    recursive = TRUE,
    pattern = "\\.csv$",
    full.names = TRUE)
  
  data <- lapply(files, function(x){
    df <- fread(x)
    df$ID <- str_split(basename(x), "_")[[1]][1]
    return(df)
  })
  data <- bind_rows(data)
  data <- data %>%
    rename(Time = time,
           Activity = Behavior) %>%
    select(ID, Time, Activity, X, Y, Z)
  
  # Adding the sequencing ---------------------------------------------------
  data <- data %>%
    group_by(ID) %>%
    arrange(Time) %>%
    mutate(time_diff = difftime(Time, data.table::shift(Time)), # had to define package or errored
           break_point = ifelse(time_diff > 2 | time_diff < 0 , 1, 0),
           break_point = replace_na(break_point, 0),
           sequence = cumsum(break_point)) %>%
    select(-break_point, -time_diff)  
}

else {
print("data already formatted")
} 

fwrite(data, "HarveyCarroll_Pangolin/HarveyCarroll_Pangolin_formatted.csv")






