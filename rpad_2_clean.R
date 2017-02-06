library(tidyverse) 
library(magrittr)
library(stringr)
library(here) 

rpad2 <- here("data-raw", "rpad", "rpad_234_16.csv") %>% 
  read_csv(guess_max = 100000) %>% 
  janitor::clean_names() %>% 
  filter(str_detect(txcl, "2"), is.na(ease), res_unit > 0) %>% 
  mutate(year_reno = pmax(yra1_rng, yra2_rng, na.rm = T),
         cd = (boro * 100) + cp_dist) %>% 
  select(boro, block, lot, cd, res_units = res_unit, year_built = yrb, year_reno, 
         stories = story, buildings = bldgs, gross_sqft = gr_sqft, zoning, building_class = bldgcl)
