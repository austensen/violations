library(tidyverse)
library(feather)
library(stringr)

dir.create("data", showWarnings = FALSE)

# Import Raw and Clean ----------------------------------------------------

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

viol_raw <- read_csv("data-raw/hpd_violations/hpd_violations.csv", col_types = violation_cols)

block_tract10_xwalk <- read_feather("data-raw/crosswalks/block_tract10_xwalk.feather")

bbl_viol <- viol_raw %>% 
  janitor::clean_names() %>% 
  filter(lubridate::year(inspectiondate) %in% 2013:2016) %>% 
  mutate(bbl = str_c(boroid, str_pad(block, 5, "left", "0"), str_pad(lot, 4, "left", "0")),
         block = str_sub(bbl, 1, 6),
         year = lubridate::year(inspectiondate),
         scope = if_else(is.na(apartment), "bldg", "apt"),
         class = if_else(class == "C", "ser", "oth")) %>% 
  left_join(block_tract10_xwalk, by = "block") %>% 
  group_by(tract10, block, bbl, year, class, scope) %>% 
  summarise(violations = n()) %>% 
  mutate(geo = "bbl") %>% 
  ungroup

block_viol <- bbl_viol %>% 
  group_by(block, year, class, scope) %>% 
  summarise(violations = n()) %>% 
  mutate(geo = "blk") %>% 
  ungroup

tract_viol <- bbl_viol %>% 
  filter(!is.na(tract10)) %>% 
  group_by(tract10, year, class, scope) %>% 
  summarise(violations = n()) %>% 
  mutate(geo = "trct") %>% 
  ungroup

reshape_wide <- function(.data, geo_type) {
  .data %>% 
    mutate(geo_scope_class_year = str_c("viol", geo, scope, class, year, sep = "_")) %>% 
    select_(.dots = c(geo_type, "geo_scope_class_year", "violations")) %>% 
    spread(geo_scope_class_year, violations, fill = 0)
}

bbl_viol_wide <- reshape_wide(bbl_viol, "bbl")
block_viol_wide <- reshape_wide(block_viol, "block")
tract_viol_wide <- reshape_wide(tract_viol, "tract10")

all_viol_wide <- bbl_viol_wide %>% 
  mutate(block = str_sub(bbl, 1, 6)) %>% 
  left_join(block_tract10_xwalk, by = "block") %>% 
  left_join(block_viol_wide, by = "block") %>% 
  left_join(tract_viol_wide, by = "tract10") %>% 
  select(-block, -tract10)


write_feather(all_viol_wide, "data/hpd_violations.feather")
