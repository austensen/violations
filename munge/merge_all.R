library(tidyverse)
library(stringr)
library(feather)

building_info <- read_feather("data/building_info.feather")
viol <- read_feather("data/hpd_violations.feather")
lit <- read_feather("data/hpd_litigation.feather")

df <- building_info %>% 
  left_join(viol, by = "bbl") %>% 
  left_join(lit, by = "bbl") %>%
  mutate_if(is.character, as.factor) %>% 
  ungroup
  
write_feather(df, "data/merged.feather")

zip("data/merged.zip", "data/merged.feather")
