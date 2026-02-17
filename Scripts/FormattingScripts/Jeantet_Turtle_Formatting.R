# Jeantet_Turtle ----------------------------------------------------------
# The data is in both h5 and csv files
# Both file types had to be read in data table and stitched together
# IDs for the data was found in the file names

# Load in the required packages for dealing with h5 files --------------------
if (!requireNamespace("BiocManager", quietly = TRUE))
  install.packages("BiocManager")
BiocManager::install("rhdf5", force = TRUE)
pacman::p_load(rhdf5)

# Variables ---------------------------------------------------------------
sample_rate <- 20
output_path <- "Data/Jeantet_Turtle/Jeantet_Turtle_formatted.csv"

if(!file.exists(output_path)){
# Read in and rename the acc data   ---------------------------------------
  raw_files <- list.files(
    path = "Data/Jeantet_Turtle/raw",
    recursive = F,
    pattern = "\\.h5$",
    full.names = TRUE)
  
  raw_data <- lapply(raw_files, function(x){
    h5ls(x)
    acc <- h5read(x, "data")
    acc <- as.data.frame(t(acc))
    colnames(acc) <- c("X", "Y", "Z", "GX", "GY", "GZ", "Depth")
    acc$Id <- tools::file_path_sans_ext(basename(x)) 
    acc$Row_Number <- seq_len(nrow(acc))  
    acc
  })
  raw_data <- rbindlist(raw_data)
  
  # Read in the behaviour files ----------------------------------------------
  behaviors_files <- list.files(
    path = "Data/Jeantet_Turtle/raw",
    recursive = TRUE,
    pattern = "\\.csv$",
    full.names = TRUE)
  
  behaviors_data <- lapply(behaviors_files, function(file) {
    print(file)
    df <- read_csv(file, show_col_types = F)
    df <- df %>% 
      rowwise %>% 
      rename(V1 = colnames(df)) %>% 
      # all columns appear as a single string... split it apart manually
      mutate(Stt_Time = str_split(V1, ";", simplify = T)[1],
             Stp_Time = str_split(V1, ";", simplify = T)[3],
             Activity = str_split(V1, ";", simplify = T)[5],
             Syc_Stt_Time = str_split(V1, ";", simplify = T)[8],
             Syc_Stp_Time = str_split(V1, ";", simplify = T)[9]) %>% 
      select(-V1) %>%
      mutate( Id =
      gsub("Behaviors_", "", tools::file_path_sans_ext(basename(file))))
    return(df)
  })
  behaviors_data <- bind_rows(behaviors_data)
  
  # the annotations are organised from the first row of the raw data, therefore
  # convert the time to row number
  behaviors_data <- behaviors_data %>% 
      mutate(
        First_Row = as.numeric(Syc_Stt_Time)*20,
        Last_Row = as.numeric(Syc_Stp_Time)*20
      )
    
  # Convert to data table to bind the data  ---------------------------------
  setDT(raw_data)
  setDT(behaviors_data)
  setkey(behaviors_data, Id, First_Row, Last_Row)
  
  # stitch based on the right row number
  data <- behaviors_data [
    raw_data,
    on = . (
      Id,
      First_Row <= Row_Number,
      Last_Row >= Row_Number
    ),
    nomatch = 0,
    .(
      Id, Activity, X, Y, Z, GX, GY, GZ, Row_Number, Stt_Time
    )
  ]

  # clean up and set times --------------------------------------------------
  data <- data %>% 
    arrange(Row_Number) %>% 
    mutate(
      change = as.integer(!is.na(lag(Stt_Time)) & Stt_Time != lag(Stt_Time)),
      group_id = cumsum(change)
    ) %>%
    group_by(group_id) %>%
    mutate(
      cumchange = row_number() / 20,
      Date = str_split(Id, "_", simplify = TRUE)[, 2]
    ) %>%
    mutate(
      Updated_Time = as.POSIXct(
        paste(Date, Stt_Time),
        format = "%d-%m-%Y %H:%M:%S",
        tz = "UTC"
      ),
      Updated_Time = Updated_Time + lubridate::seconds(cumchange),
      Id = str_split(Id, "_", simplify = TRUE)[, 1]
    ) %>% 
    ungroup()
  
  # Select and rename the data ----------------------------------------------
  data <- data %>% 
    select(Id, Activity, X, Y, Z, GX, GY, GZ, Updated_Time) %>% 
    rename(ID = Id,
           Time = Updated_Time)
  
  # Save the file -----------------------------------------------------------
  fwrite(data, output_path)  
  
} else {
  print("data already created")
}
