# ============================================================
# 04_composite_indices.R
# ============================================================
# Purpose:
#   Construct the composite development indices evaluated in
#   the manuscript.
#
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
#   output/04_composite_indices/data_indices_cal.csv
#   output/04_composite_indices/orness.csv
#   output/04_composite_indices/indices.csv
# ============================================================

# ------------------------------------------------------------
# LOAD NORMALIZED COMPONENTS AND DIRECTORY TO SAVE RESULTS
# ------------------------------------------------------------
out_dir <- "output/04_composite_indices"

# The composite indices use the three HDI dimensions:
# health (lei), education (ei), and income (gnii).
dimensions <- dimensions %>% as.matrix()
n <-ncol(dimensions)
# Equal importance is assigned to the three dimensions.
w <- rep(1 / n, n)

# ------------------------------------------------------------
# ARITHMETIC MEAN INDEX
# ------------------------------------------------------------

data$am <- dimensions %*% w
orn_am <- 0.5
k_am <- 0
# ------------------------------------------------------------
# GEOMETRIC MEAN INDEX
# ------------------------------------------------------------

data$gm <- exp(rowSums(log(dimensions) * w))

orn_gm <- -1 / (n - 1) +
  (n + 1) / (n - 1) * prod(1 / (1 + w))
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

k_const <- 2 * min(shap) / (n - 1)
k <- k_const
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

orn_ch_const <- (1 / (n - 1)) * (
  ((n - 1) / 2) * sum(mob1) +
    ((n - 2) / 3) * sum(mob2)
)

# ============================================================
# MANUSCRIPT ANALYSIS: CHOQUET SPECIFICATION 1
# ============================================================
# Constant pairwise interaction model.
# The resulting index is stored as 'ch_const'.
# ============================================================

data$ch_const <- apply(dimensions, 1, function(x) {
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

k_corr <- min(k_vec)
k<- k_corr
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
orn_ch_corr <- (1 / (n - 1)) * (
  ((n - 1) / 2) * sum(mob1) +
    ((n - 2) / 3) * sum(mob2)
)
# ============================================================
# MANUSCRIPT ANALYSIS: CHOQUET SPECIFICATION 2
# ============================================================
# Correlation-based interaction model.
# The resulting index is stored as 'ch_corr'.
# ============================================================

data$ch_corr <- apply(dimensions, 1, function(x) {
  Choquet.integral(cap2, x)
})

# ------------------------------------------------------------
# SAVE COMPLETE INDEX DATASET
# ------------------------------------------------------------
# This file retains the normalized components and all composite
# indices for transparency and further inspection.
# -----------------------------------------------------------
write.csv(
  data,
  file.path(out_dir, "data_indices_cal.csv"),
  row.names = FALSE
)
# ============================================================
# MANUSCRIPT OUTPUT: APPENDIX TABLE 11, ROWS 2, 4, 5, 6, 7 AND 9
# ============================================================
# Save orness table
# -----------------------------------------------------------
orness <- data.frame(
  Indices = c(
    "am",
    "gm",
    "choquet_const",
    "choquet_corr"
  ),
  Orness = c(
    orn_am,
    orn_gm,
    orn_ch_const,
    orn_ch_corr
  ),
  k = c(
    k_am,
    NA_real_,
    k_const,
    k_corr
  )
)

orness$Orness <- round(orness$Orness, 6)
orness$k <- round(orness$k, 6)

write.csv(
  orness,
  file.path(out_dir, "orness.csv"),
  row.names = FALSE
)
# ------------------------------------------------------------
# PREPARE DATASET FOR RANKING COMPARISONS
# ------------------------------------------------------------
# Only the composite indices required by 05_comparisons.R are retained.
# ------------------------------------------------------------

indices <- data[, -c(1, 3:11)]

write.csv(
  indices,
  file.path(out_dir, "indices.csv"),
  row.names = FALSE
)

message("Composite-index calculations completed successfully.")
