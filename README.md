# DataReformatting
Standardised workflow for formatting accelerometer datasets.

My PhD is dependent on data generaously provided by the scientific community. Each of these datasets tends to be uploaded in different ways, but I need them in a standardised format. This git is a record of how the data has been reformatted.

## Repo Structure
DataReformatting
├── Dataset Folder/ *directory for each of the datasets*
│ └── Dataset_Metadata.md *metadata for the dataset as well as instructions for download and formatting*
│ └── Dataset_Formatting.R *R script for reformatting the data*
│ └── Dataset_Characteristics.html *html report of dataset characteristics and diagnostics*
│ └── raw/ 
│    └── file *csv or subdirectories with the original data as downloaded from the repo*
│ └── Dataset_Formatted.csv *reformatted csv, ready for use in other projects*
├── Main.R *setwd(), load packages, call other scripts*
├── All_Metadata.csv *parent csv that contains releavant analysis metadata from all the datasets*
└── Dataset_Characteristics.Rmd *R markdown that creates diagnostics html report about the data*

## Data Format
All datasets are reformatted to the following structure:
- 1 observation per row
- Columns:
    - ID: Identification to separate individual animals from each other, and to separate different trials of the same individual
    - Time: preferably as a POSIXct class, however, may require alternate numeric format - defined in metadata sheet
    - X, Y, Z: raw axes
    - Activity: Behavioural label

