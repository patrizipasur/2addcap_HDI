# Input data

The analysis uses the following input file:

HDI25.xlsx

The file is read by:

scripts/02_normalization.R


# Data source

The data are obtained from the United Nations Development Programme (UNDP), Human Development Report 2025, Statistical Annex — Human Development Index (HDI) table.

Source:

UNDP Human Development Report 2025 — HDI Statistical Annex

The downloaded Excel file has been saved locally as HDI25.xlsx for use as the input dataset in this reproducibility repository.


# Use in the analysis

The analysis reads the relevant variables from the original Excel file and creates the derived datasets required for the subsequent analyses.

The original Excel file is not modified by the R scripts. Derived and intermediate datasets are written to the output/ directory.

# Reproducibility

The analysis expects the input file at:

data/HDI25.xlsx

and the complete analysis can subsequently be run using:

source("scripts/00_run_all.R")