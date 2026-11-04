# Manuscript-to-code map

This document provides a direct correspondence between the manuscript results and the scripts used to generate them.

| Manuscript result | Analysis | Script | Generated output |
|---|---|---|---|
| Table 5 | Descriptive statistics and Shapiro-Wilk normality tests | `03_analysis_dim.R` | `output/03_analysis_dim/sum_sw_normality.tex` |
| Table 6 | Mardia multivariate normality test | `03_analysis_dim.R` | `output/03_analysis_dim/mardia_mnormality.tex` |
| Table 6 | Henze-Zirkler diagnostic | `03_analysis_dim.R` | `output/03_analysis_dim/hz_normality.tex` |
| Table 6 | Correlation matrix used in the correlation-based Choquet specification | `03_analysis_dim.R` | `output/03_analysis_dim/spearman_correlations.tex` |
| Appendix Table 11, rows 2, 4, 5, 6, 7 and 9 | Orness (and k parameter) for arithmetic and geometric mean, and the two Choquet models considering the minimum feasible orness | `04_composite_indices.R` | `output/04_composite_indices/orness.csv` |
| Table 8, column 1 | Kendall rank correlations | `05_comparisons.R` | `output/05_comparisons/kendall_correlations.tex` |
| Table 8, columns 2 and 3 | Number and percentage of ranking changes | `05_comparisons.R` | `output/05_comparisons/rank_changes.tex` |
| Figure 3 | Distribution of absolute ranking changes | `05_comparisons.R` | `output/05_comparisons/figure_rank_changes_journal.pdf` |
| Table 9 | Ranking overlap across development groups | `05_comparisons.R` | `output/05_comparisons/stability_table.tex` |
| Table 10 | Rankings of Fiji and Maldives obtained directly from rankings data frame | `05_comparisons.R` | `05_comparisons/rankings.csv` |
| Appendix Table 11, rows 3 and 8 | Orness (and k parameter) for the two Choquet models considering the midpoint orness | `06a_sensitivity_orness.R` | `output/06a_sensitivity_orness/mid_orness_summary.tex` |
| Appendix Table 12 | Pairwise ranking agreement across orness scenarios | `06a_sensitivity_orness.R` | `06a_sensitivity_orness.R` | `output/06a_sensitivity_orness/scenario_rank_agreement.tex` |
| Appendix Figure 4  |  Distribution of absolute ranking changes across orness scenarios | `06a_sensitivity_orness.R` |  `output/06a_sensitivity_orness/sensitivity_rank_changes_ch_const.pdf` |
| Appendix Table 13, column 2 | Kendall rank correlations | `06b_sensitivity_comparisons_gm.R` | `output/06b_sensitivity_comparisons_gm/kendall_rank_correlations.csv` |
| Appendix Table 13, columns 3 and 4 | Number and percentage of rank changes | `06b_sensitivity_comparisons_gm.R` | `output/06b_sensitivity_comparisons_gm/number_and_percentage_of_changed_rankings.csv` |
| Appendix Figure 5 | Distribution of absolute ranking changes in the comparison with geometric mean | `06b_sensitivity_comparisons_gm.R` | `output/06b_sensitivity_comparisons_gm/rank_changes_vs_gm.pdf` |
| Table 14 | Ranking overlap across development groups for the four comparisons | `06b_sensitivity_comparisons_gm.R` | `output/06b_sensitivity_comparisons_gm/stability_table_four_models.tex` |
| Table 15 | Rankings of Fiji and Maldives obtained directly from all_rankings data frame |`06b_sensitivity_comparisons_gm.R` | `output/06b_sensitivity_comparisons_gm/all_rankings.csv` |

## Intermediate datasets

| Purpose | Script | Output |
|---|---|---|
| Normalized HDI components | `02_normalization.R` | `output/02_normalization/components_normalized.csv` |
| Composite-index dataset | `04_composite_indices.R` | `output/04_composite_indices/data_indices_cal.csv` |
| Indices | `04_composite_indices.R` | `output/04_composite_indices/indices.csv` |
| Country indices and rankings | `05_comparisons.R` | `05_comparisons/indices_rankings.csv` |
| Country rankings | `05_comparisons.R` | `05_comparisons/rankings.csv` |
| Country rankings across geometric mean and the two Choquel models considering geometric mean and midpoint orness |`06b_sensitivity_comparisons_gm.R` | `output/06b_sensitivity_comparisons_gm/all_rankings.csv`

## How to reproduce everything

Run the following command from the project root:

```r
source("scripts/00_run_all.R")
```

The output directory can then be inspected to trace each manuscript result back to the corresponding analysis stage.
