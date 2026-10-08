# Activate the project's renv environment
source("renv/activate.R")

# Open the main script when running inside RStudio
if (interactive() &&
    requireNamespace("rstudioapi", quietly = TRUE) &&
    rstudioapi::isAvailable()) {
  rstudioapi::navigateToFile("scripts/00_run_all.R")
}
