Predicted Violations Maps
================

``` r
library(tidyverse)
library(stringr)
library(feather)
library(sf)

dir.create("../maps/cd_maps", showWarnings = FALSE)
```

``` r
pred <- read_feather("../data/model_predictions_16.feather")
geo_df <- st_read(str_interp("../data-raw/dcp_mappluto/${params$boro}MapPLUTO.shp"), 
                  str_interp("${params$boro}MapPLUTO"))

cd <- geo_df %>% 
  filter(CD == params$cd_num) %>% 
  mutate(bbl = as.character(BBL)) %>% 
  select(bbl, geometry) %>% 
  left_join(pred, by = "bbl")

map_theme <- function() {
  list(viridis::scale_fill_viridis(na.value = "grey", limits = c(0, 1)),
       theme(panel.background = element_blank(),
             panel.grid = element_blank(),
             axis.ticks = element_blank(),
             axis.text = element_blank(),
             plot.caption = element_text(colour = "grey50", face = "italic", size = 8))
  )
}
```

``` r
actual <- ggplot(cd) + 
  geom_sf(aes(fill = true_16), color = NA) + 
  map_theme() +
  labs(title = str_c("Presence of Serious Violation in ", params$cd_name),
       subtitle = "Actual Violations",
       fill = NULL)

past_viol <- ggplot(cd) + 
  geom_sf(data = cd, aes(fill = past_viol), color = NA) + 
  map_theme() +
  labs(title = str_c("Prediction of Serious Violation in ", params$cd_name),
       subtitle = "Serious Violation Last Year",
       fill = NULL)

logit <- ggplot(cd) + 
  geom_sf(data = cd, aes(fill = logit), color = NA) + 
  map_theme() +
  labs(title = str_c("Prediction of Serious Violation in ", params$cd_name),
       subtitle = "Logistic Regression",
       fill = NULL)

tree <- ggplot(cd) + 
  geom_sf(data = cd, aes(fill = tree), color = NA) + 
  map_theme() +
  labs(title = str_c("Prediction of Serious Violation in ", params$cd_name),
       subtitle = "Decision Tree",
       fill = NULL)

forest <- ggplot(cd) + 
  geom_sf(data = cd, aes(fill = forest), color = NA) + 
  map_theme() +
  labs(title = str_c("Prediction of Serious Violation in ", params$cd_name),
       subtitle = "Random Forest",
       fill = NULL)
```

``` r
name_plot <- function(map, map_name) {
  filename <- str_interp("../maps/cd_maps/${params$cd_short}_${map_name}.png")
  ggsave(filename, plot = map)
}

maps <- list(actual, past_viol, logit, tree, forest) 
map_names <- c("actual", "past_viol", "logit", "tree", "forest")

walk2(maps, map_names, name_plot)
```
