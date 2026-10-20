# Workshop JOB: fit a linear model of penguin body mass and report it. Runs in seconds.
# Uses the same data.R as the app, so the job and the Model tab agree.
#
#   Rscript fit.R --formula "body_mass_g ~ flipper_length_mm"
#   Rscript fit.R --formula "body_mass_g ~ flipper_length_mm + species" --seed 2 --out /path/to/data-connector

args <- commandArgs(trailingOnly = TRUE)
opt <- list(formula = "body_mass_g ~ flipper_length_mm", seed = "1",
            out = Sys.getenv("OUTPUT_DIR", "outputs"))
i <- 1
while (i <= length(args)) {
  key <- sub("^--", "", args[i])
  if (!key %in% names(opt) || i == length(args)) stop("usage: Rscript fit.R [--formula F] [--seed N] [--out DIR]")
  opt[[key]] <- args[i + 1]
  i <- i + 2
}

# Run from the repo root no matter where the job starts.
file_arg <- grep("^--file=", commandArgs(), value = TRUE)
if (length(file_arg)) setwd(dirname(normalizePath(sub("^--file=", "", file_arg))))
source("data.R")

penguins <- load_penguins()
cat(sprintf("[1/3] %d penguins loaded from %s\n", nrow(penguins), DATA_DIR))
Sys.sleep(2)  # keep the job visible in the UI for a moment

cat(sprintf("[2/3] Fitting lm(%s), seed %s\n", opt$formula, opt$seed))
res <- fit_model(penguins, opt$formula, seed = as.integer(opt$seed))
print(round(summary(res$fit)$coefficients, 3))
cat(sprintf("      R-squared (train, n=%d) = %.3f, RMSE (test, n=%d) = %.1f g\n",
            res$n_train, res$r2, res$n_test, res$rmse))

out <- opt$out
dir.create(out, showWarnings = FALSE, recursive = TRUE)
if (file.access(out, 2) != 0) { out <- "/tmp/outputs"; dir.create(out, showWarnings = FALSE, recursive = TRUE) }
path <- file.path(out, sprintf("fit_seed%s.rds", opt$seed))
saveRDS(res$fit, path)
cat(sprintf("[3/3] Wrote %s (temporary unless --out points at a data connector)\n", path))
