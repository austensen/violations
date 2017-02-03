library(tidyverse) 
library(magrittr)
library(stringr)
library(rvest)
library(here) 

dir.create(here("data-raw"), showWarnings = FALSE)
dir.create(here("data-raw", "documentation"), showWarnings = FALSE)
dir.create(here("data-raw", "charges"), showWarnings = FALSE)


# Documentation Files -----------------------------------------------------

download.file("http://www1.nyc.gov/assets/hpd/downloads/pdf/ChargesOpenDataDoc.zip", 
              here("data-raw", "documentation", "ChargesOpenDataDoc.zip"), mode = "wb", quiet = TRUE)

unzip(here("data-raw", "documentation", "ChargesOpenDataDoc.zip"), exdir = here("data-raw", "documentation"))

# Delete xsd and zip files
here("data-raw", "documentation") %>%
  dir(pattern = "\\.(xsd|zip)$", full.names = TRUE) %>% 
  file.remove()

# Data Files --------------------------------------------------------------

data_urls <- read_html("http://www1.nyc.gov/site/hpd/about/charges-open-data.page") %>% 
  html_nodes(".about-description ul li a") %>% 
  html_attr("href") %>% 
  xml2::url_absolute("http://www1.nyc.gov/") %>% 
  str_replace_all("Complaints|Buildings", "Charges") # Correct incorrect links in some months 

download_charges <- function(url) {
  filename <- str_extract(url, "Charges*\\d{8}")
  
  dir.create(here("data-raw", "charges"), showWarnings = FALSE)
  
  download.file(url, here("data-raw", "charges", str_c(filename, ".zip")), mode = "wb", quiet = TRUE)
  
  unzip(here("data-raw", "charges", str_c(filename, ".zip")), exdir = here("data-raw", "charges"))
}

walk(data_urls, download_charges)

# Delete xml and zip files
here("data-raw", "charges") %>%
  dir(pattern = "\\.(xml|zip)$", full.names = TRUE) %>% 
  file.remove()
