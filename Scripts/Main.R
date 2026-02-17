# Main script for reformatting --------------------------------------------

#setwd("C:/Users/oaw001/OneDrive - University of the Sunshine Coast/DataReformatting")

setwd("E:/DataReformatting")
wd <- setwd("E:/DataReformatting")

# load in required package
pacman::p_load(data.table,
               dtw,
               lubridate,
               tidyverse,
               stringr,
               tsibble,
               theft, # for feature calculation
               purrr
               )

# list of all the species that could be chosen
all_species <- list.dirs() #TODO: this is currently listing the git as well, can that be changed?

# define the species to format
species <- "Dunford_Cat"
sample_rate <- 40

# load in the general functions
source(file.path(wd, "Scripts/GeneralFunctions.R"))

# reformat from raw data
source(file.path(wd, "Scripts", "FormattingScripts", paste0(species, "_Formatting.R")))

# score the dataset on complexity
# source(file.path(wd, "Scripts/Scoring/ComplexityScoring.R"))

# generate dataset characteristics and diagnostics report
source(file.path(wd, "Scripts/Generate_Dataset_Diagnostics.R"))
