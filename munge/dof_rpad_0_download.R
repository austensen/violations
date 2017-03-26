library(Hmisc) 
library(tidyverse) 
library(stringr) 

dir.create("data-raw", showWarnings = FALSE)
dir.create("data-documentation", showWarnings = FALSE)
dir.create("data-raw/rpad", showWarnings = FALSE)

# Download Documentation --------------------------------------------------

download.file("http://www1.nyc.gov/assets/finance/downloads/tar/tarfieldcodes.pdf",
              "data-documentation/rpad_data_dictionary.pdf", mode = "wb", quiet = TRUE)

# Download Data -----------------------------------------------------------

download_unzip <- function(class, yy) {
  download.file(str_interp("http://www1.nyc.gov/assets/finance/downloads/tar/tc${class}_${yy}.zip"), 
                str_interp("data-raw/dof_rpad/tc${class}_${yy}.zip"), mode = "wb", quiet = TRUE)
  unzip(str_interp("data-raw/dof_rpad/tc${class}_${yy}.zip"), exdir = "data-raw/dof_rpad")
}

# 2015

walk(c("1", "234"), download_unzip, yy = 15)

mdb.get("data-raw/dof_rpad/TC1.mdb") %>% .[[2]] %>% write_csv("data-raw/dof_rpad/rpad_15.csv")
mdb.get("data-raw/dof_rpad/tc234_15.mdb") %>% .[[2]] %>% write_csv("data-raw/dof_rpad/rpad_15.csv", append = TRUE)

dir("data-raw/dof_rpad", pattern = "\\.(mdb|zip)$", full.names = TRUE) %>% file.remove()


# 2016

walk(c("1", "234"), download_unzip, yy = 16)

mdb.get("data-raw/dof_rpad/tc1.mdb") %>% .[[2]] %>% write_csv("data-raw/dof_rpad/rpad_16.csv")
mdb.get("data-raw/dof_rpad/tc234.mdb") %>% .[[2]] %>% write_csv("data-raw/dof_rpad/rpad_16.csv", append = TRUE)

dir("data-raw/dof_rpad", pattern = "\\.(mdb|zip)$", full.names = TRUE) %>% file.remove()
