R Notebook
================

``` r
library(plyr)
library(rpart)
library(randomForest)
library(caret)
library(tidyverse)
library(magrittr)
library(stringr)
library(ROCR)

knitr::opts_knit$set(autodep=TRUE)

set.seed(2017)
```

Prep Data
=========

Create two data sets from training and testing models. The training data set (`df_15`) includes only violation data for 2013 and 2014 and an indicator for whether the property had any serious violations in 2015. The test data set (`df_16`) has violation data for 2014 and 2015 and an indicator for whether the property had any serious violations in 2016. The past years' violations indicators are renamed to be relative to the current year (eg. for 2015, 2014 becomes 1 and 2013 becomes 2). Later I plan to impute missing values, but for now I am simply dropping all records with missing data.

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

Serious violations in previous year
===================================

First I'll just simply use the presence of serious violations in 2015 to predict for 2016.

``` r
(past_viol_info <- confusionMatrix(df_15[["outcome"]], df_16[["outcome"]], 
                            positive = "TRUE", mode = "everything"))
```

    ## Confusion Matrix and Statistics
    ## 
    ##           Reference
    ## Prediction FALSE TRUE
    ##      FALSE  8438 1265
    ##      TRUE   1252 1603
    ##                                           
    ##                Accuracy : 0.7996          
    ##                  95% CI : (0.7925, 0.8065)
    ##     No Information Rate : 0.7716          
    ##     P-Value [Acc > NIR] : 1.976e-14       
    ##                                           
    ##                   Kappa : 0.4304          
    ##  Mcnemar's Test P-Value : 0.811           
    ##                                           
    ##             Sensitivity : 0.5589          
    ##             Specificity : 0.8708          
    ##          Pos Pred Value : 0.5615          
    ##          Neg Pred Value : 0.8696          
    ##               Precision : 0.5615          
    ##                  Recall : 0.5589          
    ##                      F1 : 0.5602          
    ##              Prevalence : 0.2284          
    ##          Detection Rate : 0.1276          
    ##    Detection Prevalence : 0.2273          
    ##       Balanced Accuracy : 0.7149          
    ##                                           
    ##        'Positive' Class : TRUE            
    ## 

Using the presence of serious violations in 2015 to predict violations for 2016 achieves an accuracy of 0.79957, which is only a slight improvement over the no information rate of 0.7716197. This simple prediction has a Kappa statistic of 0.4304075, its precision is 0.5614711 and recall is 0.5589261.

------------------------------------------------------------------------

Logit
=====

Next I fit a Logit model using all the attributes for the `df_15` training data set. I then get the predicted values on the `df_16` test data and iterate over threshold values, deciding on 0.5.

``` r
glm_fit <- glm(outcome ~ ., family = "binomial", df_15)

glm_p <- predict(glm_fit, df_16, type = "response")

print_results <- function(threshold, preditions) {
  ret <- if_else(preditions > threshold, TRUE, FALSE) %>% 
    as.factor %>% 
    confusionMatrix(df_16[["outcome"]])
  
  message(str_c("\nThreshold: ", threshold))
  print(ret)
}

# Use this to select a theshold - decided on 0.5
# walk(seq(0.1, 0.9, 0.1), print_results, preditions = glm_p)

(glm_info <- confusionMatrix(as.factor(glm_p > .5), df_16[["outcome"]], 
                             positive = "TRUE", mode = "everything"))
```

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
    ##             Sensitivity : 0.37727         
    ##             Specificity : 0.94871         
    ##          Pos Pred Value : 0.68524         
    ##          Neg Pred Value : 0.83733         
    ##               Precision : 0.68524         
    ##                  Recall : 0.37727         
    ##                      F1 : 0.48662         
    ##              Prevalence : 0.22838         
    ##          Detection Rate : 0.08616         
    ##    Detection Prevalence : 0.12574         
    ##       Balanced Accuracy : 0.66299         
    ##                                           
    ##        'Positive' Class : TRUE            
    ## 

The Logit model achieves an accuracy of 0.8182035, which is only a slight improvement over the previous year's violation prediction and even better than the no information rate of 0.7716197. The Logit model achieves a Kappa statistic of 0.3872416, its precision is 0.6852438, and recall is 0.3772664.

------------------------------------------------------------------------

Decision Tree
=============

Next I try a simple decision tree with 10 times 10-fold Cross-validation.

``` r
tree_fit_control <- trainControl(method = "repeatedcv", number = 10, repeats = 10)

tree_fit <- train(outcome ~ ., data = df_15, 
                  method = "rpart", 
                  trControl = tree_fit_control)

tree_p <- predict(tree_fit, df_16)

(tree_info <- confusionMatrix(tree_p, df_16[["outcome"]], positive = "TRUE", mode = "everything"))
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
    ##             Sensitivity : 0.5575          
    ##             Specificity : 0.8874          
    ##          Pos Pred Value : 0.5944          
    ##          Neg Pred Value : 0.8714          
    ##               Precision : 0.5944          
    ##                  Recall : 0.5575          
    ##                      F1 : 0.5754          
    ##              Prevalence : 0.2284          
    ##          Detection Rate : 0.1273          
    ##    Detection Prevalence : 0.2142          
    ##       Balanced Accuracy : 0.7225          
    ##                                           
    ##        'Positive' Class : TRUE            
    ## 

The decision tree's accuracy of 0.812072, is a further improvement over the accuracy Logit model, the previous year's violation prediction, and no information rate. The decision tree model also achieves an improved Kappa statistic of 0.454879, and its precision is 0.5944238, and recall is 0.5575314.

``` r
varImp(tree_fit)
```

    ## rpart variable importance
    ## 
    ##   only 20 most important variables shown (out of 81)
    ## 
    ##                 Overall
    ## viol_apt_b_1    100.000
    ## viol_apt_a_1     95.441
    ## viol_apt_c_1     87.180
    ## viol_apt_b_2     66.837
    ## viol_bldg_c_1    45.407
    ## res_sqft         12.771
    ## res_units        11.540
    ## lot_area          4.037
    ## assessed_value    3.561
    ## viol_bldg_b_1     0.000
    ## zoningM           0.000
    ## other_units       0.000
    ## county047         0.000
    ## lit_11_1          0.000
    ## basement_code     0.000
    ## county085         0.000
    ## lit_9_2           0.000
    ## building_classL   0.000
    ## cd                0.000
    ## viol_apt_a_2      0.000

As expected, the various indicators of a building's violation record in the current and previous year are the most important attributes for predicting the presence of serious violations in the subsequent year. Additionally, the building's total residential square footage and total lot area, as well as the number of residential units and the total assessed value in the current year are also important.

------------------------------------------------------------------------

Random Forest
=============

Finally, I use a Random Forest model with 10-fold Cross-validation.

``` r
forest_fit_control <- trainControl(method = "repeatedcv", number = 10)

forest_fit <- train(outcome ~ ., data = df_15, 
                    method = "rf", 
                    tuneGrid=data.frame(mtry=3),
                    trControl = forest_fit_control)

forest_p <- predict(forest_fit, newdata = df_16)

(forest_info <- confusionMatrix(forest_p, df_16[["outcome"]], positive = "TRUE", mode = "everything"))
```

    ## Confusion Matrix and Statistics
    ## 
    ##           Reference
    ## Prediction FALSE TRUE
    ##      FALSE  8879 1367
    ##      TRUE    811 1501
    ##                                           
    ##                Accuracy : 0.8266          
    ##                  95% CI : (0.8198, 0.8332)
    ##     No Information Rate : 0.7716          
    ##     P-Value [Acc > NIR] : < 2.2e-16       
    ##                                           
    ##                   Kappa : 0.4719          
    ##  Mcnemar's Test P-Value : < 2.2e-16       
    ##                                           
    ##             Sensitivity : 0.5234          
    ##             Specificity : 0.9163          
    ##          Pos Pred Value : 0.6492          
    ##          Neg Pred Value : 0.8666          
    ##               Precision : 0.6492          
    ##                  Recall : 0.5234          
    ##                      F1 : 0.5795          
    ##              Prevalence : 0.2284          
    ##          Detection Rate : 0.1195          
    ##    Detection Prevalence : 0.1841          
    ##       Balanced Accuracy : 0.7198          
    ##                                           
    ##        'Positive' Class : TRUE            
    ## 

The Random Forest outperforms all the previous models in terms of accuracy with a value of 0.8265647. This still is only a slight improvement over all the previous models, and still is only modestly more accurate than the no information rate or previous year's violation prediction of 0.79957 and 0.7716197, respectively. The Random Forest also has a Kappa statistic of 0.4718681.

``` r
varImp(forest_fit)
```

    ## rf variable importance
    ## 
    ##   only 20 most important variables shown (out of 81)
    ## 
    ##                   Overall
    ## viol_apt_b_1      100.000
    ## viol_apt_c_1       69.319
    ## viol_apt_a_1       67.702
    ## viol_apt_b_2       51.322
    ## res_sqft           44.508
    ## res_units          41.136
    ## viol_bldg_c_1      35.634
    ## lot_area           35.338
    ## assessed_value     28.929
    ## viol_apt_c_2       26.453
    ## viol_bldg_b_1      26.216
    ## viol_apt_a_2       26.133
    ## floors             24.981
    ## cd                 21.690
    ## year_built         15.977
    ## avg_res_unit_sqft  14.623
    ## viol_bldg_a_1      14.163
    ## viol_bldg_b_2       9.473
    ## viol_bldg_c_2       9.225
    ## lit_3_1             6.940

Many of the variables that were important in the single decision tree are also important in the Random Forest model. Others that were important include the number of floors in the building, the Community District in which it is located, and the year it was built.

------------------------------------------------------------------------

ROC Space
=========

In addition the the various statistics generated above, it is helpful to visualize the performance of the various models by plotting the models' true positive and false positive rates in a ROC space. Only the Logit model can be plotted as a ROC curve and have an AUC calculated, while the others are represented simply by points in the ROC space.

``` r
past_viol_pred <- prediction(as.numeric(df_15[["outcome"]]), df_16[["outcome"]])

glm_pred <- prediction(glm_p, df_16[["outcome"]])

tree_pred <- tree_fit %>% 
  predict(newdata = df_16, type = "prob") %>% 
  .[[2]] %>%
  prediction(df_16[["outcome"]])

forest_pred <- forest_fit %>% 
  predict(newdata = df_16, type = "prob") %>% 
  .[[2]] %>%
  prediction(df_16[["outcome"]])


model_preds <- list(past_viol_pred, glm_pred, tree_pred, forest_pred)

model_names <- c("Past Violation", "Logistic Regression", "Decision Tree", "Random Forest")
```

``` r
get_roc_df <- function(.pred, model_name) {
  .pred %>% 
  performance("tpr", "fpr") %$% 
  tibble(model = model_name,
         fpr = .@x.values[[1]],
         tpr = .@y.values[[1]],
         cutoff = .@alpha.values[[1]])
}

get_auc <- function(.pred) {
  performance(.pred, "auc")@y.values[[1]]
}

roc_data <- map2_df(model_preds, model_names, get_roc_df) %>% 
  mutate(model = ordered(model, model_names))

auc_values <- set_names(model_preds, model_names) %>% map_dbl(get_auc)

roc_line_data <- filter(roc_data, model %in% c("Logistic Regression", "Random Forest"))
roc_point_data <- anti_join(roc_data, roc_line_data, by = "model")

roc_line_data %>% 
  ggplot(aes(fpr, tpr, color = model)) + 
  geom_line() +
  geom_point(data = roc_point_data) +
  geom_segment(x = 0, xend = 1, y = 0, yend = 1, linetype = "dashed", color = "grey") +
  annotate("text", x = .55, y = .5, hjust = 0, label = "AUC Values:") +
  annotate("text", x = .55, y = c(.4, .3, .2, .1), hjust = 0,
           label = str_c(names(auc_values), ": ", round(auc_values, 2))) +
  labs(title = "ROC Space",
       subtitle = "Any Serious Violations in 2016",
       color = NULL, x = "False Positive Rate", y = "True Positive Rate")
```

![](models_files/figure-markdown_github/roc-curve-1.png)

``` r
get_prec_rec_df <- function(.pred, model_name) {
  .pred %>% 
  performance("prec", "rec") %$% 
  tibble(model = model_name,
         recall = .@x.values[[1]],
         precision = .@y.values[[1]],
         cutoff = .@alpha.values[[1]])
}

prec_rec_data <- map2_df(model_preds, model_names, get_prec_rec_df) %>% 
  mutate(model = ordered(model, model_names),
         precision = if_else(is.nan(precision), 1, precision))

prec_rec_line_data <- filter(prec_rec_data, model %in% c("Logistic Regression", "Random Forest"))
prec_rec_point_data <- anti_join(prec_rec_data, prec_rec_line_data, by = "model")

prec_rec_line_data %>% 
  ggplot(aes(recall, precision, color = model)) + 
  geom_line() +
  geom_point(data = prec_rec_point_data) +
  labs(title = "Precision-Recall Space",
       subtitle = "Any Serious Violations in 2016",
       color = NULL, x = "Recall", y = "Precision")
```

![](models_files/figure-markdown_github/pr-curve-1.png)
