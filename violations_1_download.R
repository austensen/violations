library(tidyverse) 
library(magrittr)
library(stringr)
library(rvest)
library(here) 

source("functionsdownload_files.R")

dir.create("data-raw", showWarnings = FALSE)
dir.create("data-rawdocumentation", showWarnings = FALSE)
dir.create("data-rawviolations", showWarnings = FALSE)


# Documentation Files -----------------------------------------------------

download.file("http://www1.nyc.gov/assets/hpd/downloads/misc/ViolationsOpenDataDoc.zip", 
              "data-raw/documentation/ViolationsOpenDataDoc.zip", mode = "wb", quiet = TRUE)

unzip("data-raw/documentation/ViolationsOpenDataDoc.zip", exdir = "data-raw/documentation")

file.rename("data-raw/documentation/ViolationsOpenDataDoc/HPD Violation Open Data.pdf",
            "data-raw/documentation/HPD Violation Open Data.pdf")


# Delete all fies in unwanted subdirectory, then the subdirectory itself
dir("data-raw/documentation/ViolationsOpenDataDoc", full.names = TRUE) %>% file.remove()

file.remove("data-raw/documentation/ViolationsOpenDataDoc")

# Data Files --------------------------------------------------------------

data_urls <- read_html("http://www1.nyc.gov/site/hpd/about/violation-open-data.page") %>% 
  html_nodes(".about-description ul li a") %>% 
  html_attr("href") %>% 
  xml2::url_absolute("http://www1.nyc.gov/") %>% 
  str_sort(decreasing = TRUE)

# There is one file where the name uses "Violation" not "Violations", the one linked to is valid

walk(data_urls, download_files, filename = "Violation", outdir = "data-raw/violations")

# Delete xml and zip files
dir("data-raw/violations", pattern = "\\.(xml|zip)$", full.names = TRUE) %>% file.remove()
