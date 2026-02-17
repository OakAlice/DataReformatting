# Script for scoring the dataset on various metrics -----------------------
# Main script that calls and runs the different functions from different files

# Load in the data --------------------------------------------------------
data <- fread(file.path(wd, "Data", species, paste0(species, "_formatted.csv")))

# Summarise every sample --------------------------------------------------
data <- identify_sequence(data)
data <- identify_events(data)
data <- data %>%
  mutate(unique_key = paste(ID, sequence, event, sep = "_")) %>%
  select(-Time, -sequence, -event)
  
# for each of the events 
unique_events <- unique(data$unique_key)

summaries <- lapply(unique_events, function(x){
  dat <- data %>% dplyr::filter(unique_key == x)
  sum <- summarising_a_sample(dat)
  sum$key <- x
  sum
})
summaries <- rbindlist(summaries)


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
