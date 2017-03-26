library(tidyverse)
library(stringr)
library(feather)

dir.create("data-raw", showWarnings = FALSE)
dir.create("data-documentation", showWarnings = FALSE)
dir.create("data-raw/hpd_complaints", showWarnings = FALSE)

# Download Documentation --------------------------------------------------

download.file("http://www1.nyc.gov/assets/hpd/downloads/pdf/ComplaintsOpenDataDoc.zip", 
              "data-documentation/ComplaintsOpenDataDoc.zip", mode = "wb", quiet = TRUE)

unzip("data-documentation/ComplaintsOpenDataDoc.zip", exdir = "data-documentation")

# Delete xsd and zip files
dir("data-documentation", pattern = "\\.(xsd|zip)$", full.names = TRUE) %>% file.remove()

# Download Data -----------------------------------------------------------

download.file("https://data.cityofnewyork.us/api/views/uwyv-629c/rows.csv?accessType=DOWNLOAD",
              "data-raw/hpd_complaints/hpd_complaints.csv", method = "curl", quiet = TRUE)

download.file("https://data.cityofnewyork.us/api/views/a2nx-4u46/rows.csv?accessType=DOWNLOAD",
              "data-raw/hpd_complaints/hpd_problems.csv", method = "curl", quiet = TRUE)
