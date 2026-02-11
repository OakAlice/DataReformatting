# Possum Data

species <- "Annett_Possum"

raw_files <- list.files(
  path = "Annett_Possum/raw",
  recursive = TRUE,
  pattern = "\\.csv$",
  full.names = TRUE)


alldata <- lapply(raw_files, function(x){
  
  data <- fread(x)
  ind <-  if (grepl ("Larry", x)) {
    "Larry"
  } else if (grepl("Damien", x)) {
    "Damien"
  } else if (grepl("Hughey", x)) {
    "Hughey"
  } else if (grepl("Joe", x)) {
    "Joe"
  }

  data <- data %>% 
    mutate(
      time=as.POSIXct((V1 - 719529)*86400, origin = "1970-01-01", tz = "UTC"))
  
  data <- data %>% 
    select(V2, V3, V4, time) %>% 
    rename(X = V2,
           Y = V3,
           Z = V4,
           Time = time) %>%
    mutate(ID = ind) 
  
  
  data
})
alldata <- rbindlist(alldata)







