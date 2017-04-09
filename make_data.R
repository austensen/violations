
# Get shapefiles for tract maps
source("munge/prep_geographies.R")

# Get shapefiles for BBL maps
source("munge/dcp_mappluto.R")

# Get BBL characteristics
source("munge/dcp_pluto_0_download.R")
source("munge/dcp_pluto_1_clean.R")
source("munge/dof_rpad_0_download.R")
source("munge/dof_rpad_1_clean.R")
source("munge/building_info.R")

# Prep complaints (requires "building_info.R")
source("munge/hpd_complaints_0_download.R")
source("munge/hpd_complaints_1_clean.R")

# Prep litigation (requires "building_info.R")
source("munge/hpd_litigation_0_download.R")
source("munge/hpd_litigation_1_clean.R")

# Prep violations (requires "building_info.R")
source("munge/hpd_violations_0_download.R")
source("munge/hpd_violations_1_clean.R")

# Join all the previous data sets into final sample for analysis
source("munge/merge_all.R")