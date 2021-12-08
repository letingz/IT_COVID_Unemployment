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

ci_data_key <- merge(ci_data_key, zip_county[, c("ZIP", "COUNTY")], by.x = "ZIPCODE", by.y = "ZIP", all.x = TRUE, allow.cartesian=TRUE)
ci_data_key <- merge(ci_data_key, msa_county, by.x = "COUNTY", by.y = "FIPS.County.Code",all.x = TRUE, allow.cartesian=TRUE )


ci_data_use <- ci_data_key %>% select(-ZIPCODE) %>% 
  full_join(ci_site) %>% 
  full_join(ci_itspend) %>% 
  left_join(adopttech_19v2 %>% select(!contains("per_emp"), -c(EMPLE, COUNTY, SIC3_CODE) ) )


### Create county-level CI IT variables


# Create no winsorzied measurements
ci_summarise_all <- ci_data_use  %>% select(SITEID, COUNTY, EMPLE, REVEN,
                                            IT_BUDGET, HARDWARE_BUDGET, SOFTWARE_BUDGET,SERVICES_BUDGET,
                                            contains("number_app")) %>% 
  filter(!is.na(COUNTY) & IT_BUDGET != 0 & EMPLE!=0) %>%
  group_by(COUNTY) %>% 
  summarise(count = n(), 
            #across(EMPLE:number_app_Network, mean, na.rm = TRUE, .names = "{col}_mean"), # create mean -ABONDON
            across(EMPLE:number_app_Infrastructure, median, na.rm = TRUE, .names = "{col}_median"))%>% #create median  
  ungroup()

# create mean - this command is useful
# across(EMPLE:it_budget_per_emp, sum, na.rm =TRUE, .names = "{col}_sum" ) ) %>%  
# mutate(across(ends_with("sum"), .fns = list( per_site = ~./count), .names = "{col}_{fn}",na.rm = TRUE)


ci_data_per_emp <- ci_data_use %>% select(SITEID, COUNTY, EMPLE, REVEN, IT_BUDGET, HARDWARE_BUDGET, 
                                          SOFTWARE_BUDGET,SERVICES_BUDGET) %>% 
  filter(EMPLE != 0 &  IT_BUDGET !=0) %>%
  mutate(
    across(ends_with("BUDGET"), .fns = list( per_emp = ~./EMPLE), .names = "{col}_{fn}",na.rm = TRUE)) %>% 
  select ( -c(ends_with("BUDGET"))) %>% 
  left_join(adopttech_19v2) %>% 
  select(SITEID, COUNTY, ends_with("per_emp"), starts_with("number_app_per_emp_") )


ci_summarise_per_emp <-  ci_data_per_emp %>% 
  group_by(COUNTY) %>% 
  summarise(across(IT_BUDGET_per_emp: number_app_per_emp_Infrastructure, median, 
                   na.rm = TRUE, .names = "{col}_median")) %>%
  ungroup() %>% 
  rename_at( .vars = vars(starts_with("number_app_per_emp_")), # reduce the length of name
             .funs = funs(gsub("_app", "", ., fixed = TRUE)) ) 




ci_county_all <- ci_summarise_all %>%
  full_join(ci_summarise_per_emp) %>% 
  mutate_if(is.integer64, as.numeric)

# rename

colnames(ci_county_all)[3:16] <- c("emple_median", "reven_median", "it_median", "hardw_median", 
                                   "soft_median", "service_median",
                                   "appdev_median", "enterp_median", "cloud_median", 
                                    "produc_median", "market_median", "collab_median",
                                    "security_median", "infra_median")

colnames(ci_county_all)[17:28] <- c("it_per_median", "hardw_per_median", 
                                    "soft_per_median", "service_per_median",
                                    "appdev_per_median", "enterp_per_median", "cloud_per_median", 
                                    "produc_per_median", "marketing_per_median", "collab_per_median",
                                    "security_per_median", "infra_per_median")



rm(ci_data_use, ci_site, ci_data_per_emp)

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




county_week_panel <- ui_county_week %>% 
  full_join(covid_county_week) %>% 
  full_join(safegraph_week) %>% 
  full_join(ci_county_all, by = c("countyfips" = "COUNTY")) %>% 
  full_join(policy_state_county, by = c("countyfips" = "FIPS")) %>% 
  full_join(county_qwi_use, by = c("countyfips" = "geography" )) %>% select(-c( geo_value)) %>% 
  full_join(county_acs)

county_week_panel_use <-  county_week_panel %>% select(-c(year.x, year.y)) 

colnames(county_week_panel )

#write.csv(county_week_panel, here(out_data_path, "county_week_panel_aug.csv"))

write_dta(county_week_panel_use, here("Stata", "county_week_panel_dec.dta"))



############# OUTPUT ###############

write.csv(county_month_panel, here(out_data_path, "county_month_panel.csv"))

#write_dta(county_month_panel, here("Stata", "county_month_panel.dta"))


write.csv(state_month_panel, here(out_data_path, "state_month_panel.csv"))

#write_dta(county_month_panel, here("Stata", "county_month_panel.dta"))





b %>%
  right_join(county_map, by = c("geography"  = "county") ) %>% 
  ggplot(mapping = aes(x = long, y = lat, 
                       fill = it2, group = group)) +
  geom_polygon(color = "gray90", size = 0.05) +
  coord_equal() + 
  scale_fill_gradient2(high = "blue", mid = "white", low= "red", 
                       midpoint = 4.5, 
                       limit = c(0,11) ,
                       breaks = c(0, 4.5, 7,10), 
                       labels = paste(c( '0', '100', '1,000', '>20,000'))) +
  labs(fill = "") + theme_map() + theme(legend.position = "right")+  
  labs(x = "", y = "", title = " Number of IT Service Employees \nCounty Level") +  
  theme(plot.title = element_text(size = rel(2.5), hjust = 0.5),
        plot.caption = element_text(size = rel(1.2), hjust = 0),
        #legend.title = element_text(size = rel(1.5)),
        legend.text = element_text(size=15),
        legend.position = c(0.98, 0.40)) + labs(caption = "Source: Quarterly Workforce Indicators 2019")


ggsave(here("3.Report","its_map.png"), width = 7, height = 4, dpi = 300, units = "in", device='png')



# Data - IT Budget Descriptive Analyses ----------------------------------------------------

##rm(list=setdiff(ls(), "ci_data_use")) # Remove all variables except "ci_data_use"

#- Import 2019 - 2020 CI site and IT spend data



col <- c("SITEID", "PRIMARY_DUNS_NUMBER", "COMPANY", "STATE", "COUNTY" ,"ZIPCODE", "EMPLE", "REVEN", "SIC2_CODE", "SIC2_DESC")

site2019 <- fread(here("1.Data", "1.raw_data", "citdb19", "SiteDescription.TXT"), select = col)
site2019$year <- 2019
site2020 <- fread(here("1.Data", "1.raw_data", "citdb20", "SiteDescription.TXT"), select = col)
site2019$year <- 2020
site1920 <- rbind(site2019, site2020)
rm(site1920)

#site2020demo <- fread(here("1.Data", "1.raw_data", "citdb20", "SiteDescription.TXT"), nrow = 1)

it2019 <- fread(here("1.Data", "1.raw_data", "citdb19", "ITSpend.TXT"))
it2020 <- fread(here("1.Data", "1.raw_data", "citdb20", "ITSpend.TXT"))
it1920 <- rbind(it2019, it2020)

rm(site_it)

site_it <- merge(site1920, site1920)
