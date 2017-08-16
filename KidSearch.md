KidSearch Analyses:
================

GitHub Documents
----------------

Code to reproduce the analyses in manuscript, "Animacy and object size are reflected in preschoolers perceptual similarity computations by the preschool years"

Step 1: Load packages
---------------------

``` r
library(tidyverse) # for data munging
library(knitr) # for kable table formating
library(haven) # import and export 'SPSS', 'Stata' and 'SAS' Files
library(readxl) # import excel files
library(forcats) #manipulating factors in data frames
library(ez) # for anova
library(lme4)
library(markdown)
library("papaja")
```

Step 1: Load data and choose experiment
---------------------------------------

``` r
## Step 2: Load data
exp = read_tsv("data/Animacy.txt")
#exp = read_tsv("data/ObjectSize.txt")
#exp = read_tsv("data/Edibility.txt")
```

Step 1: Preprocess data
-----------------------

``` r
str(exp)
```

    ## Classes 'tbl_df', 'tbl' and 'data.frame':    762 obs. of  11 variables:
    ##  $ sub           : int  1 1 1 1 1 1 1 1 1 1 ...
    ##  $ RT            : int  4341 1359 1473 1623 1780 1438 1214 1121 1005 1163 ...
    ##  $ condition     : int  2 2 1 1 1 2 2 2 1 1 ...
    ##  $ conditionName : chr  "mixed" "mixed" "uniform" "uniform" ...
    ##  $ correct       : int  1 1 1 1 1 1 1 1 1 1 ...
    ##  $ category      : chr  "Animals" "Objects" "Objects" "Objects" ...
    ##  $ repeatDist    : int  0 0 0 0 0 0 0 0 0 0 ...
    ##  $ conditionCheck: int  2 2 1 1 1 2 2 2 1 1 ...
    ##  $ categoryNum   : int  1 2 2 2 1 1 2 2 1 2 ...
    ##  $ phase         : chr  "ThreeItems" "ThreeItems" "ThreeItems" "ThreeItems" ...
    ##  $ test          : int  3 3 3 3 3 3 3 3 3 3 ...
    ##  - attr(*, "spec")=List of 2
    ##   ..$ cols   :List of 11
    ##   .. ..$ sub           : list()
    ##   .. .. ..- attr(*, "class")= chr  "collector_integer" "collector"
    ##   .. ..$ RT            : list()
    ##   .. .. ..- attr(*, "class")= chr  "collector_integer" "collector"
    ##   .. ..$ condition     : list()
    ##   .. .. ..- attr(*, "class")= chr  "collector_integer" "collector"
    ##   .. ..$ conditionName : list()
    ##   .. .. ..- attr(*, "class")= chr  "collector_character" "collector"
    ##   .. ..$ correct       : list()
    ##   .. .. ..- attr(*, "class")= chr  "collector_integer" "collector"
    ##   .. ..$ category      : list()
    ##   .. .. ..- attr(*, "class")= chr  "collector_character" "collector"
    ##   .. ..$ repeatDist    : list()
    ##   .. .. ..- attr(*, "class")= chr  "collector_integer" "collector"
    ##   .. ..$ conditionCheck: list()
    ##   .. .. ..- attr(*, "class")= chr  "collector_integer" "collector"
    ##   .. ..$ categoryNum   : list()
    ##   .. .. ..- attr(*, "class")= chr  "collector_integer" "collector"
    ##   .. ..$ phase         : list()
    ##   .. .. ..- attr(*, "class")= chr  "collector_character" "collector"
    ##   .. ..$ test          : list()
    ##   .. .. ..- attr(*, "class")= chr  "collector_integer" "collector"
    ##   ..$ default: list()
    ##   .. ..- attr(*, "class")= chr  "collector_guess" "collector"
    ##   ..- attr(*, "class")= chr "col_spec"

``` r
exp$sub = as.factor(exp$sub)
exp$conditionNum = as.numeric(exp$condition)
exp$categoryNum = as.numeric(exp$categoryNum)

## Step 3: Preprocess data
# count how many trials per subject
trialCount=exp %>%
  group_by(sub) %>%
  summarise(trials=sum(phase=='SixItems'), errors=sum(correct==0 & phase=='SixItems'), slow=sum(RT>4000 & phase=='SixItems' & correct==1))

# what percentage of trials were incorrect?
round(mean(trialCount$errors/trialCount$trials)*100,2)
```

    ## [1] 16.14

``` r
# what percentage of correct trials were slow?
round(mean(trialCount$slow/trialCount$trials)*100,2)
```

    ## [1] 5.13

``` r
# Only get data with correct trials less than 4 seconds long when there were six items on the screen.
exp.tidy=exp %>%
  filter(RT<4000) %>%
  filter(correct==1) %>%
  filter(phase=='SixItems')
  
# Now only include subjects who had more than 1 trial speeded trial in each of 4 conditions
exp.tidy=exp.tidy %>%
  group_by(sub) %>%
  mutate(indivCountC1=sum(conditionNum==1 & categoryNum==1)) %>%
  mutate(indivCountC2=sum(conditionNum==1 & categoryNum==2)) %>%
  mutate(indivCountC3=sum(conditionNum==2 & categoryNum==1)) %>%
  mutate(indivCountC4=sum(conditionNum==2 & categoryNum==2)) %>%
  filter(indivCountC1>1) %>%
  filter(indivCountC2>1) %>%
  filter(indivCountC3>1) %>%
  filter(indivCountC4>1) 

# Store included subs
includedSubs=unique(exp.tidy$sub)

# How many trials are included in each condition in this subset of children?
trialCountIncludedSubs=exp.tidy %>%
  group_by(sub) %>% 
  filter(is.element(sub,includedSubs)) %>% 
  summarise(trialCount=length(RT), uniformCount=sum(conditionNum==1), mixedCount=sum(conditionNum==2)) 

# overall how many trials (and sd)
round(mean(trialCountIncludedSubs$trialCount),2)
```

    ## [1] 27.07

``` r
round(sd(trialCountIncludedSubs$trialCount),2)
```

    ## [1] 12.35

``` r
# how many trials on average per condition?
round(mean(trialCountIncludedSubs$uniformCount),2)
```

    ## [1] 13.5

``` r
round(mean(trialCountIncludedSubs$mixedCount),2)
```

    ## [1] 13.57

``` r
# Compute accuracy means
exp.accuracy=exp %>%
  group_by(sub,conditionName, category) %>%
  filter(phase=='SixItems') %>%
  filter(is.element(sub,includedSubs)) %>% # only use subs included in RT anlayses for consistency
  summarise(meanAcc = mean(correct)) # average wtihin subjects
```

Step 3: Accuracy results
------------------------

``` r
# summarize accuracy results
condAccMeans=exp.accuracy %>%
  group_by(conditionName) %>%
  summarize(avgCondAcc=mean(meanAcc), sdCondRT=sd(meanAcc))

# descriptive means (mixed v uniform)
UniMixAcc=round(condAccMeans$avgCondAcc*100,2) 

# ANOVA
accuracyResults=ezANOVA(dv= .(meanAcc), wid= .(sub), within= .(conditionName, category), detailed=TRUE, data=data.frame(exp.accuracy), type=3)
partialEtaSquared=accuracyResults$ANOVA$SSn/(accuracyResults$ANOVA$SSn + accuracyResults$ANOVA$SSd)
```

Children were `round(UniMixAcc[1],2)`% accurate on uniform trials, and `round(UniMixAcc[2],2)` on mixed category trials.

round(accuracyResults\(ANOVA\)F[2],2)

Step 4: RT results
------------------

``` r
## Calculate descriptive statistics: Means and SD
avgByCondAndCat=exp.tidy %>%
  group_by(conditionName,category,sub) %>%
  summarise(meanRT= mean(RT))

# Report descriptives
condMeans=avgByCondAndCat %>%
  group_by(conditionName) %>%
  summarize(avgCondRT=mean(meanRT), sdCondRT=sd(meanRT))

round(condMeans$avgCondRT,0) 
```

    ## [1] 1598 1924

``` r
round(condMeans$sdCondRT,0) 
```

    ## [1] 308 363

``` r
# now by category
categoryMeans=avgByCondAndCat %>%
  group_by(category) %>%
  summarize(avgCatRT=mean(meanRT), sdCatRT=sd(meanRT))

# output category means
round(categoryMeans$avgCatRT,0) 
```

    ## [1] 1790 1731

``` r
round(categoryMeans$sdCatRT,0) 
```

    ## [1] 383 365

``` r
## Inferential statistics: ANOVA and mixed-effects model
RTResults=ezANOVA(dv= .(RT), wid= .(sub), within= .(conditionName, category), detailed=TRUE, data=data.frame(exp.tidy), type=3)
partialEtaSquared=RTResults$ANOVA$SSn/(RTResults$ANOVA$SSn + RTResults$ANOVA$SSd)
```

``` r
## some output text here

## Inferential statistics: Mixed-effects models
# model: main effects of category and condition
exp.tidy$logRT=log(exp.tidy$RT)

# Main model with full condition structure
exp.Model <- lmer(RT ~ conditionName*category + (1|sub), data=exp.tidy)

# null model - no fixed factor of condition (i.e., uniform/mixed) and it's interaction
exp.NullModel <- lmer(RT ~ category + (1|sub), data=exp.tidy)

# model comparison
anova(exp.NullModel,exp.Model)
```

    ## Data: exp.tidy
    ## Models:
    ## exp.NullModel: RT ~ category + (1 | sub)
    ## exp.Model: RT ~ conditionName * category + (1 | sub)
    ##               Df    AIC    BIC  logLik deviance  Chisq Chi Df Pr(>Chisq)
    ## exp.NullModel  4 6010.4 6026.1 -3001.2   6002.4                         
    ## exp.Model      6 5988.5 6012.1 -2988.2   5976.5 25.877      2  2.403e-06
    ##                  
    ## exp.NullModel    
    ## exp.Model     ***
    ## ---
    ## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
