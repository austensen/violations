Predicting Housing Code Violations
================
Maxwell Austensen
2017-02-19

``` r
library(tidyverse)
library(feather)
```

``` r
df <- read_feather("data/merged.feather")
```

``` r
viol_16_no15 <- df %>% 
  filter(res_units <= 3, viol_c_2016 > 0) %>% 
  summarise(mean(viol_c_2015 == 0)) %>% 
  .[[1]]
```

Of all the properties with 3+ units that had at least one serious violation in 2016, 78.04% didn't have a serious violation in 2015.
