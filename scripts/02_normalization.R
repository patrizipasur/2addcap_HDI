# ============================================================
# 02_normalization.R
# ============================================================
# Purpose:
#   Prepare and normalize the HDI component data using the
#   UN goalposts specified in the manuscript.
#
# Input:
#   data/HDI25.xlsx
#
# Main steps:
#   1. Read the original HDI dataset.
#   2. Retain the variables required for the analysis.
#   3. Apply the specified lower and upper goalposts.
#   4. Calculate the normalized health, education and income
#      component indices.
#   5. Save the normalized data for subsequent analyses.
#
# Manuscript outputs:
#   This script generates intermediate data used by the
#   statistical analyses and composite-index calculations.
# ============================================================

# ------------------------------------------------------------
# 1. LOAD RAW DATA
# ------------------------------------------------------------

file_path <- "data/HDI25.xlsx"

data <- read_excel(file_path)

data <- select(data, HDI, Country, LEB, EYS, MYS, GNI)

# ------------------------------------------------------------
# 2. DEFINE UN GOALPOSTS
# ------------------------------------------------------------
# These goalposts are used in the normalization procedure.
# ------------------------------------------------------------

goalposts <- list(
  LEB_min = 20,
  LEB_max = 85,
  EYS_min = 0,
  EYS_max = 18,
  MYS_min = 0,
  MYS_max = 15,
  GNI_min = 100,
  GNI_max = 75000
)

# ------------------------------------------------------------
# 3. CAP VALUES AT THE SPECIFIED GOALPOSTS
# ------------------------------------------------------------
# Values below/above the corresponding goalposts are capped at
# the lower/upper bound before normalization.
# ------------------------------------------------------------

data <- data %>%
  mutate(
    LEB = pmin(pmax(LEB, goalposts$LEB_min), goalposts$LEB_max),
    EYS = pmin(pmax(EYS, goalposts$EYS_min), goalposts$EYS_max),
    MYS = pmin(pmax(MYS, goalposts$MYS_min), goalposts$MYS_max),
    GNI = pmin(pmax(GNI, goalposts$GNI_min), goalposts$GNI_max)
  )

# ------------------------------------------------------------
# 4. CALCULATE NORMALIZED COMPONENT INDICES
# ------------------------------------------------------------
# lei  = normalized life expectancy index
# eysi = normalized expected-years-of-schooling index
# mysi = normalized mean-years-of-schooling index
# ei   = arithmetic mean of the two education component indices
# gnii = logarithmically normalized income index
# ------------------------------------------------------------

data <- data %>%
  mutate(
    lei =
      (LEB - goalposts$LEB_min) /
        (goalposts$LEB_max - goalposts$LEB_min),

    eysi =
      (EYS - goalposts$EYS_min) /
        (goalposts$EYS_max - goalposts$EYS_min),

    mysi =
      (MYS - goalposts$MYS_min) /
        (goalposts$MYS_max - goalposts$MYS_min),

    ei = (eysi + mysi) / 2,

    gnii =
      (log(GNI) - log(goalposts$GNI_min)) /
        (log(goalposts$GNI_max) - log(goalposts$GNI_min))
  )

# Keep only the normalized components required by the subsequent
# composite-index calculations, together with Country.
components <- data %>%
  select(Country, lei, eysi, mysi, ei, gnii)

# ------------------------------------------------------------
# 5. SAVE INTERMEDIATE DATA
# ------------------------------------------------------------
# The CSV file provides a human-readable copy of the normalized
# dataset. The RDS file is used directly by the next stages of
# the reproducibility pipeline.
# ------------------------------------------------------------

write.csv(
  data,
  "output/02_normalization/data_normalized.csv",
  row.names = FALSE
)

saveRDS(
  components,
  "output/02_normalization/data_normalized.rds"
)

message("HDI normalization completed successfully.")
