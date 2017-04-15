Predicting Housing Code Violations
================
Maxwell Austensen
2017-04-15

-   [Overview](#overview)
-   [Repository Organization](#repository-organization)
-   [Reproducability Instructions](#reproducability-instructions)
-   [To-Do](#to-do)
    -   [Data source wish-list](#data-source-wish-list)

Overview
--------

The purpose of this project is to to predict serious housing code violations in multi-family rental building in New York City. All data is taken from publicly available sources, and is organized at the borough-block-lot (BBL) level. The plan is to use all data available in 2015 to predict violations in 2016.

Repository Organization
-----------------------

<table>
<colgroup>
<col width="19%" />
<col width="80%" />
</colgroup>
<thead>
<tr class="header">
<th>Directory</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td><code>./</code></td>
<td>Pseudo makefiles for data and analysis/maps</td>
</tr>
<tr class="even">
<td><code>./analysis</code></td>
<td>R Notebook files for main analysis</td>
</tr>
<tr class="odd">
<td><code>./violations-app</code></td>
<td><a href="https://shiny.rstudio.com/"><code>shiny</code></a> files for <a href="https://maxwell-austensen.shinyapps.io/violations-app/">app to visualize model predictions</a></td>
</tr>
<tr class="even">
<td><code>./maps</code></td>
<td>R scripts to create maps and final map images</td>
</tr>
<tr class="odd">
<td><code>./munge</code></td>
<td>R scripts to download raw files, clean data, and prep for joining all sources</td>
</tr>
<tr class="even">
<td><code>./data-raw</code></td>
<td>Raw data files, and cleaned individual data sets, including crosswalks <em>(git-ignored due to file size)</em></td>
</tr>
<tr class="odd">
<td><code>./data-documentation</code></td>
<td>Documentation files downloaded for data sources</td>
</tr>
<tr class="even">
<td><code>./data</code></td>
<td>Final cleaned and joined data sets <em>(only samples of data are not git-ignored)</em></td>
</tr>
<tr class="odd">
<td><code>./functions</code></td>
<td>R functions used throughout project</td>
</tr>
<tr class="even">
<td><code>./presentations</code></td>
<td>Slide presentations for class using <a href="https://github.com/yihui/xaringan"><code>xaringan</code></a></td>
</tr>
<tr class="odd">
<td><code>./packrat</code></td>
<td>Files for <a href="https://rstudio.github.io/packrat/"><code>packrat</code></a> R package management system <em>(do not edit)</em></td>
</tr>
</tbody>
</table>

Reproducability Instructions
----------------------------

1.  Clone repo and open the RStudio project file `edsp17proj-austensen.Rproj`
    -   The package `packrat` will be automatically installed from source files in the repository. Then all the other packages used in this project will be installed from instructions saved in this repo. All installed packages will be saved in the packrat sub-directories of this repo. This allows you to easily get all the packages you need to reproduce this project while not disrupting your own local package library (eg. change versions).

2.  Run `source("make_data.R")` to download and prepare all the data necessary to reproduce all the analysis.
3.  Run `source("make_analysis_maps.R")` to run all the analysis scripts, rendering .nb.html files and generating map images.

To-Do
-----

-   Improve logit model using `MASS::stepAIC()` to choose a model

-   Plot decision tree (look at `rpart.plot` package)

-   Consider changing from classification to regression using adjusted serious violations count

-   Deal with missing data problems
    -   Impute missing data
    -   simple mean imputation,
    -   mean by zip code and/or building type,
    -   should also see if missing-not-at-random
    -   look for values in past years of data (older pluto/rpad versions),
    -   regressions using other variables
-   Add to evaluation of models using tests recommended in Dietrich (1997) reading

### Data source wish-list

-   [Building permits (DOB)](https://data.cityofnewyork.us/Housing-Development/DOB-Job-Application-Filings/ic3t-wcy2)
-   [Oil Boilers](https://data.cityofnewyork.us/Housing-Development/Oil-Boilers-Detailed-Fuel-Consumption-and-Building/jfzu-yy6n)
-   [Rodent Inspection](https://data.cityofnewyork.us/Health/Rodent-Inspection/p937-wjvj)
-   [Subsidized Housing Database](http://app.coredata.nyc/)
-   [Likely Rent-Regulated Units](http://taxbills.nyc/)
-   Certificates of Occupancy (DCP - FOIL)
-   Open Balance File (Property Tax Delinquency) (DOF - FOIL)
-   HPD registration files - corporate owner
-   DOF sales data - price and date of last sale
-   Tract-level ACS - median rent, poverty rate, etc.
-   SBA-level HVS - building quality, pests, etc.
