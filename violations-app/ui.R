library(shinydashboard)
library(leaflet)

function(request){
    
  header <- dashboardHeader(
    title = "Serious Housing Code Violations - Brooklyn (2016)",
    titleWidth = 450
  )
  
  sidebar <- dashboardSidebar(width = 400,
    tags$style(type = "text/css", "#tbl {background-color: white; color: black; border-radius: 5px; padding: 10px 10px 10px 10px}"),
    div(style = "align-text: center", bookmarkButton()),
    sidebarMenu(
      menuItem("Community District and Model Type",
        menuSubItem(icon = NULL,
          selectInput("cd", "Community District:", names(cds))
        ),
        menuSubItem(icon = NULL,
          selectInput("model", "Violations:", names(models))
        )
      )
    ),
    div(style = "margin: 5% 5% 5% 5%", DT::dataTableOutput("tbl", width = "100%"))
  )
  
  body <- dashboardBody(
     tags$style(type = "text/css", "#map {height: calc(100vh - 90px) !important;}"),
     leafletOutput("map")
  )

  dashboardPage(
    header,
    sidebar,
    body,
    skin = "black"
  )
}