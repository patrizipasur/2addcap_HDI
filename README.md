# 2addcap_HDI

## Overview

This repository contains the code required to reproduce the complete empirical analysis associated with the manuscript.

## Reproducibility script

**Purpose:**
Run the complete empirical analysis associated with the manuscript, from beginning to end.

**How to use:**

1. Clone the repository.
2. Open the R project in RStudio.
3. Restore the required package environment (see *Package management* below).
4. Run the following command from the project root directory:

```r
source("scripts/00_run_all.R")
```

This script executes the full analysis pipeline.

## Package management and reproducibility

This project uses [`renv`](https://rstudio.github.io/renv/) to manage R package dependencies and ensure reproducibility.

Please use `renv` to set up the project environment rather than installing packages manually.

After cloning the repository and opening the R project, run:

```r
install.packages("renv")  # If not already installed
renv::restore()
```

This will install the package versions specified in `renv.lock`.

If you install additional packages or update existing ones, please update the lockfile using:

```r
renv::snapshot()
```
Then, run
```r
source("scripts/00_run_all.R")
```