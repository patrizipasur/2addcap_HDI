# ============================================================
# 03_analysis_dim.R
# ============================================================
# Purpose:
#   Describe the three HDI dimension indicators and assess their
#   univariate and multivariate distributional properties.
#
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
# Outputs:
#   output/03_analysis_dim/scatterplot.png
#   output/03_analysis_dim/histograms.png
#   output/03_analysis_dim/sum_sw_normality.tex
#   output/03_analysis_dim/mardia_mnormality.tex
#   output/03_analysis_dim/hz_normality.tex
#   output/05_comparisons/spearman_correlations.tex
# ============================================================

# ------------------------------------------------------------
# NORMALIZED COMPONENTS AND DIRECTORY TO SAVE RESULTS
# ------------------------------------------------------------
vars <- c("lei", "ei", "gnii")
dimensions <- components[, vars]

out_dir <- "output/03_analysis_dim"
# ------------------------------------------------------------
# DESCRIPTIVE STATISTICS
# ------------------------------------------------------------
# ============================================================
# MANUSCRIPT OUTPUT: TABLE 5, COLUMNS 2, 3, 4 AND 5
# ============================================================

mean_vals <- round(colMeans(dimensions, na.rm = TRUE), 4)
sd_vals   <- round(apply(dimensions, 2, sd, na.rm = TRUE), 4)
min_vals  <- round(apply(dimensions, 2, min, na.rm = TRUE), 4)
max_vals  <- round(apply(dimensions, 2, max, na.rm = TRUE), 4)

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
  file.path(out_dir, "scatterplot.png"),
  width = 1200,
  height = 800
)
pairs(
  components[, vars],
  main = "Scatterplot matrix of HDI components"
)
dev.off()

png(
  file.path(out_dir, "histograms.png"),
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

SWpvalue <- sapply(dimensions, normality_flag)

table1 <- cbind(desc, SWpvalue)

# ============================================================
# MANUSCRIPT OUTPUT: TABLE 5, COLUMN 6
# ============================================================
# Summary statistics and Shapiro-Wilk normality tests for the
# three HDI dimension indicators.
# ============================================================

latex_table <- xtable(
  table1,
  caption = "Summary statistics and Shapiro-Wilk normality test",
  label = "tab:summary_normality"
)

print(
  latex_table,
  file = file.path(out_dir, "sum_sw_normality.tex"),
  booktabs = TRUE
)

# ------------------------------------------------------------
# MULTIVARIATE NORMALITY: MARDIA
# ------------------------------------------------------------
# Mardia's test is applied to the three HDI dimension
# indicators. The result is subsequently used to determine
# whether Pearson or Spearman correlations are reported.
# ------------------------------------------------------------

#dimensions <-components[, vars]

mardia_results <- mvn(
  data = dimensions,
  mvn = "mardia"
)

mardia_table <- mardia_results[["multivariate_normality"]]
# ============================================================
# MANUSCRIPT OUTPUT: TABLE 6
# ============================================================
# Multivariate-normality results and the correlation measure
# used in the subsequent interaction analysis.
# ============================================================

print(
  xtable(
    mardia_table,
    caption = "Mardia multivariate normality test",
    label = "tab:mardia_test"
  ),
  file = file.path(out_dir, "mardia_mnormality.tex"),
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
  dimensions <- components[, p]
  test <- HZ.test(dimensions)

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
  file = file.path(out_dir, "hz_normality.tex"),
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
  corr <- cor(dimensions, method = "spearman")
  message("Data is non-normal. Spearman correlation was calculated.")
} else {
  corr <- cor(dimensions, method = "pearson")
  message("Data is normal. Pearson correlation was calculated.")
}

# ============================================================
# MANUSCRIPT OUTPUT: TABLE 7
# ============================================================
# The selected correlation matrix is used by
# 04_composite_indices.R to construct the correlation-based
# Choquet specification.
# ============================================================

print(
  xtable(
    corr,
    caption = "Correlation matrix of HDI components",
    digits = 4,
    label = "tab:corr_choquet"
  ),
  file = file.path(out_dir, "spearman_correlations.tex"),
  booktabs = TRUE
)

message("Analysis of dimensions completed successfully.")