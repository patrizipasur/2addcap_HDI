# Reproducibility setup for the author

This file records the steps that should be completed once before publishing the repository on GitHub.

## 1. Open the project

Open the repository/project root in RStudio. The working directory should be the repository root, not the `scripts/` directory.

## 2. Initialize `renv`

If `renv` has not previously been initialized for this project:

```r
install.packages("renv")
renv::init()
```

Install any packages required by the analysis if they are not already available. The package list is documented in `scripts/01_packages_directories.R`.

## 3. Run the analysis successfully

Run:

```r
source("scripts/00_run_all.R")
```

Fix any environment-specific issues before publishing the repository.

## 4. Record the package environment

Once the analysis runs successfully:

```r
renv::snapshot()
```

This creates `renv.lock`. **Commit this file to GitHub.** It is the key file used by reviewers to reconstruct the package environment.

## 5. Test from a clean environment

The strongest test is to clone the repository to a different directory or computer and run:

```r
install.packages("renv")
renv::restore()
source("scripts/00_run_all.R")
```

The analysis should complete without manually setting a working directory or creating intermediate files by hand.

## 6. Before publication

Confirm that:

- `data/HDI25.xlsx` is included if its redistribution is permitted;
- otherwise, `data/README.md` explains how an authorized reviewer can obtain it;
- `renv.lock` is committed;
- no absolute paths such as `/Users/...` or `C:/Users/...` remain;
- no personal information, credentials, API keys or private files are included;
- the repository contains the final manuscript-to-code mapping.
