# Workshop APP: public R Shiny explorer of the Palmer penguins dataset.
library(shiny)

penguins <- na.omit(read.csv("data/penguins.csv", stringsAsFactors = TRUE))
num_vars <- c("bill_length_mm", "bill_depth_mm", "flipper_length_mm", "body_mass_g")
cols <- c(Adelie = "#E07B39", Chinstrap = "#8E5DB0", Gentoo = "#2A8C82")

ui <- fluidPage(
  titlePanel("Palmer penguins explorer"),
  p("Renku Jobs & Apps workshop. Data: palmerpenguins (CC0)."),
  sidebarLayout(
    sidebarPanel(
      selectInput("x", "X axis", num_vars, "flipper_length_mm"),
      selectInput("y", "Y axis", num_vars, "body_mass_g"),
      checkboxGroupInput("species", "Species", names(cols), names(cols)),
      checkboxInput("fit", "Show linear fit per species", TRUE)
    ),
    mainPanel(plotOutput("scatter", height = "420px"), tableOutput("summary"))
  )
)

server <- function(input, output) {
  data <- reactive(subset(penguins, species %in% input$species))
  output$scatter <- renderPlot({
    d <- data(); req(nrow(d) > 0)
    plot(d[[input$x]], d[[input$y]], col = cols[as.character(d$species)], pch = 19,
         xlab = input$x, ylab = input$y, las = 1, bty = "l")
    if (input$fit) for (s in unique(as.character(d$species))) {
      ds <- d[d$species == s, ]
      abline(lm(ds[[input$y]] ~ ds[[input$x]]), col = cols[s], lwd = 2)
    }
    legend("topleft", legend = input$species, col = cols[input$species], pch = 19, bty = "n")
  })
  output$summary <- renderTable({
    d <- data(); req(nrow(d) > 0)
    aggregate(d[num_vars], by = list(species = d$species), FUN = function(v) round(mean(v), 1))
  })
}

shinyApp(ui, server)
