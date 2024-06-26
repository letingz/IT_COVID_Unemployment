# title: "IT and Unemployment Amid COVID-19"
# stage: Stage 1 - Import and clean raw data
# author: "Leting Zhang"
# date: "12/07/2021"
# input: Raw data
# output: R data


# OVERVIEW ----------------------------------------------------------
# The script aims to:
#  - Import data
#  - Merge data 
#  - Create a panel dataset 
# Input: 
#  -  Unemployment data, stay-at-home policy from Economic Indicators
#  -  Covid-19 claim and death rates from Economic Indicators
#  -  IT Workforce from Quarterly Workforce Indicators
#  -  BAIT from CI Database (pre-processed in another R script)
#  -  Geographic crosswalk file
#  -  County basics from American Community Survey (ACS)
#  -  County occupation data from Occupational Employment and Wage Statistics (OEWS)
#  -  Stay at home index from COVIDcast
#  -  Telework index data from DingelNeiman
# Output:
#  -  Panel dataset 




####### LOAD LIBRARY ########

library(tidyverse)
library(here)
library(data.table)
library(R.utils)
library(lubridate)
library(robustHD)
library(haven)

raw_data_path <- here("1.Data","1.raw_data")
int_data_path <- here("1.Data", "2.intermediate_data")
out_data_path <- here("1.Data","3.output_data")

####### LOG  #######



############# IMPORT & CLEAN DATA ###############

####### Import Economic Indicator - EconomicTracker ########

#source: https://github.com/OpportunityInsights/EconomicTracker


# Unemployment Insurance Claim
ui_county <- read.csv(here(raw_data_path, "/EconomicTracker-main/data/UI Claims - County - Weekly.csv"), stringsAsFactors = F)

ui_county <- ui_county%>% mutate_if(is.character,as.numeric)

# Employment 

employment_county <- read.csv(here(raw_data_path, "/EconomicTracker-main/data/Employment Combined - County - Daily.csv"))

employment_county <- employment_county%>% mutate_if(is.character,as.numeric)

####### Import State/County Stay at Home - EconomicTracker ########

#Source:  https://github.com/OpportunityInsights/EconomicTracker
#Other Source: https://www.finra.org/rules-guidance/key-topics/covid-19/shelter-in-place
#National Emergency Concerning: March 13 
#Reference: https://www.whitehouse.gov/presidential-actions/proclamation-declaring-national-emergency-concerning-novel-coronavirus-disease-covid-19-outbreak/
#Reference: https://www.nytimes.com/interactive/2020/us/coronavirus-stay-at-home-order.html

######## Import States Stay at Home policy data

state_policy  <- read.csv(here(raw_data_path,"EconomicTracker-main/data/Policy Milestones - State.csv"), stringsAsFactors = F)
colnames(state_policy)[1] <- "state"

shelterdate <- read.csv(here(raw_data_path, "shelter-in-place.csv"))
shelterdate$State <- str_replace_all(shelterdate$State, "[*]", "") #Remove * in state names

state_info<-data.frame(abb = state.abb, state = state.name)
state_info[] <- lapply(state_info, as.character)

state_info[nrow(state_info) + 1,] = c( "DC", "District of Columbia")
state_info[nrow(state_info) + 1,] = c("PR", "Puerto Rico")

shelterdate <- merge(shelterdate,state_info, by.x = "State", by.y = "state", all.x = TRUE )
shelterdate$Order.Date <- str_replace_all(shelterdate$Order.Date, "/2020", "") #Remove * in state names
shelterdate$Order.Date1 <- shelterdate$Order.Date

shelterdate <- shelterdate %>% separate("Order.Date1", c("OrderMonth", "OrderDay"))

shelterdate$OrderMonth <- as.integer(shelterdate$OrderMonth)
shelterdate$OrderDay <- as.integer(shelterdate$OrderDay)

######## Import County Stay at Home policy data

#source: https://github.com/JieYingWu/COVID-19_US_County-level_Summaries
#After converting date format in python 

county_policy <- read.csv(here(raw_data_path, "county_shutdown.csv"))

county_policy <- county_policy %>% filter(FIPS != 0) %>% 
  mutate(year = 2020, 
         countypolicy_date = ISOdate(year,stay_at_home_month, stay_at_home_day),
         countypolicy_week = week(as.Date(countypolicy_date, "%Y-%m-%d"))  ) %>% select( -c(X, year, stay_at_home_month, stay_at_home_day))

policy_state_county <- shelterdate %>% select(abb, OrderMonth, OrderDay) %>% 
  mutate(year = 2020, 
         statepolicy_date = ISOdate(year,OrderMonth, OrderDay),
         statepolicy_week = week(as.Date(statepolicy_date, "%Y-%m-%d")) ) %>% select(-c(year,year,OrderMonth, OrderDay)) %>% 
  full_join(county_policy, by = c("abb" = "STATE"))

policy_state_county <- policy_state_county %>% select(abb, FIPS, statepolicy_week, countypolicy_week, 
                                                      statepolicy_date, countypolicy_date)

######## Import Covid19 Data from Economic Tracker ########

covid_county <- read.csv(here(raw_data_path, "EconomicTracker-main/data/COVID - County - Daily.csv"), stringsAsFactors = F)
covid_county <- covid_county%>% mutate_if(is.character,as.numeric)


######## Import & Clean: IT Workforce Data from QWI  ########

# Import 
# read each csv - for loop

qwifiles <- list.files(path = here(raw_data_path, "QWI-DATA"))

col <- c("geo_level", "geography", "industry","ownercode", "sex", "agegrp", "education", "firmage", "firmsize", "year", "quarter", "Emp", "EmpS",
         "EmpTotal", "HirA", "FrmJbGn", "FrmJbLs", "FrmJbC", "EarnS", "Payroll")

f <- list()

for (i in 1:length(qwifiles)) {
  f[[i]] <- fread( here(raw_data_path, "QWI-DATA", qwifiles[i]), select = col)
}

allqwidata <- rbindlist(f)

rm(f) # remove it because the data is too large

# Choose IT related industry - industry code
its_industry = c(5112, 5191, 5182, 5415)
computer_industry = c(3341, 3342, 3344, 3345, 5179)

# Create measurement of county level IT employment at 2019 Q4

county_qwi_emp <- allqwidata  %>% 
  filter(geo_level=="C" ) %>% 
  select ( geography, year,quarter, industry, sex, education, EmpS, EmpTotal, EarnS, Payroll)

## Reshape
county_qwi_emp_wide<- dcast(setDT(county_qwi_emp), geography+year+quarter+industry ~ paste0("sex", sex) + paste("education", education), value.var = c("EmpS", "EmpTotal", "EarnS"), na.rm = TRUE, sep = "", sum)

colnames(county_qwi_emp_wide)  <- gsub(" ","",colnames(county_qwi_emp_wide))

county_qwi_agg <- county_qwi_emp_wide %>% 
  filter(year == 2019) %>% 
  group_by(geography, year,quarter) %>% 
  select(geography, year,quarter, industry, contains("E0")) %>%
  summarise(
    # EMPS
    its_emps_all = sum(EmpSsex0educationE0[industry %in% its_industry], na.rm=T),
  
    com_emps_all = sum(EmpSsex0educationE0[industry %in% computer_industry],na.rm=T),
    
    all_emps_all = sum(EmpSsex0educationE0,na.rm=T),

    # EmpTotal
    
    its_empstotal_all = sum(EmpTotalsex0educationE0[industry %in% its_industry], na.rm=T),
   
    com_empstotal_all = sum(EmpTotalsex0educationE0[industry %in% computer_industry],na.rm=T),
   
    all_empstotal_all = sum(EmpTotalsex0educationE0,na.rm=T)

  ) %>% 
  ungroup()

rm(allqwidata, county_qwi_emp, county_qwi_emp_wide)

#output
write.csv(county_qwi_agg,here(out_data_path , "county_qwi_agg.csv"))


######## Import & Clean: CI Database  ########
ci_path <- "C:/Users/Leting/Documents/CI_Investment/1.Data/1.raw_data/USA_2019"

# read CI site description data

path <- paste(ci_path, '/SiteDescription.TXT', sep = '')
col <-  c('SITEID', 'PRIMARY_DUNS_NUMBER', 'COMPANY', 'CITY','STATE','ZIPCODE', 'MSA','EMPLE','REVEN','SALESFORCE','MOBILE_WORKERS','MOBILE_INTL', 'SICGRP', 'SICSUBGROUP')
ci_site <- fread(path, select = col)


# Import CI IT spend data
path <- paste(ci_path, '/ITSpend.TXT', sep = '')
ci_itspend <- fread(path)

# Convert interger64 to numeric 
is.integer64 <- function(x){
  class(x)=="integer64"
}

ci_itspend <- ci_itspend %>% 
  mutate_if(is.integer64, as.numeric)


# Import 2019 IT group data (processed in HPC center "covid_tech_analyses_new_task.Rmd" cell 19 - 21 )

#adopttech_19 <- readRDS("~/Covid-Cyber-Unemploy/1.Data/1.raw_data/adopttech_19_site_techgroup.rds")

county_adopttech_19 <- readRDS(here(raw_data_path, "it_app_Dec2021.rds"))



####### Import Geo data & Geo crosswalk file #######

#source: census website PS: USE THE NEW ONE 
#industry_code <- read.csv("cps_monthly_data/2017-census-industry-classification-titles-and-code-list.csv")
#occupation_code<-read.csv("cps_monthly_data/2018-census-occupation-classification-titles-and-code-list.csv")

geo_code <- read.csv(here(raw_data_path,"geocorr2018 -crosswalk.csv"))

#source: https://www.huduser.gov/portal/datasets/usps_crosswalk.html
zip_county <- read.csv(here(raw_data_path, "ZIP_COUNTY_122019.csv"))


zip_county_use <- zip_county %>%  # if a ZIP code belongs to two COUNTY, chose the COUNTY with higher proportion. 
  select(ZIP, COUNTY, RES_RATIO) %>% 
  group_by(ZIP) %>% 
  mutate(numcounty = n(), 
         max_ratio = max(RES_RATIO)) %>% 
  filter(RES_RATIO == max_ratio) %>% select(c(ZIP, COUNTY)) %>% 
  as.data.frame()

write_rds(zip_county_use, here(out_data_path, "zip_county_use.rds"))
#source: https://data.nber.org/cbsa-msa-fips-ssa-county-crosswalk/2019/
msa_county <- read.csv(here(raw_data_path, "COUNTY_METRO2019.CSV"))

write.csv(zip_county_use, here(out_data_path, "zip_county_use.csv"))
# EconomicTrack
geoid <- read.csv(here(raw_data_path, "GeoIDs - County.csv"), stringsAsFactors = F)



####### Import ACS (American Community Survey) file #######

#source(here("2.Code", "census_bls_api_data.R")) 

library(tidycensus)

#usethis::edit_r_environ()
#Use your census_api_key
#census_api_key("c398f8d9513b22463637096597e4bd7ea0be7e4f")

readRenviron("~/.Renviron")

all_vars_acs5_19 <- 
  load_variables(year = 2019, dataset = "acs5/profile")

head(all_vars_acs5_19 )



# data dictionary : https://api.census.gov/data/2019/acs/acs5/profile/groups/DP02.html

var <-  c( "DP02_0001", "DP02_0018", "DP02_0067P", "DP02_0068P",
           "DP02_0152P", "DP02_0153P", "DP03_0062", "DP03_0063",
           "DP03_0033P", "DP03_0034P","DP03_0035P","DP03_0036P","DP03_0037P", "DP03_0038P", "DP03_0039P", "DP03_0040P",
           "DP03_0041P","DP03_0042P","DP03_0043P","DP03_0044P","DP03_0045P",   "DP03_0096P", "DP05_0018",
           "DP05_0038P" )


var_info <- all_vars_acs5_19 %>% 
  filter(name %in% var )

df_acs <-
  get_acs(
    geography = "county", 
    variables = var, 
    year = 2019
  )

colnames(var_info)[1] <- "variable"

#20230523 add new variables

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
    variable == "DP03_0096P" ~ "healthinsurance",
    variable == "DP05_0018" ~ "medianage",
    variable == "DP05_0038P" ~ "blackper"
    
    
  )) %>% 
  select(c("GEOID", "estimate", "name"))


df_acs1$countyfips <- as.numeric(df_acs1$GEOID)

county_acs <- df_acs1 %>% filter(name %in% c("medianage", "blackper", "internetper", "meanincome", "medianhouseholdincome", 
                                              "population", "totalhousehold", "highschoolhigherper", 
                                                "bachelorhigherper", "computerper",
                                                "agriculture", "construction", "manufacturing", "wholesale", 
                                             "retail", "transportation", "information", "insurance") ) %>% 
                    select(-GEOID) %>% 
                      pivot_wider(
                        names_from = name , 
                        values_from = c(estimate)
                      )

library(foreign)
write.dta(county_acs, here(out_data_path, "county_acs_new.dta"))


rm(df_acs, df,acs1)


####### Import OEWS (Occupational Employment and Wage Statistics) from Bureau of LS #######
#source: https://www.bls.gov/oes/

oews <- readxl::read_xlsx(here(raw_data_path, "MSA_M2019_dl.xlsx"))
oews_use <- oews %>% 
  filter(o_group == "major") %>% 
  select(area, area_title, occ_title, o_group, tot_emp, jobs_1000, loc_quotient) %>% 
  mutate(area = as.numeric(area)) %>% 
  left_join(msa_county[, c('FIPS.County.Code', 'CBSA')], by = c( 'area' = 'CBSA'))

oews_use <- oews_use %>% 
        mutate(occ_abb_title = case_when(
          occ_title == "Management Occupations" ~ "manag_occ",
          occ_title == "Business and Financial Operations Occupations" ~ "bus_fin_oc",
          occ_title == "Computer and Mathematical Occupations" ~ "com_math_oc",
          occ_title == "Architecture and Engineering Occupations" ~ "arch_engin_oc",
          occ_title == "Life, Physical, and Social Science Occupations" ~ "life_phy_oc",
          occ_title == "Community and Social Service Occupations" ~ "com_socser_oc",
          occ_title == "Legal Occupations" ~ "legal_oc",
          occ_title == "Educational Instruction and Library Occupations" ~ "edu_lib_oc",
          occ_title == "Arts, Design, Entertainment, Sports, and Media Occupations" ~ "art_sport_oc",
          occ_title == "Healthcare Practitioners and Technical Occupations" ~ "health_oc",
          occ_title == "Healthcare Support Occupations" ~ "health_sup_oc",
          occ_title == "Protective Service Occupations" ~ "protect_oc",
          
          occ_title == "Food Preparation and Serving Related Occupations" ~  "food_ser_oc", 
          occ_title == "Building and Grounds Cleaning and Maintenance Occupations" ~ "buil_clean_oc",
          occ_title == "Personal Care and Service Occupations" ~ "percare_ser_oc" ,
          occ_title == "Sales and Related Occupations" ~ "sale_oc" ,
          occ_title == "Office and Administrative Support Occupations" ~ "off_admin_oc",
          occ_title == "Farming, Fishing, and Forestry Occupations" ~ "farm_fish_oc" ,
          occ_title == "Construction and Extraction Occupations" ~ "construct_oc" ,
          occ_title == "Installation, Maintenance, and Repair Occupations" ~ "inst_mainte_oc" ,
          occ_title == "Production Occupations" ~ "prodct_oc",
          occ_title == "Transportation and Material Moving Occupations" ~ "trans_oc"
        )) %>% select(-occ_title)
colnames(oews_use)[4] <- "county"

oews_use <- oews_use %>%  
        pivot_wider(
        names_from = c(occ_abb_title), 
        values_from = c(tot_emp,loc_quotient, jobs_1000)
      )

write_dta(oews_use, here("Stata", "oews_use.dta"))


####### Import COVIDcast data from API  #######
#source: https://cmu-delphi.github.io/delphi-epidata/api/covidcast-signals/safegraph.html
#devtools::install_github("cmu-delphi/covidcast", ref = "main",
                         #subdir = "R-packages/covidcast")

library(covidcast)


home_prop_7day <- suppressMessages(
  covidcast_signal(data_source = "safegraph", signal = "completely_home_prop_7dav",
                   start_day = "2020-01-01", end_day = "2020-11-10",
                   geo_type = "county"))


median_home_time_7dav <- suppressMessages(
  covidcast_signal(data_source = "safegraph", signal = "median_home_dwell_time_7dav",
                   start_day = "2020-01-01", end_day = "2020-11-10",
                   geo_type = "county")
)


home_prop_7day_use <- home_prop_7day %>% select(geo_value, time_value, value) %>% 
  mutate(week =  week(as.Date(time_value, "%Y-%m-%d"))) %>% 
  group_by(week, geo_value) %>% 
  summarise(avg_home_prop = mean(value, na.rm = TRUE)) %>% ungroup()

median_home_7day_use <- median_home_time_7dav %>% select(geo_value, time_value, value) %>% 
  mutate(week =  week(as.Date(time_value, "%Y-%m-%d"))) %>% 
  group_by(week, geo_value) %>% 
  summarise(avg_median_home = mean(value, na.rm = TRUE)) %>% ungroup()

rm(home_prop_7day, median_home_time_7dav)

 


####### Import Telework index data from DingelNeiman  #######

#Source: https://github.com/jdingel/DingelNeiman-workathome/blob/d5827e15f6c84589e1884c5e9c3bc88253143015/MSA_measures/output/MSA_workfromhome.csv

msa_telework <- read.csv(here(raw_data_path, "MSA_workfromhome.csv"))
county_telework <- msa_county %>% 
  left_join(msa_telework, by = c("CBSA" = "AREA"))


county_telework <- county_telework %>% 
  select(County.Name, State, FIPS.County.Code,CBSA, CBSA.Name, teleworkable_emp, teleworkable_manual_emp) %>% 
  rename(county_name = County.Name, 
         state = State,
         countyfips = FIPS.County.Code,
         cbsa = CBSA,
         cbsa_name = CBSA.Name)



#### Save

save.image("~/2.Covid_IT_Employment/2021Dec_light_data.RData")


# title: "IT and Unemployment Amid COVID-19"
# stage: Stage 2 - Data compiling
# author: "Leting Zhang"
# date: "12/07/2021"
# input: R data
# output: Panel data




############# AGGREGATE & CONSTRUCT ###############

# Import data

load("~/2.Covid_IT_Employment/2021Dec_light_data.RData")

############# Aggregate CI - COUNTY level data  #######

# Add county fips

ci_data_key <- ci_site[, c("SITEID","ZIPCODE")]
ci_data_key$ZIPCODE <- substr(ci_site[, c("SITEID","ZIPCODE")]$ZIPCODE,1,5)
ci_data_key$ZIPCODE <- sub("^0+", "", ci_data_key$ZIPCODE)
ci_data_key$ZIPCODE <- as.integer(ci_data_key$ZIPCODE)

ci_data_key <- merge(ci_data_key, zip_county_use[, c("ZIP", "COUNTY")], by.x = "ZIPCODE", by.y = "ZIP", all.x = TRUE, allow.cartesian=TRUE)
ci_data_key <- merge(ci_data_key, msa_county, by.x = "COUNTY", by.y = "FIPS.County.Code",all.x = TRUE, allow.cartesian=TRUE )


ci_data_use <- ci_data_key %>% select(-ZIPCODE) %>% 
  full_join(ci_site) %>% 
  full_join(ci_itspend)# %>% 
 # left_join(adopttech_19v2 %>% select(!contains("per_emp"), -c(EMPLE, COUNTY, SIC3_CODE) ) )


### Create county-level CI IT variables


# Create no winsorzied measurements
ci_summarise_all <- ci_data_use  %>% select(SITEID, COUNTY, EMPLE, REVEN,
                                            IT_BUDGET, HARDWARE_BUDGET,PC_BUDGET,
                                            SERVER_BUDGET, TERMINAL_BUDGET, PRINTER_BUDGET,
                                            OTHER_HARDWARE_BUDGET, STORAGE_BUDGET,COMM_BUDGET,
                                            SOFTWARE_BUDGET, SERVICES_BUDGET
                                            ) %>% 
  filter(!is.na(COUNTY) & IT_BUDGET != 0 & EMPLE!=0) %>%
  group_by(COUNTY) %>% 
  summarise(count = n(), 
            #across(EMPLE:number_app_Network, mean, na.rm = TRUE, .names = "{col}_mean"), # create mean -ABONDON
            across(EMPLE:SERVICES_BUDGET, median, na.rm = TRUE, .names = "{col}_median"))%>% #create median  
  ungroup()

# create mean - this command is useful
# across(EMPLE:it_budget_per_emp, sum, na.rm =TRUE, .names = "{col}_sum" ) ) %>%  
# mutate(across(ends_with("sum"), .fns = list( per_site = ~./count), .names = "{col}_{fn}",na.rm = TRUE)


ci_data_per_emp <- ci_data_use %>% select(SITEID, COUNTY, EMPLE, REVEN,
                                          IT_BUDGET, HARDWARE_BUDGET,PC_BUDGET,
                                          SERVER_BUDGET, TERMINAL_BUDGET, PRINTER_BUDGET,
                                          OTHER_HARDWARE_BUDGET, STORAGE_BUDGET,COMM_BUDGET,
                                          SOFTWARE_BUDGET, SERVICES_BUDGET) %>% 
  filter(EMPLE != 0 &  IT_BUDGET !=0) %>%
  mutate(
    across(ends_with("BUDGET"), .fns = list( per_emp = ~./EMPLE), .names = "{col}_{fn}",na.rm = TRUE)) %>% 
  select ( -c(ends_with("BUDGET"))) 


ci_summarise_per_emp <-  ci_data_per_emp %>% 
  group_by(COUNTY) %>% 
  summarise(across(IT_BUDGET_per_emp: SERVICES_BUDGET_per_emp, median, 
                   na.rm = TRUE, .names = "{col}_median")) %>%
  ungroup() 
#%>% rename_at( .vars = vars(starts_with("number_app_per_emp_")), # reduce the length of name
        #     .funs = funs(gsub("_app", "", ., fixed = TRUE)) ) 


ci_county_all <- ci_summarise_all %>%
  full_join(ci_summarise_per_emp) %>% 
  mutate_if(is.integer64, as.numeric) %>% 
  left_join(county_adopttech_19, by = c("COUNTY" = "county"))

write_dta(ci_county_all, here(int_data_path, "new_ci_county_all2023April.dta"))

# rename

colnames(ci_county_all)[3:15] <- c("emple_median", "reven_median", "it_bmedian", "hw_bmedian", 
                                  "pc_bmedian",  "sv_bmedian", "ter_bmedian", "pr_bmedian",
                                  "ohw_bmedian", "sto_bmedian", "comm_bmedian",  "sw_median",
                                  "ser_median")

colnames(ci_county_all)[16:26] <- c( "it_pbmedian", "hw_pbmedian", "pc_pbmedian",  "sv_pbmedian",
                                    "ter_pbmedian", "pr_pbmedian","ohw_pbmedian", "sto_pbmedian", 
                                    "comm_pbmedian",  "sw_pbmedian", "ser_pbmedian")

# ci normalize data

ci_sum_it_use <- ci_data_use %>% select(SITEID, COUNTY, EMPLE,
                       IT_BUDGET) %>% 
  filter(EMPLE != 0 &  IT_BUDGET !=0) %>% 
  group_by(COUNTY) %>%
  summarize(total_it = sum(IT_BUDGET),
            no_site = n_distinct(SITEID)) %>% 
  ungroup()

write.dta(ci_sum_it_use, here(int_data_path, "county_total_it.dta"))

############# Revised 2023: Derive mean value of BAIT #######

library(tidyverse)
ci_summarise_mean_all <- ci_data_use  %>% select(SITEID, COUNTY, EMPLE, REVEN,
                                            IT_BUDGET, HARDWARE_BUDGET, SOFTWARE_BUDGET,SERVICES_BUDGET) %>% 
  filter(!is.na(COUNTY) & IT_BUDGET != 0 & EMPLE!=0) %>%
  group_by(COUNTY) %>% 
  summarise(count = n(), 
            #across(EMPLE:number_app_Network, mean, na.rm = TRUE, .names = "{col}_mean"), # create mean -ABONDON
            across(EMPLE:SERVICES_BUDGET, mean, na.rm = TRUE, .names = "{col}_mean"))%>% #create median  
  ungroup()

ci_summarise_mean_per_emp <-  ci_data_per_emp %>% 
  group_by(COUNTY) %>% 
  summarise(across(IT_BUDGET_per_emp: SERVICES_BUDGET_per_emp, mean, 
                   na.rm = TRUE, .names = "{col}_mean")) %>%
  ungroup() 

ci_county_mean_all <- ci_summarise_mean_all %>%
  full_join(ci_summarise_mean_per_emp) %>% 
  mutate_if(is.integer64, as.numeric) 

# rename

colnames(ci_county_mean_all)[3:8] <- c("emple_mean", "reven_mean", "it_mean",
                                       "hardw_mean", 
                                        "soft_mean", "service_mean")

colnames(ci_county_mean_all)[9:12] <- c("it_per_mean", "hardw_per_mean", 
                                   "soft_per_mean", "service_per_mean")

library(foreign)
library(here)

write.dta(ci_county_mean_all, here(out_data_path, "ci_county_mean_all.dta"))

############# Aggregate and contruct county, weekly data #######

# Unemployement insurance:  county, week

ui_county_week <- ui_county %>% 
  mutate(date = ISOdate(year,month, day_endofweek),
         week =  week(as.Date(date, "%Y-%m-%d"))) %>% 
  select(-c(year, month, day_endofweek, date))



# Covid: county, day -> county,week

covid_county_week <-  covid_county %>% 
  mutate(date = ISOdate(year,month, day),
         week =  week(as.Date(date, "%Y-%m-%d"))) %>% 
  group_by(countyfips,week,year) %>% 
  summarise(case_count = max(case_count, na.rm = T),
            death_count = max(death_count, na.rm = T),
            case_rate = max(case_rate, na.rm = T),
            death_rate = max(death_rate, na.rm = T),
            avg_new_case_count = mean(new_case_count, na.rm = T),
            avg_new_death_rate = mean(new_death_count, nna.rm = T),
            avg_new_case_rate = mean(new_case_count, na.rm = T),
            avg_new_death_rate = mean(new_death_count, na.rm =T),
            
  ) %>% ungroup()


#Safegraph: county daily - weekly

safegraph_week <- home_prop_7day_use %>% 
  full_join(median_home_7day_use) %>% 
  mutate(countyfips = as.numeric(geo_value))



##### QWI sum 

county_qwi_use <- county_qwi_agg 


# Compile data and create the panel dataset

county_week_panel <- ui_county_week %>% 
  full_join(covid_county_week) %>% 
  full_join(safegraph_week) %>% 
  full_join(ci_county_all, by = c("countyfips" = "COUNTY")) %>% 
  full_join(policy_state_county, by = c("countyfips" = "FIPS")) %>% 
  full_join(county_qwi_use, by = c("countyfips" = "geography" )) %>% select(-c( geo_value)) %>% 
  full_join(county_acs) %>% 
  full_join(county_telework)

county_week_panel_use <-  county_week_panel %>% select(-c(year.x, year.y)) 

# Add new dataset

county_week_panel_use <-  county_week_panel %>% left_join(oews_use, by = c("countyfips" = "FIPS.County.Code"))

#write.csv(county_week_panel, here(out_data_path, "county_week_panel_aug.csv"))
#write_dta(county_week_panel_use, here("Stata", "county_week_panel_dec_streamed.dta"))

write_dta(county_week_panel_use, here(out_data_path, "county_week_panel_dec_streamed.dta"))

#county_week_panel <- read_dta(here("Stata", "county_week_panel_dec_streamed.dta"))

############# 2021 and newer datasets #######

ui_new_county <- read.csv(here(raw_data_path, "UI Claims - County - Weekly_updated.csv"), stringsAsFactors = F)

ui_new_county <- ui_new_county%>% mutate_if(is.character,as.numeric)

ui_new_county_week <- ui_new_county %>% 
  mutate(date = ISOdate(year,month, day_endofweek),
         week =  week(as.Date(date, "%Y-%m-%d"))) %>% 
  filter(year <2022)


covid_2020_county <- read.csv(here(raw_data_path, "COVID - County - Daily 2020.csv"), stringsAsFactors = F)
covid_2020_county <- covid_2020_county%>% mutate_if(is.character,as.numeric)

covid_2020_county_week <-  covid_2020_county %>% 
  mutate(date = ISOdate(year,month, day),
         week =  week(as.Date(date, "%Y-%m-%d"))) %>% 
  group_by(countyfips,week,year) %>% 
  summarise(case_count = max(case_count, na.rm = T),
            death_count = max(death_count, na.rm = T),
            case_rate = max(case_rate, na.rm = T),
            death_rate = max(death_rate, na.rm = T),
            avg_new_case_count = mean(new_case_count, na.rm = T),
            avg_new_death_rate = mean(new_death_count, nna.rm = T),
            avg_new_case_rate = mean(new_case_count, na.rm = T),
            avg_new_death_rate = mean(new_death_count, na.rm =T),
            
  ) %>% ungroup()


covid_2021_county <- read.csv(here(raw_data_path, "COVID - County - Daily 2021.csv"), stringsAsFactors = F)
covid_2021_county <- covid_2021_county%>% mutate_if(is.character,as.numeric)

covid_2021_county_week <-  covid_2021_county %>% 
  mutate(date = ISOdate(year,month, day),
         week =  week(as.Date(date, "%Y-%m-%d"))) %>% 
  group_by(countyfips,week,year) %>% 
  summarise(case_count = max(case_count, na.rm = T),
            death_count = max(death_count, na.rm = T),
            case_rate = max(case_rate, na.rm = T),
            death_rate = max(death_rate, na.rm = T),
            avg_new_case_count = mean(new_case_count, na.rm = T),
            avg_new_death_rate = mean(new_death_count, nna.rm = T),
            avg_new_case_rate = mean(new_case_count, na.rm = T),
            avg_new_death_rate = mean(new_death_count, na.rm =T),
            
  ) %>% ungroup()


covid_new_county_week <- rbind(covid_2020_county_week, covid_2021_county_week)

county_new_week_panel <- ui_new_county_week %>% 
  full_join(covid_new_county_week)

county_new_week_panel_use <- ui_new_county_week %>% 
  left_join(covid_new_county_week) %>% 
  mutate(week_use = ifelse(year == 2021, week+52, week))


colnames(county_new_week_panel_use)[4] <- "county"


library(haven)

write_dta(county_new_week_panel_use, here(out_data_path, "county_2021.dta"))


