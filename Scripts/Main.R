# Main script for reformatting --------------------------------------------

#setwd("C:/Users/oaw001/OneDrive - University of the Sunshine Coast/DataReformatting")

setwd("E:/DataReformatting")
wd <- setwd("E:/DataReformatting")

# load in required package
pacman::p_load(data.table,
               lubridate,
               tidyverse,
               stringr
               )

# list of all the species that could be chosen
all_species <- list.dirs() #TODO: this is currently listing the git as well, can that be changed?

# define the species to format
species <- "Maekawa_Gull"
sample_rate <- 25 #TODO: change from hardcode to be pulled from a central csv

# reformat from raw data
source(file.path(wd, "Scripts", "FormattingScripts", paste0(species, "_Formatting.R")))

# generate dataset characteristics and diagnostics report
source(file.path(wd, "Scripts/Generate_Dataset_Diagnostics.R"))



# TODo:
# Standardise the path names (all hardcode from DataReformatting not Data)
# standardise commenting
# standardise formatting
# clean up and make faster
# only generate if isnt already generated


# set all dates to be generic 1970