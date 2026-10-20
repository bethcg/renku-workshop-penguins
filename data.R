#' Palmer penguins: Shiny-free data and model layer, shared by the app and the job (fit.R).

#' Where the CSV lives. Defaults to the copy bundled in the repo; set PENGUINS_DATA_DIR
#' to read from a mounted (public, credential-free) data connector instead.
DATA_DIR <- Sys.getenv("PENGUINS_DATA_DIR", "data")

NUM_VARS <- c(
  "Bill length (mm)"    = "bill_length_mm",
  "Bill depth (mm)"     = "bill_depth_mm",
  "Flipper length (mm)" = "flipper_length_mm",
  "Body mass (g)"       = "body_mass_g"
)

#' Load and tidy penguins.csv; stops loudly if it is missing.
load_penguins <- function(data_dir = DATA_DIR) {
  f <- file.path(data_dir, "penguins.csv")
  if (!file.exists(f)) stop(sprintf("penguins.csv not found under %s", normalizePath(data_dir, mustWork = FALSE)))
  df <- read.csv(f, stringsAsFactors = FALSE, encoding = "UTF-8")
  df <- df[stats::complete.cases(df), ]
  df$species <- factor(df$species)
  df$island <- factor(df$island)
  df$sex <- factor(df$sex)
  df
}

#' Subset by species / island / year range; NULL means "no filter".
filter_penguins <- function(df, species = NULL, islands = NULL, years = NULL) {
  keep <- rep(TRUE, nrow(df))
  if (!is.null(species)) keep <- keep & df$species %in% species
  if (!is.null(islands)) keep <- keep & df$island %in% islands
  if (!is.null(years)) keep <- keep & df$year >= years[1] & df$year <= years[2]
  df[keep, ]
}

#' Mean of every numeric measurement per species.
species_means <- function(df) {
  if (nrow(df) == 0) return(data.frame())
  agg <- stats::aggregate(df[unname(NUM_VARS)], by = list(species = df$species), FUN = function(v) round(mean(v), 1))
  agg$n <- as.integer(table(df$species)[as.character(agg$species)])
  agg
}

#' Fit lm(formula) on an 80% split; return the model, train R-squared and test RMSE.
fit_model <- function(df, formula, seed = 1) {
  set.seed(seed)
  idx <- sample(nrow(df), floor(0.8 * nrow(df)))
  train <- df[idx, ]
  test <- df[-idx, ]
  fit <- stats::lm(stats::as.formula(formula), data = train)
  response <- all.vars(stats::as.formula(formula))[1]
  pred <- stats::predict(fit, test)
  list(
    fit = fit,
    r2 = summary(fit)$r.squared,
    rmse = sqrt(mean((pred - test[[response]])^2)),
    n_train = nrow(train),
    n_test = nrow(test)
  )
}
