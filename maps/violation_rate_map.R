library(tidyverse)
library(stringr)
library(feather)
library(sf)


# Load Datasets and Shapefiles --------------------------------------------

viol <- read_feather("data/hpd_violations.feather")
bbl_tract10_units <- read_feather("data/bbl_tract10_units.feather")
tract10_nta_xwalk <- read_feather("data-raw/crosswalks/tract2010_nta_xwalk.feather")
ntas <- st_read("http://services5.arcgis.com/GfwWNkhOj9bNBqoJ/arcgis/rest/services/nynta/FeatureServer/0/query?where=1=1&outFields=*&outSR=4326&f=geojson",
                stringsAsFactors = FALSE)


# Create NTA-level map data -----------------------------------------------

nta_viol_df <- bbl_tract10_units %>% 
  left_join(viol, by = "bbl") %>% 
  left_join(tract10_nta_xwalk, by = c("tract10" = "geoid")) %>% 
  group_by(nta) %>% 
  summarise(nta_viol = sum(viol_bbl_ser_2016, na.rm = T),
            nta_units = sum(res_units, na.rm = T)) %>% 
  mutate(nta_viol_rt = (nta_viol / nta_units) * 1000)

nta_map_data <- left_join(ntas, nta_viol_df, by = c("NTACode" = "nta")) %>% 
  mutate(nta_viol_rt = if_else(str_detect(NTACode, "99"), NA_real_, nta_viol_rt))


# saveRDS(nta_map_data, "data/nta_map_data.rds")

# plot(nta_map_data[11])


# Static Map --------------------------------------------------------------

ggplot(nta_map_data, aes(fill = nta_viol_rt)) + 
  geom_sf(size = .1) + 
  viridis::scale_fill_viridis() +
  theme(legend.position = c(.1, .7),
        panel.background = element_blank(),
        panel.grid = element_blank(),
        axis.ticks = element_blank(),
        axis.text = element_blank(),
        plot.caption = element_text(colour = "grey50", face = "italic", size = 8)) +
  labs(title = "Adjusted Number of Serious Housing Code Violations \nper 1,000 Privately Owned Rental Units",
       subtitle = "Neighborhood Tabulation Areas, 2016",
       fill = NULL,
       caption = "Sources: NYC HPD, MapPLUTO, NYC DOF Final Tax Roll File")

ggsave("maps/nta_violation_rate_2016.png", width = 20, height = 20, units = "cm")


# Interactive Map ---------------------------------------------------------

library(leaflet)

pal <- colorNumeric("viridis", nta_map_data$nta_viol_rt)

leaflet(nta_map_data) %>%
  addPolygons(color = "#444444", weight = 0.5, smoothFactor = 0.5,
              opacity = 1.0, fillOpacity = 1,
              fillColor = ~pal(nta_viol_rt),
              popup = ~paste("Adjust Violation Rate:", round(nta_viol_rt, 1), NTACode),
              highlightOptions = highlightOptions(color = "white", weight = 1,
                                                  bringToFront = TRUE))
