library(shinydashboard)
library(dplyr)
library(leaflet)
library(shiny)
library(sf)

map_df <- readRDS("map_df.rds")

pal <- colorNumeric("viridis", domain = 0:1)

function(input, output, session) {
  
  cd_df <- reactive({
    filter(map_df, cd %in% cds[[input$cd]])
  })
  
  output$map <- renderLeaflet({
    cd_df() %>% 
      rename_(.dots = setNames(models[[input$model]], "pred")) %>% 
      leaflet() %>%
      addProviderTiles(providers$CartoDB.Positron) %>% 
      addPolygons(color = "#444444", weight = 1, smoothFactor = 0.5,
                  opacity = 1, fillOpacity = 1,
                  fillColor = ~pal(pred),
                  popup = ~bbl,
                  highlightOptions = highlightOptions(color = "white", weight = 2,
                                                      bringToFront = TRUE)) %>%
      addLegend(pal = pal, values = ~pred, opacity = 1, title = NULL,
                position = "bottomright")
  })
  
  output$tbl <- DT::renderDataTable({
    cd_df() %>% 
      tibble::as_tibble() %>% 
      rename_(.dots = setNames(models[[input$model]], "pred")) %>% 
      select(bbl, pred) %>% 
      arrange(desc(pred))
  })
}