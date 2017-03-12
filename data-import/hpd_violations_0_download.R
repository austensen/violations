library(tidyverse)
library(feather)
library(stringr)

dir.create("data-raw", showWarnings = FALSE)
dir.create("data-documentation", showWarnings = FALSE)
dir.create("data-raw/hpd_violations", showWarnings = FALSE)

# Download Documentation --------------------------------------------------

download.file("http://www1.nyc.gov/assets/hpd/downloads/misc/ViolationsOpenDataDoc.zip", 
              "data-documentation/ViolationsOpenDataDoc.zip", mode = "wb", quiet = TRUE)

unzip("data-documentation/ViolationsOpenDataDoc.zip", exdir = "data-documentation")

file.rename("data-documentation/ViolationsOpenDataDoc/HPD Violation Open Data.pdf",
            "data-documentation/HPD Violation Open Data.pdf")

download.file("https://www1.nyc.gov/assets/buildings/pdf/HousingMaintenanceCode.pdf",
              "data-documentation/HousingMaintenanceCode.pdf", mode = "wb", quiet = TRUE)

# Delete all fies in unwanted subdirectory, then the subdirectory itself 
dir("data-documentation/ViolationsOpenDataDoc", full.names = TRUE) %>% file.remove() 

file.remove("data-raw/documentation/ViolationsOpenDataDoc") 

# Download Data -----------------------------------------------------------

download.file("https://data.cityofnewyork.us/api/views/wvxf-dwi5/rows.csv?accessType=DOWNLOAD",
              str_interp("data-raw/hpd_violations/hpd_violations.csv"), mode = "wb", quiet = TRUE)

