#' Palmer penguins explorer: global setup, evaluated once before ui.R / server.R.

library(shiny)
library(shinydashboard)
library(ggplot2)

source("data.R")

# Renku palette, as in the renku-apps-demos R Shiny example.
RK_NAVY   <- "#01192d"
RK_GREEN  <- "#009568"
RK_INFO   <- "#0f7396"
RK_YELLOW <- "#d1bb4c"
RK_PINK   <- "#ca4e86"
RK_BG_0   <- "#f5f6fa"
RK_WHITE  <- "#ffffff"

SPECIES_COLOURS <- c(Adelie = RK_GREEN, Chinstrap = RK_PINK, Gentoo = RK_INFO)

#' Shared Renku look, added to a plot with `+ renku_layout()`.
renku_layout <- function(...) {
  list(
    theme_minimal(base_size = 14),
    theme(
      plot.background  = element_rect(fill = RK_WHITE, colour = NA),
      panel.background = element_rect(fill = RK_WHITE, colour = NA),
      legend.position  = "top",
      text             = element_text(color = RK_NAVY),
      ...
    )
  )
}

penguins <- load_penguins()

SPECIES_CHOICES <- levels(penguins$species)
ISLAND_CHOICES  <- levels(penguins$island)
YEAR_MIN <- min(penguins$year)
YEAR_MAX <- max(penguins$year)

message(sprintf("[penguins] loaded %d rows from %s", nrow(penguins), DATA_DIR))
