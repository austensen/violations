library(tidyverse) 
library(magrittr)
library(stringr)
library(here) 

source(here("functions", "read_files.R"))

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

# read in and stack all files
violations <- read_files(here("data-raw", "violations"), "Violation", violation_cols, months = 13)
