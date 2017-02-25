library(tidyverse)
library(stringr)
library(feather)

dir.create("data", showWarnings = FALSE)

rpad <- read_feather("data-raw/dof_rpad/rpad_15.feather")
pluto <- read_feather("data-raw/dcp_pluto/pluto_16.feather")

building_info <- full_join(rpad, pluto, by = "bbl", suffix = c("_rpad", "_pluto")) %>% 
  mutate(cd = if_else(is.na(cd_pluto), cd_rpad, cd_pluto),
         building_class = if_else(is.na(building_class_pluto), building_class_rpad, building_class_pluto),
         floors = pmax(floors_pluto, floors_rpad, na.rm = TRUE),
         buildings = pmax(buildings_pluto, buildings_rpad, na.rm = TRUE),
         res_units = pmax(res_units_pluto, res_units_rpad, na.rm = TRUE),
         other_units = pmax(other_units_pluto, other_units_rpad, na.rm = TRUE),
         avg_res_unit_sqft = res_sqft / res_units,
         year_built = pmax(year_built_pluto, year_built_rpad, na.rm = TRUE),
         year_built = pmax(year_reno_pluto, year_reno_rpad, na.rm = TRUE)) %>% 
  select(-matches("rpad|pluto$"))

viol <- read_feather("data-raw/hpd_violations/hpd_violations.feather")
lit <- read_feather("data-raw/hpd_litigation/hpd_litigation.feather")

df <- building_info %>% 
  left_join(viol, by = "bbl") %>% 
  left_join(lit, by = "bbl") %>% 
  mutate_at(vars(matches("\\d{4}$")), funs(if_else(is.na(.), 0, .)))

write_feather(df, "data/merged.feather")


