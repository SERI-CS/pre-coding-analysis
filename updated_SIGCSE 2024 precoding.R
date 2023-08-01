---
  title: "Precoding analysis"
author: "Joyce Zhang and Elizabeth Cloude"
date: "08/01/2023"
output: html_document
---

library(tidyverse)
library(lubridate)
library(stringr)
library(reshape2)
library(ggplot2)
library(psych)
library(knitr)
library(dplyr)

### extra packages needed to install alpha.correction.bh package by Mogessie (2023); https://cran.r-project.org/web/packages/alpha.correction.bh/readme/README.html
write('PATH="${RTOOLS40_HOME}\\usr\\bin;${PATH}"', file = "~/.Renviron", append = TRUE)
Sys.which("make")
## "C:\\rtools40\\usr\\bin\\make.exe"
install.packages("jsonlite", type = "source")


### Jump here if you already have Rtools 4.0 installed 
devtools::install_github('pcla-code/alpha.correction.bh', force = TRUE)

set.seed(20)

options(scipen=999)

setwd("C://")

### use of platform before start coding ###
df_seq <- read.csv("del_pre.csv") 

# import grade
df_grade <- 
  read.csv("df_HWGrades.csv") %>% 
  select(-grade,-HashedId) %>% 
  melt(id = "PennId") %>% 
  mutate(variable = as.numeric(gsub("X","",variable))) %>% 
  select(PennId, Unit = variable,grade = value) %>% 
  group_by(Unit) %>% 
  mutate(rank = rank(grade))

#nrow(df_grade[!duplicated(df_grade[c(1,2)]),]) #make sure there's no duplicates

# import class schedule
HW_date <- 
  read.csv("HW release date.csv") %>% 
  mutate(
    release.date = mdy(release.date),
    HW = as.numeric(gsub("HW0","",ï..HW)))

#start date & 4 measures
# Date diff between start date and HW release date
df_dateDiff <- 
  left_join(
    df_seq %>% subset(Event == "CodioAssign"),
    HW_date, 
    by = c("Unit" = "HW")) %>% 
  mutate(dateDiff = as.numeric(mdy(date) - ymd(release.date))) %>% 
  select("PennId","Unit","Event","dateDiff")

df_dateDiff = df_dateDiff[!duplicated(df_dateDiff[c(1,2)]),]

# number of days on piazza
piazza_canvas_Days <- 
  df_seq %>% 
  group_by(PennId,Unit) %>% 
  summarise(
    NDaysPiazza = sum(Event == "Piazza"),
    NDaysCanvas = sum(Event == "Canvas"))

# piazza posts viewed
piazza_posts <- 
  left_join(
    read.csv("df_Piazza.csv"),
    subset(df_seq,Event == "CodioAssign"), 
    by = c("PennId","Unit")) %>% 
  mutate(Keep = ifelse(ymd_hms(Timestamp.x) <= mdy_hm(Timestamp.y),1,0)) %>% 
  subset(Keep ==1) %>% 
  select(PennId, Unit, Timestamp.x) %>% 
  mutate(Event = "Piazza") %>% 
  group_by(PennId,Unit) %>% 
  summarise(NViews = n())

# canvas videos watched in minutes
df_v = 
  read.csv("canvas_videos_data_fa20_anon.csv") %>% 
  subset(Category != "Exam 1 Review Sessions") %>% 
  mutate(Timestamp = mdy_hm(Timestamp))

df_mapping = read.csv("video_HW_mapping.csv")

df_v = left_join(df_v,df_mapping, by = "Topic")
colnames(df_v)[9] = "Unit"
df_v$Unit = as.numeric(as.character(df_v$Unit))

canvas_minutes = 
  inner_join(
    df_v,
    subset(df_seq,Event == "CodioAssign"), by = c("PennId","Unit")) %>%
  mutate(Keep = ifelse(ymd_hms(Timestamp.x) <= mdy_hm(Timestamp.y),1,0)) %>%
  subset(Keep ==1) %>% 
  group_by(PennId,Unit) %>%
  summarise(
    NVideos_clips = n(),
    NVideos = n_distinct(Topic),
    NMinutes = sum(Minutes))


    ## join data frames
df_startDate = 
  left_join(df_dateDiff, piazza_canvas_Days, by = c("PennId","Unit")) %>% 
  left_join(.,piazza_posts, by = c("PennId","Unit")) %>% 
  left_join(.,canvas_minutes, by = c("PennId","Unit"))

df_startDate[, c(5,6,7,10)][is.na(df_startDate[,c(5,6,7,10)])] <- 0


#### RQ1 ###

#rank of days on Piazza
df_startDate %>% 
  subset(NDaysPiazza>0) %>% 
  group_by(Unit) %>% 
  summarise(
    N = n(),
    sum(NDaysPiazza),
    mean(NDaysPiazza))

# rank of days on Canvas
df_startDate %>% 
  subset(NDaysCanvas>0) %>% 
  group_by(Unit) %>% 
  summarise(
    sum = sum(NDaysCanvas),
    N_students = n_distinct(PennId),
    avg = mean(NDaysCanvas))

# rank of post viewed on Piazza
df_startDate %>% 
  subset(NDaysPiazza>0) %>% 
  group_by(Unit) %>% 
  summarise(
    sum = sum(NViews),
    N_students = n_distinct(PennId),
    avg = mean(NViews))

# rank of minutes of video watched on Canvas
df_startDate %>% 
  subset(NDaysCanvas>0) %>% 
  group_by(Unit) %>% 
  summarise(
    sum = sum(NMinutes),
    N_students = n_distinct(PennId),
    avg = mean(NMinutes))

# correlation
difficulty = c(0,7,5,3,1,2,6,4,8)
NDaysPiazza = c(0,8,3,4,5,2,1,6,7)
NDaysCanvas = c(0,7,8,3,2,5,1,6,4)
NPostsViewed = c(0,8,2,1,5,3,4,7,6)
NMinutedWatched = c(0,5,2,7,6,8,3,1,4)

cor.test(difficulty,NDaysPiazza, method = "spearman")
cor.test(difficulty,NDaysCanvas, method = "spearman")
cor.test(difficulty,NPostsViewed, method = "spearman")
cor.test(difficulty,NMinutedWatched, method = "spearman")

# p-values:
get_alphas_bh(list(0.1206,0.2125,0.0968,0.9484)) # not significant

## RQ2 ##
library("Hmisc")
df_corr = select(df_startDate,"NDaysPiazza","NDaysCanvas","NViews","NMinutes")

res2 <- rcorr(as.matrix(df_corr), type = "spearman")
res2
res2$P

temp = df_startDate %>% 
  group_by(Unit) %>% 
  summarise(
    N = n(),
    NDaysPiazza_avg = mean(NDaysPiazza),
    NDaysCanvas_avg = mean(NDaysCanvas),
    NPostsViewedPiazza_avg = mean(NViews),
    NMinutesWathedCanvas_avg = mean(NMinutes)
  )

# overall
library(Rfit)
a <- rfit(dateDiff~ as.factor(Unit) + NDaysPiazza+NDaysCanvas + NViews + NMinutes, scores = bentscores1, , data = df_startDate)
summary_stats <- summary(a)

p_values <- summary_stats$coefficients[, "p.value"]

get_alphas_bh(p_values) # corrected alphas using B-H correction

#Unit 0 
df_0 = subset(df_startDate, Unit == 2) %>% mutate(NMinutes != 0)
all.reg <- rfit(dateDiff~ NDaysPiazza+NDaysCanvas + NViews + NMinutes, scores = bentscores1, data = df_0)

# check for homoscedasticity assumption (constant variance)
plot(all.reg$fitted.values, which = 1)
# check for the normality of the residuals
plot(all.reg$residuals, which = 2)
#check for multicollinearity assumption by checking the variance inflation factors (VIF)
library(usdm)
vif.1 <- usdm::vif(df_0[,c(5,6,7,10)]) #VIF should be below 5
vif.1 

# for each homework
variableResults_all = NULL
modelResults_all = NULL

for (i in c(1:9)) {
  temp = subset(df_startDate, Unit == i)
  temp = subset(temp, NDaysPiazza>0 | NDaysCanvas>0)
  r = summary(rfit(dateDiff ~ NDaysPiazza + NDaysCanvas + NViews + NMinutes, scores = bentscores1, data = temp))
  coe = as.data.frame(r$coefficients[,1])
  bh_correction = get_alphas_bh(r$coefficients[,"p.value"])
  
  variableResults = cbind(rep(i,5),coe, bh_correction)
  variableResults_all = rbind(variableResults_all, variableResults)
  
  rSqr = r$r.squared
  fStats = r$fstatistic
  
  modelResults = cbind(rep(i,3),rSqr,fStats)
  modelResults_all = rbind(modelResults_all, modelResults)
  
  print(i)
  print(r)
  
  
}  

## RQ3

df_gradeRanks = 
  left_join(df_grade, df_startDate, by = c("PennId","Unit"))

df_gradeRanks = df_gradeRanks[!duplicated(df_gradeRanks[c(1,2)]),]
df_gradeRanks <- subset(df_gradeRanks,df_gradeRanks$dateDiff<=15)

b <- rfit(rank~as.factor(Unit) + NDaysPiazza + NDaysCanvas + NViews + NMinutes,  scores = bentscores1, data = df_gradeRanks)
summary_stats <- summary(b)

p_values <- summary_stats$coefficients[, "p.value"]

get_alphas_bh(p_values) # corrected alphas using B-H correction

#HW 0
df_grade_3 = subset(df_gradeRanks, Unit == 3)

all.reg <- rfit(rank~ NDaysPiazza + NDaysCanvas + NViews + NMinutes, scores = bentscores1, data = df_grade_3)
summary_stats <- summary(all.reg)

p_values <- summary_stats$coefficients[, "p.value"]

get_alphas_bh(p_values) # corrected alphas using B-H correction

# check multiple linear regression assumptions
# check for homoscedasticity assumption (constant variance)
plot(all.reg, which = 1)
# check for the normality of the residuals
plot(all.reg$residuals, which = 2)

# for each homework
for (i in c(1:9)) {
  temp = subset(df_gradeRanks, Unit == i)
  r = summary(rfit(rank~ NDaysPiazza + NDaysCanvas + NViews + NMinutes, scores = bentscores1, data = temp))
  print(i)
  print(r)
  
}

# individual model for each HW ----
variableResults_all = NULL

for (i in c(1:9)){
  temp = subset(df_gradeRanks, Unit == i)
  
  for(x in c(7,8,9,12)){
    
    predictor_name = colnames(temp[x])
    predictor_column = temp[,x] %>% unlist()
    r = summary(rfit(temp$rank ~ predictor_column, scores = bentscores1))
    
    coe = as.data.frame(r$coefficients[2,1])
    bh_correction = get_alphas_bh(r$coefficients[,"p.value"])
    
    variableResults = cbind(i,predictor_name,coe, bh_correction)
    variableResults_all = rbind(variableResults_all, variableResults)
    
    print(i)
    print(predictor_name)
    print(coe)
    print(bh_correction)
  }
  
}

colnames(variableResults_all)[3] <- "coe"
colnames(variableResults_all)[4] <- "bh_correction"
variableResults_all$sigLevel = 
  ifelse(
    variableResults_all$p <=.001,"***",
    ifelse(variableResults_all$p <=.01,"**",
           ifelse(variableResults_all$p <=.05,"*",
                  ifelse(variableResults_all$p <=.1,".",""))))

variableResults_all$Coefficient_sig = paste0(round(variableResults_all$coe,2),variableResults_all$sigLevel)
