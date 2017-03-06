Predicting Housing Code Violations
================
Maxwell Austensen
2017-03-06

-   [Overview](#overview)
-   [Repository Organization](#repository-organization)
-   [To-Do](#to-do)
    -   [Data source wish-list](#data-source-wish-list)

Overview
--------

The purpose of this project is to to predict serious housing code violations in multi-family rental building in New York City. All data is taken from publically available sources, and is organized at the borough-block-lot (BBL) level. The plan is to use all data available in 2015 to predict violations in 2016.

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
<td><code>./analysis</code></td>
<td>R Notebook files for main analysis</td>
</tr>
<tr class="even">
<td><code>./data-import</code></td>
<td>All scripts to download raw data and documentation files, clean data, and prep for joining all sources</td>
</tr>
<tr class="odd">
<td><code>./data-raw</code></td>
<td>All raw data files downloaded, and cleaned individual data sets <em>(git-ignored due to file size)</em></td>
</tr>
<tr class="even">
<td><code>./data-documentation</code></td>
<td>All documentation files downloaded for data sources</td>
</tr>
<tr class="odd">
<td><code>./data</code></td>
<td>Final sample data set(s) after joining all sources <em>(only samples of data are not git-ignored)</em></td>
</tr>
<tr class="even">
<td><code>./functions</code></td>
<td>All R functions used thoughout project</td>
</tr>
<tr class="odd">
<td><code>./presentations</code></td>
<td>Slide presentations for class using <a href="https://github.com/yihui/xaringan"><code>xaringan</code></a></td>
</tr>
<tr class="even">
<td><code>./packrat</code></td>
<td>Files for <a href="https://rstudio.github.io/packrat/"><code>packrat</code></a> R package management system <em>(do not edit)</em></td>
</tr>
</tbody>
</table>

To-Do
-----

-   Switch over from HPD website to NYC open data (charges, and complaints)

-   Run basic descriptives on final sample data
    -   Overall prevelence of (serious) housing code violations
    -   ...
-   Add step to `merge_all.R` that creates larger geography level indicators
    -   eg. buildings with violations in the block/tract/NTA etc.
-   Deal with missing data problems
    -   Could simplify features where applicable (eg. first character of `zoning`, `building_class`, etc.)
    -   Impute missing data
-   Add to evaluation of models using tests reccomended in Dietterich (1997) reading

### Data source wish-list

-   [Building permits (DOB)](https://data.cityofnewyork.us/Housing-Development/DOB-Job-Application-Filings/ic3t-wcy2)
-   [Oil Boilers](https://data.cityofnewyork.us/Housing-Development/Oil-Boilers-Detailed-Fuel-Consumption-and-Building/jfzu-yy6n)
-   [Rodent Inspection](https://data.cityofnewyork.us/Health/Rodent-Inspection/p937-wjvj)
-   [Subsidized Housing Database](http://app.coredata.nyc/)
-   [Likely Rent-Regulated Units](http://taxbills.nyc/)
-   Certificates of Occupancy (DCP - FOIL)
-   Open Balance File (Poperty Tax Delinquency) (DOF - FOIL)
