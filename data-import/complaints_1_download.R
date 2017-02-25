library(tidyverse) 
library(magrittr)
library(stringr)
library(rvest)

source("functions/download_files.R")

dir.create("data-raw", showWarnings = FALSE)
dir.create("data-raw/documentation", showWarnings = FALSE)
dir.create("data-raw/complaints", showWarnings = FALSE)


# Documentation Files -----------------------------------------------------

download.file("http://www1.nyc.gov/assets/hpd/downloads/pdf/ComplaintsOpenDataDoc.zip", 
              "data-raw/documentation", "ComplaintsOpenDataDoc.zip", mode = "wb", quiet = TRUE)

unzip("data-raw/documentation/ComplaintsOpenDataDoc.zip", exdir = "data-raw/documentation")

# Delete xsd and zip files
dir("data-raw/documentation", pattern = "\\.(xsd|zip)$", full.names = TRUE) %>% file.remove()


# Data Files --------------------------------------------------------------

data_urls <- read_html("http://www1.nyc.gov/site/hpd/about/Complaints-open-data.page") %>% 
  html_nodes(".about-description ul li a") %>% 
  html_attr("href") %>% 
  xml2::url_absolute("http://www1.nyc.gov/")

walk(data_urls, download_files, filename = "Complaints", outdir = "data-raw/complaints")

# Delete xml and zip files
dir("data-raw/complaints", pattern = "\\.(xml|zip)$", full.names = TRUE) %>% file.remove()
