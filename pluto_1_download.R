library(tidyverse)
library(feather)
library(stringr)

dir.create("data-raw", showWarnings = FALSE)
dir.create("data-raw/documentation", showWarnings = FALSE)
dir.create("data-raw/pluto", showWarnings = FALSE)

download.file("http://www1.nyc.gov/assets/planning/download/pdf/data-maps/open-data/pluto_datadictionary.pdf?v=16v2",
              "data-raw/documentation/pluto_16v2.pdf", mode = "wb")

download.file("http://www1.nyc.gov/assets/planning/download/zip/data-maps/open-data/nyc_pluto_16v2%20.zip",
              "data-raw/pluto/nyc_pluto_16v2.zip", mode = "wb")

unzip("data-raw/pluto/nyc_pluto_16v2.zip", exdir = "data-raw/pluto")

file.remove("data-raw/pluto/nyc_pluto_16v2.zip")

file.rename("data-raw/pluto/BORO_zip_files_csv", "data-raw/pluto/boro_files")

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

pluto_16v2 <- c("MN", "BX", "BK", "QN", "SI")  %>% 
  map_df(~ read_csv(str_interp("data-raw/pluto/boro_files/${.x}.csv"), col_types = pluto_cols)) %>% 
  janitor::clean_names()

write_feather(pluto_16v2, "data-raw/pluto/pluto_16v2.feather")
