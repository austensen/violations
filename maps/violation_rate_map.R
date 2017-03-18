library(tidyverse)
library(stringr)
library(feather)
library(sf)

viol <- read_feather("data/hpd_violations_map_data.feather")

tracts <- st_read("data-raw/crosswalks/tract2010_sf.shp", stringsAsFactors = FALSE)

tract_units <- read_feather("data/tract10_res_units.feather")

map_data <- tracts %>% 
  left_join(viol, by = c("geoid" = "tract10")) %>% 
  left_join(tract_units, by = c("geoid" = "tract10")) %>% 
  mutate(ser_2016 = if_else(is.na(ser_2016), 0L, ser_2016),
         ser_viol_rt_2016 = (ser_2016 / res_units) * 1000,
         ser_viol_rt_2016 = if_else(res_units < 100, NA_real_, ser_viol_rt_2016)) 
  

ggplot(map_data, aes(fill = ser_viol_rt_2016)) + 
  geom_sf(size = .1) + 
  viridis::scale_fill_viridis() +
  theme(legend.position = c(.1, .7),
        panel.background = element_blank(),
        panel.grid = element_blank(),
        axis.ticks = element_blank(),
        axis.text = element_blank(),
        plot.caption = element_text(colour = "grey50", face = "italic", size = 8)) +
  labs(title = "Serious Housing Code Violations in New York City, 2016",
       subtitle = "per 1,000 privately owned rental units",
       fill = NULL,
       caption = "Sources: NYC HPD, MapPLUTO, NYC DOF Final Tax Roll File")

ggsave("maps/tract_violations_rate_2016.png", width = 20, height = 20, units = "cm")
