library(tidyverse) 
library(magrittr)
library(stringr)

source("functions/read_files.R")

omo_cols <- cols(
  OMOID = col_integer(),
  OMONumber = col_character(),
  BuildingID = col_integer(),
  BoroID = col_integer(),
  Boro = col_character(),
  HouseNumber = col_character(),
  StreetName = col_character(),
  Apartment = col_character(),
  Zip = col_integer(),
  Block = col_integer(),
  Lot = col_integer(),
  LifeCycle = col_character(),
  WorkTypeGeneral = col_character(),
  OMOStatusReason = col_character(),
  OMOAwardAmount = col_double(),
  OMOCreateDate = col_date("%m/%d/%Y"),
  NetChangeOrders = col_integer(),
  OMOAwardDate = col_date("%m/%d/%Y"),
  IsAEP = col_character(),
  IsCommercialDemolition = col_character(),
  ServiceChargeFlag = col_character(),
  FEMAEventID = col_character(),
  FEMAEvent = col_character(),
  OMODescription = col_character()
)

hwo_cols <- cols(
  HWOID = col_integer(),
  HWONumber = col_character(),
  BuildingID = col_integer(),
  BoroID = col_integer(),
  Boro = col_character(),
  HouseNumber = col_character(),
  StreetName = col_character(),
  Zip = col_integer(),
  Block = col_integer(),
  Lot = col_integer(),
  LifeCycle = col_character(),
  WorkTypeGeneral = col_character(),
  HWOStatusReason = col_character(),
  HWOCreateDate = col_date("%m/%d/%Y"),
  IsAEP = col_character(),
  IsCommercialDemolition = col_character(),
  FEMAEventID = col_character(),
  FEMAEvent = col_character(),
  HWODescription = col_character(),
  HWOApprovedAmount = col_double(),
  SalesTax = col_double(),
  AdminFee = col_double(),
  ChargeAmount = col_double(),
  DateTransferDoF = col_date("%m/%d/%Y")
)

invoice_cols <- cols(
  InvoiceID = col_integer(),
  InvoiceNumber = col_character(),
  OMONumber = col_character(),
  InvoiceStatus = col_character(),
  InvoiceDate = col_date("%m/%d/%Y"),
  InvoiceBillAmount = col_double(),
  InvoicePayAmount = col_double(),
  SalesTax = col_double(),
  AdminFee = col_double(),
  PaymentID = col_integer(),
  ChargeAmount = col_double(),
  DateTransferDoF = col_date("%m/%d/%Y")
)

fee_cols <- cols(
  FeeID = col_integer(),
  BuildingID = col_integer(),
  BoroID = col_integer(),
  Boro = col_character(),
  HouseNumber = col_character(),
  StreetName = col_character(),
  Zip = col_integer(),
  Block = col_integer(),
  Lot = col_integer(),
  LifeCycle = col_character(),
  FeeTypeID = col_integer(),
  FeeType = col_character(),
  FeeSourceTypeID = col_integer(),
  FeeSourceType = col_character(),
  FeeSourceID = col_integer(),
  FeeIssuedDate = col_date("%m/%d/%Y"),
  FeeAmount = col_integer(),
  DoFAccountType = col_integer(),
  DoFTransferDate = col_date("%m/%d/%Y")
)
 
omo_charges <- read_files("data-raw/charges", "OMOCharge", omo_cols, months = 1)
hwo_charges <- read_files("data-raw/charges", "HWOCharge", hwo_cols, months = 1)
invoice_charges <- read_files("data-raw/charges", "Invoice", invoice_cols, months = 1)
fee_charges <- read_files("data-raw/charges", "FEECharge", fee_cols, months = 1)
