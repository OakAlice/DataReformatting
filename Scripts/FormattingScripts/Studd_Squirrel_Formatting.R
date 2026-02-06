# Formatting the squirrel data --------------------------------------------
# another nice and easy one

# read in the data
sample_rate <- 1
species <- "Studd_Squirrel"
output_path <- "Studd_Squirrel/Studd_Squirrel_formatted.csv"


if(!file.exists(file.path(base_path, "Data", species, "Formatted_raw_data.csv"))){
    
  data <- fread(file.path(species, "raw/Studd_2019.csv"))
  
  data <- data %>%
    select(TIME, BEHAV, X, Y, Z, LCOLOUR, RCOLOUR) %>%
    mutate(ID = paste0(LCOLOUR, RCOLOUR)) %>%
    rename(Time = TIME,
           Activity = BEHAV) %>%
    select(!c(LCOLOUR, RCOLOUR)) 
  
  
  data <- data %>%
    group_by(ID) %>%
    arrange(Time) %>%
    mutate(time_diff = difftime(Time, data.table::shift(Time)), # had to define package or errored
           break_point = ifelse(time_diff > 2 | time_diff < 0 , 1, 0),
           break_point = replace_na(break_point, 0),
           sequence = cumsum(break_point)) %>%
    select(-break_point, -time_diff)
  
  
  fwrite(data, file.path(species, "Studd_Squirrel_formatted.csv"))
}
