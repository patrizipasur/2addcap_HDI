# ============================================================
# 00_run_all.R
# ============================================================
# REPRODUCIBILITY SCRIPT
#
# Purpose:
#   Run the complete empirical analysis associated with the
#   manuscript from beginning to end.
#
# How to use:
#   Open the project from its root directory and run:
#
#       source("scripts/00_run_all.R")
#
#   All input data are read from data/ and all generated files
#   are written to output/.
#
# Analysis pipeline:
#   01  Check packages and create output directories
#   02  Normalize the HDI component data
#   03  Analyse the HDI dimensions
#   04  Construct the composite indices
#   05  Compare the resulting country rankings
#
# The individual scripts contain the methodological notes and
# identify the corresponding manuscript tables and figures.
# ============================================================

message("========================================")
message("REPRODUCIBILITY ANALYSIS")
message("========================================")

message("[1/5] Checking packages and directories...")
source("scripts/01_packages_directories.R")

message("[2/5] Normalizing HDI data...")
source("scripts/02_normalization.R")

message("[3/5] Analysing HDI dimensions...")
source("scripts/03_analysis_dim.R")

message("[4/5] Constructing composite indices...")
source("scripts/04_composite_indices.R")

message("[5/5] Comparing rankings...")
source("scripts/05_comparisons.R")

message("========================================")
message("Analysis completed successfully.")
message("Generated files are available in output/.")
message("========================================")
