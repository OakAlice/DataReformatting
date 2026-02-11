# Glider Data

  species <- "Annett_Glider"

  raw_files <- list.files(
      path = "Annett_Glider/raw",
    recursive = TRUE,
    pattern = "\\.txt$",
    full.names = TRUE)
  
alldata <- lapply(raw_files, function(x){
  
  data <- fread(x)
  ind <- ifelse(grepl("Flip", x), "Flip", "Gilberta")
  
  data <- data %>% 
    mutate(
      time=as.POSIXct((V1 - 719529)*86400, origin = "1970-01-01", tz = "UTC"))
  
  data <- data %>% 
    select(V2, V3, V4, V5, time) %>% 
    rename(X = V2,
           Y = V3,
           Z = V4,
           Activity = V5,
           Time = time) %>%
    mutate(ID = ind) 
  
  data <- filter(data, Activity != 0) 
  data
})
alldata <- rbindlist(alldata)


alldata <- alldata %>%
  group_by(ID) %>%
  arrange(Time) %>%
  mutate(time_diff = difftime(Time, data.table::shift(Time)), # had to define package or errored
         break_point = ifelse(time_diff > 2 | time_diff < 0 , 1, 0),
         break_point = replace_na(break_point, 0),
         sequence = cumsum(break_point)) %>%
  select(-break_point, -time_diff)

  
  
  
  
  fwrite(alldata, "Annett_Glider/Annett_Glider_formatted.csv")    
  
  
  
  
  
  
  
  
  