# Script for initialising a markdown report ---------------------------

# TODO: for some reason this is generating a _files/ directory, 
# linked to the html so cant delete without removing html too
# looking online, found this is a bug multiple people get... I couldnt see a solve but worth having another look
# can you figure out how to get rid of it but retain the html
# just spitballing --> maybe dupe the file after creation and then remove originals???

# TODO: fox whatever's going on with the wd
# i dont like how I have to hardcode the wds in this file for it to work... defeats the purpose
# either actually fix it, or use a substitude variable like base_path <- getwd() and then input???
# also getting this message
# You changed the working directory to C:/Users/oaw001/OneDrive - University of the Sunshine Coast/DataReformatting (probably via setwd()). It will be restored to C:/Users/oaw001/OneDrive - University of the Sunshine Coast/DataReformatting/Scripts. See the Note section in ?knitr::knit
# why is that happening??? I never set the wd to Scripts/???

if (1 == 1) { # TODO: change this to be some more helpful condition later lol
  tryCatch({
    # Define the output directory and file
    output_file <- file.path(wd, "Data", species, paste0(species, "_characteristics.html"))
    
    # Knit the r markdown file as an HTML report (has the least errors/dependencies compared to other types of knits)
    rmarkdown::render(
      output_options = c("self_contained = TRUE"),
      quiet = TRUE,
      input = file.path("Scripts", "DatasetDiagnostics.Rmd"),
      output_format = "html_document",
      output_file = output_file,  # File name only
      params = list( # these are the things I'm going to feed in to change report
        wd = wd,
        species = species,
        sample_rate = sample_rate
      )
    )
    
    # Success message with full path
    message("Diagnostics saved to: ", output_file)
  }, error = function(e) {
    message("Error in making diagnostics report: ", e$message)
    stop()
  })
}
