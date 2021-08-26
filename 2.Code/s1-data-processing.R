# title: "IT and Future of Working from Home"
# stage: Stage 1
# author: "LetingZhang"
# date: "04/22/2021"
# input: Raw data
# output: Panel data
   

####### LOAD LIBRARY ########
  
library(tidyverse)
library(here)
library(data.table)
library(R.utils)
library(lubridate)
library(robustHD)
library(haven)

raw_data_path <- here("1.Data","1.raw_data")
out_data_path <- here("1.Data","3.output_data")


####### LOG  #######

# 2021/07/27 create new measurements for IT budget: IT budget/emp, computer, computer/emp
  # create industry measurement, firm size 


############# IMPORT & CLEAN DATA ###############

####### Import Economic Indicator - EconomicTracker ########

#source: https://github.com/OpportunityInsights/EconomicTracker


# Unemployment Insurance Claim
ui_county <- read.csv(here(raw_data_path, "/EconomicTracker-main/data/UI Claims - County - Weekly.csv"), stringsAsFactors = F)
ui_state <- read.csv(here(raw_data_path,"/EconomicTracker-main/data/UI Claims - State - Weekly.csv"), stringsAsFactors = F)

ui_county <- ui_county%>% mutate_if(is.character,as.numeric)
ui_state <- ui_state%>% mutate_if(is.character,as.numeric)

# Employment 

employment_county <- read.csv(here(raw_data_path, "/EconomicTracker-main/data/Employment Combined - County - Daily.csv"))
employment_state <- read.csv(here(raw_data_path,"/EconomicTracker-main/data/Employment Combined - State - Daily.csv"))

employment_county <- employment_county%>% mutate_if(is.character,as.numeric)
employment_state <- employment_state%>% mutate_if(is.character,as.numeric)

# Other indicators

affinity_county <- read.csv(here(raw_data_path,"/EconomicTracker-main/data/Affinity - County - Daily.csv"))
affinity_state <- read.csv(here(raw_data_path,"/EconomicTracker-main/data/Affinity - State - Daily.csv"))

jobpost_state_week <- read.csv(here(raw_data_path,"/EconomicTracker-main/data/Burning Glass - state - Weekly.csv"))

gogmobility_county <- read.csv(here(raw_data_path,"/EconomicTracker-main/data/Google Mobility - County - Daily.csv"))
gogmobility_state <- read.csv(here(raw_data_path,"/EconomicTracker-main/data/Google Mobility - State - Daily.csv"))

smallbus_county <- read.csv(here(raw_data_path,"/EconomicTracker-main/data/Womply Merchants - County - Daily.csv"))
smallbus_state <- read.csv(here(raw_data_path,"/EconomicTracker-main/data/Womply Merchants - State - Daily.csv"))

smallrev_county <- read.csv(here(raw_data_path,"/EconomicTracker-main/data/Womply Revenue - County - Daily.csv"))
smallrev_state <- read.csv(here(raw_data_path,"/EconomicTracker-main/data/Womply Revenue - State - Daily.csv"))

## Merge
econ_county <- Reduce(function(x, y) merge(x, y, all=TRUE), list(affinity_county,  gogmobility_county,   
                                                                 smallbus_county,smallrev_county ))
econ_county[, 8:14] <- sapply(econ_county[, 8:14], as.numeric )


econ_state <- Reduce(function(x, y) merge(x, y, all=TRUE), list(affinity_state,jobpost_state_week, gogmobility_state, smallbus_state ,smallrev_state ))
econ_state <- econ_state%>% mutate_if(is.character,as.numeric)

####### Import State/County Stay at Home - EconomicTracker ########

#Source:  https://github.com/OpportunityInsights/EconomicTracker
#Other Source: https://www.finra.org/rules-guidance/key-topics/covid-19/shelter-in-place
#National Emergency Concerning: March 13 
#Reference: https://www.whitehouse.gov/presidential-actions/proclamation-declaring-national-emergency-concerning-novel-coronavirus-disease-covid-19-outbreak/
#Reference: https://www.nytimes.com/interactive/2020/us/coronavirus-stay-at-home-order.html


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

######## Import County Stay at Home 

#source: https://github.com/JieYingWu/COVID-19_US_County-level_Summaries
#After converting date format in python 

county_policy <- read.csv(here( "1.Data", "2.intermediate_data", "county_shutdown.csv"))

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
                  

######## Import Covid19 Data from Eonomic Tracker ########

covid_county <- read.csv(here(raw_data_path, "EconomicTracker-main/data/COVID - County - Daily.csv"), stringsAsFactors = F)
covid_state <- read.csv(here(raw_data_path, "EconomicTracker-main/data/COVID - State - Daily.csv"), stringsAsFactors = F)
covid_county <- covid_county%>% mutate_if(is.character,as.numeric)
covid_state<- covid_state%>% mutate_if(is.character,as.numeric)


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

# Choose IT related industry - industry code
its_industry = c(5112, 5191, 5182, 5415)
computer_industry = c(3341, 3342, 3344, 3345, 5179)


# Create measurement of state_level IT employment at 2019 Q4
state_qwi_emp <- allqwidata  %>% 
  filter(geo_level=="S" ) %>% 
  select ( geography, year, quarter, industry, sex, education, Emp, EmpS,EmpTotal, EarnS, Payroll) 

## Reshape
state_qwi_emp_wide <- dcast(setDT(state_qwi_emp), geography+year+quarter+industry ~ paste0("sex", sex) + paste("education", education), value.var = c("EmpS", "EmpTotal","EarnS"), na.rm = TRUE, sep = "", sum)

colnames(state_qwi_emp_wide)  <- gsub(" ","",colnames(state_qwi_emp_wide))

state_qwi_agg <- state_qwi_emp_wide %>% 
  filter(year == 2019) %>% 
  group_by(geography, year,quarter) %>% 
  select(geography, year,quarter, industry, contains("E0")) %>%
  summarise(
    # EMPS
    its_emps_all = sum(EmpSsex0educationE0[industry %in% its_industry], na.rm=T),
    its_emps_male = sum(EmpSsex1educationE0[industry %in% its_industry], na.rm=T),
    its_emps_female = sum(EmpSsex2educationE0[industry %in% its_industry], na.rm=T),
    
    com_emps_all = sum(EmpSsex0educationE0[industry %in% computer_industry],na.rm=T),
    com_emps_male = sum(EmpSsex1educationE0[industry %in% computer_industry], na.rm=T),
    com_emps_female = sum(EmpSsex2educationE0[industry %in% computer_industry], na.rm=T),
    
    
    all_emps_all = sum(EmpSsex0educationE0,na.rm=T),
    all_emps_male = sum(EmpSsex1educationE0, na.rm=T),
    all_emps_female = sum(EmpSsex2educationE0, na.rm=T),
    
    # EmpTotal
    
    its_empstotal_all = sum(EmpTotalsex0educationE0[industry %in% its_industry], na.rm=T),
    its_empstotal_male = sum(EmpTotalsex1educationE0[industry %in% its_industry], na.rm=T),
    its_empstotal_female = sum(EmpTotalsex2educationE0[industry %in% its_industry], na.rm=T),
    
    com_empstotal_all = sum(EmpTotalsex0educationE0[industry %in% computer_industry],na.rm=T),
    com_empstotal_male = sum(EmpTotalsex1educationE0[industry %in% computer_industry], na.rm=T),
    com_empstotal_female = sum(EmpTotalsex2educationE0[industry %in% computer_industry], na.rm=T),
    
    all_empstotal_all = sum(EmpTotalsex0educationE0,na.rm=T),
    all_empstotal_male = sum(EmpTotalsex1educationE0, na.rm=T),
    all_empstotal_female = sum(EmpTotalsex2educationE0, na.rm=T),
    
    # Earn
    
    its_earn_all = sum(EarnSsex0educationE0[industry %in% its_industry], na.rm=T),
    its_earn_male = sum(EarnSsex1educationE0[industry %in% its_industry], na.rm=T),
    its_earn_female = sum(EarnSsex2educationE0[industry %in% its_industry], na.rm=T),
    
    com_earn_all = sum(EarnSsex0educationE0[industry %in% computer_industry],na.rm=T),
    com_earn_male = sum(EarnSsex1educationE0[industry %in% computer_industry], na.rm=T),
    com_earn_female = sum(EarnSsex2educationE0[industry %in% computer_industry], na.rm=T),
    
    all_earn_all = sum(EarnSsex0educationE0,na.rm=T),
    all_earn_male = sum(EarnSsex1educationE0, na.rm=T),
    all_earn_female = sum(EarnSsex2educationE0, na.rm=T),
    
  ) %>% 
  ungroup()


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
    # its_emps_male = sum(EmpSsex1educationE0[industry %in% its_industry], na.rm=T),
    # its_emps_female = sum(EmpSsex2educationE0[industry %in% its_industry], na.rm=T),
    
    com_emps_all = sum(EmpSsex0educationE0[industry %in% computer_industry],na.rm=T),
    # com_emps_male = sum(EmpSsex1educationE0[industry %in% computer_industry], na.rm=T),
    # com_emps_female = sum(EmpSsex2educationE0[industry %in% computer_industry], na.rm=T),
    
    
    all_emps_all = sum(EmpSsex0educationE0,na.rm=T),
    # all_emps_male = sum(EmpSsex1educationE0, na.rm=T),
    # all_emps_female = sum(EmpSsex2educationE0, na.rm=T),
    # 
    # EmpTotal
    
    its_empstotal_all = sum(EmpTotalsex0educationE0[industry %in% its_industry], na.rm=T),
    # its_empstotal_male = sum(EmpTotalsex1educationE0[industry %in% its_industry], na.rm=T),
    # its_empstotal_female = sum(EmpTotalsex2educationE0[industry %in% its_industry], na.rm=T),
    
    com_empstotal_all = sum(EmpTotalsex0educationE0[industry %in% computer_industry],na.rm=T),
    # com_empstotal_male = sum(EmpTotalsex1educationE0[industry %in% computer_industry], na.rm=T),
    # com_empstotal_female = sum(EmpTotalsex2educationE0[industry %in% computer_industry], na.rm=T),
    
    all_empstotal_all = sum(EmpTotalsex0educationE0,na.rm=T),
    # all_empstotal_male = sum(EmpTotalsex1educationE0, na.rm=T),
    # all_empstotal_female = sum(EmpTotalsex2educationE0, na.rm=T),
    
    # Earn
    
    its_earn_all = sum(EarnSsex0educationE0[industry %in% its_industry], na.rm=T),
    # its_earn_male = sum(EarnSsex1educationE0[industry %in% its_industry], na.rm=T),
    # its_earn_female = sum(EarnSsex2educationE0[industry %in% its_industry], na.rm=T),
    
    com_earn_all = sum(EarnSsex0educationE0[industry %in% computer_industry],na.rm=T),
    # com_earn_male = sum(EarnSsex1educationE0[industry %in% computer_industry], na.rm=T),
    # com_earn_female = sum(EarnSsex2educationE0[industry %in% computer_industry], na.rm=T),
    # 
    all_earn_all = sum(EarnSsex0educationE0,na.rm=T),
    # all_earn_male = sum(EarnSsex1educationE0, na.rm=T),
    # all_earn_female = sum(EarnSsex2educationE0, na.rm=T),
    
  ) %>% 
  ungroup()

#output
write.csv(county_qwi_agg,here(out_data_path , "county_qwi_agg.csv"))
write.csv(state_qwi_agg,here(out_data_path , "state_qwi_agg.csv"))



######## Import & Clean: CI Database  ########
ci_path <- "C:/Users/Leting/Documents/CI_Investment/1.Data/1.raw_data/USA_2019"

# Import CI cyber data
ci_cyber <- read.csv(here("1.Data/2.intermediate_data", "CI_cyber_use.csv"))
ci_cyber <- subset(ci_cyber, select = c('SITEID','cyber_sum', 'IT_STAFF','PCS'))

# read CI site description data
#ci_path <- readWindowsShortcut(here(raw_data_path,"USA_2019.lnk"))
#ci_path <- gsub("\\\\", "/", ci_path$pathname)

path <- paste(ci_path, '/SiteDescription.TXT', sep = '')
col <-  c('SITEID', 'PRIMARY_DUNS_NUMBER', 'COMPANY', 'CITY','STATE','ZIPCODE', 'MSA','EMPLE','REVEN','SALESFORCE','MOBILE_WORKERS','MOBILE_INTL', 'SICGRP', 'SICSUBGROUP')
ci_site <- fread(path, select = col)


# Import CI app install presence data
path <- paste(ci_path, '/PresenceInstall.TXT', sep = '')
col <-  c('SITEID', 'VPN_PRES', 'IDACCESS_SW_PRES', 'DBMS_PRES', 'DATAWAREHOUSE_SW_PRES', 'SECURITY_SW_PRES')
ci_presence <- fread(path, select = col)

ci_presence[ci_presence == "Yes"] <- 1
ci_presence[ci_presence == ""] <- 0
ci_presence <- as.data.frame(ci_presence)
ci_presence[, 2:6] <- sapply(ci_presence[, 2:6], as.numeric )

# Import CI IT spend data
path <- paste(ci_path, '/ITSpend.TXT', sep = '')
ci_itspend <- fread(path)

# Convert interger64 to numeric 
is.integer64 <- function(x){
  class(x)=="integer64"
}

ci_itspend <- ci_itspend %>% 
  mutate_if(is.integer64, as.numeric)



# Import 2019 IT group data (processed in HPC center "covid_tech_analyses.Rmd" )

#adopttech_19 <- readRDS("~/Covid-Cyber-Unemploy/1.Data/1.raw_data/adopttech_19_site_techgroup.rds")

adopttech_19v2 <- readRDS(here(raw_data_path, "adopttech_19_site_techgroup_ver2.rds"))



# TODO: Import CI site industry & employment data

path <- paste(ci_path, '/SiteDescription.TXT', sep = '')

col <-  c('SITEID', 'EMPLE', 'SIC4_CODE', 'SIC4_DESC', 'NAICS6_CODE', 'NAICS6_DESC')

ci_industry <- fread(path, select = col)


####### Import Geo data & Geo crosswalk file #######

#source: census website PS: USE THE NEW ONE 
#industry_code <- read.csv("cps_monthly_data/2017-census-industry-classification-titles-and-code-list.csv")
#occupation_code<-read.csv("cps_monthly_data/2018-census-occupation-classification-titles-and-code-list.csv")
geo_code <- read.csv(here(raw_data_path,"geocorr2018 -crosswalk.csv"))

#source: https://www.huduser.gov/portal/datasets/usps_crosswalk.html
zip_county <- read.csv(here(raw_data_path, "ZIP_COUNTY_122019.csv"))

#source: https://data.nber.org/cbsa-msa-fips-ssa-county-crosswalk/2019/
msa_county <- read.csv(here(raw_data_path, "COUNTY_METRO2019.CSV"))

# EconomicTrack
geoid <- read.csv(here(raw_data_path, "GeoIDs - County.csv"), stringsAsFactors = F)



####### Import ACS (American Community Survey) file #######

source(here("2.Code", "asc_api.R"))


####### Import CPS data from IPUMS #######

#source: ipums
library(ipumsr)
# Change these filepaths to the filepaths of your downloaded extract
cps_ddi <- read_ipums_ddi(here(raw_data_path,"cps_00003.xml")) # Contains metadata, nice to have as separate object
cps_data <- read_ipums_micro(cps_ddi, data_file = here(raw_data_path, "cps_00003.dat" ))


table(cps_data$YEAR)
table(cps_data$MONTH)
table(cps_data$YEAR,cps_data$MONTH)

cps_use <- cps_data %>% filter(YEAR == 2020  & COUNTY !=0)

####### Import COVIDcast data from API  #######
#source: https://cmu-delphi.github.io/delphi-epidata/api/covidcast-signals/safegraph.html
devtools::install_github("cmu-delphi/covidcast", ref = "main",
                         subdir = "R-packages/covidcast")

library(covidcast)


home_prop_7day <- suppressMessages(
  covidcast_signal(data_source = "safegraph", signal = "completely_home_prop_7dav",
                   start_day = "2020-01-01", end_day = "2020-11-10",
                   geo_type = "county"))



work_prop_7day <- suppressMessages(
  covidcast_signal(data_source = "safegraph", signal = "full_time_work_prop_7dav",
                   start_day = "2020-01-01", end_day = "2020-11-10",
                   geo_type = "county")
)



part_prop_7day <- suppressMessages(
  covidcast_signal(data_source = "safegraph", signal = "part_time_work_prop_7dav",
                   start_day = "2020-01-01", end_day = "2020-11-10",
                   geo_type = "county")
)




median_home_time_7dav <- suppressMessages(
  covidcast_signal(data_source = "safegraph", signal = "median_home_dwell_time_7dav",
                   start_day = "2020-01-01", end_day = "2020-11-10",
                   geo_type = "county")
)


bar_visit_num <- suppressMessages(
  covidcast_signal(data_source = "safegraph", signal = "bars_visit_num",
                   start_day = "2020-01-01", end_day = "2020-11-10",
                   geo_type = "county")
)




bars_visit_prop <- suppressMessages(
  covidcast_signal(data_source = "safegraph", signal = "bars_visit_prop",
                   start_day = "2020-01-01", end_day = "2020-11-10",
                   geo_type = "county")
)



restaurants_visit_num <- suppressMessages(
  covidcast_signal(data_source = "safegraph", signal = "restaurants_visit_num",
                   start_day = "2020-01-01", end_day = "2020-11-10",
                   geo_type = "county")
)



restaurants_visit_prop <- suppressMessages(
  covidcast_signal(data_source = "safegraph", signal = "restaurants_visit_prop",
                   start_day = "2020-01-01", end_day = "2020-11-10",
                   geo_type = "county")
)





############# AGGREGATE & CONSTRUCT ###############



############# Aggregate CI - COUNTY level data  #######

### Add county indicators (1. median; 2. per emp) # drop MEAN 

## Add county indicators 1. agg median

# add county fips
ci_data_key <- ci_site[, c("SITEID","ZIPCODE")]
ci_data_key$ZIPCODE <- substr(ci_site[, c("SITEID","ZIPCODE")]$ZIPCODE,1,5)
ci_data_key$ZIPCODE <- sub("^0+", "", ci_data_key$ZIPCODE)
ci_data_key$ZIPCODE <- as.integer(ci_data_key$ZIPCODE)

ci_data_key <- merge(ci_data_key, zip_county[, c("ZIP", "COUNTY")], by.x = "ZIPCODE", by.y = "ZIP", all.x = TRUE, allow.cartesian=TRUE)
ci_data_key <- merge(ci_data_key, msa_county, by.x = "COUNTY", by.y = "FIPS.County.Code",all.x = TRUE, allow.cartesian=TRUE )

# merge

ci_data_use <- ci_data_key %>% select(-ZIPCODE) %>% 
  full_join(ci_site) %>% 
  full_join(ci_cyber) %>% 
  full_join(ci_presence) %>% 
  full_join(ci_itspend) %>% 
  #left_join(adopttech_19 %>% select(!contains("per_emp"), -c(division, division_name, EMPLE,COUNTY)) )
  left_join(adopttech_19v2 %>% select(!contains("per_emp"), -c(EMPLE, COUNTY, SIC3_CODE) ) )
### Create county-level CI IT variables


# Create no winsorzied measurements
ci_summarise_all <- ci_data_use  %>% select(SITEID, COUNTY, EMPLE, REVEN, PCS,
                          IT_BUDGET, HARDWARE_BUDGET, SOFTWARE_BUDGET,SERVICES_BUDGET,
                          contains("number_app")) %>% 
  filter(!is.na(COUNTY) & IT_BUDGET != 0 & EMPLE!=0) %>%
  group_by(COUNTY) %>% 
  summarise(count = n(), 
            #across(EMPLE:number_app_Network, mean, na.rm = TRUE, .names = "{col}_mean"), # create mean -ABONDON
            across(EMPLE:number_app_Infrastructure, median, na.rm = TRUE, .names = "{col}_median")) #create median %>% 
  ungroup()
            
  # create mean - this command is useful
  # across(EMPLE:it_budget_per_emp, sum, na.rm =TRUE, .names = "{col}_sum" ) ) %>%  
  # mutate(across(ends_with("sum"), .fns = list( per_site = ~./count), .names = "{col}_{fn}",na.rm = TRUE)

# Create winsorzied measurements - Abondon


ci_data_per_emp <- ci_data_use %>% select(SITEID, COUNTY, EMPLE, REVEN, PCS, IT_BUDGET, HARDWARE_BUDGET, 
                       SOFTWARE_BUDGET,SERVICES_BUDGET) %>% 
                 filter(EMPLE != 0 &  IT_BUDGET !=0) %>%
                 mutate(pc_per_emp = PCS/EMPLE,
                  across(ends_with("BUDGET"), .fns = list( per_emp = ~./EMPLE), .names = "{col}_{fn}",na.rm = TRUE)) %>% 
                 select ( -c(ends_with("BUDGET"))) %>% 
                 left_join(adopttech_19v2) %>% 
                 select(SITEID, COUNTY, ends_with("per_emp"), starts_with("number_app_per_emp_") )

ci_summarise_per_emp <-  ci_data_per_emp %>% 
  group_by(COUNTY) %>% 
  summarise(across(pc_per_emp: number_app_per_emp_Infrastructure, median, 
                   na.rm = TRUE, .names = "{col}_median")) %>%
  ungroup() %>% 
  rename_at( .vars = vars(starts_with("number_app_per_emp_")), # reduce the length of name
             .funs = funs(gsub("_app", "", ., fixed = TRUE)) ) 
    
#write_dta(ci_per_emp_county, here(out_data_path, "ci_per_emp_county.dta"))


ci_county_all <- ci_summarise_all %>%
              full_join(ci_summarise_per_emp) %>% 
              mutate_if(is.integer64, as.numeric)

# rename

colnames(ci_county_all)[10:17] <- c("appdev_median", "enterp_median", "cloud_median", 
                                    "productivity_median", "marketing_median", "collab_median",
                                    "security_median", "infra_median")

colnames(ci_county_all)[23:30] <- c("appdev_peremp_median", "enterp_peremp_median", "cloud_peremp_median", 
                                    "productivity_peremp_median", "marketing_peremp_median", "collab_peremp_median",
                                    "security_peremp_median", "infra_peremp_median")

# merge industry 

### TODO

ci_industry_use <- ci_industry %>% 
  left_join(ci_data_key %>% select(c("COUNTY", "SITEID")))


############# Aggregate and contruct county, weekly data #######

# Unemployement insurance:  county, week

ui_county_week <- ui_county %>% 
  mutate(date = ISOdate(year,month, day_endofweek),
         week =  week(as.Date(date, "%Y-%m-%d"))) %>% 
  select(-c(year, month, day_endofweek, date))



demo <- ui_county %>% 
  mutate(date = ISOdate(year,month, day_endofweek),
         week =  week(as.Date(date, "%Y-%m-%d"))) 

# Employment rate: county, day -> county, week
employ_county_week <- employment_county %>% 
  mutate(date = ISOdate(year,month, day),
         week =  week(as.Date(date, "%Y-%m-%d"))) %>% 
  select(-c(year, month, day, date)) %>% 
  group_by(countyfips, week) %>% 
  summarise_at(vars(emp_combined:emp_combined_inchigh), mean, na.rm = TRUE) %>% ungroup()
no

# Econ: county, day -> county, month

econ_county_week_pre <- econ_county %>% 
  mutate(date = ISOdate(year,month, day),
         week =  week(as.Date(date, "%Y-%m-%d"))) %>% 
  select(-c(year, month, day, freq, provisional, date)) %>% 
  relocate(week, .after = countyfips)
  
econ_county_week <- econ_county_week_pre %>% 
  group_by(countyfips, week) %>%
  summarise_at(vars(spend_all:revenue_all), mean, na.rm = TRUE) %>% ungroup()


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

home_prop_7day_use <- home_prop_7day %>% select(geo_value, time_value, value) %>% 
  mutate(week =  week(as.Date(time_value, "%Y-%m-%d"))) %>% 
  group_by(week, geo_value) %>% 
  summarise(avg_home_prop = mean(value, na.rm = TRUE)) %>% ungroup()


work_prop_7day_use <- work_prop_7day %>% select(geo_value, time_value, value) %>% 
  mutate(week =  week(as.Date(time_value, "%Y-%m-%d"))) %>% 
  group_by(week, geo_value) %>% 
  summarise(avg_work_prop = mean(value, na.rm = TRUE)) %>% ungroup()

part_prop_7day_use <- part_prop_7day %>% select(geo_value, time_value, value) %>% 
  mutate(week =  week(as.Date(time_value, "%Y-%m-%d"))) %>% 
  group_by(week, geo_value) %>% 
  summarise(avg_part_prop = mean(value, na.rm = TRUE)) %>% ungroup()

median_home_7day_use <- median_home_time_7dav %>% select(geo_value, time_value, value) %>% 
  mutate(week =  week(as.Date(time_value, "%Y-%m-%d"))) %>% 
  group_by(week, geo_value) %>% 
  summarise(avg_median_home = mean(value, na.rm = TRUE)) %>% ungroup()

bar_visit_num_use <- bar_visit_num %>% select(geo_value, time_value, value) %>% 
  mutate(week =  week(as.Date(time_value, "%Y-%m-%d"))) %>% 
  group_by(week, geo_value) %>% 
  summarise(avg_bar_visitnum = mean(value, na.rm = TRUE)) %>% ungroup()


bar_visit_prop_use <- bars_visit_prop %>% select(geo_value, time_value, value) %>% 
  mutate(week =  week(as.Date(time_value, "%Y-%m-%d"))) %>% 
  group_by(week, geo_value) %>% 
  summarise(avg_bar_visitprop = mean(value, na.rm = TRUE)) %>% ungroup()


res_visit_num_use <- restaurants_visit_num %>% select(geo_value, time_value, value) %>% 
  mutate(week =  week(as.Date(time_value, "%Y-%m-%d"))) %>% 
  group_by(week, geo_value) %>% 
  summarise(avg_res_visitnum = mean(value, na.rm = TRUE)) %>% ungroup()


res_visit_prop_use <- restaurants_visit_prop %>% select(geo_value, time_value, value) %>% 
  mutate(week =  week(as.Date(time_value, "%Y-%m-%d"))) %>% 
  group_by(week, geo_value) %>% 
  summarise(avg_res_visitprop = mean(value, na.rm = TRUE)) %>% ungroup()


safegraph_week <- home_prop_7day_use %>% 
  full_join(work_prop_7day_use) %>% 
  full_join(part_prop_7day_use) %>% 
  full_join(median_home_7day_use) %>% 
  full_join(bar_visit_num_use) %>% 
  full_join(bar_visit_prop_use) %>% 
  full_join(res_visit_num_use) %>% 
  full_join(res_visit_prop_use)

safegraph_week$countyfips <- as.numeric( safegraph_week$geo_value)


##### QWI sum & percap

county_qwi_use <- county_qwi_agg %>% select(geography, its_emps_all, com_emps_all, all_emps_all,
                                            its_empstotal_all, com_empstotal_all, all_empstotal_all,
                                            its_earn_all, com_earn_all, all_earn_all) %>% 
         left_join(county_demo[, c(1,3)], by = c("geography"= "countyfips")) %>% 
          mutate(across(-geography, .fns = list(per_cap= ~./population), .names = "{col}_{fn}" )) %>% select(-population)
        

        


county_week_panel <- ui_county_week %>% 
              full_join(employ_county_week) %>% 
              full_join(econ_county_week) %>% 
              full_join(covid_county_week) %>% 
              full_join(safegraph_week) %>% 
              full_join(ci_county_all, by = c("countyfips" = "COUNTY")) %>% 
              full_join(policy_state_county, by = c("countyfips" = "FIPS")) %>% 
              full_join(county_qwi_use, by = c("countyfips" = "geography" )) %>% select(-c(year, geo_value))



write.csv(county_week_panel, here(out_data_path, "county_week_panel_aug.csv"))

write_dta(county_week_panel, here("Stata", "county_week_panel_aug.dta"))





############# Aggregate and contruct county, monthly data #######

# Unemployement insurance: county, week -> county, month
ui_county_month <- ui_county %>% 
  group_by(month, countyfips) %>% 
  summarise (avg_initclaims_count = mean(initclaims_count_regular, na.rm = T),
             avg_initclaims_rate = mean(initclaims_rate_regular, na.rm = T)  ) %>% 
  ungroup

# Employment rate: county, day -> county, month
employ_county_month <- employment_county %>% 
  group_by(month, countyfips) %>% 
  summarise_at(c("emp_combined","emp_combined_inclow", "emp_combined_incmiddle", "emp_combined_inchigh"), mean, na.rm = TRUE) %>% ungroup()

# CI: site -> county (sum)

ci_sum_county<- ci_data_use %>% select(SITEID, STATE, COUNTY,CBSA.Name, EMPLE, REVEN, MOBILE_WORKERS, IT_STAFF 
                                       ,cyber_sum,VPN_PRES,IDACCESS_SW_PRES,
                                       DBMS_PRES, DATAWAREHOUSE_SW_PRES, SECURITY_SW_PRES, PCS, IT_BUDGET, HARDWARE_BUDGET, 
                                       SOFTWARE_BUDGET,SERVICES_BUDGET) %>% 
  group_by(COUNTY) %>% 
  summarise_at(c('EMPLE', 'REVEN', 'MOBILE_WORKERS','cyber_sum','VPN_PRES','IDACCESS_SW_PRES', 'DBMS_PRES', 'DATAWAREHOUSE_SW_PRES', 'SECURITY_SW_PRES', 'PCS', 'IT_BUDGET', 'HARDWARE_BUDGET', 'SOFTWARE_BUDGET','SERVICES_BUDGET'), sum, na.rm = TRUE) %>% ungroup()


# Econ: county, day -> county, month

econ_county_month <- econ_county %>% 
  group_by(month, countyfips) %>% 
  summarise_at(c('spend_all','gps_retail_and_recreation','gps_grocery_and_pharmacy','gps_parks', 'gps_transit_stations',
                 'gps_workplaces', 'gps_residential', 'gps_away_from_home', 'merchants_all', 'revenue_all'), mean, na.rm = TRUE) %>% ungroup()

# Covid: county, day -> county,month

covid_county_month <-  covid_county %>% 
  group_by(countyfips,month) %>% 
  summarise(case_count = max(case_count, na.rm = T),
            death_count = max(death_count, na.rm = T),
            case_rate = max(case_rate, na.rm = T),
            death_rate = max(death_rate, na.rm = T),
            avg_new_case_count = mean(new_case_count, na.rm = T),
            avg_new_death_rate = mean(new_death_count, nna.rm = T),
            avg_new_case_rate = mean(new_case_count, na.rm = T),
            avg_new_death_rate = mean(new_death_count, na.rm =T),
            
  ) %>% ungroup()

# Aggregation

county_month_panel <- ui_county_month %>% 
  full_join(employ_county_month, c('month', 'countyfips') ) %>% 
  full_join(geoid[, c('countyfips', 'statefips', 'stateabbrev')], 'countyfips' ) %>% 
  full_join(econ_county_month, c('month', 'countyfips')) %>% 
  full_join(covid_county_month, c('month', 'countyfips')) %>% 
  full_join(state_policy, c('statefips')) %>% 
  full_join(shelterdate[, c('abb', 'OrderMonth', 'OrderDay')], c('stateabbrev' = 'abb') )





############# Aggregate and contruct state, monthly data #######


# Unemployement insurance: state, week -> state, month
ui_state_month <- ui_state %>% 
  group_by(month,statefips) %>% 
  summarise_at(c('initclaims_count_regular', 'initclaims_rate_regular', 'contclaims_count_regular', 'contclaims_rate_regular', 'initclaims_count_pua', 'contclaims_count_pua'), mean, na.rm = TRUE)

# Employment rate: county, day -> county, month
employ_state_month <- employment_state %>% 
  group_by(month, statefips) %>% 
  summarise_at(c("emp_combined","emp_combined_inclow", "emp_combined_incmiddle", "emp_combined_inchigh",  "emp_combined_ss40", "emp_combined_ss60", "emp_combined_ss65", "emp_combined_ss70" ), mean, na.rm = TRUE)



# CI: site -> state (sum)

ci_state<- ci_data_use %>% select(SITEID, STATE, COUNTY,CBSA.Name, EMPLE, REVEN, MOBILE_WORKERS ,cyber_sum,VPN_PRES,IDACCESS_SW_PRES, DBMS_PRES, DATAWAREHOUSE_SW_PRES, SECURITY_SW_PRES, PCS, IT_BUDGET, HARDWARE_BUDGET, SOFTWARE_BUDGET,SERVICES_BUDGET) %>% 
  group_by(STATE) %>% 
  summarise_at(c('EMPLE', 'REVEN', 'MOBILE_WORKERS','cyber_sum','VPN_PRES','IDACCESS_SW_PRES', 'DBMS_PRES', 'DATAWAREHOUSE_SW_PRES', 'SECURITY_SW_PRES', 'PCS', 'IT_BUDGET', 'HARDWARE_BUDGET', 'SOFTWARE_BUDGET','SERVICES_BUDGET'), sum, na.rm = TRUE) %>% 
  ungroup()


# Econ: state, day -> state, month
econ_state_month <- econ_state%>% 
  group_by(month, statefips) %>% 
  summarise_at(vars(spend_acf:revenue_ss70), mean, na.rm = TRUE)


# Covid: state, day -> state,month

covid_state_month <-  covid_state %>% 
  group_by(month, statefips) %>% 
  summarise(test_count = max(test_count, na.rm = T),
            test_rate = max(test_rate, na.rm = T),
            case_count = max(case_count, na.rm = T),
            death_count = max(death_count, na.rm = T),
            case_rate = max(case_rate, na.rm = T),
            death_rate = max(death_rate, na.rm = T),
            avg_new_case_count = mean(new_case_count, na.rm = T),
            avg_new_death_rate = mean(new_death_count, nna.rm = T),
            avg_new_case_rate = mean(new_case_count, na.rm = T),
            avg_new_death_rate = mean(new_death_count, na.rm =T),
            
  ) %>% ungroup()



data_state <- ui_mean_state %>% 
  full_join(employ_mean_state, c('month', 'statefips') ) %>% 
  left_join(geoid[, c('statefips', 'stateabbrev')], 'statefips' ) %>% 
  unique() %>% 
  full_join(econ_mean_state, c('month', 'statefips')) %>% 
  full_join(covid_stat_state, c('month', 'statefips')) %>% 
  full_join(state_policy, c('statefips')) %>% 
  full_join(shelterdate[, c('abb', 'OrderMonth', 'OrderDay')], c('stateabbrev' = 'abb') )


state_month_panel <- ui_state_month %>% 
  full_join(employ_state_month, c('month', 'statefips') ) %>% 
  left_join(geoid[, c('statefips', 'stateabbrev')], 'statefips' ) %>% 
  unique() %>% 
  full_join(econ_state_month, c('month', 'statefips')) %>% 
  full_join(covid_state_month, c('month', 'statefips')) %>% 
  full_join(state_policy, c('statefips')) %>% 
  full_join(shelterdate[, c('abb', 'OrderMonth', 'OrderDay')], c('stateabbrev' = 'abb') )





############# OUTPUT ###############

write.csv(county_month_panel, here(out_data_path, "county_month_panel.csv"))

#write_dta(county_month_panel, here("Stata", "county_month_panel.dta"))


write.csv(state_month_panel, here(out_data_path, "state_month_panel.csv"))

#write_dta(county_month_panel, here("Stata", "county_month_panel.dta"))
