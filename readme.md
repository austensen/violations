Predicting Housing Code Violations
================
Maxwell Austensen
2017-02-24

-   [Overview](#overview)
-   [Repository Organization](#repository-organization)
-   [To-Do](#to-do)
    -   [Data source wish-list](#data-source-wish-list)

Overview
--------

The purpose of this project is to to predict serious housing code violations in multi-family rental building in New York City. All data is taken from publically available sources, and is organized at the borough-block-lot (BBL) level.

Repository Organization
-----------------------

`/analysis` - R Notebook files for main analysis

`/data-import` - All scripts to download raw data and documentation files, clean data, and prep for joining all sources

`/data-raw` - All raw data files downloaded, and cleaned individual data sets

`/data-documentation` - All documentation files downloaded for data sources

`/data` - Final sample data set(s) after joining all sources

`/functions` - All utility functions used thoughout project

`/presentations` - Slide presentations for class

`/packrat` - Files for [`packrat`](https://rstudio.github.io/packrat/) R package management system (do not edit)

To-Do
-----

-   Switch over from HPD website to NYC open data (charges, and complaints)

-   Run basic descriptives on final sample data
    -   Overall prevelence of (serious) housing code violations
    -   Accuracy of simple prediction based on presence of violations in the perious year
    -   ...

### Data source wish-list

-   [Building permits (DOB)](https://data.cityofnewyork.us/Housing-Development/DOB-Job-Application-Filings/ic3t-wcy2)
-   [Oil Boilers](https://data.cityofnewyork.us/Housing-Development/Oil-Boilers-Detailed-Fuel-Consumption-and-Building/jfzu-yy6n)
-   [Rodent Inspection](https://data.cityofnewyork.us/Health/Rodent-Inspection/p937-wjvj)
-   [Subsidized Housing Database](http://app.coredata.nyc/)
-   [Likely Rent-Regulated Units](http://taxbills.nyc/)
-   Certificates of Occupancy (DCP - FOIL)
-   Open Balance File (Poperty Tax Delinquency) (DOF - FOIL)
