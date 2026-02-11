#Meerkat




raw_files <- list.files(
  path = "Chakravarty_Meerkat/raw",
  recursive = TRUE,
  pattern = "\\.mat$",
  full.names = TRUE)

  data <- readMat(raw_files)
  

  dat <- rbindlist(data[1:100])
  
  d <- data[1:20]
  
  