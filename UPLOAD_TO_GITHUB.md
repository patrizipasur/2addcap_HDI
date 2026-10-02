# Uploading this project to GitHub

After completing the `renv` setup and placing `data/HDI25.xlsx` in `data/` (if redistribution is permitted), open a terminal in the project root and run:

```bash
git init
git add .
git status
git commit -m "Prepare reproducibility repository for manuscript"
git branch -M main
git remote add origin https://github.com/YOUR-USERNAME/YOUR-REPOSITORY.git
git push -u origin main
```

Replace `YOUR-USERNAME/YOUR-REPOSITORY` with the repository you created on GitHub.

## Before `git add .`

Check that the project contains:

```text
data/HDI25.xlsx
renv.lock
scripts/00_run_all.R
README.md
MANUSCRIPT_MAP.md
```

Do not commit:

- `.RData`
- `.Rhistory`
- the local `renv/library/`
- credentials or API keys
- confidential data
- data that cannot legally be redistributed
