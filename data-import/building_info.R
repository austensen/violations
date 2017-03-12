library(tidyverse)
library(stringr)
library(feather)

dir.create("data", showWarnings = FALSE)

rpad <- read_feather("data-raw/dof_rpad/rpad_15.feather")
pluto <- read_feather("data-raw/dcp_pluto/pluto_16.feather")

building_info <- full_join(rpad, pluto, by = "bbl", suffix = c("_rpad", "_pluto")) %>% 
  mutate(block = str_sub(bbl, 1, 6),
         cd = if_else(is.na(cd_pluto), cd_rpad, cd_pluto),
         building_class = if_else(is.na(building_class_pluto), building_class_rpad, building_class_pluto),
         floors = pmax(floors_pluto, floors_rpad, na.rm = TRUE),
         buildings = pmax(buildings_pluto, buildings_rpad, na.rm = TRUE),
         res_units = pmax(res_units_pluto, res_units_rpad, na.rm = TRUE),
         other_units = pmax(other_units_pluto, other_units_rpad, na.rm = TRUE),
         avg_res_unit_sqft = res_sqft / res_units,
         year_built = pmax(year_built_pluto, year_built_rpad, na.rm = TRUE),
         year_built = pmax(year_reno_pluto, year_reno_rpad, na.rm = TRUE)) %>% 
  group_by(block) %>% 
  mutate(tract10 = max(tract10, na.rm = TRUE)) %>% 
  ungroup %>% 
  select(-matches("rpad|pluto$"))
  # warnings are just cases where tract10 is missing for all bbls in block, that's okay

# Create block-tract xwalk since blocks always nest in tracts, and there are fewer missing tracts by block
block_tract10_xwalk <- building_info %>% 
  filter(!is.na(tract10)) %>% 
  select(block, tract10) %>% 
  group_by(block) %>% 
  slice(1) %>% 
  ungroup

write_feather(building_info, "data/building_info.feather")
write_feather(block_tract10_xwalk, "data-raw/crosswalks/block_tract10_xwalk.feather")
