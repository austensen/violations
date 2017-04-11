library(shinydashboard)
library(leaflet)

header <- dashboardHeader(
  title = "Serious Housing Code Violations - Brooklyn (2016)",
  titleWidth = 450
)

body <- dashboardBody(
  fluidRow(
    column(width = 8,
           box(width = NULL, solidHeader = TRUE,
               leafletOutput("map", height = 700)
           )
    ),
    column(width = 4,
           box(width = NULL,
               selectInput("cd", "Community District:", names(cds))
           ),
           box(width = NULL,
               selectInput("model", "Violations:", names(models))
           ),
           box(width = NULL,
               DT::dataTableOutput("tbl")
           )
    )
  )
)

dashboardPage(
  header,
  dashboardSidebar(disable = TRUE),
  body,
  skin = "black"
)