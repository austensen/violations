library(tidyverse) 
library(magrittr)
library(stringr)
library(rvest)
library(here) 

source(here("functions", "download_files.R"))

dir.create(here("data-raw"), showWarnings = FALSE)
dir.create(here("data-raw", "documentation"), showWarnings = FALSE)
dir.create(here("data-raw", "complaints"), showWarnings = FALSE)


# Documentation Files -----------------------------------------------------

download.file("http://www1.nyc.gov/assets/hpd/downloads/pdf/ComplaintsOpenDataDoc.zip", 
              here("data-raw", "documentation", "ComplaintsOpenDataDoc.zip"), mode = "wb", quiet = TRUE)

unzip(here("data-raw", "documentation", "ComplaintsOpenDataDoc.zip"), exdir = here("data-raw", "documentation"))

# Delete xsd and zip files
here("data-raw", "documentation") %>%
  dir(pattern = "\\.(xsd|zip)$", full.names = TRUE) %>% 
  file.remove()


# Data Files --------------------------------------------------------------

data_urls <- read_html("http://www1.nyc.gov/site/hpd/about/Complaints-open-data.page") %>% 
  html_nodes(".about-description ul li a") %>% 
  html_attr("href") %>% 
  xml2::url_absolute("http://www1.nyc.gov/")

walk(data_urls, download_files, filename = "Complaints", outdir = here("data-raw", "complaints"))

# Delete xml and zip files
here("data-raw", "complaints") %>%
  dir(pattern = "\\.(xml|zip)$", full.names = TRUE) %>% 
  file.remove()
