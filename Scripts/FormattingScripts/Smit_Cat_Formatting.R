# Smit_Cat --------------------------------------------
# refer to folder for email correspondence with lead author
# there is also instructions on the lead author's github
# this is a reproduction of her code
# slightly changed to fit my file paths and use tidyverse notation
# be mindful and careful of timezone changes

# Load in the required packages -------------------------------------------
pacman::p_load(readxl,
               reshape2,
               plyr)

# Variables ---------------------------------------------------------------
sample_rate <- 50
output_path <-  "Data/Smit_Cat/Smit_Cat_formatted.csv"

if(!file.exists(output_path)){
  # Prepare the annotations -------------------------------------------------
  # read together the behaviour scoring data output for each cat - xlsx files
  if(!file.exists(file.path("Data", "Smit_Cat", "raw", "Annotations.csv"))){
    
    anno <- list.files(file.path("Data/Smit_Cat/raw/Labels_Data"),pattern="*.xlsx", full.names = TRUE)
    longanno <- lapply(anno, function(y){
      read_xlsx(y, sheet = "Clean") %>%
        mutate(ID = as.factor(
          gsub("ch[0-9]{2}_", "", 
               strsplit(tools::file_path_sans_ext(basename(y)), "-")[[1]][1])))
    })
    longanno <- rbindlist(longanno)
    
    # Correct the timestamps
    df <- colsplit(string = longanno$Time,pattern = " ",names = c("Date","Time"))
    # this appears to be substituting the exact same time?? but I'll do it because smit did it
    longanno <- longanno %>%
      mutate(Time = as.POSIXct(paste("2021/06/30",df$Time, sep=" "), format="%Y/%m/%d %H:%M:%S")) # this comes in as the timezone of your default system (for me, AEST)
    
    # the time is right, but the timestamp is wrong. retain the exact same time but convert 
    longanno$Time <- force_tz(longanno$Time, tzone = "UTC")
    
    # reshape and condesce it
    longanno <- longanno[rowSums(is.na(longanno))==0,] # remove rows wth no behaviours
    setDT(longanno)
    behaviour_cols <- setdiff(names(longanno), c("Time", "ID"))
    longanno_long <- melt(
      longanno,
      id.vars = c("Time", "ID"),
      measure.vars = behaviour_cols,
      variable.name = "Activity",
      value.name = "Status"
    )
    longanno_activity <- longanno_long %>% dplyr::filter(Status == 1) %>% select(-Status)
    
    # save these annotations
    fwrite(longanno_activity, file.path("Data", "Smit_Cat", "raw", "Annotations.csv"))
    
  } else {
    longanno_activity <- fread(file.path("Data", "Smit_Cat", "raw", "Annotations.csv"))
  }
  
  # Prepare the acceleration data -------------------------------------------
  files <- list.files(file.path("Data/Smit_Cat/raw/Harness_Data"), pattern = "*.csv", full.names = TRUE)
  
  data <- lapply(files, function(x){
    dat <- fread(x) %>%
      dplyr::rename(Time = Timestamp,
                    X = `Accelerometer X`,
                    Y = `Accelerometer Y`,
                    Z = `Accelerometer Z`)

    # ensure that the timezone for this data is set correctly
    # set the tz to UTC (DOUBLE CHECK THIS DOESNT CHANGE THE VALUE)
    dat[, Time := as.POSIXct(Time, format = "%d/%m/%Y %H:%M:%OS", tz = "UTC")]
    
    # select the data that falls within the annotation times
    relevant_annotations <- longanno_activity %>%
      dplyr::filter(ID == str_split(tools::file_path_sans_ext(basename(x)), "-")[[1]][3]) 
    
    Strt <- relevant_annotations %>% arrange(Time) %>% slice(1) %>% select(Time)
    Ed <- relevant_annotations %>% arrange(desc(Time)) %>% slice(1) %>% select(Time)
    
    # are the annotations while the cat is wearing the annotation?
    if (dat$Time[1]<Strt$Time){
      print("accel starts before the annotations do (good)")
    } else {
      print("something is wrong (annotations before accel)")
    }
    dat2 <- dat[Time > Strt$Time & Time < Ed$Time]
    
    setDT(dat2)
    setDT(relevant_annotations)
    
    # annotations were made per second whereas data is in 30Hz so we need to do some steps
    # add second-level time keys to join them together
    dat2[, Time_sec := as.POSIXct(floor(as.numeric(Time)), tz = "UTC")]
    relevant_annotations[, Time_sec := as.POSIXct(floor(as.numeric(Time)), tz = "UTC")]
    # ensure there is only one annotation per second (just in case)
    relevant_annotations <- relevant_annotations[ , .SD[1], by = Time_sec]
    # join
    labelled_dat <- merge(dat2, relevant_annotations,
                          by = "Time_sec",
                          all.x = TRUE
    )
    
    # remove the NA observations and clean up a bit
    labelled_dat <- labelled_dat %>%
      na.omit() %>%
      dplyr::rename(Time = Time.x) %>%
      select(-Time.y, -Time_sec)
    
    return(labelled_dat) # return this object
    
  })
  data <- rbindlist(data)
  
  # Recoding the behaviours -------------------------------------------------
  data <- data %>%
    mutate(FuncActivity = case_when(
      
      # General Active
      Activity %in% c(
        "Active_Climbing",
        "Active_Playfight.Fighting",
        "Active_Rubbing"
      ) ~ "Active",
      
      # Locomotion
      Activity %in% c(
        "Active_Trotting",
        "Active_Walking"
      ) ~ "Locomotion",
      
      Activity %in% c(
        "Active_Jumping.Horizontal",
        "Active_Jumping.Vertical"
      ) ~ "Jumping",
      
      # Lying
      Activity %in% c(
        "Inactive_Lying.Crouch",
        "Inactive_Lying.Down"
      ) ~ "Lying",
      
      # Sitting
      Activity %in% c(
        "Inactive_Sitting.Down",
        "Inactive_Sitting.Stationary",
        "Inactive_Sitting.Up"
      ) ~ "Sitting",
      
      # Standing
      Activity %in% c(
        "Inactive_Standing.Stationary",
        "Inactive_Standing.Up"
      ) ~ "Standing",
      
      # Grooming
      Activity %in% c(
        "Maintenance_Grooming",
        "Maintenance_Scratching",
        "Maintenance_Shake.Body",
        "Maintenance_Shake.Head"
      ) ~ "Grooming",
      
      # Littering
      Activity %in% c(
        "Maintenance_Littering.Digging",
        "Maintenance_Littering.None",
        "Maintenance_Littering.Urinating"
      ) ~ "Littering",
      
      # Eating
      Activity == "Maintenance_Nutrition.Eating" ~ "Eating",
      
      Activity == "Other_Social.Allogrooming" ~ "Social",
      
      # other / synchronisation stuff
      Activity %in% c(
        "Other_Start",
        "Other_Outofsight",
        "Other_Other"
      ) ~ "Other"
      
    )) %>%
    mutate(BroadActivity = str_split(Activity, "_", simplify = TRUE)[[1]])
            
  # Save the file -----------------------------------------------------------
  fwrite(data, output_path)
  
} else {
  print("data already created")
}
