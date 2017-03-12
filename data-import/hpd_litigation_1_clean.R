library(tidyverse)
library(stringr)
library(feather)

dir.create("data", showWarnings = FALSE)

# Import Raw, Clean, Reshape wide by year ---------------------------------

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

lit_raw <- read_csv("data-raw/hpd_litigation/hpd_litigation.csv", col_types = litigation_cols)

lit_wide <- lit_raw %>% 
  mutate(bbl = str_c(BoroID, str_pad(Block, 5, "left", "0"), str_pad(Lot, 4, "left", "0")),
         year = lubridate::year(CaseOpenDate)) %>% 
  filter(year %in% 2013:2016) %>% 
  group_by(bbl, year) %>% 
  summarise(litigation = n()) %>% 
  ungroup %>%
  spread(year, litigation, fill = 0)

names(lit_wide) <- names(lit_wide) %>% str_replace("(^\\d{4})$", "lit_\\1")

write_feather(lit_wide, "data/hpd_litigation.feather")
