library(tidyverse)
library(feather)
library(stringr)

dir.create("data-raw", showWarnings = FALSE)
dir.create("data-documentation", showWarnings = FALSE)
dir.create("data-raw/hpd_violations", showWarnings = FALSE)

# Download Documentation --------------------------------------------------

download.file("http://www1.nyc.gov/assets/hpd/downloads/misc/ViolationsOpenDataDoc.zip", 
              "data-documentation/ViolationsOpenDataDoc.zip", mode = "wb", quiet = TRUE)

unzip("data-documentation/ViolationsOpenDataDoc.zip", exdir = "data-documentation")

file.rename("data-documentation/ViolationsOpenDataDoc/HPD Violation Open Data.pdf",
            "data-documentation/HPD Violation Open Data.pdf")

download.file("https://www1.nyc.gov/assets/buildings/pdf/HousingMaintenanceCode.pdf",
              "data-documentation/HousingMaintenanceCode.pdf", mode = "wb", quiet = TRUE)

# Delete all fies in unwanted subdirectory, then the subdirectory itself 
dir("data-documentation/ViolationsOpenDataDoc", full.names = TRUE) %>% file.remove() 

file.remove("data-raw/documentation/ViolationsOpenDataDoc") 

# Download Data -----------------------------------------------------------

download.file("https://data.cityofnewyork.us/api/views/wvxf-dwi5/rows.csv?accessType=DOWNLOAD",
              str_interp("data-raw/hpd_violations/hpd_violations.csv"), mode = "wb", quiet = TRUE)


# Import and Clean --------------------------------------------------------


violation_cols <- cols(
  ViolationID = col_integer(),
  BuildingID = col_integer(),
  RegistrationID = col_integer(),
  BoroID = col_integer(),
  Boro = col_character(),
  HouseNumber = col_character(),
  LowHouseNumber = col_character(),
  HighHouseNumber = col_character(),
  StreetName = col_character(),
  StreetCode = col_integer(),
  Zip = col_integer(),
  Apartment = col_character(),
  Story = col_character(),
  Block = col_integer(),
  Lot = col_integer(),
  Class = col_character(),
  InspectionDate = col_date("%m/%d/%Y"),
  ApprovedDate = col_date("%m/%d/%Y"),
  OriginalCertifyByDate = col_date("%m/%d/%Y"),
  OriginalCorrectByDate = col_date("%m/%d/%Y"),
  NewCertifyByDate = col_date("%m/%d/%Y"),
  NewCorrectByDate = col_date("%m/%d/%Y"),
  CertifiedDate = col_date("%m/%d/%Y"),
  OrderNumber = col_character(),
  NOVID = col_integer(),
  NOVDescription = col_character(),
  NOVIssuedDate = col_date("%m/%d/%Y"),
  CurrentStatusID = col_integer(),
  CurrentStatus = col_character(),
  CurrentStatusDate = col_date("%m/%d/%Y")
)

viol <- read_csv("data-raw/hpd_violations/hpd_violations.csv", col_types = violation_cols) %>% 
  janitor::clean_names() %>% 
  filter(lubridate::year(inspectiondate) %in% 2013:2016) %>% 
  mutate(bbl = str_c(boroid, str_pad(block, 5, "left", "0"), str_pad(lot, 4, "left", "0")),
         year = lubridate::year(inspectiondate),
         scope = if_else(is.na(apartment), "bldg", "apt"),
         class = str_to_lower(class)) %>% 
  group_by(bbl, year, class, scope) %>% 
  summarise(violations = n()) %>% 
  ungroup %>% 
  mutate(scope_class_year = str_c("viol", scope, class, year, sep = "_")) %>% 
  select(bbl, scope_class_year, violations) %>% 
  spread(scope_class_year, violations, fill = 0)


write_feather(viol, "data-raw/hpd_violations/hpd_violations.feather")
