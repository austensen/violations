library(tidyverse)
library(feather)
library(stringr)


# Set up directories ------------------------------------------------------

dir.create("data-raw", showWarnings = FALSE)
dir.create("data-raw/documentation", showWarnings = FALSE)
dir.create("data-raw/pluto", showWarnings = FALSE)


# Download files (and delete unnecessary ones) ----------------------------

download.file("http://www1.nyc.gov/assets/planning/download/pdf/data-maps/open-data/pluto_datadictionary.pdf?v=16v2",
              "data-raw/documentation/pluto_16v2.pdf", mode = "wb")

download.file("http://www1.nyc.gov/assets/planning/download/zip/data-maps/open-data/nyc_pluto_16v2%20.zip",
              "data-raw/pluto/nyc_pluto_16v2.zip", mode = "wb")

unzip("data-raw/pluto/nyc_pluto_16v2.zip", exdir = "data-raw/pluto")

file.remove("data-raw/pluto/nyc_pluto_16v2.zip")

file.rename("data-raw/pluto/BORO_zip_files_csv", "data-raw/pluto/boro_files")


# Stack separate borough files --------------------------------------------

# Start by reading manhattan file, and writing to new csv
read_lines("data-raw/pluto/boro_files/MN.csv") %>% write_lines("data-raw/pluto/pluto_16v2.csv")

# Then read each other boro (skipping header) and append to the new all-boroughs file
c("BX", "BK", "QN", "SI")  %>% 
  walk(~ read_lines(str_interp("data-raw/pluto/boro_files/${.x}.csv"), skip = 1) %>% 
           write_lines("data-raw/pluto/pluto_16v2.csv", append = TRUE))
