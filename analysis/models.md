Violation Prediction Models
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
df <- feather::read_feather("../data/merged.feather") %>% drop_na()

df_15 <- df %>% 
  mutate(viol_bbl_ser_all_2015 = viol_bbl_bldg_ser_2015 + viol_bbl_apt_ser_2015,
         outcome = factor(viol_bbl_ser_all_2015 > 0)) %>% 
  select(-matches("2015|2016$"), -bbl, -block, -tract10) %>% 
  mutate_if(is.character, as.factor)

names(df_15) <- names(df_15) %>% str_replace_all("2014", "1") %>% str_replace_all("2013", "2")

df_16 <- df %>% 
  mutate(viol_bbl_ser_all_2016 = viol_bbl_bldg_ser_2016 + viol_bbl_apt_ser_2016,
         outcome = factor(viol_bbl_ser_all_2016 > 0)) %>% 
  select(-matches("2013|2016$"), -bbl, -block, -tract10) %>% 
  mutate_if(is.character, as.factor)

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
    ## Prediction  FALSE   TRUE
    ##      FALSE 131327   7136
    ##      TRUE    7071   7963
    ##                                          
    ##                Accuracy : 0.9074         
    ##                  95% CI : (0.906, 0.9089)
    ##     No Information Rate : 0.9016         
    ##     P-Value [Acc > NIR] : 6.376e-15      
    ##                                          
    ##                   Kappa : 0.4772         
    ##  Mcnemar's Test P-Value : 0.5913         
    ##                                          
    ##             Sensitivity : 0.52739        
    ##             Specificity : 0.94891        
    ##          Pos Pred Value : 0.52967        
    ##          Neg Pred Value : 0.94846        
    ##               Precision : 0.52967        
    ##                  Recall : 0.52739        
    ##                      F1 : 0.52852        
    ##              Prevalence : 0.09837        
    ##          Detection Rate : 0.05188        
    ##    Detection Prevalence : 0.09794        
    ##       Balanced Accuracy : 0.73815        
    ##                                          
    ##        'Positive' Class : TRUE           
    ## 

Using the presence of serious violations in 2015 to predict violations for 2016 achieves an accuracy of 0.9074444, which is only a slight improvement over the no information rate of 0.9016333. This simple prediction has a Kappa statistic of 0.4772093, its precision is 0.5296661 and recall is 0.5273859.

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
    ## Prediction  FALSE   TRUE
    ##      FALSE 123525   5192
    ##      TRUE   14873   9907
    ##                                          
    ##                Accuracy : 0.8693         
    ##                  95% CI : (0.8676, 0.871)
    ##     No Information Rate : 0.9016         
    ##     P-Value [Acc > NIR] : 1              
    ##                                          
    ##                   Kappa : 0.4268         
    ##  Mcnemar's Test P-Value : <2e-16         
    ##                                          
    ##             Sensitivity : 0.65614        
    ##             Specificity : 0.89253        
    ##          Pos Pred Value : 0.39980        
    ##          Neg Pred Value : 0.95966        
    ##               Precision : 0.39980        
    ##                  Recall : 0.65614        
    ##                      F1 : 0.49685        
    ##              Prevalence : 0.09837        
    ##          Detection Rate : 0.06454        
    ##    Detection Prevalence : 0.16144        
    ##       Balanced Accuracy : 0.77434        
    ##                                          
    ##        'Positive' Class : TRUE           
    ## 

The Logit model achieves an accuracy of 0.8692808, which is only a slight improvement over the previous year's violation prediction and even better than the no information rate of 0.9016333. The Logit model achieves a Kappa statistic of 0.4267789, its precision is 0.3997982, and recall is 0.6561362.

------------------------------------------------------------------------

Decision Tree
=============

Next I try a simple decision tree with 10 times 10-fold Cross-validation.

``` r
tree_fit_control <- trainControl(method = "repeatedcv", number = 2) # repeats = 10

tree_fit <- train(outcome ~ ., data = df_15, 
                  method = "rpart", 
                  trControl = tree_fit_control)

tree_p <- predict(tree_fit, df_16)

(tree_info <- confusionMatrix(tree_p, df_16[["outcome"]], positive = "TRUE", mode = "everything"))
```

    ## Confusion Matrix and Statistics
    ## 
    ##           Reference
    ## Prediction  FALSE   TRUE
    ##      FALSE 135414   8989
    ##      TRUE    2984   6110
    ##                                           
    ##                Accuracy : 0.922           
    ##                  95% CI : (0.9206, 0.9233)
    ##     No Information Rate : 0.9016          
    ##     P-Value [Acc > NIR] : < 2.2e-16       
    ##                                           
    ##                   Kappa : 0.4656          
    ##  Mcnemar's Test P-Value : < 2.2e-16       
    ##                                           
    ##             Sensitivity : 0.40466         
    ##             Specificity : 0.97844         
    ##          Pos Pred Value : 0.67187         
    ##          Neg Pred Value : 0.93775         
    ##               Precision : 0.67187         
    ##                  Recall : 0.40466         
    ##                      F1 : 0.50510         
    ##              Prevalence : 0.09837         
    ##          Detection Rate : 0.03981         
    ##    Detection Prevalence : 0.05925         
    ##       Balanced Accuracy : 0.69155         
    ##                                           
    ##        'Positive' Class : TRUE            
    ## 

The decision tree's accuracy of 0.9219985, is a further improvement over the accuracy Logit model, the previous year's violation prediction, and no information rate. The decision tree model also achieves an improved Kappa statistic of 0.4655843, and its precision is 0.6718716, and recall is 0.4046626.

``` r
varImp(tree_fit)
```

    ## rpart variable importance
    ## 
    ##   only 20 most important variables shown (out of 65)
    ## 
    ##                      Overall
    ## viol_bbl_apt_oth_1   100.000
    ## viol_bbl_apt_ser_1    81.348
    ## viol_bbl_apt_oth_2    78.604
    ## res_sqft              71.941
    ## res_units             68.446
    ## viol_bbl_apt_ser_2     6.113
    ## lot_area               6.112
    ## viol_blk_bldg_ser_2    0.000
    ## building_class1N       0.000
    ## assessed_value         0.000
    ## building_class1S       0.000
    ## building_class1E       0.000
    ## building_class1K       0.000
    ## viol_blk_apt_ser_1     0.000
    ## viol_trct_bldg_oth_1   0.000
    ## zoning1M               0.000
    ## building_class1W       0.000
    ## building_class1M       0.000
    ## viol_trct_bldg_ser_2   0.000
    ## viol_bbl_bldg_ser_2    0.000

As expected, the various indicators of a building's violation record in the current and previous year are the most important attributes for predicting the presence of serious violations in the subsequent year. Additionally, the building's total residential square footage and total lot area, as well as the number of residential units and the total assessed value in the current year are also important.

------------------------------------------------------------------------

Random Forest
=============

Finally, I use a Random Forest model with 10-fold Cross-validation.

``` r
forest_fit_control <- trainControl(method = "repeatedcv", number = 2)

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
    ## Prediction  FALSE   TRUE
    ##      FALSE 133129   6838
    ##      TRUE    5269   8261
    ##                                           
    ##                Accuracy : 0.9211          
    ##                  95% CI : (0.9198, 0.9225)
    ##     No Information Rate : 0.9016          
    ##     P-Value [Acc > NIR] : < 2.2e-16       
    ##                                           
    ##                   Kappa : 0.5338          
    ##  Mcnemar's Test P-Value : < 2.2e-16       
    ##                                           
    ##             Sensitivity : 0.54712         
    ##             Specificity : 0.96193         
    ##          Pos Pred Value : 0.61057         
    ##          Neg Pred Value : 0.95115         
    ##               Precision : 0.61057         
    ##                  Recall : 0.54712         
    ##                      F1 : 0.57711         
    ##              Prevalence : 0.09837         
    ##          Detection Rate : 0.05382         
    ##    Detection Prevalence : 0.08815         
    ##       Balanced Accuracy : 0.75453         
    ##                                           
    ##        'Positive' Class : TRUE            
    ## 

The Random Forest outperforms all the previous models in terms of accuracy with a value of 0.9211255. This still is only a slight improvement over all the previous models, and still is only modestly more accurate than the no information rate or previous year's violation prediction of 0.9074444 and 0.9016333, respectively. The Random Forest also has a Kappa statistic of 0.5337579, and its precision is 0.6105691, and recall is 0.5471223.

``` r
varImp(forest_fit)
```

    ## rf variable importance
    ## 
    ##   only 20 most important variables shown (out of 65)
    ## 
    ##                      Overall
    ## viol_bbl_apt_oth_1    100.00
    ## res_sqft               90.49
    ## res_units              72.72
    ## viol_bbl_apt_ser_1     70.93
    ## assessed_value         59.19
    ## viol_bbl_apt_oth_2     56.47
    ## lot_area               53.92
    ## viol_trct_bldg_ser_1   44.63
    ## viol_blk_apt_oth_1     44.10
    ## viol_trct_bldg_oth_1   43.43
    ## floors                 42.78
    ## viol_blk_apt_ser_1     39.54
    ## viol_trct_bldg_oth_2   37.75
    ## viol_trct_apt_ser_1    36.42
    ## viol_bbl_bldg_oth_1    36.24
    ## viol_blk_bldg_ser_1    34.97
    ## viol_trct_apt_oth_2    34.79
    ## viol_blk_bldg_oth_1    34.42
    ## viol_trct_apt_oth_1    34.35
    ## viol_bbl_bldg_ser_1    33.91

Many of the variables that were important in the single decision tree are also important in the Random Forest model. Others that were important include the number of floors in the building, the Community District in which it is located, and the year it was built.

------------------------------------------------------------------------

Comparing Models
================

First I'll present all the model performance statistics together in a simple table.

``` r
combine_stats <- function(.info) {
  c(.info[["overall"]], .info[["byClass"]])
}

model_names <- c("Past Violation", "Logistic Regression", "Decision Tree", "Random Forest")
stat_names <- tree_info %>% combine_stats() %>% names()

model_stat_table <- list(past_viol_info, glm_info, tree_info, forest_info) %>% 
  map(combine_stats) %>% 
  set_names(model_names) %>% 
  as_tibble %>% 
  mutate_all(funs(round(., digits = 3))) %>% 
  mutate(Statistic = stat_names) %>% 
  select(Statistic, everything())

feather::write_feather(model_stat_table, "../data/model_stat_table.feather")

knitr::kable(model_stat_table)
```

| Statistic            |  Past Violation|  Logistic Regression|  Decision Tree|  Random Forest|
|:---------------------|---------------:|--------------------:|--------------:|--------------:|
| Accuracy             |           0.907|                0.869|          0.922|          0.921|
| Kappa                |           0.477|                0.427|          0.466|          0.534|
| AccuracyLower        |           0.906|                0.868|          0.921|          0.920|
| AccuracyUpper        |           0.909|                0.871|          0.923|          0.922|
| AccuracyNull         |           0.902|                0.902|          0.902|          0.902|
| AccuracyPValue       |           0.000|                1.000|          0.000|          0.000|
| McnemarPValue        |           0.591|                0.000|          0.000|          0.000|
| Sensitivity          |           0.527|                0.656|          0.405|          0.547|
| Specificity          |           0.949|                0.893|          0.978|          0.962|
| Pos Pred Value       |           0.530|                0.400|          0.672|          0.611|
| Neg Pred Value       |           0.948|                0.960|          0.938|          0.951|
| Precision            |           0.530|                0.400|          0.672|          0.611|
| Recall               |           0.527|                0.656|          0.405|          0.547|
| F1                   |           0.529|                0.497|          0.505|          0.577|
| Prevalence           |           0.098|                0.098|          0.098|          0.098|
| Detection Rate       |           0.052|                0.065|          0.040|          0.054|
| Detection Prevalence |           0.098|                0.161|          0.059|          0.088|
| Balanced Accuracy    |           0.738|                0.774|          0.692|          0.755|

Next I'll get the predictions of all the models, and store the names and predictions of the models.

``` r
past_viol_pred <- prediction(as.numeric(df_15[["outcome"]]), df_16[["outcome"]])

glm_pred <- prediction(as.numeric(glm_p), df_16[["outcome"]])

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

I'll also save predictions from the models into a data frame for additional analysis and mapping in later scripts.

``` r
predictions <- tibble(bbl = df[["bbl"]],
                      true_16 = df_16[["outcome"]] %>% as.logical %>% as.numeric, 
                      past_viol = df_15[["outcome"]] %>% as.logical %>% as.numeric,
                      logit = glm_pred@predictions %>% as_vector,
                      tree = tree_pred@predictions %>% as_vector,
                      forest = forest_pred@predictions %>% as_vector)

feather::write_feather(predictions, "../data/model_predictions_16.feather")
```

ROC Space
---------

In addition the the various statistics generated above, it is helpful to visualize the performance of the various models by plotting the models' true positive and false positive rates in a ROC space. Only the Logit model can be plotted as a ROC curve and have an AUC calculated, while the others are represented simply by points in the ROC space.

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

Precision-Recall Space
----------------------

Since the no-information accuracy for prediting violations is realatively high, at 0.9016333, and given that in different potential applications of these predictions we may be particualarily concerend about false positive vs false negatives, it is especially useful to look at the tradeoff between precision and recall for the models. I do this below by ploting the modelss precision-recall curves (or points).

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
