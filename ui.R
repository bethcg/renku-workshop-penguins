#' Palmer penguins explorer: Shiny UI (shinydashboard).

dashboardPage(
  dashboardHeader(title = "Palmer penguins"),

  dashboardSidebar(
    selectInput("species", "Species", choices = SPECIES_CHOICES, selected = SPECIES_CHOICES, multiple = TRUE),
    selectInput("islands", "Islands", choices = ISLAND_CHOICES, selected = ISLAND_CHOICES, multiple = TRUE),
    sliderInput("years", "Years", min = YEAR_MIN, max = YEAR_MAX, value = c(YEAR_MIN, YEAR_MAX), step = 1, sep = ""),
    selectInput("x", "X axis", choices = NUM_VARS, selected = "flipper_length_mm"),
    selectInput("y", "Y axis", choices = NUM_VARS, selected = "body_mass_g"),
    tags$hr(),
    downloadButton("download_csv", "Download filtered CSV",
                   style = "margin: 0 15px; width: calc(100% - 30px);"),
    tags$div(textOutput("app_info"), style = "padding: 12px 15px; font-size: 11px; color: #b8c7ce; white-space: pre-line;")
  ),

  dashboardBody(
    tags$head(tags$style(HTML("
      .skin-blue .main-header .logo,
      .skin-blue .main-header .navbar { background-color: #01192d; }
      .skin-blue .main-header .logo { font-weight: 700; }
      .skin-blue .main-sidebar { background-color: #01324d; }
      .content-wrapper, .right-side { background-color: #f5f6fa; }
      .small-box.bg-green { background-color: #009568 !important; }
      .small-box.bg-aqua { background-color: #0f7396 !important; }
      .small-box.bg-yellow { background-color: #d1bb4c !important; }
      h2, h3, h4 { color: #01192d; }
    "))),

    fluidRow(
      valueBoxOutput("vb_n", width = 4),
      valueBoxOutput("vb_mass", width = 4),
      valueBoxOutput("vb_flipper", width = 4)
    ),

    fluidRow(
      tabBox(
        width = 12, id = "tabs",
        tabPanel("Scatter", plotOutput("scatter_plot", height = "460px")),
        tabPanel("Distributions", plotOutput("dist_plot", height = "460px")),
        tabPanel("Model",
          p("The same linear model the job (fit.R) runs, fitted live on the filtered data with an 80/20 split."),
          textInput("formula", "Formula", "body_mass_g ~ flipper_length_mm + species", width = "100%"),
          verbatimTextOutput("model_summary"),
          tableOutput("coef_tbl")
        ),
        tabPanel("Species means", tableOutput("means_tbl")),
        tabPanel("Data", tableOutput("data_tbl"))
      )
    )
  ),

  skin = "blue"
)
