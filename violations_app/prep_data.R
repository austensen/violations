library(tidyverse)
library(sf)

dir.create("violations_app", showWarnings = TRUE)

pred <- feather::read_feather("data/model_predictions_16.feather")
geo_df <- st_read("data-raw/dcp_mappluto/BKMapPLUTO.shp")

map_df <- geo_df %>% 
  st_transform('+proj=longlat +datum=WGS84') %>% 
  mutate(bbl = as.character(BBL)) %>% 
  select(bbl, cd = CD, geometry) %>% 
  inner_join(pred, by = "bbl")

saveRDS(map_df, "violations_app/map_df.RDS")
