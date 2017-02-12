library(Hmisc) 
library(tidyverse) 

dir.create("data-raw", showWarnings = FALSE)
dir.create("data-raw/documentation", showWarnings = FALSE)
dir.create("data-raw/rpad", showWarnings = FALSE)

# Documentation
download.file("http://www1.nyc.gov/assets/finance/downloads/tar/tarfieldcodes.pdf",
              "data-raw/documentation/rpad_data_dictionary.pdf")

# 2017 --------------------------------------------------------------------

download.file("http://www1.nyc.gov/assets/finance/downloads/tar/tc234_17.zip", 
              "data-raw/rpad/tc234_17.zip", mode = "wb")

unzip("data-raw/rpad/tc234_17.zip", exdir = "data-raw/rpad")

rpad_234_17 <- mdb.get("data-raw/rpad/tc234_17.mdb")

write_csv(rpad_234_17[[1]], "data-raw/rpad/rpad_234_17_nametable.csv")
write_csv(rpad_234_17[[2]], "data-raw/rpad/rpad_234_17.csv")

# 2016 --------------------------------------------------------------------

download.file("http://www1.nyc.gov/assets/finance/downloads/tar/tc234_16.zip", 
              "data-raw/rpad/tc234_16.zip", mode = "wb")

unzip("data-raw/rpad/tc234_16.zip", exdir = "data-raw/rpad")

rpad_234_16 <- mdb.get("data-raw/rpad/tc234.mdb")

write_csv(rpad_234_16[[1]], "data-raw/rpad/rpad_234_16_nametable.csv")
write_csv(rpad_234_16[[2]], "data-raw/rpad/rpad_234_16.csv")


# Delete mdb and zip files
dir("data-raw/rpad", pattern = "\\.(mdb|zip)$", full.names = TRUE) %>% file.remove()
