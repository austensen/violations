library(tidyverse) 
library(magrittr)
library(stringr)
library(here) 

source(here("functions", "read_files.R"))

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

# read in and stack all files
litigations <- read_files(here("data-raw", "litigation"), "Litigation", litigation_cols, months = 13)
