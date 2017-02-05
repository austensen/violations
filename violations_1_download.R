library(tidyverse) 
library(magrittr)
library(stringr)
library(rvest)
library(here) 

source(here("functions", "download_files.R"))

dir.create(here("data-raw"), showWarnings = FALSE)
dir.create(here("data-raw", "documentation"), showWarnings = FALSE)
dir.create(here("data-raw", "violations"), showWarnings = FALSE)


# Documentation Files -----------------------------------------------------

download.file("http://www1.nyc.gov/assets/hpd/downloads/misc/ViolationsOpenDataDoc.zip", 
              here("data-raw", "documentation", "ViolationsOpenDataDoc.zip"), mode = "wb", quiet = TRUE)

unzip(here("data-raw", "documentation", "ViolationsOpenDataDoc.zip"), exdir = here("data-raw", "documentation"))

file.rename(here("data-raw", "documentation", "ViolationsOpenDataDoc", "HPD Violation Open Data.pdf"),
            here("data-raw", "documentation", "HPD Violation Open Data.pdf"))


# Delete all fies in unwanted subdirectory, then the subdirectory itself
here("data-raw", "documentation", "ViolationsOpenDataDoc") %>%
  dir(full.names = TRUE) %>% 
  file.remove()

file.remove(here("data-raw", "documentation", "ViolationsOpenDataDoc"))

# Data Files --------------------------------------------------------------

data_urls <- read_html("http://www1.nyc.gov/site/hpd/about/violation-open-data.page") %>% 
  html_nodes(".about-description ul li a") %>% 
  html_attr("href") %>% 
  xml2::url_absolute("http://www1.nyc.gov/") %>% 
  str_sort(decreasing = TRUE)

# There is one file where the name uses "Violation" not "Violations", the one linked to is valid

walk(data_urls, download_files, filename = "Violation", outdir = here("data-raw", "violations"))

# Delete xml and zip files
here("data-raw", "violations") %>%
  dir(pattern = "\\.(xml|zip)$", full.names = TRUE) %>% 
  file.remove()
