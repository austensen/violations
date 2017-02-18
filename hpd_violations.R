library(tidyverse)
library(feather)
library(stringr)

dir.create("data-raw", showWarnings = FALSE)
dir.create("data-raw/documentation", showWarnings = FALSE)
dir.create("data-raw/hpd_violations", showWarnings = FALSE)

# Download Documentation --------------------------------------------------

download.file("http://www1.nyc.gov/assets/hpd/downloads/misc/ViolationsOpenDataDoc.zip", 
              "data-raw/documentation/ViolationsOpenDataDoc.zip", mode = "wb", quiet = TRUE)

unzip("data-raw/documentation/ViolationsOpenDataDoc.zip", exdir = "data-raw/documentation")

file.rename("data-raw/documentation/ViolationsOpenDataDoc/HPD Violation Open Data.pdf",
            "data-raw/documentation/HPD Violation Open Data.pdf")

download.file("https://www1.nyc.gov/assets/buildings/pdf/HousingMaintenanceCode.pdf",
              "data-raw/documentation/HousingMaintenanceCode.pdf", mode = "wb", quiet = TRUE)

# Delete all fies in unwanted subdirectory, then the subdirectory itself 
dir("data-raw/documentation/ViolationsOpenDataDoc", full.names = TRUE) %>% file.remove() 

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

extract_records <- function(.year, file, path = NULL, date_col, col_specs = NULL) {
  f <- function(x, pos) filter_(x, str_interp("lubridate::year(${col}) == ${.year}"))
  
  df <- readr::read_csv_chunked(file, DataFrameCallback$new(f), chunk_size = 10000, col_types = col_specs)
  
  df %>% 
    mutate(bbl = str_c(BoroID, str_pad(Block, 5, "left", "0"), str_pad(Lot, 4, "left", "0")),
           year = .year) %>% 
    group_by(bbl, Class, year) %>% 
    summarise(violations = n())
}

map_df(2013:2015, extract_records, file = "data-raw/hpd_violations/hpd_violations.csv", 
       date_col = "InspectionDate", col_specs = violation_cols) %>% 
  unite(class_year, Class, year) %>% 
  spread(class_year, violations, fill = 0) %>% 
  write_feather("data-raw/hpd_violations/hpd_violations_13_15.feather")


map_df(2016, extract_records, file = "data-raw/hpd_violations/hpd_violations.csv", 
       date_col = "InspectionDate", col_specs = violation_cols) %>% 
  unite(class_year, Class, year) %>% 
  spread(class_year, violations, fill = 0) %>% 
  write_feather("data-raw/hpd_violations/hpd_violations_16.feather")
