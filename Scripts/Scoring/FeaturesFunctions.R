# generate TSfetures
generateTsFeatures <- function(data) {
  ts_list <- list( ## TODO: Make these changeable
    X = data[["X"]],
    Y = data[["Y"]],
    Z = data[["Z"]]
  )
  
  # List of features to calculate
  features_to_calculate <- c(
    "acf_features",
    "autocorr_features",
    "pacf_features",
    "entropy",
    "hurst",
    "nonlinearity",
    "dist_features",
    "crossing_points",
    "lumpiness",
    "stability",
    "heterogeneity",
    "zero_proportion"
  )
  
  # Initialise an empty list to store features
  time_series_features <- list()
  
  # Loop through each feature and calculate it
  for (feature in features_to_calculate) {
    tryCatch({
      feature_values <- tsfeatures(
        tslist = ts_list,
        features = feature,
        scale = FALSE,
        multiprocess = TRUE
      )
      time_series_features[[feature]] <- feature_values
    }, error = function(e) {
      message("Skipping feature ", feature, " due to error: ", e$message)
    })
  }
  
  # Combine all features into a single tibble
  if (length(time_series_features) > 0) {
    time_series_features <- bind_cols(time_series_features)
  } else {
    time_series_features <- tibble()
  }
  
  return(time_series_features)
}

# summarising a single sample
summarising_a_sample <- function(dat){
  
  time_series_features <- generateTsFeatures(data = dat)
  
  if (nrow(time_series_features) > 0) {
    single_row_features <- time_series_features %>%
      ### NOTE: changed this here to add the gyro but didn't test it ####
    mutate(axis = rep(c("X", "Y", "Z"), length.out = n())) %>%
      pivot_longer(cols = -axis, names_to = "feature", values_to = "value") %>%
      unite("feature_name", axis, feature, sep = "_") %>%
      pivot_wider(names_from = feature_name, values_from = value)
  } else {
    message("No rows in time_series_features. Returning empty tibble.")
    single_row_features <- tibble(matrix(NA, nrow = 1, ncol = length(unique(paste0(rep(c("X", "Y", "Z"), each = length(time_series_features)), "_", names(time_series_features))))))  # Fill with NAs
    colnames(single_row_features) <- unique(paste0(rep(c("X", "Y", "Z"), each = length(time_series_features)), "_", names(time_series_features)))  # Match the column names
  }
  
  window_info <- dat %>% 
    summarise(
      ID = first(ID),
      Activity = first(Activity)
    ) %>% 
    ungroup()
  
  mean_sd <- dat %>%
    summarise(meanX = mean(X),
              meanY = mean(Y),
              meanZ = mean(Z),
              sdX = sd(X),
              sdY = sd(Y),
              sdZ = sd(Z))
  
  combined_features <- cbind(window_info, single_row_features, mean_sd) %>%
    mutate(across(everything(), ~replace_na(., NA)))  # Ensure all columns are present
  
  return(combined_features)
}
