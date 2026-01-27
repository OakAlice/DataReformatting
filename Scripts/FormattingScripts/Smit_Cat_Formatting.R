# Formatting the Smit_Cat data --------------------------------------------
# refer to folder for email correspondence with lead author
# there is also instructions on the lead author's github





# NOTE: THE WAY THIS IS CURRENTLY DONE IS WRONG
# i.e., IT LEADS TO NON-SENSICAL ANNOTATIONS... MUST RE-READ THE AUTHOR'S GIT



# Aligning the annotations and raw readings -------------------------------
if(!file.exists(file.path(base_path, "Data", species, "Formatted_raw_data.csv"))){
    
  files <- list.files(file.path(species, "raw"), pattern = "Collar.csv", full.names = TRUE)
  annotations <- fread(file.path(species, "raw", "Annotations.csv")) %>%
    select(-V1)
  observation_times <- fread(file.path(species, "raw", "Smit_2023_metadata.csv")) %>%
    rename(ID = Cat_id)
    
  data <- lapply(files, function(x){
    dat <- fread(x) %>%
      rename(Time = Timestamp,
             X = `Accelerometer X`,
             Y = `Accelerometer Y`,
             Z = `Accelerometer Z`)
    
    dat <- datX
    
    # ensure that the timezone for this data is set correctly
    dat[, Time := as.POSIXct(Time, format = "%d/%m/%Y %H:%M:%OS", tz = "UTC")] # firstly set it to UTC
    
    # checking the times
    # I know from my emails with Smit that the accelerometer should start a while before theyre put on the animal
    # check that this is actually the case and flag if any of the times seem off
    # extract the start and end times for the observation
    Start <- as.POSIXct(
      paste("2021-06-30", observation_times$Ob_Start[observation_times$ID == this_ID]), 
      format = "%Y-%m-%d %H:%M:%S",
      tz = "UTC" # Smit set to UTC in her github
    )
    End <- as.POSIXct(
      paste("2021-06-30", observation_times$Ob_End[observation_times$ID == this_ID]), 
      format = "%Y-%m-%d %H:%M:%S",
      tz = "UTC" # Smit set to UTC in her github
    )
    if (dat$Time[1]<Start){
      print("accel starts before the experiment does")
    } else {
      print("the time zones are wrong")
    }
  
    # now to deal with adding in the annotations
    # update the time in the annotations to be the same day as the data was collected
    # then select the data that falls within the annotation times
    relevant_annotations <- annotations %>%
      dplyr::filter(ID == str_split(tools::file_path_sans_ext(basename(x)), "-")[[1]][3]) 
    
    # these times seem a bit improbable for human observation times... maybe they are in the wrong timezone?
    # maybe it was recorded in local time rather than UTC time
    # Study was conducted in Palmerston North, NZ, during June (winter)
    # meaning the local timezone would have been UTC+12 at the time... 
    # this doesn't align though... (I checked)
    # What if they were using a summer tz (UTC+13)? some devices automatically make this change while others dont
    relevant_annotations$Time <- force_tz(relevant_annotations$Time, tzone = "Pacific/Auckland") # define as originally in NZMT
    relevant_annotations$Time <- as.POSIXct(relevant_annotations$Time, tz = "UTC") # change them to UTC
    relevant_annotations$Time <- relevant_annotations$Time + 3600 # add 1 hour
    # according to the git, everything is done on the 30-06-2021
    relevant_annotations$Time <- update(relevant_annotations$Time, year = 2021, month = 6, day = 30)
    Strt <- relevant_annotations %>% arrange(Time) %>% slice(1) %>% select(Time)
    Ed <- relevant_annotations %>% arrange(desc(Time)) %>% slice(1) %>% select(Time)
    
    # are the annotations while the cat is wearing the annotation?
    if (dat$Time[1]<Strt$Time){
      print("accel starts before the annotations do")
    } else {
      print("something is wrong")
    }
    
    # extract the relevant portion
    dat2 <- dat[Time > Strt$Time & Time < Ed$Time]
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
      rename(Time = Time.x) %>%
      select(-Time.y, -Time_sec)
    
    labelled_dat # return this object
    
  })
  data <- rbindlist(data)
  # just the reformatted data
  fwrite(data, file.path("Smit_Cat", paste0("Smit_Cat_rawcombined.csv")))

# Adding the sequencing ---------------------------------------------------
data <- data %>%
  group_by(ID) %>%
  arrange(Time) %>%
  mutate(time_diff = difftime(Time, data.table::shift(Time)), # had to define package or errored
         break_point = ifelse(time_diff > 2 | time_diff < 0 , 1, 0), # greater than 2 seconds unlabelled counts as a break
         break_point = replace_na(break_point, 0),
         sequence = cumsum(break_point)) %>%
  select(-break_point, -time_diff)


# Recoding the behaviours -------------------------------------------------
data <- data %>%
  mutate(GeneralisedActivity = case_when(
    
    # Active
    Activity %in% c(
      "Active_Climbing",
      "Active_Jumping.Horizontal",
      "Active_Jumping.Vertical",
      "Active_Playfight.Fighting",
      "Active_Rubbing",
      "Active_Trotting",
      "Active_Walking"
    ) ~ "Active",
    
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
    
    TRUE ~ NA_character_
  ))


# Write to file -----------------------------------------------------------
  fwrite(data, file.path("Smit_Cat", paste0("Smit_Cat_formatted.csv")))
}

