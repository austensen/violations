R Notebook
================

``` r
library(plyr)
library(rpart)
library(randomForest)
library(caret)
library(tidyverse)
library(stringr)

set.seed(2017)
```

Prep Data
=========

``` r
df <- feather::read_feather("../data/merged.feather") %>% na.omit()

df_15 <- df %>% 
  mutate(viol_c_all_2015 = viol_bldg_c_2015 + viol_apt_c_2015,
         outcome = factor(viol_c_all_2015 > 0)) %>% 
  select(-matches("2015|2016$"), -bbl, -tract10) %>% 
  mutate(zoning = stringr::str_sub(zoning, 1, 1),
         building_class = stringr::str_sub(building_class, 1, 1)) %>%
  mutate_if(is.character, as.factor) %>% 
  na.omit

names(df_15) <- names(df_15) %>% str_replace_all("2014", "1") %>% str_replace_all("2013", "2")

df_16 <- df %>% 
  mutate(viol_c_all_2016 = viol_bldg_c_2016 + viol_apt_c_2016,
         outcome = factor(viol_c_all_2016 > 0)) %>% 
  select(-matches("2013|2016$"), -bbl, -tract10) %>% 
  mutate(zoning = stringr::str_sub(zoning, 1, 1),
         building_class = stringr::str_sub(building_class, 1, 1)) %>%
  mutate_if(is.character, as.factor) %>% 
  na.omit

names(df_16) <- names(df_16) %>% str_replace_all("2015", "1") %>% str_replace_all("2014", "2")
```

------------------------------------------------------------------------

Logit
=====

``` r
glm_fit <- glm(outcome ~ ., family = "binomial", df_15)

glm_p <- predict(glm_fit, df_16, type = "response")

print_results <- function(threshold, preditions) {
  ret <- if_else(preditions > threshold, TRUE, FALSE) %>% 
    as.factor %>% 
    confusionMatrix(df_16[["outcome"]])
  
  message(str_c("Threshold: ", threshold))
  print(ret)
}

# walk(seq(0.1, 0.9, 0.1), print_results, preditions = glm_p)

print_results(.5, glm_p)
```

    ## Threshold: 0.5

    ## Confusion Matrix and Statistics
    ## 
    ##           Reference
    ## Prediction FALSE TRUE
    ##      FALSE  9193 1786
    ##      TRUE    497 1082
    ##                                           
    ##                Accuracy : 0.8182          
    ##                  95% CI : (0.8113, 0.8249)
    ##     No Information Rate : 0.7716          
    ##     P-Value [Acc > NIR] : < 2.2e-16       
    ##                                           
    ##                   Kappa : 0.3872          
    ##  Mcnemar's Test P-Value : < 2.2e-16       
    ##                                           
    ##             Sensitivity : 0.9487          
    ##             Specificity : 0.3773          
    ##          Pos Pred Value : 0.8373          
    ##          Neg Pred Value : 0.6852          
    ##              Prevalence : 0.7716          
    ##          Detection Rate : 0.7320          
    ##    Detection Prevalence : 0.8743          
    ##       Balanced Accuracy : 0.6630          
    ##                                           
    ##        'Positive' Class : FALSE           
    ## 

------------------------------------------------------------------------

Decision Tree
=============

``` r
tree_fit_control <- trainControl(method = "repeatedcv", number = 10, repeats = 10)

tree_fit <- train(outcome ~ ., data = df_15, 
                  method = "rpart", 
                  trControl = tree_fit_control)

tree_p <- predict(tree_fit, newdata = df_16)

confusionMatrix(tree_p, df_16[["outcome"]])
```

    ## Confusion Matrix and Statistics
    ## 
    ##           Reference
    ## Prediction FALSE TRUE
    ##      FALSE  8599 1269
    ##      TRUE   1091 1599
    ##                                           
    ##                Accuracy : 0.8121          
    ##                  95% CI : (0.8051, 0.8189)
    ##     No Information Rate : 0.7716          
    ##     P-Value [Acc > NIR] : < 2.2e-16       
    ##                                           
    ##                   Kappa : 0.4549          
    ##  Mcnemar's Test P-Value : 0.000269        
    ##                                           
    ##             Sensitivity : 0.8874          
    ##             Specificity : 0.5575          
    ##          Pos Pred Value : 0.8714          
    ##          Neg Pred Value : 0.5944          
    ##              Prevalence : 0.7716          
    ##          Detection Rate : 0.6847          
    ##    Detection Prevalence : 0.7858          
    ##       Balanced Accuracy : 0.7225          
    ##                                           
    ##        'Positive' Class : FALSE           
    ## 

------------------------------------------------------------------------

Random Forest
=============

``` r
forest_fit_control <- trainControl(method = "repeatedcv", number = 10)

forest_fit <- train(outcome ~ ., data = df_15, 
                    method = "rf", 
                    tuneGrid=data.frame(mtry=3),
                    trControl = forest_fit_control)

forest_p <- predict(forest_fit, newdata = df_16)

confusionMatrix(forest_p, df_16[["outcome"]])
```

    ## Confusion Matrix and Statistics
    ## 
    ##           Reference
    ## Prediction FALSE TRUE
    ##      FALSE  8945 1423
    ##      TRUE    745 1445
    ##                                           
    ##                Accuracy : 0.8274          
    ##                  95% CI : (0.8206, 0.8339)
    ##     No Information Rate : 0.7716          
    ##     P-Value [Acc > NIR] : < 2.2e-16       
    ##                                           
    ##                   Kappa : 0.4657          
    ##  Mcnemar's Test P-Value : < 2.2e-16       
    ##                                           
    ##             Sensitivity : 0.9231          
    ##             Specificity : 0.5038          
    ##          Pos Pred Value : 0.8628          
    ##          Neg Pred Value : 0.6598          
    ##              Prevalence : 0.7716          
    ##          Detection Rate : 0.7123          
    ##    Detection Prevalence : 0.8256          
    ##       Balanced Accuracy : 0.7135          
    ##                                           
    ##        'Positive' Class : FALSE           
    ##
