# Quoll

species <- "Gashk_Quoll"

raw_files <- list.files(
  path = "Gashk_Quoll/raw",
  recursive = TRUE,
  pattern = "\\.txt$",
  full.names = TRUE)

alldata <- lapply(raw_files, function(x){
  data <- fread(x)
  
  id <- str_split(basename(dirname(x)), "_", simplify = T)[1]
  
  data <- data %>% 
    mutate(
      time=as.POSIXct((V1 - 719529)*86400, origin = "1970-01-01", tz = "UTC")) %>%
    select(time, V2, V3, V4,V5) %>% 
    rename(X = V2,
           Y = V3,
           Z = V4,
           Activity = V5,
           Time = time) %>% 
    mutate(ID = id)
  
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


fwrite(alldata, "Gashk_Quoll/Gashk_Quoll_formatted.csv")    

  
