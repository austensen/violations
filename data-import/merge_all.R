library(tidyverse)
library(stringr)
library(feather)

building_info <- read_feather("data/building_info.feather")
viol <- read_feather("data/hpd_violations.feather")
lit <- read_feather("data-raw/hpd_litigation/hpd_litigation.feather")

df <- building_info %>% 
  left_join(viol, by = "bbl") %>% 
  # left_join(lit, by = "bbl") %>% 
  mutate_at(vars(matches("\\d{4}$")), funs(if_else(is.na(.), 0, .))) %>% 
  mutate_at(vars(matches("^viol_bbl_apt")), funs(. / res_units)) %>% 
  group_by(block) %>% # adjust block and tract level violation counts by appropirate denominators
  mutate_at(vars(matches("^viol_blk_apt")), funs(. / sum(res_units, na.rm = TRUE))) %>%
  mutate_at(vars(matches("^viol_blk_bldg")), funs(. / n())) %>%
  group_by(tract10) %>% 
  mutate_at(vars(matches("^viol_trct_apt")), funs(. / sum(res_units, na.rm = TRUE))) %>% 
  mutate_at(vars(matches("^viol_trct_bldg")), funs(. / n())) %>%
  ungroup
  
write_feather(df, "data/merged.feather")

zip("data/merged.zip", "data/merged.feather")
