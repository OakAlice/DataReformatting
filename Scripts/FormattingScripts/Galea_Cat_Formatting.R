# formatting this data


# came formatted this way because I made it

if(!file.exists(file.path(base_path, "Data", species, "Formatted_raw_data.csv"))){
  
  data <- fread(paste0("Galea_Cat/raw/all_labelled.csv"))
  
  data <- data %>% 
  rename(Time = time,
         X = x,
         Y = y,
         Z = z,
         Activity = activity)
  
  data <- data %>%
    group_by(ID) %>%
    arrange(Time) %>%
    mutate(time_diff = difftime(Time, data.table::shift(Time)), # had to define package or errored
           break_point = ifelse(time_diff > 2 | time_diff < 0 , 1, 0),
           break_point = replace_na(break_point, 0),
           sequence = cumsum(break_point)) %>%
    select(-break_point, -time_diff)
  
  
  
  
  print("there is an issue, data doesn't exist")
}

fwrite(data, "Galea_Cat/Galea_Cat_formatted.csv")




