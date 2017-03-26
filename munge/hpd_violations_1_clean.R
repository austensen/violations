library(tidyverse)
library(feather)
library(stringr)

dir.create("data", showWarnings = FALSE)

# Import Raw and Clean ----------------------------------------------------

violation_cols <- cols_only(
  # ViolationID = col_integer(),
  # BuildingID = col_integer(),
  # RegistrationID = col_integer(),
  BoroID = col_integer(),
  # Boro = col_character(),
  # HouseNumber = col_character(),
  # LowHouseNumber = col_character(),
  # HighHouseNumber = col_character(),
  # StreetName = col_character(),
  # StreetCode = col_integer(),
  # Zip = col_integer(),
  Apartment = col_character(),
  # Story = col_character(),
  Block = col_integer(),
  Lot = col_integer(),
  Class = col_character(),
  InspectionDate = col_date("%m/%d/%Y")
  # ApprovedDate = col_date("%m/%d/%Y"),
  # OriginalCertifyByDate = col_date("%m/%d/%Y"),
  # OriginalCorrectByDate = col_date("%m/%d/%Y"),
  # NewCertifyByDate = col_date("%m/%d/%Y"),
  # NewCorrectByDate = col_date("%m/%d/%Y"),
  # CertifiedDate = col_date("%m/%d/%Y"),
  # OrderNumber = col_character(),
  # NOVID = col_integer(),
  # NOVDescription = col_character(),
  # NOVIssuedDate = col_date("%m/%d/%Y"),
  # CurrentStatusID = col_integer(),
  # CurrentStatus = col_character(),
  # CurrentStatusDate = col_date("%m/%d/%Y")
)

viol_raw <- read_csv("data-raw/hpd_violations/hpd_violations.csv", col_types = violation_cols)

bbl_tract10_units <- read_feather("data/bbl_tract10_units.feather")

# Violation adjustments:
  # bbl viols = bldg + (apt / bbl_units)
  # tract viols = ((bldg * bbl_units) + apt ) / tract_units

bbl_viol <- viol_raw %>% 
  filter(lubridate::year(InspectionDate) %in% 2013:2016) %>% 
  mutate(bbl = str_c(BoroID, str_pad(Block, 5, "left", "0"), str_pad(Lot, 4, "left", "0")),
         year = lubridate::year(InspectionDate),
         space = if_else(is.na(Apartment), "bldg", "apt"),
         class = if_else(Class == "C", "ser", "oth")) %>% 
  group_by(bbl, year, class, space) %>% 
  summarise(violations = n())


adj_bbl_viol <- bbl_viol %>% 
  inner_join(bbl_tract10_units, by = "bbl") %>% 
  mutate(adj_bbl_viol = if_else(space == "apt", violations / res_units, as.double(violations))) %>% 
  group_by(bbl, tract10, year, class) %>% 
  summarise(adj_viol = sum(adj_bbl_viol)) %>% 
  mutate(geo = "bbl") %>% 
  ungroup

adj_bbl_viol_wide <- adj_bbl_viol %>% 
  mutate(geo_class_year = str_c("viol", geo, class, year, sep = "_")) %>% 
  select(bbl, tract10, geo_class_year, adj_viol) %>% 
  spread(geo_class_year, adj_viol, fill = 0)

adj_tract_viol <- bbl_viol %>% 
  filter(class == "ser") %>% 
  inner_join(bbl_tract10_units, by = "bbl") %>% 
  group_by(tract10, tract_res_units, year, space) %>% 
  mutate(violations = if_else(space == "bldg", violations * res_units, violations)) %>% 
  summarise(violations = n()) %>% 
  mutate(adj_tract_viol = violations / tract_res_units) %>% 
  group_by(tract10, year) %>% 
  summarise(adj_viol = sum(adj_tract_viol)) %>% 
  mutate(geo = "trct") %>% 
  ungroup
  
adj_tract_viol_wide <- adj_tract_viol %>% 
  mutate(geo_year = str_c("viol", geo, year, sep = "_")) %>% 
  select(tract10, geo_year, adj_viol) %>% 
  spread(geo_year, adj_viol, fill = 0)

adj_all_viol_wide <- adj_bbl_viol_wide %>% 
  left_join(adj_tract_viol_wide, by = "tract10") %>% 
  select(-tract10)


write_feather(adj_all_viol_wide, "data/hpd_violations.feather")

# Make tract-level wide counts of violatiosn for mapping
tract_viol_map <- adj_tract_viol_wide %>% 
  mutate_at(vars(-tract10), funs(. * 1000))

write_feather(tract_viol_map, "data/hpd_violations_map_data.feather")
