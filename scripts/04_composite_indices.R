# ============================================================
# 04_composite_indices.R
# ============================================================
# Purpose:
#   Construct the composite development indices evaluated in
#   the manuscript.
#
# Input:
#   output/02_normalization/data_normalized.rds
#
# Composite indices:
#   AM       - arithmetic mean of the three dimensions
#   GM       - geometric mean of the three dimensions
#   Ch_const - Choquet integral with constant interaction
#   Ch_corr  - Choquet integral with correlation-based
#              interaction
#
# The correlation matrix used in Ch_corr is produced by
# 03_analysis_dim.R and remains in the analysis environment when
# the complete pipeline is run through 00_run_all.R.
#
# Outputs:
#   output/04_composite_indices/data_indices_cal.rds
#   output/04_composite_indices/data_indices_cal.csv
#   output/04_composite_indices/data_indices.rds
#   output/04_composite_indices/data_indices.csv
#
# These files are used by 05_comparisons.R.
# ============================================================

# ------------------------------------------------------------
# LOAD NORMALIZED COMPONENTS
# ------------------------------------------------------------

data <- readRDS("output/02_normalization/data_normalized.rds") |>
  as.data.frame()

data <- data %>%
  mutate(across(c(lei, eysi, mysi, ei, gnii), as.numeric))

# The composite indices use the three HDI dimensions:
# health (lei), education (ei), and income (gnii).
X <- data %>% select(lei, ei, gnii) %>% as.matrix()
n <- ncol(X)

# Equal importance is assigned to the three dimensions.
w <- rep(1 / n, n)

# ------------------------------------------------------------
# ARITHMETIC MEAN INDEX
# ------------------------------------------------------------

data$am <- X %*% w

# ------------------------------------------------------------
# GEOMETRIC MEAN INDEX
# ------------------------------------------------------------

data$gm <- exp(rowSums(log(X) * w))

# ============================================================
# CHOQUET INTEGRAL
# ============================================================
# Two interaction specifications are constructed.
#
# Case 1: constant pairwise interaction.
# Case 2: interaction based on the correlation-derived
#         dissimilarity matrix.
# ============================================================

# The object 'corr' is created in 03_analysis_dim.R when the
# complete reproducibility pipeline is run from 00_run_all.R.
if (!exists("corr")) {
  stop(
    "The correlation matrix 'corr' is not available. Run the complete " ,
    "pipeline from scripts/00_run_all.R rather than this script in isolation."
  )
}

# ------------------------------------------------------------
# CASE 1: CONSTANT INTERACTION
# ------------------------------------------------------------

umco <- 1 - corr
shap <- w

k <- 2 * min(shap) / (n - 1)
I <- k * matrix(1, n, n)
diag(I) <- 0

mob1 <- shap - rowSums(I) / 2

mob2 <- c()
for (i in 1:(n - 1)) {
  mob2 <- c(mob2, I[i, (i + 1):n])
}

mob_rest <- rep(0, 2^n - (1 + n + n * (n - 1) / 2))

cap1 <- Mobius.capacity(
  c(0, mob1, mob2, mob_rest),
  n,
  n
)

# ============================================================
# MANUSCRIPT ANALYSIS: CHOQUET SPECIFICATION 1
# ============================================================
# Constant pairwise interaction model.
# The resulting index is stored as 'ch_const'.
# ============================================================

data$ch_const <- apply(X, 1, function(x) {
  Choquet.integral(cap1, x)
})

# ------------------------------------------------------------
# CASE 2: CORRELATION-BASED INTERACTION
# ------------------------------------------------------------
# Interaction is determined from the correlation-based
# dissimilarity matrix umco = 1 - corr.
# ------------------------------------------------------------

k_vec <- c()
for (i in 1:n) {
  k_vec <- c(k_vec, 2 * shap[i] / sum(umco[i, ]))
}

k <- min(k_vec)
I <- k * umco

mob1 <- shap - rowSums(I) / 2

mob2 <- c()
for (i in 1:(n - 1)) {
  mob2 <- c(mob2, I[i, (i + 1):n])
}

mob_rest <- rep(0, 2^n - (1 + n + n * (n - 1) / 2))

cap2 <- Mobius.capacity(
  c(0, mob1, mob2, mob_rest),
  n,
  n
)

# ============================================================
# MANUSCRIPT ANALYSIS: CHOQUET SPECIFICATION 2
# ============================================================
# Correlation-based interaction model.
# The resulting index is stored as 'ch_corr'.
# ============================================================

data$ch_corr <- apply(X, 1, function(x) {
  Choquet.integral(cap2, x)
})

# ------------------------------------------------------------
# SAVE COMPLETE INDEX DATASET
# ------------------------------------------------------------
# This file retains the normalized components and all composite
# indices for transparency and further inspection.
# ------------------------------------------------------------

saveRDS(
  data,
  "output/04_composite_indices/data_indices_cal.rds"
)
write.csv(
  data,
  "output/04_composite_indices/data_indices_cal.csv",
  row.names = FALSE
)

# ------------------------------------------------------------
# PREPARE DATASET FOR RANKING COMPARISONS
# ------------------------------------------------------------
# Only the variables required by 05_comparisons.R are retained.
# ------------------------------------------------------------

data <- data[, -c(2:6)]

saveRDS(
  data,
  "output/04_composite_indices/data_indices.rds"
)
write.csv(
  data,
  "output/04_composite_indices/data_indices.csv",
  row.names = FALSE
)

message("Composite-index calculations completed successfully.")
