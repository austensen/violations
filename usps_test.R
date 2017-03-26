library(tidyverse)
source("functions/clean_address.R")

raw_adds <- tibble(
  x = 1:7,
  zipcode = c(10002, 10002, NA, NA, 10013, 10022, NA),
  st = c("10 ludlow", " 176 orchard street", "168 ludlow street", "87 allen", "55 suffolk", "1 delancy", "205 houston"),
  city = c(rep("New York", 3), NA, rep("New York", 3)),
  apt = c("suite 3", NA, "apt 10", "B", NA, " 6", NA),
  state_name = c(rep("NY", 3), NA, rep("NY", 3))
)



foo <- raw_adds %>% 
  usps_addresses(.unit = apt, .street = st, .city = city, .state = state_name, .zip = zipcode, 
                 .username = "683MAXWE4358")
