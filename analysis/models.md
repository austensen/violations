R Notebook
================

``` r
library(plyr)
library(rpart)
library(randomForest)
library(caret)
library(tidyverse)
library(stringr)
library(broom)
library(AUC)

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
(past_viol_info <- confusionMatrix(df_15[["outcome"]], df_16[["outcome"]]))
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
    ##             Sensitivity : 0.8708          
    ##             Specificity : 0.5589          
    ##          Pos Pred Value : 0.8696          
    ##          Neg Pred Value : 0.5615          
    ##              Prevalence : 0.7716          
    ##          Detection Rate : 0.6719          
    ##    Detection Prevalence : 0.7727          
    ##       Balanced Accuracy : 0.7149          
    ##                                           
    ##        'Positive' Class : FALSE           
    ## 

Using the presence of serious violations in 2015 to predict violations for 2016 achieves an accuracy of 0.79957, which is only a slight improvement over the no information rate of 0.7716197, and has a Kappa statistic of 0.4304075.

------------------------------------------------------------------------

Logit
=====

Next I fit a Logit model using all the attributes for the `df_15` training data set. I then get the predicted values on the `df_16` test data and iterate over threshold values, deciding on 0.5.

``` r
glm_fit <- glm(outcome ~ ., family = "binomial", df_15)
```

    ## Warning: glm.fit: fitted probabilities numerically 0 or 1 occurred

``` r
glm_p <- predict(glm_fit, df_16, type = "response")
```

    ## Warning in predict.lm(object, newdata, se.fit, scale = 1, type =
    ## ifelse(type == : prediction from a rank-deficient fit may be misleading

``` r
print_results <- function(threshold, preditions) {
  ret <- if_else(preditions > threshold, TRUE, FALSE) %>% 
    as.factor %>% 
    confusionMatrix(df_16[["outcome"]])
  
  message(str_c("\nThreshold: ", threshold))
  print(ret)
}

# walk(seq(0.1, 0.9, 0.1), print_results, preditions = glm_p)

glm_info <- if_else(glm_p > .5, TRUE, FALSE) %>% 
    as.factor %>% 
    confusionMatrix(df_16[["outcome"]])

print_results(.5, glm_p)
```

    ## 
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

The Logit model achieves an accuracy of 0.8182035, which is only a slight improvement over the previous year's violation prediction and even better than the no information rate of 0.7716197. The Logit model achieves a Kappa statistic of 0.3872416.

------------------------------------------------------------------------

Decision Tree
=============

Next I try a simple decision tree with 10 times 10-fold Cross-validation.

``` r
tree_fit_control <- trainControl(method = "repeatedcv", number = 10, repeats = 10)

tree_fit <- train(outcome ~ ., data = df_15, 
                  method = "rpart", 
                  trControl = tree_fit_control)

tree_p <- predict(tree_fit, newdata = df_16)

(tree_info <- confusionMatrix(tree_p, df_16[["outcome"]]))
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

The decision tree's accuracy of 0.812072, is a further improvement over the accuracy Logit model, the previous year's violation prediction, and no information rate. The decision tree model also achieves an improved Kappa statistic of 0.454879.

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

(forest_info <- confusionMatrix(forest_p, df_16[["outcome"]]))
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

The Random Forest outperforms all the previous models in terms of accuracy with a value of 0.827361. This still is only a slight improvement over all the previous models, and still is only modestly more accurate than the no information rate or previous year's violation prediction of 0.79957 and 0.7716197, respectively. The Random Forest also has a Kappa statistic of 0.4657064.

ROC Space
=========

In addition the the various statistics generated above, it is helpful to visualize the performance of the various models by plotting the models' true positive and false positive rates in a ROC space. Only the Logit model can be plotted as a ROC curve and have an AUC calculated, while the others are represented simply by points in the ROC space.

``` r
glm_roc <- AUC::roc(glm_p, df_16[["outcome"]])
glm_auc <- AUC::auc(glm_roc)

past_viol_fpr <- 1 - past_viol_info[["byClass"]][["Specificity"]]
past_viol_tpr <- past_viol_info[["byClass"]][["Sensitivity"]]

tree_fpr <- 1 - tree_info[["byClass"]][["Specificity"]]
tree_tpr <- tree_info[["byClass"]][["Sensitivity"]]

forest_fpr <- 1 - forest_info[["byClass"]][["Specificity"]]
forest_tpr <- forest_info[["byClass"]][["Sensitivity"]]

glm_roc %>% 
  broom::tidy() %>%
  ggplot(aes(fpr, tpr)) + 
  geom_line() +
  geom_segment(x = 0, xend = 1, y = 0, yend = 1, linetype = "dashed", color = "grey") +
  annotate("text", x = .3, y = .6, label = str_interp("Logit AUC = ${round(glm_auc, 3)}")) +
  annotate("point", x = past_viol_fpr, y = past_viol_tpr, color = "red") + 
  annotate("text", x = past_viol_fpr - .15, y = past_viol_tpr, label = "Previous Year Violation", color = "red") +
  annotate("point", x = tree_fpr, y = tree_tpr, color = "blue") + 
  annotate("text", x = tree_fpr - .07, y = tree_tpr + .04, label = "Decision Tree", color = "blue") +
  annotate("point", x = forest_fpr, y = forest_tpr, color = "goldenrod") + 
  annotate("text", x = forest_fpr + .07, y = forest_tpr + .05, label = "Random Forest", color = "goldenrod") +
  labs(title = "ROC Space",
       subtitle = "Any Serious Violations in 2016",
       x = "False Positive Rate", y = "True Positive Rate")
```

![](models_files/figure-markdown_github/roc-curve-1.png)
