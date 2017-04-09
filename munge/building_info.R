library(tidyverse)
library(stringr)
library(feather)

dir.create("data", showWarnings = FALSE)

rpad <- read_feather("data-raw/dof_rpad/rpad_15.feather")
pluto <- read_feather("data-raw/dcp_pluto/pluto_16.feather")

# consolidate pluto/rpad variables were overlap, fill out missing tract IDs
building_info_filtered <- full_join(rpad, pluto, by = "bbl", suffix = c("_rpad", "_pluto")) %>% 
  mutate(block = str_sub(bbl, 1, 6),
         cd = if_else(is.na(cd_pluto), cd_rpad, cd_pluto),
         building_class = if_else(is.na(building_class_pluto), building_class_rpad, building_class_pluto),
         floors = pmax(floors_pluto, floors_rpad, na.rm = TRUE),
         buildings = pmax(buildings_pluto, buildings_rpad, na.rm = TRUE),
         res_units = pmax(res_units_pluto, res_units_rpad, na.rm = TRUE),
         other_units = pmax(other_units_pluto, other_units_rpad, na.rm = TRUE),
         avg_res_unit_sqft = res_sqft / res_units,
         last_reno = pmax(year_built_pluto, year_built_rpad, na.rm = TRUE),
         last_reno = pmax(year_reno_pluto, year_reno_rpad, na.rm = TRUE),
         zoning1 = str_sub(zoning, 1, 1),
         building_class1 = str_sub(building_class, 1, 1)) %>%
  group_by(block) %>% 
  mutate(tract10 = max(tract10, na.rm = TRUE)) %>% 
  ungroup %>% 
  select(-matches("rpad|pluto$")) %>% 
  filter( # remove vacant land, city-owned, single-family, coops, condos (imperfect, but better than nothing)
    res_units >= 3,
    str_sub(tax_class, 1, 1) %in% 1:2,
    tax_class != "1B",
    !owner_type %in% c("C", "M", "O"),
    !building_class1 %in% c("A","Z","G","V"),
    !building_class %in% c("C6","C8","D0","D4","R0","R1","R2","R3","R4","R5","R6","R7","R8","R9")
  )

message("warnings are just cases where tract10 is missing for all bbls in block, that's okay")

bbl_tract10_units <- building_info_filtered %>% 
  select(bbl, tract10, res_units) %>% 
  group_by(tract10) %>% 
  mutate(tract_res_units = sum(res_units, na.rm = TRUE),
         tract_res_units = if_else(is.na(tract10), NA_integer_, tract_res_units)) %>% 
  ungroup

building_info <- building_info_filtered %>% 
  select(-tract10, -block, -tax_class, -zoning, -building_class, -owner_type)

write_feather(building_info, "data/building_info.feather")
write_feather(bbl_tract10_units, "data/bbl_tract10_units.feather")
