library(tidyverse) 
library(magrittr)
library(stringr)
library(rvest)

source("functions/download_files.R"))

dir.create("data-raw", showWarnings = FALSE)
dir.create("data-raw/documentation", showWarnings = FALSE)
dir.create("data-raw/charges", showWarnings = FALSE)


# Documentation Files -----------------------------------------------------

download.file("http://www1.nyc.gov/assets/hpd/downloads/pdf/ChargesOpenDataDoc.zip", 
              "data-raw/documentation/ChargesOpenDataDoc.zip", mode = "wb", quiet = TRUE)

unzip("data-raw/documentation/ChargesOpenDataDoc.zip", exdir = "data-raw/documentation")

# Delete xsd and zip files
dir("data-raw/documentation", pattern = "\\.(xsd|zip)$", full.names = TRUE) %>% file.remove()

# Data Files --------------------------------------------------------------

# Unlike other files, for Charges the most recent months includes _all_ past charges
data_urls <- read_html("http://www1.nyc.gov/site/hpd/about/charges-open-data.page") %>% 
  html_nodes(".about-description ul li a") %>% 
  html_attr("href") %>% 
  xml2::url_absolute("http://www1.nyc.gov/") %>% 
  str_replace("Complaints|Buildings", "Charges") %>% # there are some incorrectly named links in some months 
  str_sort(decreasing = TRUE) %>% 
  extract(1)

download_files(data_urls, filename = "Charges", outdir = "data-raw/charges")

# Delete xml and zip files
dir("data-raw/charges", pattern = "\\.(xml|zip)$", full.names = TRUE) %>% file.remove()
