# Script for scoring the dataset on various metrics -----------------------
# Main script that calls and runs the different functions from different files

# Load in the data --------------------------------------------------------
data <- fread(file.path(wd, "Data", species, paste0(species, "_formatted.csv")))

# Intra-ID Behavioural Complexity -----------------------------------------
# How much variation is there within an ID-Activity combination

# power spectral density 
compute_psd <- function(x, sample_rate){
  
  n <- length(x)
  
  # detrend
  x <- x - mean(x)
  
  X <- fft(x)
  
  freq <- (0:(n-1)) * sample_rate / n
  pos <- 1:floor(n/2)
  
  psd <- (Mod(X)^2) / (n * sample_rate)
  
  data.frame(
    frequency = freq[pos],
    power = psd[pos]
  )
}



summarising_a_sample <- function(data, id, act){
  # extract all bouts of this behaviour
  samples <- data %>% 
    dplyr::filter(ID == id, 
                  Activity == act)
  
  # identify the continuous sequences
  samples <- identify_sequence(samples)
  
  # add row number
  samples <- samples %>%
    group_by(sequence) %>%
    mutate(sec = row_number()/sample_rate)
  
  # some very basic statistics
  mean_sd <- samples %>%
    group_by(sequence) %>%
    summarise(meanX = mean(X),
             meanY = mean(Y),
             meanZ = mean(Z),
             sdX = sd(X),
             sdY = sd(Y),
             sdZ = sd(Z)
           )
  
  psds <- lapply(1:max(samples$sequence), function(x){
  
    dat <- samples %>% dplyr::filter(sequence == x)
    
    all_psd_computes <- data.frame()
    for (axis in c("X", "Y", "Z")){
      vector <- dat[[axis]]
      psd_computes <- compute_psd(vector, sample_rate)
      
      # summary features
      peak_freq_value <- psd_computes$frequency[which.max(psd_computes$power)]
      centroid_value <- sum(psd_computes$frequency * psd_computes$power) / sum(psd_computes$power)
      p <- psd_computes$power / sum(psd_computes$power)
      entropy_value <- -sum(p * log(p + 1e-12))
      band_power_value <- sum(psd_computes$power[psd_computes$frequency >= 0 & psd_computes$frequency <=2])
      total_power_value <- sum(psd_computes$power)
      
      psd_summaries <- data.frame(
        sequence = dat$sequence[1],
        vector = axis,
        peak_freq = peak_freq_value,
        centroid = centroid_value,
        entropy = entropy_value,
        band_power = band_power_value,
        total_power = total_power_value
      )
      
      all_psd_computes <- rbind(all_psd_computes, psd_summaries)
    }
    all_psd_computes
  })
  psds <- rbindlist(psds)
  
  # make wide
  tidyr
  
  
  
  
}



ggplot(samples, aes(x = sec)) +
  geom_path(aes(y = X), colour = "plum") +
  geom_path(aes(y = Y), colour = "darkblue") +
  geom_path(aes(y = Z), colour = "goldenrod") +
  my_theme() +
  facet_wrap(~sequence, scales = "free_x")



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
