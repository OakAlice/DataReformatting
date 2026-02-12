# Gashk_Quoll -------------------------------------------------------------
# This data set needed a generic date to be generated

# Variables ---------------------------------------------------------------
sample_rate <- 50
outputpath <- "Data/Gashk_Quoll/Gashk_Quoll_formatted.csv"
  

# Read in and rename the data ---------------------------------------------
if(!file.exists(file.path(file.path("Gashk_Quoll"), "Formatted_raw_data.csv"))){


raw_files <- list.files(
  path = "Data/Gashk_Quoll/raw",
  recursive = TRUE,
  pattern = "\\.txt$",
  full.names = TRUE)

alldata <- lapply(raw_files, function(x){
  data <- fread(x)
  
  id <- str_split(basename(dirname(x)), "_", simplify = T)[1]
  
  data <- data %>% 
    # generate a generic date
    mutate(
      time=as.POSIXct((V1 - 719529)*86400,
                      origin = "1970-01-01", 
                      tz = "UTC")) %>%
    select(time, V2, V3, V4,V5) %>% 
    rename(X = V2,
           Y = V3,
           Z = V4,
           Activity = V5,
           Time = time) %>% 
    mutate(ID = id)
  
  data
})
data <- rbindlist(alldata)

} else {
  print("data already created")
  
    
}
# Save the file -----------------------------------------------------------
fwrite(data, outputpath)  


  
