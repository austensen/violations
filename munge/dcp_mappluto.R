library(tidyverse)
library(feather)
library(stringr)


# Set up directories ------------------------------------------------------

dir.create("data-raw", showWarnings = FALSE)
dir.create("data-raw/dcp_mappluto", showWarnings = FALSE)

# Download files (and delete unnecessary ones) ----------------------------

download.file("https://www1.nyc.gov/assets/planning/download/zip/data-maps/open-data/mappluto_16v2.zip",
              "data-raw/dcp_mappluto/nyc_mappluto_16v2.zip", mode = "wb")

unzip("data-raw/dcp_mappluto/nyc_mappluto_16v2.zip", exdir = "data-raw/dcp_mappluto")

dir("data-raw/dcp_mappluto", full.names = TRUE) %>% walk(unzip, exdir = "data-raw/dcp_mappluto")

dir("data-raw/dcp_mappluto", pattern = "zip$", full.names = TRUE) %>% file.remove()

