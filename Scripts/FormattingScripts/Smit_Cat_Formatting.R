# Formatting the Smit_Cat data --------------------------------------------
# refer to folder for email correspondence with lead author
# there is also instructions on the lead author's github
# this is a reproduction of her code
# slightly changed to fit my file paths and use tidyverse notation
# be mindful and careful of timezone changes


pacman::p_load(data.table,
               tidyverse,
               lubridate,
               readxl,
               reshape2,
               plyr
               )

if(!file.exists(file.path(base_path, "Data", species, "Formatted_raw_data.csv"))){
  
  # Prepare the annotations -------------------------------------------------
  # read together the behaviour scoring data output for each cat - xlsx files
  anno <- list.files(file.path(species, "raw", "Annotations"),pattern="*.xlsx", full.names = TRUE)
  lanno <- lapply(setNames(anno, make.names(gsub("ch0", "pen",gsub("*.xlsx$", "", anno)))), read_excel)
  longanno<-ldply(lanno, rbind)

  # Correct the timestamps
  df <- colsplit(string = longanno$Time,pattern = " ",names = c("Date","Time"))
  # this appears to be substituting the exact same time?? but I'll do it because smit did it
  longanno <- longanno %>%
    mutate(Time = as.POSIXct(paste("2021/06/30",df$Time, sep=" "), format="%Y/%m/%d %H:%M:%S"), # this comes in as the timezone of your default system (for me, AEST)
           ID = as.factor(gsub(".20210630", "", strsplit(.id, "_")[[1]][3]))) %>%
    select(-".id")
  
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
  fwrite(longanno, file.path(species, "raw", "Annotations.csv"))
  
  
  # Prepare the acceleration data -------------------------------------------
  files <- list.files(file.path(species, "raw", "Accel"), pattern = "Collar.csv", full.names = TRUE)
   
  data <- lapply(files, function(x){
    dat <- fread(x) %>%
      dplyr::rename(Time = Timestamp,
             X = `Accelerometer X`,
             Y = `Accelerometer Y`,
             Z = `Accelerometer Z`)
    
    datX <- dat # just duplicate for messing around
    
    # ensure that the timezone for this data is set correctly
    # set the tz to UTC (DOUBLE CHECK THIS DOESNT CHANGE THE VALUE)
    dat[, Time := as.POSIXct(Time, format = "%d/%m/%Y %H:%M:%OS", tz = "UTC")]

    
    
    
    
    
    
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







# Modifying her original code ---------------------------------------------
# this is a reproduction of her code
# slightly changed to fit my file paths and use tidyverse notation




############################################################################################################## PREPARATION META DATA
#######################################
### STEP 3 -  PREPARATION META DATA ###
#######################################
# Required input:   - Meta data

start_path <- "..."
setwd(paste0(start_path,"meta_data"))
meta <- read.csv("Model_Meta.csv")
head(meta)
str(meta)

df <- meta

### ADD DATE TO COLUMNS OB_START AND OB_END
df <- df %>%
  mutate(Ob_Start = paste("2021/06/30",df$Ob_Start, sep=" "),Ob_End = paste("2021/06/30",df$Ob_End, sep=" "))

### REMOVE PEN VARIABLE
df <- subset(df, select = -c(Pen))

### CHANGE VARIABLE TYPES
# Change Cat_id from chr to factor
df$Cat_id <- as.factor(df$Cat_id)
# Change Ob_Start and Ob_End from chr to POSIXct
df$Ob_Start<-as.POSIXct(df$Ob_Start,format="%Y/%m/%d %H:%M:%S")
df$Ob_End<-as.POSIXct(df$Ob_End,format="%Y/%m/%d %H:%M:%S")
str(df)

meta <- df

### SET TIMEZONE TO UTC
tz(meta$Ob_Start)
tz(meta$Ob_End)
tz(meta$Ob_Start) <- "UTC"
tz(meta$Ob_End) <- "UTC"

### SAVE META DATAFRAME
start_path <- "..."
setwd(paste0(start_path,"meta_data"))
save(meta, file="meta_data.RDATA")


##################################################################################################################### MERGE DATASETS
###################################################
### STEP 4 - MERGE META DATA AND ANNOTATED DATA ###
###################################################
# Required input:   - Meta data
#                   - Annotated (scored) behaviour data
start_path <- "..."
setwd(paste0(start_path,"meta_data"))
load("meta_data.RDATA")

start_path <- "..."
setwd(paste0(start_path,"Preparation"))
load("anno_data.RDATA")

### MERGE META DATA WITH ANNOTATED DATA
dfAnnoMeta <- longanno %>% left_join(meta, by = 'Cat_id')
head(dfAnnoMeta)
str(dfAnnoMeta)

### SELECT ANNOTATED DATA THAT FALL BETWEEN START AND END TIME
df <- dfAnnoMeta %>% group_by(Cat_id) %>%
  filter(Timestamp >= Ob_Start & Timestamp <= Ob_End)
head(df)
dim(df)
tail(df)
str(df)

### REMOVE ABUNDANT COLUMNS
names(df)
df <- df %>% select(-Ob_Start,-Ob_End)

### SAVE ANNOMETA DATAFRAME
dfAnnoMeta <- df

start_path <- "..."
setwd(paste0(start_path,"Preparation"))
save(dfAnnoMeta, file= "MetaAnno_data.RDATA")


#######################################################
### STEP 5 - MERGE META DATA AND ACCELEROMETER DATA ###
#######################################################
# Required input:   - Meta data
#                   - Accelerometer data
start_path <- "..."
setwd(paste0(start_path,"meta_data"))
load("meta_data.RDATA")

start_path <- "..."
setwd(paste0(start_path,"Preparation"))
load("accel_data.RDATA")

### SET TIMEZONE TO UTC
tz(meta$Ob_Start)
tz(meta$Ob_End)
tz(longaccl$Timestamp)
tz(meta$Ob_Start) <- "UTC"
tz(meta$Ob_End) <- "UTC"

### MERGE META DATA WITH ACCELEROMETER DATA
dfAcclMeta <- longaccl %>% left_join(meta, by = 'Cat_id')
head(dfAcclMeta)
str(dfAcclMeta)

### SELECT ACCELERATION DATA THAT FALL BETWEEN START AND END TIME
df <- dfAcclMeta %>% group_by(Cat_id) %>%
  filter(Timestamp >= Ob_Start & Timestamp <= Ob_End)
head(df)
tail(df)
str(df)
dim(df)

### SAVE ACCLMETA DATAFRAME
dfAcclMeta <- df
save(dfAcclMeta, file= "MetaAccl_data.RDATA")


########################################################
### STEP 6 - MERGE META-ANNO DATA AND META-ACCL DATA ###
########################################################
# Required input:   - MetaAnno data
#                   - MetaAccl data

start_path <- "..."
setwd(paste0(start_path,"Preparation"))
load("MetaAnno_data.RDATA")
load("MetaAccl_data.RDATA")

### CHECK AND SET TIMEZONE TO UTC
tz(dfAcclMeta$Timestamp)
tz(dfAnnoMeta$Timestamp)
tz(dfAnnoMeta$Timestamp) <- "UTC"

### MERGE ANNOMETA AND ACCLMETA
dfCompl <- dfAcclMeta %>% left_join(dfAnnoMeta, by = c('Cat_id', 'Timestamp'))
str(dfCompl)

### SAVE COMPLETE DATAFRAME
start_path <- "..."
setwd(paste0(start_path,"Preparation"))
save(dfCompl, file= "Compl_data.RDATA")

########################################################################################################## PREPARATION COMPLETE DATA
#######################################################
### STEP 7 - PREPARATION COMPLETE (MERGED) DATASET ###
#######################################################
# Required input: - Complete data

start_path <- "..."
setwd(paste0(start_path,"Preparation"))
load("Compl_data.RDATA")

# REMOVE ABUNDANT COLUMNS
dfCompl <- dfCompl %>% select(-Ob_Start,-Ob_End)
dfCompl <- dfCompl %>% select(-Pen)

### CHANGE FROM WIDE FORMAT TO LONG FORMAT
dfCompl <- dfCompl %>% gather(key=Behaviour, value=Status, Other_ActigraphOff:Active_Walking)
str(dfCompl)
head(dfCompl)
table(dfCompl$Behaviour, dfCompl$Status)

### CHANGE VARIABLE TYPES
# Change Cat_id to a factor variable
dfCompl$Cat_id <- as.factor(dfCompl$Cat_id)
# Change Behaviour to a factor variable
dfCompl$Behaviour <- as.factor(dfCompl$Behaviour)
# Change Position to a factor variable
dfCompl$Position <- as.factor(dfCompl$Position)

### REMOVE EVERYTHING WITH STATUS=0
df <- dfCompl[grep(pattern="0", x=dfCompl$Status, invert = TRUE),]
dfCompl <- df

### REMOVE EVERYTHING WITH STATUS=NA
sum(is.na(dfCompl$Status))
df <- dfCompl[!is.na(dfCompl$Status),]
str(df)
dfCompl <- df

dfCompl <- dfCompl %>% select(-Status)

### SAVE COMPLETE DATAFRAME
start_path <- "..."
setwd(paste0(start_path,"Preparation"))
save(dfCompl, file= "Compl_data.RDATA")

