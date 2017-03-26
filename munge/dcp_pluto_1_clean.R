library(tidyverse)
library(stringr)
library(feather)


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

nycha_names <- c("HOUSING AUTHORITY", "NYCHA", "NEW YORK CITY HOUSING")

clean_pluto <- function(x, pos) {
  x %>% 
    janitor::clean_names() %>% 
    filter(easements == 0, !ownername %in% nycha_names) %>% 
    transmute(bbl = str_sub(bbl, 1, 10),
              cd = as.character(cd),
              county = recode(borocode, `1` = "061", `2` = "005", `3` = "047", `4` = "081", `5` = "085"),
              tract10 = if_else(str_detect(ct2010, "\\."), str_replace(ct2010, "\\.", ""), str_c(ct2010, "00")),
              tract10 = str_c(county, str_pad(tract10, 6, "left", "0")),
              res_units = unitsres,
              other_units = unitstotal - unitsres,
              year_built = yearbuilt,
              year_reno = pmax(year_built, yearalter1, yearalter2, na.rm = TRUE),
              buildings = numbldgs,
              floors = numfloors, 
              building_class = bldgclass, 
              basement_code = as.character(bsmtcode),
              owner_type = ownertype,
              lot_area = lotarea,
              res_sqft = resarea) %>% 
    mutate_at(vars(year_built, year_reno), funs(if_else(. == 0, NA_integer_, .)))
}

process_pluto <- function(yy) {
  str_interp("data-raw/dcp_pluto/pluto_${yy}.csv") %>% 
    read_csv_chunked(DataFrameCallback$new(clean_pluto), col_types = pluto_cols) %>% 
    write_feather(str_interp("data-raw/dcp_pluto/pluto_${yy}.feather"))
}

walk(16, process_pluto)
