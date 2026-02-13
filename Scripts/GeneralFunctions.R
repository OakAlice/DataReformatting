# find continuous sequences in the data
identify_sequence <- function(data){
  data %>%
    group_by(ID) %>%
    arrange(Time) %>%
    mutate(time_diff = difftime(Time, data.table::shift(Time)), # had to define package or errored
           break_point = ifelse(time_diff > 0.02 | time_diff < 0 , 1, 0),
           break_point = replace_na(break_point, 0),
           sequence = cumsum(break_point)) %>%
    select(-break_point, -time_diff)
}

identify_events <- function(data){
  
  data <- data %>%
    group_by(ID, sequence) %>%
    arrange(Time, .by_group = TRUE) %>%
    mutate(
      change_point = if_else(lag(Activity) == Activity, 0L, 1L),
      change_point = replace_na(change_point, 0L),
      event = cumsum(change_point)
    ) %>%
    ungroup() %>%
    select(-change_point)
  
  return(data)
}
