# ============================================================
# 06b_sensitivity_comparison_gm.R
# ============================================================
# Purpose:
#   Compare the existing geometric-mean ranking with four
#   2-additive Choquet specifications calibrated to GM orness
#   or to the midpoint of the feasible interaction parameter.
#
# Inputs from previous project scripts:
#   vars       - criterion names
#   dimensions - matrix of criterion values, one row per country
#   data       - country-level data, optionally including Country
#   corr       - empirical correlation matrix
#   phi        - Shapley importance vector
#   n          - number of criteria
#   orn_gm     - geometric-mean orness target
#   tol        - tolerance parameter: tol <- 1e-8
#   interaction_matrix - symmetric interaction matrix defined in 06a script
#   validate_capacity  - Mobius coefficients, orness, normalization, and
#                        monotonicity margins in 06a script
#   country_label      - names of countries
#   rankings   - data frame with rankings to recover geometric mean rank
#
# Outputs:
#   output/06b_sensitivity_comparisons_gm/all_rankings.csv
#   output/06b_sensitivity_comparisons_gm/kendall_rank_correlations.csv
#   output/06b_sensitivity_comparisons_gm/absolute_rank_changes_vs_gm.csv
#   output/06b_sensitivity_comparisons_gm/number_and_percentage_of_changed_rankings.csv
#   output/06b_sensitivity_comparisons_gm/rank_changes_vs_gm.pdf
#   output/06b_sensitivity_comparisons_gm/stability_table_four_models.csv
#   output/06b_sensitivity_comparisons_gm/stability_table_four_models.tex
#   output/06b_sensitivity_comparisons_gm/midpoint_model_diagnostics.csv
# ============================================================

# ------------------------------------------------------------
# DIRECTORY TO SAVE RESULTS
# ------------------------------------------------------------

out_dir <- "output/06b_sensitivity_comparison_gm"

# ------------------------------------------------------------
# CORRELATION-BASED INTERACTION STRUCTURE
# ------------------------------------------------------------

# Convert pairwise correlations into dissimilarities. Small negative
# values caused by numerical precision are set to zero.
D <- 1 - corr
diag(D) <- 0

D[D < 0 & D >= -tol] <- 0

if (any(D < -tol)) {
  stop("Invalid dissimilarity values derived from 'corr'.")
}

D <- pmax(D, 0)

row_D_sum <- rowSums(D)
D_pairs <- D[upper.tri(D)]
n_pairs <- choose(n, 2)

if (sum(D_pairs) <= tol) {
  stop(
    "Correlation-based interactions cannot be constructed: ",
    "all pairwise dissimilarities are zero."
  )
}

if (any(row_D_sum <= tol)) {
  stop(
    "At least one criterion has zero total dissimilarity. ",
    "The correlation-based midpoint parameter is undefined ",
    "under the parameterization used in 06_sensitivity.R."
  )
}

# ------------------------------------------------------------
# ORNESS TARGET AND FEASIBLE MIDPOINT PARAMETERS
# ------------------------------------------------------------

# orn_gm is supplied by the upstream project scripts.
# Do not recalculate the GM ranking or GM orness here.


# Translate the GM orness target into the required sum of pairwise
# interactions, then calculate the feasible midpoint parameters.
target_pair_sum <- n * (0.5 - orn_gm)

# Maximum feasible interaction parameters, as in 06_sensitivity.R.

k_const_star <- 2 * min(phi) / (n - 1)

k_corr_star <- min(
  2 * phi / row_D_sum
)

k_const_mid <- k_const_star / 2
k_corr_mid <- k_corr_star / 2

# ------------------------------------------------------------
# CAPACITY AND CHOQUET HELPER FUNCTIONS
# ------------------------------------------------------------

choquet_scores <- function(X, I, validation) {

  if (!validation$valid) {
    stop("Cannot calculate scores from an invalid capacity.")
  }

  mob1 <- validation$mob1

  scores <- apply(
    X,
    1,
    function(x) {
      sum(mob1 * x) +
        sum(I[upper.tri(I)] *
              pmin(
                x[row(I)[upper.tri(I)]],
                x[col(I)[upper.tri(I)]]
              ))
    }
  )

  as.numeric(scores)
}

# ------------------------------------------------------------
# CONSTRUCT THE FOUR CHOQUET SPECIFICATIONS
# ------------------------------------------------------------

# Specification 1: constant interactions at GM orness.

I_const_geom <- interaction_matrix(
  rep(
    target_pair_sum / n_pairs,
    n_pairs
  )
)

# Specification 2: correlation-based interactions at GM orness.

I_corr_geom <- interaction_matrix(
  target_pair_sum * D_pairs / sum(D_pairs)
)

# Specification 3: constant interactions at midpoint k.

I_const_mid <- interaction_matrix(
  rep(k_const_mid, n_pairs)
)

# Specification 4: correlation-based interactions at midpoint k.

I_corr_mid <- k_corr_mid * D
diag(I_corr_mid) <- 0

# ------------------------------------------------------------
# VALIDATE CAPACITIES AND CALCULATE CHOQUET SCORES
# ------------------------------------------------------------

# Collect the four interaction matrices for common validation
# and score calculation.
interaction_sets <- list(
  ch_const_geom = I_const_geom,
  ch_corr_geom = I_corr_geom,
  ch_const_mid = I_const_mid,
  ch_corr_mid = I_corr_mid
)

capacity_checks <- lapply(
  names(interaction_sets),
  function(model) {
    validate_capacity(
      I = interaction_sets[[model]],
      scenario = "GM comparison",
      model = model
    )
  }
)

names(capacity_checks) <- names(interaction_sets)

invalid_models <- names(capacity_checks)[
  !vapply(
    capacity_checks,
    function(x) x$valid,
    logical(1)
  )
]

if (length(invalid_models) > 0L) {
  stop(
    "Capacity validation failed for: ",
    paste(invalid_models, collapse = ", "),
    ". Check the GM orness target and interaction constraints."
  )
}

# Calculate the four sets of Choquet scores.
choquet_score_list <- lapply(
  names(interaction_sets),
  function(model) {
    choquet_scores(
      dimensions,
      interaction_sets[[model]],
      capacity_checks[[model]]
    )
  }
)

names(choquet_score_list) <- names(interaction_sets)

# ------------------------------------------------------------
# COMBINE THE GM AND CHOQUET RANKINGS
# ------------------------------------------------------------
# Keep the pre-existing GM ranking as the reference.
# Only the four Choquet rankings are newly calculated.

all_rankings <- data.frame(
  Country = country_label,
  geometric_mean = as.numeric(rankings[[3]]),
  ch_const_geom = rank(
    -choquet_score_list$ch_const_geom,
    ties.method = "max"
  ),
  ch_corr_geom = rank(
    -choquet_score_list$ch_corr_geom,
    ties.method = "max"
  ),
  ch_const_mid = rank(
    -choquet_score_list$ch_const_mid,
    ties.method = "max"
  ),
  ch_corr_mid = rank(
    -choquet_score_list$ch_corr_mid,
    ties.method = "max"
  ),
  check.names = FALSE
)

# ============================================================
# MANUSCRIPT OUTPUT: APPENDIX TABLE 15
# ============================================================
# Use the all_rankings data frame to identify an illustrative
# example of a ranking reversal between Fiji and the Maldives.

write.csv(
  all_rankings,
  file.path(out_dir, "all_rankings.csv"),
  row.names = FALSE
)

# ------------------------------------------------------------
# KENDALL RANK-CORRELATION MATRIX
# ------------------------------------------------------------

# Calculate pairwise Kendall correlations across the GM ranking
# and the four Choquet rankings.
rank_matrix <- as.matrix(
  all_rankings[, -1, drop = FALSE]
)

kendall_matrix <- cor(
  rank_matrix,
  method = "kendall",
  use = "pairwise.complete.obs"
)

# ============================================================
# MANUSCRIPT OUTPUT: APPENDIX TABLE 13, COLUMN 2
# ============================================================

write.csv(
  kendall_matrix,
  file.path(out_dir, "kendall_rank_correlations.csv"),
  row.names = TRUE
)

# ------------------------------------------------------------
# ABSOLUTE RANK CHANGES RELATIVE TO THE GM
# ------------------------------------------------------------

choquet_methods <- c(
  "ch_const_geom",
  "ch_const_mid",
  "ch_corr_geom",
  "ch_corr_mid"
)

# Express each Choquet rank as a signed and absolute difference
# from the pre-existing GM rank.

rank_change_long <- do.call(
  rbind,
  lapply(
    choquet_methods,
    function(method) {

      difference <- all_rankings[[method]] -
        all_rankings$geometric_mean

      data.frame(
        Country = country_label,
        Method = method,
        GM_rank = all_rankings$geometric_mean,
        Choquet_rank = all_rankings[[method]],
        Rank_change = difference,
        Absolute_rank_change = abs(difference),
        stringsAsFactors = FALSE
      )
    }
  )
)

write.csv(
  rank_change_long,
  file.path(out_dir, "absolute_rank_changes_vs_gm.csv"),
  row.names = FALSE
)

#------------------------------------------------------------
#  NUMBER AND PERCENTAGE OF COUNTRIES WITH CHANGED RANKS
#------------------------------------------------------------

n_countries <- nrow(all_rankings)

rank_change_summary <- do.call(
  rbind,
  lapply(
    choquet_methods,
    function(method) {

      changed <- !is.na(all_rankings[[method]]) &
        !is.na(all_rankings$geometric_mean) &
        all_rankings[[method]] !=
        all_rankings$geometric_mean

      n_changed <- sum(changed)

      data.frame(
        Method = method,
        Changed_rankings = n_changed,
        Percentage_changed = round(
          100 * n_changed / n_countries,
          2
        ),
        stringsAsFactors = FALSE
      )
    }

  )
)

# ============================================================
# MANUSCRIPT OUTPUT: APPENDIX TABLE 13, COLUMNS 3 AND 4
# ============================================================

write.csv(
  rank_change_summary,
  file.path(out_dir, "number_and_percentage_of_changed_rankings.csv"),
  row.names = FALSE
)

cat("\nNumber and percentage of changed rankings vs GM:\n")
#print(rank_change_summary, row.names = FALSE)

# ------------------------------------------------------------
# FIGURE LABELS AND MODEL DISPLAY ORDER
# ------------------------------------------------------------

method_labels <- c(
  ch_const_geom = "C[mu[1]]^{s[G]}",
  ch_corr_geom  = "C[mu[2]]^{s[G]}",
  ch_const_mid  = "C[mu[1]]^{s[mid]}",
  ch_corr_mid   = "C[mu[2]]^{s[mid]}"
)

# Preserve the specified order of Choquet specifications.

rank_change_long$Method <- factor(
  rank_change_long$Method,
  levels = choquet_methods
)

#------------------------------------------------------------
# JOURNAL FIGURE THEME
#------------------------------------------------------------

  theme_journal <- function() {
    theme_minimal(base_size = 9) +
      theme(
        panel.grid.major = element_line(linewidth = 0.2),
        panel.grid.minor = element_blank(),
        axis.text = element_text(color = "black", size = 8),
        axis.title = element_text(size = 9),
        strip.text = element_text(size = 8),
        panel.spacing.y = grid::unit(1.5, "lines"),
        panel.spacing.x = grid::unit(1.2, "lines"),
        legend.position = "none"
      )
  }

#------------------------------------------------------------
# HISTOGRAMS OF ABSOLUTE RANK CHANGES
#------------------------------------------------------------

  p_hist <- ggplot(
    rank_change_long,
    aes(x = Absolute_rank_change)
  ) +
  geom_histogram(
    binwidth = 1,
    fill = "grey75",
    colour = "black",
    linewidth = 0.2
  ) +
  facet_wrap(
    ~ Method,
    ncol = 2,
    scales = "fixed",
    drop = FALSE,
    labeller = labeller(
      Method = as_labeller(
        method_labels,
        default = label_parsed
      )
    )
  ) +
  labs(
    x = "Absolute rank change relative to GM",
    y = "Frequency"
  ) +
  theme_journal()

#------------------------------------------------------------
# BOXPLOTS OF ABSOLUTE RANK CHANGES
#------------------------------------------------------------

plot_method_order <- choquet_methods
  p_box <- ggplot(
    rank_change_long,
    aes(
      x = Absolute_rank_change,
      y = Method
    )
  ) +
  geom_boxplot(
    fill = "grey75",
    colour = "black",
    linewidth = 0.3,
    outlier.size = 0.6
  ) +
  scale_y_discrete(
    limits = rev(plot_method_order),
    labels = function(x) {
      parse(
        text = unname(method_labels[as.character(x)])
      )
    },
    drop = FALSE
  ) +
  scale_x_continuous(
    breaks = scales::pretty_breaks(n = 6)
  ) +
  labs(
    x = "Absolute rank change relative to GM",
    y = NULL
  ) +
  theme_journal()

# ------------------------------------------------------------
# MANUSCRIPT OUTPUT: APPENDIX FIGURE 5
# ------------------------------------------------------------

  p_rank_changes <- p_hist | p_box +
    theme(
      plot.tag.position = "top",
      plot.tag = element_text(hjust = 0.5, size = 12, margin = margin(b = 15) ),
      plot.margin = margin(t = 5, r = 10, b = 5, l = 10)
    )

ggsave(
  file.path(out_dir, "rank_changes_vs_gm.pdf"),
  plot = p_rank_changes,
  width = 7.2,
  height = 4.8
)

# ------------------------------------------------------------
# DEVELOPMENT-GROUP RANKING STABILITY
# ------------------------------------------------------------
# Compare the country membership of rank bands under each
# Choquet specification with the corresponding GM rank band.

stab4_model_cols <- c(
  ch_const_geom = "ch_const_geom",
  ch_const_mid  = "ch_const_mid",
  ch_corr_geom  = "ch_corr_geom",
  ch_corr_mid   = "ch_corr_mid"
)

stab4_gm_col <- "geometric_mean"

# ------------------------------------------------------------
# DEFINE OVERLAP FUNCTIONS
# ------------------------------------------------------------

stab4_topN_overlap <- function(r1, r2, N) {
  top1 <- all_rankings$Country[all_rankings[[r1]] <= N]
  top2 <- all_rankings$Country[all_rankings[[r2]] <= N]

  length(intersect(top1, top2)) / N
}

stab4_overlap_range <- function(r1, r2, lower, upper) {
  group1 <- all_rankings$Country[
    all_rankings[[r1]] >= lower & all_rankings[[r1]] <= upper
  ]

  group2 <- all_rankings$Country[
    all_rankings[[r2]] >= lower & all_rankings[[r2]] <= upper
  ]

  length(intersect(group1, group2)) / (upper - lower + 1)
}

# ------------------------------------------------------------
# DEFINE THE FOUR COMPARISONS WITH GM
# ------------------------------------------------------------
# Each comparison measures overlap between GM and one Choquet model.
# ------------------------------------------------------------

stab4_comparison_pairs <- lapply(names(stab4_model_cols), function(model) {
  c(stab4_gm_col, unname(stab4_model_cols[model]))
})

names(stab4_comparison_pairs) <- paste0(
  "gm_vs_", names(stab4_model_cols)
)
# ------------------------------------------------------------
# CALCULATE OVERLAP FOR A DEVELOPMENT GROUP
# ------------------------------------------------------------

stab4_calculate <- function(lower, upper, top_n = NULL) {

  stab4_values <- vapply(
    names(stab4_comparison_pairs),
    function(comparison) {

      cols <- stab4_comparison_pairs[[comparison]]
      r1 <- cols[1]
      r2 <- cols[2]

      if (!all(c(r1, r2) %in% names(all_rankings))) {
        stop(
          "Ranking column not found for comparison: ",
          comparison,
          ". Columns required: ", r1, " and ", r2
        )
      }

      if (!is.null(top_n)) {
        stab4_topN_overlap(r1, r2, top_n)
      } else {
        stab4_overlap_range(r1, r2, lower, upper)
      }
    },
    numeric(1)
  )

  as.data.frame(as.list(stab4_values), check.names = FALSE)
}

# ------------------------------------------------------------
# CALCULATE OVERLAP FOR THE FOUR DEVELOPMENT GROUPS
# ------------------------------------------------------------

Stab4_vhhd <- stab4_calculate(1, 74, top_n = 74)
Stab4_hhd  <- stab4_calculate(75, 124)
Stab4_mhd  <- stab4_calculate(125, 167)
Stab4_lhd  <- stab4_calculate(168, 193)

# ------------------------------------------------------------
# COMBINE DEVELOPMENT-GROUP RESULTS
# ------------------------------------------------------------

Stab4_all <- rbind(
  data.frame(
    Group = "Very high human development",
    Stab4_vhhd,
    check.names = FALSE
  ),
  data.frame(
    Group = "High human development",
    Stab4_hhd,
    check.names = FALSE
  ),
  data.frame(
    Group = "Medium human development",
    Stab4_mhd,
    check.names = FALSE
  ),
  data.frame(
    Group = "Low human development",
    Stab4_lhd,
    check.names = FALSE
  )
)

#print(Stab4_all)

stab4_compare_countries <- function(lower, upper, top_n = NULL) {

  gm_countries <- if (!is.null(top_n)) {
    all_rankings$Country[
      all_rankings$geometric_mean <= top_n
    ]
  } else {
    all_rankings$Country[
      all_rankings$geometric_mean >= lower &
        all_rankings$geometric_mean <= upper
    ]
  }

  results <- lapply(names(stab4_model_cols), function(model) {

    model_col <- unname(stab4_model_cols[model])

    model_countries <- if (!is.null(top_n)) {
      all_rankings$Country[
        all_rankings[[model_col]] <= top_n
      ]
    } else {
      all_rankings$Country[
        all_rankings[[model_col]] >= lower &
          all_rankings[[model_col]] <= upper
      ]
    }

    shared <- intersect(gm_countries, model_countries)

    data.frame(
      Model = model,
      GM_n = length(gm_countries),
      Model_n = length(model_countries),
      Shared = length(shared),
      Overlap = length(shared) / length(gm_countries),
      Only_in_GM = paste(
        setdiff(gm_countries, model_countries),
        collapse = ", "
      ),
      Only_in_model = paste(
        setdiff(model_countries, gm_countries),
        collapse = ", "
      ),
      Identical = setequal(gm_countries, model_countries),
      stringsAsFactors = FALSE
    )
  })

  do.call(rbind, results)
}

# Very high
stab4_compare_countries(1, 74, top_n = 74)

# High
stab4_compare_countries(75, 124)

# Medium
stab4_compare_countries(125, 167)

# Low
stab4_compare_countries(168, 193)


stab4_check_choquet_tiers <- function(lower, upper) {

  models <- unname(stab4_model_cols)

  countries_by_model <- lapply(models, function(model) {
    all_rankings$Country[
      all_rankings[[model]] >= lower &
        all_rankings[[model]] <= upper
    ]
  })

  reference <- countries_by_model[[1]]

  vapply(
    countries_by_model,
    function(x) setequal(reference, x),
    logical(1)
  )
}

stab4_check_choquet_tiers(1, 74)
stab4_check_choquet_tiers(75, 124)
stab4_check_choquet_tiers(125, 167)
stab4_check_choquet_tiers(168, 193)

# ============================================================
# MANUSCRIPT OUTPUT: APPENDIX TABLE 14
# ============================================================

print(
  xtable::xtable(Stab4_all),
  include.rownames = FALSE,
  type = "latex",
  file = file.path(out_dir, "stability_table_four_models.tex")
)

write.csv(
  Stab4_all,
  file.path(out_dir, "stability_table_four_models.csv"),
  row.names = FALSE
)


# ------------------------------------------------------------
# 12. CONSOLE SUMMARY
# ------------------------------------------------------------

cat("\nGeometric-mean comparison completed.\n\n")

cat("Kendall rank-correlation matrix:\n")
print(round(kendall_matrix, 4))

cat("\nChoquet rankings saved to:\n")
cat(
  file.path(out_dir, "all_rankings.csv"),
  "\n"
)

cat("\nAll outputs saved to: ", out_dir, "\n", sep = "")

# ------------------------------------------------------------
# ADDITIONAL DIAGNOSTICS: MIDPOINT MODEL COMPARISON
# ------------------------------------------------------------
# Compare the two midpoint specifications in terms of their
# Kendall agreement with GM, numerical rank changes, and the
# magnitude of those changes.
#
# The direct comparison also identifies how many countries
# receive different numerical ranks under the two midpoint models.
# ------------------------------------------------------------

gm <- all_rankings$geometric_mean
r_const <- all_rankings$ch_const_mid
r_corr <- all_rankings$ch_corr_mid

country_ids <- all_rankings$Country

# Confirm that the ranking vectors have the same length.

stopifnot(
  length(gm) == length(r_const),
  length(gm) == length(r_corr),
  length(gm) == length(country_ids)
)

# ------------------------------------------------------------
# KENDALL AGREEMENT AND RANK MOVEMENTS
# ------------------------------------------------------------

midpoint_diagnostics <- do.call(
  rbind,
  lapply(
    list(
      ch_const_mid = r_const,
      ch_corr_mid = r_corr
    ),
    function(model_rank) {

      valid <- !is.na(gm) & !is.na(model_rank)

      delta <- model_rank[valid] - gm[valid]
      abs_delta <- abs(delta)

      data.frame(
        Countries_compared = length(delta),
        Kendall_tau = cor(
          gm[valid],
          model_rank[valid],
          method = "kendall"
        ),
        Changed_rankings = sum(delta != 0),
        Percentage_changed = 100 * mean(delta != 0),
        Mean_absolute_rank_movement = mean(abs_delta),
        Median_absolute_rank_movement = median(abs_delta),
        Maximum_absolute_rank_movement = max(abs_delta)
      )
    }
  )
)

midpoint_diagnostics$Method <- c(
  "ch_const_mid",
  "ch_corr_mid"
)

midpoint_diagnostics <- midpoint_diagnostics[
  ,
  c(
    "Method",
    "Countries_compared",
    "Kendall_tau",
    "Changed_rankings",
    "Percentage_changed",
    "Mean_absolute_rank_movement",
    "Median_absolute_rank_movement",
    "Maximum_absolute_rank_movement"
  )
]

# ------------------------------------------------------------
# DIRECT COMPARISON OF MIDPOINT RANKINGS
# ------------------------------------------------------------

valid_pair <- !is.na(r_const) & !is.na(r_corr)

n_different_midpoint_ranks <- sum(
  r_const[valid_pair] != r_corr[valid_pair]
)

tau_between_midpoint_models <- cor(
  r_const[valid_pair],
  r_corr[valid_pair],
  method = "kendall"
)

cat("\nMidpoint model comparison:\n")

print(
  midpoint_diagnostics,
  row.names = FALSE,
  digits = 4
)

cat(
  "\nCountries with different numerical ranks between midpoint models:",
  n_different_midpoint_ranks,
  "\n"
)

cat(
  "Kendall correlation between midpoint models:",
  round(tau_between_midpoint_models, 4),
  "\n"
)

# ------------------------------------------------------------
# MIDPOINT MODEL DIAGNOSTICS
# ------------------------------------------------------------

write.csv(
  midpoint_diagnostics,
  file.path(out_dir, "midpoint_model_diagnostics.csv"),
  row.names = FALSE
)
