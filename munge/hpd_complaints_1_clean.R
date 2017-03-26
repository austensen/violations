library(tidyverse)
library(feather)
library(stringr)

dir.create("data", showWarnings = FALSE)

# Import Raw and Clean ----------------------------------------------------

complaint_cols <- cols_only(
  ComplaintID = col_character(),
  # BuildingID = col_character(),
  BoroughID = col_integer(),
  # Borough = col_character(),
  # HouseNumber = col_character(),
  # StreetName = col_character(),
  # Zip = col_integer(),
  Block = col_integer(),
  Lot = col_integer(),
  # Apartment = col_character(),
  # CommunityBoard = col_integer(),
  ReceivedDate = col_date("%m/%d/%Y")
  # StatusID = col_integer(),
  # Status = col_character(),
  # StatusDate = col_date("%m/%d/%Y")
)

problem_cols <- cols_only(
  ProblemID = col_character(),
  ComplaintID = col_character(),
  # UnitTypeID = col_integer(),
  UnitType = col_character(),
  # SpaceTypeID = col_integer(),
  # SpaceType = col_character(),
  # TypeID = col_integer(),
  Type = col_character()
  # MajorCategoryID = col_integer(),
  # MajorCategory = col_character(),
  # MinorCategoryID = col_integer(),
  # MinorCategory = col_character(),
  # CodeID = col_integer(),
  # Code = col_character(),
  # StatusID = col_integer(),
  # Status = col_character(),
  # StatusDate = col_character(),
  # StatusDescription = col_character()
)

problems <- read_csv("data-raw/hpd_complaints/hpd_problems.csv", col_types = problem_cols)

complaints <- read_csv("data-raw/hpd_complaints/hpd_complaints.csv", col_types = complaint_cols)

bbl_tract10_units <- read_feather("data/bbl_tract10_units.feather")


bbl_comp <- complaints %>% 
  inner_join(problems, by = "ComplaintID") %>% 
  mutate(bbl = str_c(BoroughID, str_pad(Block, 5, "left", "0"), str_pad(Lot, 4, "left", "0")),
         year = lubridate::year(ReceivedDate),
         space = if_else(UnitType == "APARTMENT", "apt", "bldg")) %>% 
  filter(str_detect(Type, "EMERGENCY"),
         year %in% 2014:2015) %>% 
  group_by(bbl, year, space) %>% 
  summarise(complaints = n()) %>% 
  ungroup




adj_bbl_comp <- bbl_comp %>% 
  inner_join(bbl_tract10_units, by = "bbl") %>% 
  mutate(adj_bbl_comp = if_else(space == "apt", complaints / res_units, as.double(complaints))) %>% 
  group_by(bbl, tract10, year) %>% 
  summarise(adj_comp = sum(adj_bbl_comp)) %>% 
  mutate(geo = "bbl") %>% 
  ungroup


adj_bbl_comp_wide <- adj_bbl_comp %>% 
  mutate(geo_year = str_c("comp", geo, year, sep = "_")) %>% 
  select(bbl, tract10, geo_year, adj_comp) %>% 
  spread(geo_year, adj_comp, fill = 0)

adj_tract_comp <- bbl_comp %>% 
  inner_join(bbl_tract10_units, by = "bbl") %>% 
  group_by(tract10, tract_res_units, year, space) %>% 
  mutate(complaints = if_else(space == "bldg", complaints * res_units, complaints)) %>% 
  summarise(complaints = n()) %>% 
  mutate(adj_tract_comp = complaints / tract_res_units) %>% 
  group_by(tract10, year) %>% 
  summarise(adj_comp = sum(adj_tract_comp)) %>% 
  mutate(geo = "trct") %>% 
  ungroup

adj_tract_comp_wide <- adj_tract_comp %>% 
  mutate(geo_year = str_c("comp", geo, year, sep = "_")) %>% 
  select(tract10, geo_year, adj_comp) %>% 
  spread(geo_year, adj_comp, fill = 0)

adj_all_comp_wide <- adj_bbl_comp_wide %>% 
  left_join(adj_tract_comp_wide, by = "tract10") %>% 
  select(-tract10)


write_feather(adj_all_comp_wide, "data/hpd_complaints.feather")

