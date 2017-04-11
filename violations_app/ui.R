library(shinydashboard)
library(leaflet)

dashboardPage(
  dashboardHeader(title = "Serious Housing Code Violations (2016)"),
  dashboardSidebar(disable = TRUE),
  dashboardBody(
    fluidRow(
      column(width = 9,
             box(width = NULL, solidHeader = TRUE,
                 leafletOutput("map", height = 700)
             )
      ),
      column(width = 3,
             box(width = NULL,
                 selectInput("cd", "Community District:", names(cds))
             )
      ),
      column(width = 3,
             box(width = NULL,
                 selectInput("model", "Violations:", names(models))
             )
      )
    )
  )
)