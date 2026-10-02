# ============================================================
# 03_analysis_dim.R
# ============================================================
# Purpose:
#   Describe the three HDI dimension indicators and assess their
#   univariate and multivariate distributional properties.
#
# Input:
#   output/02_normalization/data_normalized.rds
#
# Main analyses:
#   1. Descriptive statistics.
#   2. Scatterplot matrix and histograms.
#   3. Shapiro-Wilk normality tests.
#   4. Mardia multivariate normality test.
#   5. Henze-Zirkler tests for pairs of indicators.
#   6. Selection of Pearson or Spearman correlation according
#      to the multivariate-normality assessment.
#
# Manuscript outputs:
#   Table 5  - summary statistics and Shapiro-Wilk tests.
#   Table 6  - multivariate normality/correlation analysis.
#
# Generated files are written to output/03_analysis_dim/.
# ============================================================

# ------------------------------------------------------------
# LOAD NORMALIZED COMPONENTS
# ------------------------------------------------------------

components <- readRDS("output/02_normalization/data_normalized.rds")

vars <- c("lei", "ei", "gnii")
data <- components[, vars]

# ------------------------------------------------------------
# DESCRIPTIVE STATISTICS
# ------------------------------------------------------------
# These statistics form the descriptive part of manuscript
# Table 5.
# ------------------------------------------------------------

mean_vals <- round(colMeans(data, na.rm = TRUE), 4)
sd_vals   <- round(apply(data, 2, sd, na.rm = TRUE), 4)
min_vals  <- round(apply(data, 2, min, na.rm = TRUE), 4)
max_vals  <- round(apply(data, 2, max, na.rm = TRUE), 4)

desc <- data.frame(
  Mean = mean_vals,
  SD = sd_vals,
  Min = min_vals,
  Max = max_vals
)

# ------------------------------------------------------------
# DISTRIBUTIONAL DIAGNOSTICS
# ------------------------------------------------------------
# These plots are diagnostic outputs rather than direct
# manuscript tables. They allow the reviewer to inspect the
# distribution and pairwise relationships of the indicators.
# ------------------------------------------------------------

png(
  "output/03_analysis_dim/scatterplot.png",
  width = 1200,
  height = 800
)
pairs(
  components[, vars],
  main = "Scatterplot matrix of HDI components"
)
dev.off()

png(
  "output/03_analysis_dim/histograms.png",
  width = 1200,
  height = 800
)
par(mfrow = c(2, 3))
for (v in vars) {
  hist(
    components[[v]],
    main = paste("Histogram:", v),
    xlab = v
  )
}
dev.off()

# ------------------------------------------------------------
# SHAPIRO-WILK NORMALITY TESTS
# ------------------------------------------------------------
# The significance threshold is alpha = 0.001, consistent with
# the original analysis.
# ------------------------------------------------------------

normality_flag <- function(x, alpha = 0.001) {
  p <- shapiro.test(x)$p.value
  if (p >= alpha) p else "<0.001"
}

SWpvalue <- sapply(data, normality_flag)

table1 <- cbind(desc, SWpvalue)

# ============================================================
# MANUSCRIPT OUTPUT: TABLE 5
# ============================================================
# Summary statistics and Shapiro-Wilk normality tests for the
# three HDI dimension indicators.
#
# Generated file:
#   output/03_analysis_dim/sum_sw_normality.tex
# ============================================================

latex_table <- xtable(
  table1,
  caption = "Summary statistics and Shapiro-Wilk normality test",
  label = "tab:summary_normality"
)

print(
  latex_table,
  file = "output/03_analysis_dim/sum_sw_normality.tex",
  booktabs = TRUE
)

# ------------------------------------------------------------
# MULTIVARIATE NORMALITY: MARDIA
# ------------------------------------------------------------
# Mardia's test is applied to the three HDI dimension
# indicators. The result is subsequently used to determine
# whether Pearson or Spearman correlations are reported.
# ------------------------------------------------------------

data_mvn <- components[, vars]

mardia_results <- mvn(
  data = data_mvn,
  mvn = "mardia"
)

mardia_table <- mardia_results[["multivariate_normality"]]

# ============================================================
# MANUSCRIPT OUTPUT: TABLE 6
# ============================================================
# Multivariate-normality results and the correlation measure
# used in the subsequent interaction analysis.
#
# Generated file:
#   output/03_analysis_dim/mardia_mnormality.tex
# ============================================================

print(
  xtable(
    mardia_table,
    caption = "Mardia multivariate normality test",
    label = "tab:mardia_test"
  ),
  file = "output/03_analysis_dim/mardia_mnormality.tex",
  include.rownames = FALSE,
  booktabs = TRUE
)

# ------------------------------------------------------------
# HENZE-ZIRKLER TESTS
# ------------------------------------------------------------
# These tests provide an additional distributional diagnostic
# for pairs of HDI indicators.
# ------------------------------------------------------------

pairs <- combn(vars, 2, simplify = FALSE)

hz_results <- do.call(rbind, lapply(pairs, function(p) {
  data_mvn <- components[, p]
  test <- HZ.test(data_mvn)

  data.frame(
    Var1 = p[1],
    Var2 = p[2],
    HZ = test@HZ,
    p_value = test@p.value
  )
}))

hz_results$HZ <- round(hz_results$HZ, 3)
hz_results$p_value <- round(hz_results$p_value, 4)
hz_results$p_value <- ifelse(
  hz_results$p_value < 0.001,
  "<0.001",
  hz_results$p_value
)

print(
  xtable(
    hz_results,
    caption = "Henze--Zirkler multivariate normality tests for pairs of HDI components",
    label = "tab:hz_test"
  ),
  file = "output/03_analysis_dim/hz_normality.tex",
  include.rownames = FALSE,
  booktabs = TRUE
)

# ------------------------------------------------------------
# CORRELATION MEASURE SELECTION
# ------------------------------------------------------------
# The original analysis uses the Mardia multivariate-normality
# results to select the correlation coefficient used later in
# the correlation-based Choquet specification.
#
# If any Mardia p-value is below 0.01, Spearman correlation is
# used; otherwise Pearson correlation is used.
# ------------------------------------------------------------

mardia_p <- mardia_table[, 3]
mardia_p[mardia_p == "<0.001"] <- "0.001"
mardia_p <- as.numeric(mardia_p)

if (any(mardia_p < 0.01)) {
  corr <- cor(data, method = "spearman")
  message("Data is non-normal. Spearman correlation was calculated.")
} else {
  corr <- cor(data, method = "pearson")
  message("Data is normal. Pearson correlation was calculated.")
}

# ============================================================
# MANUSCRIPT OUTPUT: TABLE 6 (CORRELATION MATRIX)
# ============================================================
# The selected correlation matrix is used by
# 04_composite_indices.R to construct the correlation-based
# Choquet specification.
#
# Generated file:
#   output/03_analysis_dim/spearman_correlations.tex
# ============================================================

print(
  xtable(
    corr,
    caption = "Correlation matrix of HDI components",
    digits = 4,
    label = "tab:corr_choquet"
  ),
  file = "output/03_analysis_dim/spearman_correlations.tex",
  booktabs = TRUE
)
