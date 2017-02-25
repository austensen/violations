library(tidyverse)
library(stringr)
library(feather)

dir.create("../data-raw", showWarnings = FALSE)
dir.create("../data-documentation", showWarnings = FALSE)
dir.create("../data-raw/hpd_litigation", showWarnings = FALSE)

# Download Documentation --------------------------------------------------

download.file("http://www1.nyc.gov/assets/hpd/downloads/pdf/LitigationOpenDataDoc.zip", 
              "../data-documentation/LitigationOpenDataDoc.zip", mode = "wb", quiet = TRUE)

unzip("../data-documentation/LitigationOpenDataDoc.zip", exdir = "../data-documentation")

# Download Data -----------------------------------------------------------

download.file("https://data.cityofnewyork.us/api/views/59kj-x8nc/rows.csv?accessType=DOWNLOAD",
              str_interp("../data-raw/hpd_litigation/hpd_litigation.csv"), method = "curl", quiet = TRUE)

# Clean Litigations -------------------------------------------------------

litigation_cols <- cols(
  LitigationID = col_integer(),
  BuildingID = col_integer(),
  BoroID = col_integer(),
  Boro = col_character(),
  HouseNumber = col_character(),
  StreetName = col_character(),
  Zip = col_integer(),
  Block = col_integer(),
  Lot = col_integer(),
  CaseType = col_character(),
  CaseOpenDate = col_date("%m/%d/%Y"),
  CaseStatus = col_character(),
  CaseJudgement = col_character()
)

lit_raw <- read_csv("../data-raw/hpd_litigation/hpd_litigation.csv", col_types = litigation_cols)

case_type_codes <- tibble(case_type = unique(lit_raw$CaseType)) %>% mutate(type_code = row_number())

lit_clean <- lit_raw %>% 
  mutate(bbl = str_c(BoroID, str_pad(Block, 5, "left", "0"), str_pad(Lot, 4, "left", "0")),
         year = lubridate::year(CaseOpenDate)) %>% 
  filter(year %in% 2013:2016) %>% 
  left_join(case_type_codes, by = c("CaseType" = "case_type")) %>% 
  group_by(bbl, type_code, year) %>% 
  summarise(litigation = n()) %>% 
  ungroup %>%
  mutate(type_year = str_c("lit", type_code, year, sep = "_")) %>% 
  select(-type_code, -year) %>% 
  filter(!is.na(type_year)) %>% 
  spread(type_year, litigation, fill = 0) 

write_feather(lit_clean, "../data-raw/hpd_litigation/hpd_litigation.feather")
