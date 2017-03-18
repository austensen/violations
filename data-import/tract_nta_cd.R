library(tidyverse)
library(feather)
library(stringr)
library(sf)

dir.create("data-raw", showWarnings = FALSE)
dir.create("data-raw/crosswalks", showWarnings = FALSE)

tracts <- st_read("https://data.cityofnewyork.us/api/geospatial/fxpq-c8ku?method=export&format=GeoJSON",
                  stringsAsFactors = FALSE) %>% 
  mutate(county = recode(boro_name, "Manhattan" = "061",
                                    "Bronx" = "005",
                                    "Brooklyn" = "047",
                                    "Queens" = "081",
                                    "Staten Island" = "085"),
         geoid = str_c(county, ct_2010),
         nta = ntacode,
         nta_name = ntaname) %>% 
  select(county, geoid, nta, nta_name, geometry)

# Simple non-spatial data frame for adding other geos composed of tracts
tract_xwalk <- tracts %>% 
  as.data.frame %>% 
  as_tibble %>% 
  select(-geometry)
  

st_write(tracts, "data-raw/crosswalks/tract2010_sf.shp")
write_feather(tract_xwalk, "data-raw/crosswalks/tract2010_nta_xwalk.feather")

# st_write(tracts, "data-raw/crosswalks/census_tracts_2010.shp")
