#Studd_Squirrel --------------------------------------------


# Variables ---------------------------------------------------------------
sample_rate <- 1
outputpath <- "Data/Studd_Squirrel/Studd_Squirrel_formatted.csv"


# Read in and rename the data ---------------------------------------------
if(!file.exists(file.path(file.path("Studd_Squirrel"), "Formatted_raw_data.csv"))){
  
  data <- fread(file.path("Data/Studd_Squirrel/raw/Studd_2019.csv"))
  
  data <- data %>%
    select(TIME, BEHAV, X, Y, Z, LCOLOUR, RCOLOUR) %>%
    mutate(ID = paste0(LCOLOUR, RCOLOUR)) %>%
    rename(Time = TIME,
           Activity = BEHAV) %>%
    select(!c(LCOLOUR, RCOLOUR)) 

  
} else {
  print("data already created")
  
}

# Save the file -----------------------------------------------------------
fwrite(data, outputpath)
