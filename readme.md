Predicting Housing Code Violations
================
Maxwell Austensen
2017-02-26

-   [Overview](#overview)
-   [Repository Organization](#repository-organization)
-   [To-Do](#to-do)
    -   [Data source wish-list](#data-source-wish-list)

Overview
--------

The purpose of this project is to to predict serious housing code violations in multi-family rental building in New York City. All data is taken from publically available sources, and is organized at the borough-block-lot (BBL) level. The plan is to use all data available in 2015 to predict violations in 2016.

Repository Organization
-----------------------

`/analysis` - R Notebook files for main analysis

`/data-import` - All scripts to download raw data and documentation files, clean data, and prep for joining all sources

`/data-raw` - All raw data files downloaded, and cleaned individual data sets *(git-ignored due to file size)*

`/data-documentation` - All documentation files downloaded for data sources

`/data` - Final sample data set(s) after joining all sources *(only samples of data are not git-ignored)*

`/functions` - All R functions used thoughout project

`/presentations` - Slide presentations for class using [`xaringan`](https://github.com/yihui/xaringan)

`/packrat` - Files for [`packrat`](https://rstudio.github.io/packrat/) R package management system (do not edit)

To-Do
-----

-   Switch over from HPD website to NYC open data (charges, and complaints)

-   Run basic descriptives on final sample data
    -   Overall prevelence of (serious) housing code violations
    -   Accuracy of simple prediction based on presence of violations in the perious year
    -   ...
-   add step to `merge_all.R` that creates larger geography level indicators
    -   eg. buildings with violations in the block/tract/NTA etc.
-   Deal with missing data problems
    -   Could simplify features where applicable (eg. first character of `zoning`, `building_class`, etc.)
    -   Impute missing data
-   May want to separate building-wide and unit-specific violations, and adjust the unit-specific ones by number of units.

### Data source wish-list

-   [Building permits (DOB)](https://data.cityofnewyork.us/Housing-Development/DOB-Job-Application-Filings/ic3t-wcy2)
-   [Oil Boilers](https://data.cityofnewyork.us/Housing-Development/Oil-Boilers-Detailed-Fuel-Consumption-and-Building/jfzu-yy6n)
-   [Rodent Inspection](https://data.cityofnewyork.us/Health/Rodent-Inspection/p937-wjvj)
-   [Subsidized Housing Database](http://app.coredata.nyc/)
-   [Likely Rent-Regulated Units](http://taxbills.nyc/)
-   Certificates of Occupancy (DCP - FOIL)
-   Open Balance File (Poperty Tax Delinquency) (DOF - FOIL)
