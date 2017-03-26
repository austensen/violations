library(tidyverse)
library(stringr)

# Set up directories ------------------------------------------------------

dir.create("data-raw", showWarnings = FALSE)
dir.create("data-documentation", showWarnings = FALSE)
dir.create("data-raw/dcp_pluto", showWarnings = FALSE)

# Download files (and delete unnecessary ones) ----------------------------

download.file("http://www1.nyc.gov/assets/planning/download/pdf/data-maps/open-data/pluto_datadictionary.pdf?v=16v2",
              "data-documentation/pluto_16v2.pdf", mode = "wb")

download.file("http://www1.nyc.gov/assets/planning/download/zip/data-maps/open-data/nyc_pluto_16v2%20.zip",
              "data-raw/dcp_pluto/nyc_pluto_16v2.zip", mode = "wb")

unzip("data-raw/dcp_pluto/nyc_pluto_16v2.zip", exdir = "data-raw/dcp_pluto")

file.remove("data-raw/dcp_pluto/nyc_pluto_16v2.zip")

# Stack separate borough files --------------------------------------------

# Start by reading manhattan file, and writing to new csv
read_lines("data-raw/dcp_pluto/BORO_zip_files_csv/MN.csv") %>% write_lines("data-raw/dcp_pluto/pluto_16.csv")

# Then read each other boro (skipping header) and append to the new all-boroughs file
c("BX", "BK", "QN", "SI")  %>% 
  walk(~ read_lines(str_interp("data-raw/dcp_pluto/BORO_zip_files_csv/${.x}.csv"), skip = 1) %>% 
         write_lines("data-raw/dcp_pluto/pluto_16.csv", append = TRUE))

# Delete all fies in unwanted subdirectory, then the subdirectory itself 
dir("data-raw/dcp_pluto/BORO_zip_files_csv", full.names = TRUE) %>% file.remove() 

file.remove("data-raw/dcp_pluto/BORO_zip_files_csv")
