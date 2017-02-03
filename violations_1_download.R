library(tidyverse) 
library(magrittr)
library(stringr)
library(rvest)
library(here) 

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
  xml2::url_absolute("http://www1.nyc.gov/")

# There are some inconsistencies (errors?) in the naming of zip files, "violations" is not plural in one month

download_violations <- function(url) {
  filename <- str_extract(url, "Violations*\\d{8}")
  
  dir.create(here("data-raw", "violations"), showWarnings = FALSE)
  
  download.file(url, here("data-raw", "violations", str_c(filename, ".zip")), mode = "wb", quiet = TRUE)
  
  unzip(here("data-raw", "violations", str_c(filename, ".zip")), exdir = here("data-raw", "violations"))
}

walk(data_urls, download_violations)

# Delete xml and zip files
here("data-raw", "violations") %>%
  dir(pattern = "\\.(xml|zip)$", full.names = TRUE) %>% 
  file.remove()
