library(tidyverse) 
library(magrittr)
library(stringr)
library(rvest)
library(here) 

source(here("functions", "download_files.R"))

dir.create(here("data-raw"), showWarnings = FALSE)
dir.create(here("data-raw", "documentation"), showWarnings = FALSE)
dir.create(here("data-raw", "litigation"), showWarnings = FALSE)


# Documentation Files -----------------------------------------------------

download.file("http://www1.nyc.gov/assets/hpd/downloads/pdf/LitigationOpenDataDoc.zip", 
              here("data-raw", "documentation", "LitigationOpenDataDoc.zip"), mode = "wb", quiet = TRUE)

unzip(here("data-raw", "documentation", "LitigationOpenDataDoc.zip"), exdir = here("data-raw", "documentation"))

# Delete xsd and zip files
here("data-raw", "documentation") %>%
  dir(pattern = "\\.(xsd|zip)$", full.names = TRUE) %>% 
  file.remove()

# Data Files --------------------------------------------------------------

# Unlike other files, for Charges the most recent months includes _all_ past charges
data_urls <- read_html("http://www1.nyc.gov/site/hpd/about/Litigation-open-data.page") %>% 
  html_nodes(".about-description ul li a") %>% 
  html_attr("href") %>% 
  xml2::url_absolute("http://www1.nyc.gov/") %>% 
  str_sort(decreasing = TRUE) %>% 
  extract(1)

download_files(data_urls, filename = "Litigation", outdir = here("data-raw", "litigation"))

# Delete xml and zip files
here("data-raw", "litigation") %>%
  dir(pattern = "\\.(xml|zip)$", full.names = TRUE) %>% 
  file.remove()
