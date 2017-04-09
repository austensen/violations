

# Analysis Scripts
rmarkdown::render(input = "analysis/descriptives.Rmd", output_format = c("html_notebook", "github_document"))
rmarkdown::render(input = "analysis/models.Rmd", output_format = c("html_notebook", "github_document"))

# Mapping Scripts

# You can choose a boro and CD number, then the cd_name is for the map title, and cd_short is for the filenames
# http://www.baruch.cuny.edu/nycdata/population-geography/maps-boroughdistricts.htm
# MN = 1, BX = 2, BK = 3, QN = 4, SI = 5
# I'm planning to do these later with leaflet though...
rmarkdown::render(input = "maps/prediction_maps.Rmd", 
                  output_format = c("html_notebook", "github_document"),
                  params = list(boro = 'BX',
                                cd_num = 201,
                                cd_name = 'Mott Haven/Melrose',
                                cd_short = 'MottHaven'))

source("maps/violation_rate_map.R")
