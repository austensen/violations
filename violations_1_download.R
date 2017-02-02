library(tidyverse) 
library(magrittr)
library(stringr)
library(rvest)
library(here) 

dir.create(here("data-raw"), showWarnings = FALSE)
dir.create(here("data-raw", "violations"), showWarnings = FALSE)

data_urls <- read_html("http://www1.nyc.gov/site/hpd/about/violation-open-data.page") %>% 
  html_nodes(".about-description ul li a") %>% 
  html_attr("href") %>% 
  xml2::url_absolute("http://www1.nyc.gov/") %>% 
  extract(1:12) # for now just getting most recent year

# There are some inconsistencies (errors?) in the naming, "violations" is not plural in one month
# The names of the internal files are not the same as the zip files (dates differ)

download_violations <- function(url) {
  filename <- str_extract(url, "Violations*\\d{8}")
  
  dir.create(here("data-raw", "violations"), showWarnings = FALSE)
  
  download.file(url, here("data-raw", "violations", str_c(filename, ".zip")), mode = "wb", quiet = TRUE)
  
  unzip(here("data-raw", "violations", str_c(filename, ".zip")), exdir = here("data-raw", "violations"))
}

walk(data_urls[1:2], download_violations)

# Delete xml files
here("data-raw", "violations") %>% 
  list.files(pattern = "\\.xml$", full.names = TRUE) %>% 
  file.remove()
