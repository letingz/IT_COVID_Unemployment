********************
*Title: COVID 19 and Unemployment 
*Author: Leting Zhang
*Date: 20201210
********************

********** Import county eco data ************
clear
import delimited data\output\data_county.csv, varnames(1) 

drop v1

rename countyfips county

order statefips stateabbrev state ordermonth orderday, a(county)

destring month countyfips avg_initclaims_count avg_initclaims_rate emp_combined emp_combined_inclow emp_combined_incmiddle emp_combined_inchigh spend_all gps_retail_and_recreation gps_grocery_and_pharmacy gps_parks gps_transit_stations gps_workplaces gps_residential gps_away_from_home merchants_all revenue_all case_count death_count case_rate death_rate avg_new_case_count avg_new_death_rate avg_new_case_rate, replace force

save stata\county_data.dta, replace

************* Import state eco data ******************
clear

import delimited data\output\data_state.csv, varnames(1) 

drop v1

order stateabbrev state ordermonth orderday, a( statefips )

destring statefips month initclaims_count_regular initclaims_rate_regular contclaims_count_regular contclaims_rate_regular initclaims_count_pua contclaims_count_pua emp_combined emp_combined_inclow emp_combined_incmiddle emp_combined_inchigh emp_combined_ss40 emp_combined_ss60 emp_combined_ss65 emp_combined_ss70 spend_acf spend_aer spend_all spend_apg spend_grf spend_hcs spend_tws spend_all_inchigh spend_all_inclow spend_all_incmiddle spend_retail_w_grocery spend_retail_no_grocery provisional day_endofweek bg_posts bg_posts_ss30 bg_posts_ss55 bg_posts_ss60 bg_posts_ss65 bg_posts_ss70 bg_posts_jz1 bg_posts_jzgrp12 bg_posts_jz2 bg_posts_jz3 bg_posts_jzgrp345 bg_posts_jz4 bg_posts_jz5 gps_retail_and_recreation gps_grocery_and_pharmacy gps_parks gps_transit_stations gps_workplaces gps_residential gps_away_from_home merchants_all merchants_inchigh merchants_inclow merchants_incmiddle merchants_ss40 merchants_ss60 merchants_ss65 merchants_ss70 revenue_all revenue_inchigh revenue_inclow revenue_incmiddle revenue_ss40 revenue_ss60 revenue_ss65 revenue_ss70 test_count test_rate case_count death_count case_rate death_rate avg_new_case_count avg_new_death_rate avg_new_case_rate, replace force

save stata\state_data.dta, replace



*********** Import CI data ************
clear
import delimited data\output\ci_raw.csv
drop v1

destring county_pop2019 cyber_sum pcs it_budget hardware_budget software_budget services_budget vpn_pres idaccess_sw_pres dbms_pres datawarehouse_sw_pres security_sw_pres ,replace ignore("NA")

order statename stateabbrev county_pop2019, b( siteid )

tabulate it_staff , generate(no_it_employee)
tabulate sicgrp , generate(sic) 

/*
rename no_it_employee2 no_it_employee12
rename no_it_employee3 no_it_employee13
rename no_it_employee6 no_it_employee2
rename no_it_employee12 no_it_employee3
rename no_it_employee5 no_it_employee15
rename no_it_employee7 no_it_employee5
rename no_it_employee13 no_it_employee6
rename no_it_employee15 no_it_employee7
*/

rename no_it_employee9 no_it_employee0
save stata\ci_raw.dta

clear
use stata\ci_raw.dta 

preserve

collapse (count)  siteid (sum)  emple reven salesforce mobile_workers cyber_sum pcs it_budget hardware_budget software_budget services_budget vpn_pres idaccess_sw_pres dbms_pres datawarehouse_sw_pres security_sw_pres no_it_employee1 no_it_employee3 no_it_employee6 no_it_employee4 no_it_employee7 no_it_employee2 no_it_employee5 no_it_employee8 no_it_employee0 sic1 sic2 sic3 sic4 sic5 sic6 sic7 sic8 sic9 sic10, by(county)



label variable no_it_employee1 "(sum) if_staff == 1 to 4"
label variable no_it_employee3 "(sum) 10 to 24"
label variable no_it_employee6 "(sum) 100 to 249"
label variable no_it_employee4 "(sum) 25 to 49"
label variable no_it_employee7 "(sum) 250 to 499"
label variable no_it_employee2 "(sum) 5 to 9"
label variable no_it_employee5 "(sum) 50 to 99"
label variable no_it_employee8 "(sum) 500 to more"
label variable no_it_employee0 "(sum) NA"
label variable sic1 "(sum) AG-M-C"
label variable sic2 "(sum) EDUC"
label variable sic3 "(sum) F-I-RE"
label variable sic4 "(sum) GOVTR"
label variable sic4 "(sum) GOVT"
label variable sic5 "(sum) MANUF"
label variable sic6 "(sum) MED"
label variable sic7 "(sum) NON-CL"
label variable sic8 "(sum) SVCS"
label variable sic9 "(sum) TR-UTL"
label variable sic10 "(sum) WHL-RT"

compress
save "stata\ci_county_data.dta" /*CI data at aggregate level*/

restore

collapse (count)  siteid (sum)  emple reven salesforce mobile_workers cyber_sum pcs it_budget hardware_budget software_budget services_budget vpn_pres idaccess_sw_pres dbms_pres datawarehouse_sw_pres security_sw_pres no_it_employee1 no_it_employee3 no_it_employee6 no_it_employee4 no_it_employee7 no_it_employee2 no_it_employee5 no_it_employee8 no_it_employee0 sic1 sic2 sic3 sic4 sic5 sic6 sic7 sic8 sic9 sic10, by(stateabbrev)

label variable no_it_employee1 "(sum) if_staff == 1 to 4"
label variable no_it_employee3 "(sum) 10 to 24"
label variable no_it_employee6 "(sum) 100 to 249"
label variable no_it_employee4 "(sum) 25 to 49"
label variable no_it_employee7 "(sum) 250 to 499"
label variable no_it_employee2 "(sum) 5 to 9"
label variable no_it_employee5 "(sum) 50 to 99"
label variable no_it_employee8 "(sum) 500 to more"
label variable no_it_employee0 "(sum) NA"
label variable sic1 "(sum) AG-M-C"
label variable sic2 "(sum) EDUC"
label variable sic3 "(sum) F-I-RE"
label variable sic4 "(sum) GOVT"
label variable sic5 "(sum) MANUF"
label variable sic6 "(sum) MED"
label variable sic7 "(sum) NON-CL"
label variable sic8 "(sum) SVCS"
label variable sic9 "(sum) TR-UTL"
label variable sic10 "(sum) WHL-RT"


compress
save "stata\ci_state_data.dta" /*CI data at state level*/

****************20210114 MSA data & WFH feasibility 
clear

projmanager "C:\Users\Leting\Documents\Covid-Cyber-Unemploy\covidcyber.stpr" 
import delimited "C:\Users\Leting\Documents\Covid-Cyber-Unemploy\data\geocorr2018 -crosswalk_revised.csv", varnames(1)
drop if state == "State code"
keep new_cbsa cbsaname15 county14
duplicates drop
destring county14 cbsa, replace
rename new_cbsa area
rename county14 county
destring area, replace
merge m:1 area using "C:\Users\Leting\Documents\Covid-Cyber-Unemploy\stata\msa_teleworkable.dta"
sort area
drop _merge
drop if county ==.
save "C:\Users\Leting\Documents\Covid-Cyber-Unemploy\stata\msa_teleworkable.dta"



************* Import QWI state and county data *****************
clear

rename geography statefips
import delimited "C:\Users\Leting\Documents\Covid-Cyber-Unemploy\data\output\state_qwi_agg.csv"
codebook
drop v1
rename geography statefips
rename ( its_emps_all its_emps_male its_emps_female com_emps_all com_emps_male com_emps_female all_emps_all all_emps_male all_emps_female its_empstotal_all its_empstotal_male its_empstotal_female com_empstotal_all com_empstotal_male com_empstotal_female all_empstotal_all all_empstotal_male all_empstotal_female its_earn_all its_earn_male its_earn_female com_earn_all com_earn_male com_earn_female all_earn_all all_earn_male all_earn_female ) (state_=)
save "C:\Users\Leting\Documents\Covid-Cyber-Unemploy\stata\qwi_state.dta"



import delimited "C:\Users\Leting\Documents\Covid-Cyber-Unemploy\data\output\county_qwi_agg.csv"
codebook
drop v1
rename geography county
rename ( its_emps_all its_emps_male its_emps_female com_emps_all com_emps_male com_emps_female all_emps_all all_emps_male all_emps_female its_empstotal_all its_empstotal_male its_empstotal_female com_empstotal_all com_empstotal_male com_empstotal_female all_empstotal_all all_empstotal_male all_empstotal_female its_earn_all its_earn_male its_earn_female com_earn_all com_earn_male com_earn_female all_earn_all all_earn_male all_earn_female ) (county_=)
save "C:\Users\Leting\Documents\Covid-Cyber-Unemploy\stata\qwi_county.dta"




