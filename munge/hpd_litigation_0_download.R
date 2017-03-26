library(tidyverse)
library(stringr)
library(feather)

dir.create("data-raw", showWarnings = FALSE)
dir.create("data-documentation", showWarnings = FALSE)
dir.create("data-raw/hpd_litigation", showWarnings = FALSE)

# Download Documentation --------------------------------------------------

download.file("http://www1.nyc.gov/assets/hpd/downloads/pdf/LitigationOpenDataDoc.zip", 
              "data-documentation/LitigationOpenDataDoc.zip", mode = "wb", quiet = TRUE)

unzip("data-documentation/LitigationOpenDataDoc.zip", exdir = "data-documentation")

# Delete xsd and zip files
dir("data-documentation", pattern = "\\.(xsd|zip)$", full.names = TRUE) %>% file.remove()

# Download Data -----------------------------------------------------------

download.file("https://data.cityofnewyork.us/api/views/59kj-x8nc/rows.csv?accessType=DOWNLOAD",
              "data-raw/hpd_litigation/hpd_litigation.csv", method = "curl", quiet = TRUE)
