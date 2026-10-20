# Workshop JOB: fit a linear model of body mass and report it. Runs in seconds.
#
#   Rscript fit.R --formula "body_mass_g ~ flipper_length_mm"
#   Rscript fit.R --formula "body_mass_g ~ flipper_length_mm + species" --seed 2 --out /path/to/data-connector

args <- commandArgs(trailingOnly = TRUE)
opt <- list(formula = "body_mass_g ~ flipper_length_mm", seed = "1",
            out = Sys.getenv("OUTPUT_DIR", "outputs"))
i <- 1
while (i <= length(args)) {
  key <- sub("^--", "", args[i])
  if (!key %in% names(opt)) stop("unknown argument: ", args[i])
  opt[[key]] <- args[i + 1]
  i <- i + 2
}

script_dir <- tryCatch(dirname(normalizePath(sub("--file=", "", grep("--file=", commandArgs(), value = TRUE)))),
                       error = function(e) ".")
penguins <- read.csv(file.path(script_dir, "data", "penguins.csv"), stringsAsFactors = TRUE)
penguins <- na.omit(penguins)
cat(sprintf("[1/3] %d penguins loaded (rows with missing values dropped)\n", nrow(penguins)))

set.seed(as.integer(opt$seed))
idx <- sample(nrow(penguins), floor(0.8 * nrow(penguins)))
train <- penguins[idx, ]; test <- penguins[-idx, ]
Sys.sleep(2)

cat(sprintf("[2/3] Fitting lm(%s), seed %s\n", opt$formula, opt$seed))
fit <- lm(as.formula(opt$formula), data = train)
print(summary(fit)$coefficients)
rmse <- sqrt(mean((predict(fit, test) - test$body_mass_g)^2))
cat(sprintf("      R-squared (train) = %.3f, RMSE (test) = %.1f g\n", summary(fit)$r.squared, rmse))

out <- opt$out
ok <- tryCatch({ dir.create(out, showWarnings = FALSE, recursive = TRUE); file.access(out, 2) == 0 }, error = function(e) FALSE)
if (!isTRUE(ok)) { out <- "/tmp/outputs"; dir.create(out, showWarnings = FALSE, recursive = TRUE) }
path <- file.path(out, sprintf("fit_seed%s.rds", opt$seed))
saveRDS(fit, path)
cat(sprintf("[3/3] Wrote %s (temporary unless --out is a data connector)\n", path))
