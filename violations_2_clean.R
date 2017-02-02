library(tidyverse) 
library(magrittr)
library(stringr)
library(here) 


# read in and stack all files
df <- here("data-raw", "violations") %>% 
  list.files(pattern = "\\.txt$", full.names = TRUE) %>% 
  map_df(read_delim, delim = "|", trim_ws = T, col_types = cols(.default = col_guess(),
                                                                HouseNumber = col_character(),
                                                                LowHouseNumber = col_character(),
                                                                HighHouseNumber = col_character()))