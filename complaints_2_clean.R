library(tidyverse) 
library(magrittr)
library(stringr)

source("functions/read_files.R")

complaint_cols <- cols(
  ComplaintID = col_integer(),
  BuildingID = col_integer(),
  BoroughID = col_integer(),
  Borough = col_character(),
  HouseNumber = col_character(),
  StreetName = col_character(),
  Zip = col_integer(),
  Block = col_integer(),
  Lot = col_integer(),
  Apartment = col_character(),
  CommunityBoard = col_integer(),
  ReceivedDate = col_date("%m/%d/%Y"),
  StatusID = col_integer(),
  Status = col_character(),
  StatusDate = col_date("%m/%d/%Y")
)

problem_cols <- cols(
  ProblemID = col_integer(),
  ComplaintID = col_integer(),
  UnitTypeID = col_integer(),
  UnitType = col_character(),
  SpaceTypeID = col_integer(),
  SpaceType = col_character(),
  TypeID = col_integer(),
  Type = col_character(),
  MajorCategoryID = col_integer(),
  MajorCategory = col_character(),
  MinorCategoryID = col_integer(),
  MinorCategory = col_character(),
  CodeID = col_integer(),
  Code = col_character(),
  StatusID = col_integer(),
  Status = col_character(),
  StatusDate = col_date("%m/%d/%Y"),
  StatusDescription = col_character()
)

# read in and stack all files

complaints <- read_files("data-raw/complaints", "Complaint", complaint_cols, months = 13)
problems <- read_files("data-raw/complaints", "Problem", problem_cols, months = 13)

complaints_problems <- full_join(complaints, problems, by = c("ComplaintID", "StatusID", "Status", "StatusDate"))
