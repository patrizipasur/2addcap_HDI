# ============================================================
# 01_packages_directories.R
# ============================================================
# Purpose:
#   Check that all R packages required by the analysis are
#   available and create the directories used to store outputs.
#
# Reproducibility:
#   Package versions should be restored from renv.lock before
#   running the analysis. This script deliberately does not
#   install packages automatically, because automatic package
#   installation can make a reproducibility run depend on the
#   current CRAN state.
#
# Manuscript outputs:
#   This script produces no manuscript table or figure. It only
#   prepares the environment used by the subsequent scripts.
# ============================================================

required <- c(
  "tidyverse",
  "readxl",
  "dplyr",
  "kappalab",
  "corrplot",
  "xtable",
  "kableExtra",
  "readr",
  "modelsummary",
  "MVN",
  "mvnTest",
  "patchwork"
)

missing <- required[!vapply(required, requireNamespace, logical(1), quietly = TRUE)]

if (length(missing) > 0) {
  stop(
    paste0(
      "The following required packages are missing: ",
      paste(missing, collapse = ", "),
      ".\n\n",
      "For the reproducibility setup, first run:\n",
      "  install.packages('renv')\n",
      "  renv::restore()\n",
      "Then run scripts/00_run_all.R again."
    )
  )
}

# Load packages used directly by the scripts.
library(tidyverse)
library(readxl)
library(dplyr)
library(kappalab)
library(corrplot)
library(xtable)
library(ggplot2)
library(kableExtra)
library(readr)
library(modelsummary)
library(MVN)
library(mvnTest)
library(patchwork)

# ------------------------------------------------------------
# Create output directories.
# ------------------------------------------------------------
# The analysis scripts write intermediate data, tables and
# figures to these directories. Existing directories are kept.
# ------------------------------------------------------------

output_dirs <- c(
  "output/02_normalization",
  "output/03_analysis_dim",
  "output/04_composite_indices",
  "output/05_comparisons"
)

invisible(lapply(
  output_dirs,
  dir.create,
  recursive = TRUE,
  showWarnings = FALSE
))

message("Packages available and output directories ready.")
