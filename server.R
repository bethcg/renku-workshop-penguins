#' Palmer penguins explorer: Shiny server. Presentation only; transforms live in data.R.

function(input, output, session) {

  empty_plot <- function(msg = "No data for the current selection") {
    ggplot() +
      annotate("text", x = 0.5, y = 0.5, label = msg, size = 7, colour = RK_NAVY) +
      theme_void()
  }

  label_of <- function(var) names(NUM_VARS)[NUM_VARS == var]

  filtered <- reactive({
    filter_penguins(penguins, species = input$species, islands = input$islands, years = input$years)
  })

  output$app_info <- renderText({
    project <- Sys.getenv("RENKU_PROJECT_URL", "")
    paste0("Data: palmerpenguins (CC0)", if (nzchar(project)) paste0("\nSource: ", project) else "")
  })

  output$download_csv <- downloadHandler(
    filename = function() "penguins_filtered.csv",
    content = function(file) utils::write.csv(filtered(), file, row.names = FALSE)
  )

  # --- Value boxes ---------------------------------------------------------
  output$vb_n <- renderValueBox({
    valueBox(nrow(filtered()), "Penguins", icon = icon("database"), color = "green")
  })
  output$vb_mass <- renderValueBox({
    d <- filtered()
    valueBox(if (nrow(d)) sprintf("%s g", format(round(mean(d$body_mass_g)), big.mark = "'")) else "–",
             "Mean body mass", icon = icon("weight-scale"), color = "aqua")
  })
  output$vb_flipper <- renderValueBox({
    d <- filtered()
    valueBox(if (nrow(d)) sprintf("%.0f mm", mean(d$flipper_length_mm)) else "–",
             "Mean flipper length", icon = icon("ruler"), color = "yellow")
  })

  # --- Plots ---------------------------------------------------------------
  output$scatter_plot <- renderPlot({
    d <- filtered()
    if (nrow(d) == 0) return(empty_plot())
    ggplot(d, aes(x = .data[[input$x]], y = .data[[input$y]], colour = species)) +
      geom_point(alpha = 0.8, size = 2.5) +
      geom_smooth(method = "lm", formula = y ~ x, se = FALSE) +
      scale_colour_manual(values = SPECIES_COLOURS) +
      labs(x = label_of(input$x), y = label_of(input$y), colour = NULL,
           title = sprintf("%s vs %s, linear fit per species", label_of(input$y), label_of(input$x))) +
      renku_layout()
  })

  output$dist_plot <- renderPlot({
    d <- filtered()
    if (nrow(d) == 0) return(empty_plot())
    ggplot(d, aes(x = species, y = .data[[input$y]], fill = species)) +
      geom_boxplot(alpha = 0.35, outlier.shape = NA, colour = RK_NAVY) +
      geom_jitter(aes(colour = species), width = 0.15, size = 1.6, alpha = 0.7) +
      scale_fill_manual(values = SPECIES_COLOURS, guide = "none") +
      scale_colour_manual(values = SPECIES_COLOURS, guide = "none") +
      facet_wrap(~ sex) +
      labs(x = NULL, y = label_of(input$y), title = sprintf("%s by species and sex", label_of(input$y))) +
      renku_layout()
  })

  # --- Model ---------------------------------------------------------------
  model <- reactive({
    d <- filtered()
    validate(need(nrow(d) >= 20, "Select at least 20 penguins to fit a model."))
    res <- tryCatch(fit_model(d, input$formula), error = function(e) e)
    if (inherits(res, "error")) validate(need(FALSE, paste("Model error:", conditionMessage(res))))
    res
  })

  output$model_summary <- renderText({
    m <- model()
    sprintf("lm(%s)\nR-squared (train, n=%d) = %.3f\nRMSE (test, n=%d) = %.1f",
            input$formula, m$n_train, m$r2, m$n_test, m$rmse)
  })

  output$coef_tbl <- renderTable({
    co <- summary(model()$fit)$coefficients
    data.frame(term = rownames(co), estimate = co[, 1], std_error = co[, 2], p_value = format.pval(co[, 4], digits = 2))
  }, digits = 2)

  # --- Tables --------------------------------------------------------------
  output$means_tbl <- renderTable(species_means(filtered()), digits = 1)
  output$data_tbl <- renderTable(utils::head(filtered(), 200))
}
