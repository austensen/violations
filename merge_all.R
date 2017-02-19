library(tidyverse)
library(feather)

dir.create("data", showWarnings = FALSE)

rpad <- read_feather("data-raw/dof_rpad/rpad_15.feather")
viol <- read_feather("data-raw/hpd_violations/hpd_violations.feather")
lit <- read_feather("data-raw/hpd_litigation/hpd_litigation.feather")

df <- rpad %>% 
  left_join(viol, by = "bbl") %>% 
  left_join(lit, by = "bbl") %>% 
  mutate_at(vars(matches("\\d{4}$")), funs(if_else(is.na(.), 0, .)))

write_feather(df, "data/merged.feather")


