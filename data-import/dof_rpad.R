library(Hmisc) 
library(tidyverse) 
library(feather) 
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

# Clean RPAD --------------------------------------------------------------

rpad_cols <- cols(
  BBLE = col_character(),
  BORO = col_integer(),
  BLOCK = col_integer(),
  LOT = col_integer(),
  EASE = col_character(),
  SECVOL = col_integer(),
  DISTRICT = col_integer(),
  YEAR4 = col_integer(),
  CUR.FV.L = col_double(),
  CUR.FV.T = col_double(),
  NEW.FV.L = col_double(),
  NEW.FV.T = col_double(),
  FV.CHGDT = col_character(),
  CURAVL = col_double(),
  CURAVT = col_double(),
  CUREXL = col_double(),
  CUREXT = col_double(),
  CURAVL.A = col_double(),
  CURAVT.A = col_double(),
  CUREXL.A = col_double(),
  CUREXT.A = col_double(),
  CHGDT = col_character(),
  TN.AVL = col_double(),
  TN.AVT = col_double(),
  TN.EXL = col_double(),
  TN.EXT = col_double(),
  TN.AVL.A = col_double(),
  TN.AVT.A = col_double(),
  TN.EXL.A = col_double(),
  TN.EXT.A = col_double(),
  FCHGDT = col_character(),
  FN.AVL = col_double(),
  FN.AVT = col_double(),
  FN.EXL = col_double(),
  FN.EXT = col_double(),
  FN.AVL.A = col_double(),
  FN.AVT.A = col_double(),
  FN.EXL.A = col_double(),
  FN.EXT.A = col_double(),
  TXCL = col_character(),
  O.TXCL = col_character(),
  CBN.TXCL = col_character(),
  BLDGCL = col_character(),
  EXMTCL = col_character(),
  OWNER = col_character(),
  HNUM.LO = col_character(),
  HNUM.HI = col_character(),
  STR.NAME = col_character(),
  ZIP = col_integer(),
  TOT.UNIT = col_integer(),
  RES.UNIT = col_integer(),
  LFRT.DEC = col_double(),
  LDEP.DEC = col_double(),
  L.ACRE = col_character(),
  IRREG = col_character(),
  BFRT.DEC = col_double(),
  BDEP.DEC = col_double(),
  BLD.VAR = col_character(),
  EXT = col_character(),
  STORY = col_double(),
  BLDGS = col_integer(),
  CORNER = col_character(),
  LND.AREA = col_integer(),
  GR.SQFT = col_integer(),
  ZONING = col_character(),
  YRB = col_integer(),
  YRB.FLAG = col_character(),
  YRB.RNG = col_integer(),
  YRA1 = col_integer(),
  YRA1.RNG = col_integer(),
  YRA2 = col_integer(),
  YRA2.RNG = col_integer(),
  CP.BORO = col_integer(),
  CP.DIST = col_integer(),
  LIMIT = col_integer(),
  O.LIMIT = col_integer(),
  STATUS1 = col_integer(),
  STATUS2 = col_character(),
  NEWLOT = col_integer(),
  DROPLOT = col_integer(),
  DELCHG = col_character(),
  CORCHG = col_integer(),
  NODESC = col_integer(),
  NOAV = col_integer(),
  VALREF = col_integer(),
  MBLDG = col_integer(),
  CONDO.NM = col_integer(),
  CONDO.S1 = col_character(),
  CONDO.S2 = col_integer(),
  CONDO.S3 = col_character(),
  CONDO.A = col_character(),
  COMINT.L = col_double(),
  COMINT.B = col_double(),
  APTNO = col_character(),
  AP.BORO = col_integer(),
  AP.BLOCK = col_integer(),
  AP.LOT = col_integer(),
  AP.EASE = col_character(),
  AP.DATE = col_character(),
  AP.TIME = col_integer(),
  PROTEST = col_character(),
  AT.GRP = col_integer(),
  APPLIC = col_integer(),
  PROTEST2 = col_character(),
  AT.GRP2 = col_integer(),
  APPLIC2 = col_integer(),
  O.PROTST = col_character(),
  O.AT.GRP = col_integer(),
  O.APPLIC = col_integer(),
  REUC = col_character(),
  GEO.RC = col_character(),
  COOP.NUM = col_integer(),
  EX.INDS = col_character(),
  EX.COUNT = col_integer(),
  EX.CHGDT = col_character(),
  DCHGDT = col_character(),
  SM.CHGDT = col_character()
)

clean_rpad <- function(x, pos) {
  x %>% 
  janitor::clean_names() %>% 
  filter(is.na(ease), res_unit >= 3) %>%
  transmute(bbl = as.character(bble),
            cd = as.integer((boro * 100) + cp_dist),
            res_units = res_unit,
            other_units = tot_unit - res_unit,
            assessed_value = fn_avt_a,
            year_built = pmax(yrb, yrb_rng, na.rm = TRUE),
            year_reno = pmax(year_built, yra1, yra1_rng, yra2, yra2_rng, na.rm = TRUE),
            floors = story,
            buildings = bldgs,
            new_lot = newlot,
            building_class = bldgcl,
            zoning = zoning) %>% 
  mutate_at(vars(year_built, year_reno), funs(if_else(. == 0, NA_integer_, .))) 
}

process_rpad <- function(yy) {
  str_interp("data-raw/dof_rpad/rpad_${yy}.csv") %>% 
    read_csv_chunked(DataFrameCallback$new(clean_rpad), col_types = rpad_cols) %>% 
    write_feather(str_interp("data-raw/dof_rpad/rpad_${yy}.feather"))
}


walk(15:16, process_rpad)

