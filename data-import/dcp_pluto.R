library(tidyverse)
library(feather)
library(stringr)


# Set up directories ------------------------------------------------------

dir.create("../data-raw", showWarnings = FALSE)
dir.create("../data-documentation", showWarnings = FALSE)
dir.create("../data-raw/dcp_pluto", showWarnings = FALSE)

# Download files (and delete unnecessary ones) ----------------------------

download.file("http://www1.nyc.gov/assets/planning/download/pdf/data-maps/open-data/pluto_datadictionary.pdf?v=16v2",
              "../data-documentation/pluto_16v2.pdf", mode = "wb")

download.file("http://www1.nyc.gov/assets/planning/download/zip/data-maps/open-data/nyc_pluto_16v2%20.zip",
              "../data-raw/dcp_pluto/nyc_pluto_16v2.zip", mode = "wb")

unzip("../data-raw/dcp_pluto/nyc_pluto_16v2.zip", exdir = "../data-raw/dcp_pluto")

file.remove("../data-raw/dcp_pluto/nyc_pluto_16v2.zip")


# Stack separate borough files --------------------------------------------

# Start by reading manhattan file, and writing to new csv
read_lines("../data-raw/dcp_pluto/BORO_zip_files_csv/MN.csv") %>% write_lines("../data-raw/dcp_pluto/pluto_16.csv")

# Then read each other boro (skipping header) and append to the new all-boroughs file
c("BX", "BK", "QN", "SI")  %>% 
  walk(~ read_lines(str_interp("../data-raw/dcp_pluto/BORO_zip_files_csv/${.x}.csv"), skip = 1) %>% 
         write_lines("../data-raw/dcp_pluto/pluto_16.csv", append = TRUE))

# Delete all fies in unwanted subdirectory, then the subdirectory itself 
dir("../data-raw/dcp_pluto/BORO_zip_files_csv", full.names = TRUE) %>% file.remove() 

file.remove("../data-raw/dcp_pluto/BORO_zip_files_csv")

# Clean PLUTO -------------------------------------------------------------

pluto_cols <- cols(
  Borough = col_character(),
  Block = col_integer(),
  Lot = col_integer(),
  CD = col_integer(),
  CT2010 = col_character(),
  CB2010 = col_character(),
  SchoolDist = col_character(),
  Council = col_integer(),
  ZipCode = col_integer(),
  FireComp = col_character(),
  PolicePrct = col_integer(),
  HealthArea = col_integer(),
  SanitBoro = col_integer(),
  SanitDistrict = col_character(),
  SanitSub = col_character(),
  Address = col_character(),
  ZoneDist1 = col_character(),
  ZoneDist2 = col_character(),
  ZoneDist3 = col_character(),
  ZoneDist4 = col_character(),
  Overlay1 = col_character(),
  Overlay2 = col_character(),
  SPDist1 = col_character(),
  SPDist2 = col_character(),
  SPDist3 = col_character(),
  LtdHeight = col_character(),
  SplitZone = col_character(),
  BldgClass = col_character(),
  LandUse = col_character(),
  Easements = col_integer(),
  OwnerType = col_character(),
  OwnerName = col_character(),
  LotArea = col_integer(),
  BldgArea = col_integer(),
  ComArea = col_integer(),
  ResArea = col_integer(),
  OfficeArea = col_integer(),
  RetailArea = col_integer(),
  GarageArea = col_integer(),
  StrgeArea = col_integer(),
  FactryArea = col_integer(),
  OtherArea = col_integer(),
  AreaSource = col_integer(),
  NumBldgs = col_integer(),
  NumFloors = col_double(),
  UnitsRes = col_integer(),
  UnitsTotal = col_integer(),
  LotFront = col_double(),
  LotDepth = col_double(),
  BldgFront = col_double(),
  BldgDepth = col_double(),
  Ext = col_character(),
  ProxCode = col_integer(),
  IrrLotCode = col_character(),
  LotType = col_integer(),
  BsmtCode = col_integer(),
  AssessLand = col_double(),
  AssessTot = col_double(),
  ExemptLand = col_double(),
  ExemptTot = col_double(),
  YearBuilt = col_integer(),
  YearAlter1 = col_integer(),
  YearAlter2 = col_integer(),
  HistDist = col_character(),
  Landmark = col_character(),
  BuiltFAR = col_double(),
  ResidFAR = col_double(),
  CommFAR = col_double(),
  FacilFAR = col_double(),
  BoroCode = col_integer(),
  BBL = col_character(),
  CondoNo = col_integer(),
  Tract2010 = col_character(),
  XCoord = col_integer(),
  YCoord = col_integer(),
  ZoneMap = col_character(),
  ZMCode = col_character(),
  Sanborn = col_character(),
  TaxMap = col_integer(),
  EDesigNum = col_character(),
  APPBBL = col_double(),
  APPDate = col_character(),
  PLUTOMapID = col_integer(),
  Version = col_character()
)


clean_pluto <- function(x, pos) {
  x %>% 
    janitor::clean_names() %>% 
    filter(easements == 0, unitsres > 1) %>% 
    transmute(bbl = str_sub(bbl, 1, 10),
              cd = cd,
              tract10 = if_else(str_detect(ct2010, "\\."), str_replace(ct2010, "\\.", ""), str_c(ct2010, "00")),
              tract10 = str_pad(tract10, 6, "left", "0"),
              res_units = unitsres,
              other_units = unitstotal - unitsres,
              year_built = yearbuilt,
              year_reno = pmax(yearalter1, yearalter2, na.rm = TRUE),
              buildings = numbldgs,
              floors = numfloors, 
              building_class = bldgclass, 
              basement_code = bsmtcode,
              owner_type = ownertype,
              lot_area = lotarea,
              res_sqft = resarea) %>% 
    mutate_at(vars(year_built, year_reno), funs(if_else(. == 0, NA_integer_, .)))
}

process_pluto <- function(yy) {
  str_interp("../data-raw/dcp_pluto/pluto_${yy}.csv") %>% 
    read_csv_chunked(DataFrameCallback$new(clean_pluto), col_types = pluto_cols) %>% 
    write_feather(str_interp("../data-raw/dcp_pluto/pluto_${yy}.feather"))
}

walk(16, process_pluto)
