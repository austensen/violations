library(tidyverse)
library(stringr)
library(feather)

dir.create("data", showWarnings = FALSE)

rpad <- read_feather("data-raw/dof_rpad/rpad_15.feather")
pluto <- read_feather("data-raw/dcp_pluto/pluto_16.feather")

building_info_all <- full_join(rpad, pluto, by = "bbl", suffix = c("_rpad", "_pluto")) %>% 
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

# Get counts of all res units by tract for maps
tract_units <- building_info_all %>% 
  filter( # remove vacant land, single-family, coops, condos (this is imperfect, but better than nothing)
    as.numeric(str_sub(tax_class, 1, 1)) < 3,
    tax_class != "1B",
    res_units > 0,
    !str_sub(building_class, 1, 1) %in% c("A","Z","G","V"),
    !building_class %in% c("C6","C8","D0","D4","R0","R1","R2","R3","R4","R5","R6","R7","R8","R9")
  ) %>% 
  group_by(tract10) %>% 
  summarise(res_units = sum(res_units, na.rm = TRUE)) %>% 
  ungroup


# restrict to only 3+ units for prediction modeling
building_info <- building_info_all %>% 
  filter(res_units >= 3) %>% 
  select(-tax_class) %>% 
  mutate(zoning = str_sub(zoning, 1, 1),
         building_class = str_sub(building_class, 1, 1))


# Create block-tract xwalk since blocks always nest in tracts, and there are fewer missing tracts by block
block_tract10_xwalk <- building_info %>% 
  filter(!is.na(tract10)) %>% 
  select(block, tract10) %>% 
  group_by(block) %>% 
  slice(1) %>% 
  ungroup

write_feather(tract_units, "data/tract10_res_units.feather")
write_feather(building_info, "data/building_info.feather")
write_feather(block_tract10_xwalk, "data-raw/crosswalks/block_tract10_xwalk.feather")
