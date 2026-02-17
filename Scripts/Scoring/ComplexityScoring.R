# Script for scoring the dataset on various metrics -----------------------
# Main script that calls and runs the different functions from different files

# Load in the data --------------------------------------------------------
data <- fread(file.path(wd, "Data", species, paste0(species, "_formatted.csv")))
data <- identify_sequence(data)
data <- identify_events(data)
data <- data %>%
  mutate(unique_key = paste(ID, sequence, event, sep = "_")) %>%
  select(-sequence, -event)
  
# for each of the events 
unique_events <- unique(data$unique_key)
unique_events <- unique_events[1:20]

# Summarise every sample --------------------------------------------------
# makes features
summaries <- lapply(unique_events, function(x){
  print(x)
  dat <- data %>% dplyr::filter(unique_key == x)
  sum <- summarising_a_sample(dat)
  sum$key <- x
  sum
})
summaries <- rbindlist(summaries)


# Compare two given samples -----------------------------------------------

signal_1 <- data %>% dplyr::filter(unique_key == unique_events[1])
signal_2 <- data %>% dplyr::filter(unique_key == unique_events[3])
dynamics <- dtw(signal_1[,"X"], signal_2[,"X"],
    distance.only = TRUE)$distance


# mean distance within a class using dynamic time warping -----------------
classes <- unique(data$Activity)
axes <- c("X", "Y", "Z")

within_class_dist_dtw <- lapply(classes, function(current_class) {
  
  single_class <- data %>%
    dplyr::filter(Activity == current_class)
  
  axis_results <- lapply(axes, function(current_axis) {
    
    # Split into bouts by unique_key for the selected axis
    bout_list <- split(single_class[[current_axis]], 
                       single_class$unique_key)
    
    # Optional: limit to first 20 bouts
    bout_list <- bout_list[1:min(20, length(bout_list))]
    
    n <- length(bout_list)
    dist_mat <- matrix(NA, n, n)
    
    for (i in 1:n) {
      for (j in i:n) {
        d <- dtw(bout_list[[i]],
                 bout_list[[j]],
                 distance.only = TRUE)$distance
        
        dist_mat[i, j] <- d
        dist_mat[j, i] <- d
      }
    }
    
    mean(dist_mat[upper.tri(dist_mat)], na.rm = TRUE)
  })
  
  names(axis_results) <- axes
  axis_results
})

within_class_dist_dtw <- rbindlist(within_class_dist_dtw)
within_class_dist_dtw$Activity <- classes

ggplot(within_class_dist_dtw, aes(x = Activity)) +
  geom_point(aes(y = X), colour = "plum") +
  geom_point(aes(y = Y), colour = "darkblue") +
  geom_point(aes(y = Z), colour = "goldenrod") +
  my_theme()

# Mean distance within a class using cross-correlation --------------------
# only makes sense when all samples are roughly the same size
within_class_corr <- lapply(classes, function(current_class) {
  
  single_class <- data %>%
    dplyr::filter(Activity == current_class)
  
  axis_results <- lapply(axes, function(current_axis) {
    
    # Split into bouts
    bout_list <- split(single_class[[current_axis]], 
                       single_class$unique_key)
    
    # Optional: limit to first 20 bouts
    bout_list <- bout_list[1:min(20, length(bout_list))]
    
    n <- length(bout_list)
    corr_mat <- matrix(NA, n, n)
    
    for (i in 1:n) {
      for (j in i:n) {
        
        x <- bout_list[[i]]
        y <- bout_list[[j]]
        
        # Make same length if needed
        min_len <- min(length(x), length(y))
        x <- x[1:min_len]
        y <- y[1:min_len]
        
        # Normalized cross-correlation
        cc <- ccf(x, y, plot = FALSE, lag.max = min_len - 1)
        rho <- max(abs(cc$acf))  # take max absolute correlation
        
        corr_mat[i, j] <- rho
        corr_mat[j, i] <- rho
      }
    }
    
    mean(corr_mat[upper.tri(corr_mat)], na.rm = TRUE)
  })
  
  names(axis_results) <- axes
  axis_results
})

within_class_corr <- rbindlist(within_class_corr)
within_class_corr$Activity <- classes

ggplot(within_class_corr, aes(x = Activity)) +
  geom_point(aes(y = X), colour = "plum") +
  geom_point(aes(y = Y), colour = "darkblue") +
  geom_point(aes(y = Z), colour = "goldenrod") +
  my_theme()





# Visualise ---------------------------------------------------------------
plot_overlay <- function(data, class_name, axis_name) {
  
  df <- data %>%
    filter(Activity == class_name) %>%
    select(unique_key, ID, all_of(axis_name)) %>%
    group_by(unique_key) %>%
    mutate(Time = row_number()) %>%
    ungroup()
  
  ggplot(df, aes(x = Time, y = .data[[axis_name]], 
                 group = unique_key)) +
    geom_line(alpha = 0.2) +
    labs(title = paste(class_name, "-", axis_name),
         x = "Row Number",
         y = axis_name) +
    my_theme() + 
    facet_wrap(~ID)
}

plot_overlay(data, 
             class_name = "Run", 
             axis_name = "Z")



# eventually trying to get down to
# effect_size <- (mean_within - mean_between) / sd(c(within_vals, between_vals))








ggplot(mean_sd, aes(x = sequence)) + 
  geom_point(aes(y = meanX), colour = "plum") +
  geom_point(aes(y = meanY), colour = "darkblue") +
  geom_point(aes(y = meanZ), colour = "goldenrod") +
  my_theme()




tracePlots <- plotTraceExamples(
  behaviours = "Walk",
  data = data,
  individuals = 5,
  n_samples = 10 * sample_rate
)
