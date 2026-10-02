# Manuscript-to-code map

This document provides a direct correspondence between the manuscript results and the scripts used to generate them.

| Manuscript result | Analysis | Script | Generated output |
|---|---|---|---|
| Table 5 | Descriptive statistics and Shapiro-Wilk normality tests | `03_analysis_dim.R` | `output/03_analysis_dim/sum_sw_normality.tex` |
| Table 6 | Mardia multivariate normality test | `03_analysis_dim.R` | `output/03_analysis_dim/mardia_mnormality.tex` |
| Table 6 | Henze-Zirkler diagnostic | `03_analysis_dim.R` | `output/03_analysis_dim/hz_normality.tex` |
| Table 6 | Correlation matrix used in the correlation-based Choquet specification | `03_analysis_dim.R` | `output/03_analysis_dim/spearman_correlations.tex` |
| Table 8, column 1 | Kendall rank correlations | `05_comparisons.R` | `output/05_comparisons/kendall_correlations.tex` |
| Table 8, columns 2–3 | Number and percentage of ranking changes | `05_comparisons.R` | `output/05_comparisons/rank_changes.tex` |
| Figure 3 | Distribution of absolute ranking changes | `05_comparisons.R` | `output/05_comparisons/figure_rank_changes_journal.pdf` |
| Table 9 | Ranking overlap across development groups | `05_comparisons.R` | `output/05_comparisons/stability_table.tex` |

## Intermediate datasets

| Purpose | Script | Output |
|---|---|---|
| Normalized HDI components | `02_normalization.R` | `output/02_normalization/data_normalized.rds` |
| Human-readable normalized dataset | `02_normalization.R` | `output/02_normalization/data_normalized.csv` |
| Complete composite-index dataset | `04_composite_indices.R` | `output/04_composite_indices/data_indices_cal.rds` |
| Human-readable composite-index dataset | `04_composite_indices.R` | `output/04_composite_indices/data_indices_cal.csv` |
| Dataset used for ranking comparisons | `04_composite_indices.R` | `output/04_composite_indices/data_indices.rds` |
| Human-readable ranking input | `04_composite_indices.R` | `output/04_composite_indices/data_indices.csv` |
| Country rankings | `05_comparisons.R` | `output/05_comparisons/data_indices_rankings.csv` |

## How to reproduce everything

Run the following command from the project root:

```r
source("scripts/00_run_all.R")
```

The output directory can then be inspected to trace each manuscript result back to the corresponding analysis stage.

> **Note:** The table/figure numbering above reflects the manuscript references explicitly associated with the supplied analysis scripts. Before submission, check that the numbering matches the final manuscript version.
