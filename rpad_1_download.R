library(Hmisc) 
library(tidyverse) 
library(here) 

dir.create(here("data-raw"), showWarnings = FALSE)
dir.create(here("data-raw", "rpad"), showWarnings = FALSE)

# 2017 --------------------------------------------------------------------

download.file("http://www1.nyc.gov/assets/finance/downloads/tar/tc234_17.zip", 
              here("data-raw", "rpad", "tc234_17.zip"), mode = "wb")

unzip(here("data-raw", "rpad", "tc234_17.zip"), exdir = here("data-raw", "rpad"))

rpad_234_17 <- mdb.get(here("data-raw", "rpad", "tc234_17.mdb"))

write_csv(rpad_234_17[[1]], here("data-raw", "rpad", "rpad_234_17_nametable.csv"))
write_csv(rpad_234_17[[2]], here("data-raw", "rpad", "rpad_234_17.csv"))

# 2016 --------------------------------------------------------------------

download.file("http://www1.nyc.gov/assets/finance/downloads/tar/tc234_16.zip", 
              here("data-raw", "rpad", "tc234_16.zip"), mode = "wb")

unzip(here("data-raw", "rpad", "tc234_16.zip"), exdir = here("data-raw", "rpad"))

rpad_234_16 <- mdb.get(here("data-raw", "rpad", "tc234.mdb"))

write_csv(rpad_234_16[[1]], here("data-raw", "rpad", "rpad_234_16_nametable.csv"))
write_csv(rpad_234_16[[2]], here("data-raw", "rpad", "rpad_234_16.csv"))
