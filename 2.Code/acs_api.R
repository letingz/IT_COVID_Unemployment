############
#title: "ACS"
#author: Leting Zhang
#date: 03/31/2021
#output: html_notebook
#############

# Tidycensus usage: https://walker-data.com/tidycensus/articles/basic-usage.html

########### Setting ###########

library(tidycensus)
library(tidyverse)
library(ggpubr)
#API
usethis::edit_r_environ()
# CENSUS_API_KEY = c398f8d9513b22463637096597e4bd7ea0be7e4f

census_api_key("c398f8d9513b22463637096597e4bd7ea0be7e4f")

all_vars_acs5_19 <- 
  load_variables(year = 2019, dataset = "acs5/profile")


var <-  c( "DP02_0001", "DP02_0018", "DP02_0067P", "DP02_0068P",
           "DP02_0152P", "DP02_0153P", "DP03_0062", "DP03_0063",
          "DP03_0033P", "DP03_0034P","DP03_0035P","DP03_0036P","DP03_0037P", "DP03_0038P", "DP03_0039P", "DP03_0040P",
          "DP03_0041P","DP03_0042P","DP03_0043P","DP03_0044P","DP03_0045P",   "DP03_0096P")


var_info <- all_vars_acs5_19 %>% 
  filter(name %in% var )

df_acs <-
  get_acs(
    geography = "county", 
    variables = var, 
    year = 2019
  )

colnames(var_info)[1] <- "variable"

df_acs <- df_acs %>% 
  left_join(var_info)




df_acs1 <- df_acs %>% 
  mutate(name = case_when (
    variable == "DP02_0001" ~ "totalhousehold",
    variable == "DP02_0018" ~ "population",
    variable == "DP02_0067P" ~ "highschoolhigherper"  ,
    variable == "DP02_0068P" ~  "bachelorhigherper",
    variable == "DP02_0152P" ~ "computerper",
    variable == "DP02_0153P" ~  "internetper", 
    variable == "DP03_0033P" ~  "agriculture",
    variable == "DP03_0034P" ~ "construction" ,
    variable == "DP03_0035P" ~  "manufacturing" ,
    variable == "DP03_0036P" ~ "wholesale",
    variable == "DP03_0037P" ~ "retail",
    variable == "DP03_0038P" ~ "transportation",
    variable == "DP03_0039P" ~ "information",
    variable == "DP03_0040P" ~ "insurance",
    variable ==  "DP03_0041P" ~ "Professional",
    variable == "DP03_0042P" ~ "education",
    variable == "DP03_0043P" ~ "arts",
    variable == "DP03_0044P" ~ "other services",
    variable == "DP03_0045P" ~ "publicadmin",
    variable == "DP03_0062" ~ "medianhouseholdincome",
    variable == "DP03_0063" ~ "meanincome",
    variable == "DP03_0096P" ~ "healthinsurance"
    
  )) %>% 
  select(c("GEOID", "estimate", "name"))


df_acs1$countyfips <- as.numeric(df_acs1$GEOID)

############ compare employment rate vs unemployment rate differences
load("~/Covid-Cyber-Unemploy/.RData")

#unique county in "employment" dataset
sub_employ_county <- subset(employ_county_mean, !is.na(emp_combined))
sub_employ_county <- sub_employ_county[, c("countyfips")] %>% distinct() %>% mutate(label = "payroll")

#unique county in "unemployment" dataset
sub_ui_mean_county <- ui_mean_county[, c( "countyfips")] %>% distinct() %>% mutate(label = "ui")
sub_dv <- rbind(sub_employ_county, sub_ui_mean_county)

sub_dv_char <- merge(sub_dv, df_acs1, all.x = TRUE)

demo <- sub_dv_char %>% 
  group_by(label, name) %>% 
  summarise(value = list(estimate))

sub_dv_char %>% 
  ggplot( aes(x = label, y = estimate, color = label) ) + geom_boxplot() + facet_wrap(~ name, scales = "free")

p <- sub_dv_char %>% 
  filter(name %in% c("bachelorhigherper", "computerper", "healthinsurance",
                     "highschoolhigherper", "internetper", "meanincome", "medianhouseholdincome",
                     "population")) %>% 
  ggboxplot(x = "label", y = "estimate", color = "label" ) 

facet(p, facet.by  = "name", scales = "free") + stat_compare_means(method = "t.test", label.x.npc = "center", vjust = 2)

