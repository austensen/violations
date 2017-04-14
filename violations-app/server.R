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
      leaflet() %>%
      addProviderTiles(providers$CartoDB.Positron) %>% 
      addPolygons(fillColor = NULL) %>%
      addLegend(pal = pal, values = 0:1, opacity = 1, title = NULL, position = "bottomright")
  })
  
  observe({
    fill_var <- cd_df()[[models[[input$model]]]]
    
    leafletProxy("map", data = cd_df()) %>% 
      clearShapes() %>% 
      addPolygons(color = "#444444", weight = 1, smoothFactor = 0.5,
                  opacity = 1, fillOpacity = 1,
                  fillColor = ~pal(fill_var),
                  popup = paste("BBL:", cd_df()$bbl, "<br>",
                                "Actual Violations:", cd_df()$true_16, "<br>",
                                "Previous Year Violations:", cd_df()$past_viol, "<br>",
                                "Logit Predictions:", round(cd_df()$logit, 2), "<br>",
                                "Decision Tree Predictions:", round(cd_df()$tree, 2), "<br>",
                                "Random Forest Predictions:", round(cd_df()$forest, 2), "<br>"),
                  highlightOptions = highlightOptions(color = "white", weight = 2,
                                                      bringToFront = TRUE))
  })
  
  output$tbl <- DT::renderDataTable({
    cd_df() %>% 
      tibble::as_tibble() %>% 
      rename_(.dots = setNames(models[[input$model]], "prediction")) %>% 
      select(bbl, prediction) %>% 
      arrange(desc(prediction))
  })
}