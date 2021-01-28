********************
*Title: COVID 19 and Unemployment 
*Author: Leting Zhang
*Date: 20201210
********************


*********************
*Packages: genicv: for generating interaction terms 
*
*********************

clear
* Import county data
import delimited data\output\data_county.csv, varnames(1) 

drop v1

rename countyfips county

order statefips stateabbrev state ordermonth orderday, a(county)

destring month countyfips avg_initclaims_count avg_initclaims_rate emp_combined emp_combined_inclow emp_combined_incmiddle emp_combined_inchigh spend_all gps_retail_and_recreation gps_grocery_and_pharmacy gps_parks gps_transit_stations gps_workplaces gps_residential gps_away_from_home merchants_all revenue_all case_count death_count case_rate death_rate avg_new_case_count avg_new_death_rate avg_new_case_rate, replace force

save stata\county_data.dta, replace

* Import state data
clear

import delimited data\output\data_state.csv, varnames(1) 

drop v1

order stateabbrev state ordermonth orderday, a( statefips )

destring statefips month initclaims_count_regular initclaims_rate_regular contclaims_count_regular contclaims_rate_regular initclaims_count_pua contclaims_count_pua emp_combined emp_combined_inclow emp_combined_incmiddle emp_combined_inchigh emp_combined_ss40 emp_combined_ss60 emp_combined_ss65 emp_combined_ss70 spend_acf spend_aer spend_all spend_apg spend_grf spend_hcs spend_tws spend_all_inchigh spend_all_inclow spend_all_incmiddle spend_retail_w_grocery spend_retail_no_grocery provisional day_endofweek bg_posts bg_posts_ss30 bg_posts_ss55 bg_posts_ss60 bg_posts_ss65 bg_posts_ss70 bg_posts_jz1 bg_posts_jzgrp12 bg_posts_jz2 bg_posts_jz3 bg_posts_jzgrp345 bg_posts_jz4 bg_posts_jz5 gps_retail_and_recreation gps_grocery_and_pharmacy gps_parks gps_transit_stations gps_workplaces gps_residential gps_away_from_home merchants_all merchants_inchigh merchants_inclow merchants_incmiddle merchants_ss40 merchants_ss60 merchants_ss65 merchants_ss70 revenue_all revenue_inchigh revenue_inclow revenue_incmiddle revenue_ss40 revenue_ss60 revenue_ss65 revenue_ss70 test_count test_rate case_count death_count case_rate death_rate avg_new_case_count avg_new_death_rate avg_new_case_rate, replace force

save stata\state_data.dta, replace

clear

* Import CI data
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

/*
* Import EconTrack Data 

import delimited data\output\econ_mean.csv
drop v1
destring spend_all gps_retail_and_recreation gps_grocery_and_pharmacy gps_parks gps_transit_stations gps_workplaces gps_residential gps_away_from_home merchants_all revenue_all, replace force
rename countyfips county
save stata\econ_panel.dta
*/

* Create CI county/state level data
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


/*
local site_sum_var "emple reven salesforce mobile_workers cyber_sum pcs it_budget hardware_budget software_budget services_budget vpn_pres idaccess_sw_pres dbms_pres datawarehouse_sw_pres security_sw_pres no_it_employee1 no_it_employee3 no_it_employee6 no_it_employee4 no_it_employee7 no_it_employee2 no_it_employee5 no_it_employee8 no_it_employee9 sic1 sic2 sic3 sic4 sic5 sic6 sic7 sic8 sic9 sic10"

bys county: egen site_number = count( siteid )


foreach i of local site_sum_var {
	bys county: egen sum_`i' = sum(`i')
	}

foreach i of local sic {
	local j = subinstr("`i'", "-", "_", .)
	bys county: egen sum_`j' = count(siteid/ (sicgrp == "`i'")) 
}

save "stata\ci_raw_sum_county.dta", replace

keep county statename stateabbrev county_pop2019 sum_emple sum_reven sum_salesforce sum_mobile_workers sum_cyber_sum sum_pcs sum_it_budget sum_hardware_budget sum_software_budget sum_services_budget sum_vpn_pres sum_idaccess_sw_pres sum_dbms_pres sum_datawarehouse_sw_pres sum_security_sw_pres sum_AG_M_C sum_EDUC sum_F_I_RE sum_GOVT sum_MANUF sum_MED sum_NON_CL sum_SVCS sum_TR_UTL sum_WHL_RT
duplicates drop
*/

compress
save "stata\ci_county_data.dta"

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
save "stata\ci_state_data.dta"

stateabbrev

* Create county panel 
use stata\county_data.dta
merge m:1 county using "stata\ci_county_data.dta"
destring statefips county month ordermonth orderday, replace ignore("NA")
xtset county month
xtdescribe

bys county: replace stateabbrev = stateabbrev[_n-1] if stateabbrev == "NA"
bys county: replace state = state[_n-1] if state == "NA"
bys county: replace statefips = statefips[_n-1] if statefips == .
bys county: replace orderday = orderday[_n-1] if orderday ==.

generate afterstayhome = (month > ordermonth)
egen mean_cyber = mean( cyber_sum )
g high_cyber = ( cyber_sum >mean_cyber )



* Label data
label variable avg_initclaims_count "Count of initial claims, regular UI only"
label variable avg_initclaims_rate "Number of initial claims per 100 people in the 2019 labor force"

label variable emp_combined "Employment level for all workers"
label variable emp_combined_inclow "Employment level - low income"
label variable emp_combined_incmiddle "Employment level - middle income"
label variable emp_combined_inchigh "Employment level - high income workers"

label variable spend_all "Spending in all merchant category codes"
label variable merchants_all "Percent change in number of small businesses open"
label variable revenue_all "Percent change in net revenue for small businesses"

label variable case_count "Confirmed COVID-19 cases"
label variable death_count "Confirmed COVID-19 deaths"
label variable case_rate "Confirmed COVID-19 cases per 100,000 people"
label variable death_rate "Confirmed COVID-19 deaths per 100,000 people"
label variable avg_new_case_count "New confirmed COVID-19 cases"
label variable avg_new_case_rate "New confirmed COVID-19 cases per 100,000 people"
label variable avg_new_death_rate "New confirmed COVID-19 deaths per 100,000 people"
label variable afterstayhome "After Stay-at-Home"

label variable ln_it_budget "IT Budget"
label variable ln_siteid "No. of Sites"
label variable ln_emple "Number of Employess"
label variable ln_reven "Total Revenue"
label variable ln_salesforce "Number of Salfesforces"
label variable ln_mobile_workers "Number of Mobile Workers"
label variable ln_cyber_sum "Total Cybersecurity Investment"
label variable ln_pcs "Number of PCs"
label variable ln_hardware_budget "Hardware Budget"
label variable ln_software_budget "Software Budget"
label variable ln_services_budget "Services Budget"
label variable ln_vpn_pres "Number of VPN Presence"
label variable ln_idaccess_sw_pres "Number of ID Access Software Presence"
label variable ln_dbms_pres "Number of Database Management Presence"
label variable ln_datawarehouse_sw_pres "Number of Datawarehouse Presence"
label variable ln_security_sw_pres "Number of Security Software Presence"


label variable avg_initclaims_rate "Rate of unemployment claims"
notes avg_initclaims_count : (regular UI only)
label variable avg_initclaims_count "Count of unemployment claims"
label variable avg_initclaims_rate ""
notes avg_initclaims_rate : Number of initial claims per 100 people in the 2019 labor force
label variable avg_initclaims_rate "Rate of Unemployment Claimes"
label variable avg_initclaims_count "Count of Unemployment Claims"

notes avg_new_death_rate : per 100,000 people
notes avg_new_case_rate : per 100,000 people

label variable avg_new_case_count "New COVID-19 cases"
label variable avg_new_death_rate "New COVID-19 deaths rate"
label variable avg_new_case_rate "New COVID-19 cases rate"

label variable avg_initclaims_count "Count of unemployment claims"
label variable avg_initclaims_rate "Rate of unemployment claimes"
label variable gps_retail_and_recreation "GPS retail and recreation"
label variable gps_grocery_and_pharmacy "GPS grocery and pharmacy"
label variable gps_parks "GPS parks"
label variable gps_transit_stations "GPS tramsot stations"
label variable gps_workplaces "GPS Workplaces"
label variable gps_residential "GPS residential"
label variable gps_away_from_home "GPS away from home"
label variable gps_workplaces "GPS workplaces"




label variable ln_no_it_employee3 "Number of Sites with 1-4 IT Employees"
label variable ln_no_it_employee3 "Number of Sites with 10-24 IT Employees"
label variable ln_no_it_employee6 "Number of Sites with 100-249 IT Employees"
label variable ln_no_it_employee4 "Number of Sites with 25-49 IT Employees"
label variable ln_no_it_employee7 "Number of Sites with 250-499 IT Employees"
label variable ln_no_it_employee2 "Number of Sites with 5-9 IT Employees"
label variable ln_no_it_employee5 "Number of Sites with 50-99 IT Employees"
label variable ln_no_it_employee8 "Number of Sites with more than 500 IT Employees"
label variable ln_no_it_employee0 "NA"

label variable ln_sic1 "Number of Sites in AG-M-C"
label variable ln_sic2 "Number of Sites in EDUC"
label variable ln_sic3 "Number of Sites in F-I-RE"
label variable ln_sic4 "Number of Sites in GOVT"
label variable ln_sic5 "Number of Sites in MANUF"
label variable ln_sic6 "Number of Sites in MED"
label variable ln_sic7 "Number of Sites in NON-CL"
label variable ln_sic8 "Number of Sites in SVCS"
label variable ln_sic9 "Number of Sites in TR-UTL"
label variable ln_sic10 "Number of Sites in WHL-RT"

rename ln_no_it_employee1 ln_no_it_em1
rename ln_no_it_employee3 ln_no_it_em3
rename ln_no_it_employee6 ln_no_it_em6
rename ln_no_it_employee4 ln_no_it_em4
rename ln_no_it_employee7 ln_no_it_em7
rename ln_no_it_employee2 ln_no_it_em2
rename ln_no_it_employee5 ln_no_it_em5
rename ln_no_it_employee8 ln_no_it_em8
rename ln_no_it_employee0 ln_no_it_em0

rename ln_hardware_budget ln_hw_budget
rename ln_software_budget ln_sw_budget
rename ln_services_budget ln_s_budget
rename ln_idaccess_sw_pres ln_ida_sw_pres
rename ln_datawarehouse_sw_pres ln_dw_sw_pres

rename afterstayhome aftersh



local ci "ln_siteid ln_emple ln_reven ln_salesforce ln_mobile ln_cyber_sum ln_pcs ln_it_budget ln_hw_budget ln_sw_budget ln_s_budget ln_vpn_pres ln_ida_sw_pres ln_dbms_pres ln_dw_sw_pres ln_security_sw_pres ln_no_it_em1 ln_no_it_em3 ln_no_it_em6 ln_no_it_em4 ln_no_it_em7 ln_no_it_em2 ln_no_it_em5 ln_no_it_em8 ln_no_it_em0 ln_sic1 ln_sic2 ln_sic3 ln_sic4 ln_sic5 ln_sic6 ln_sic7 ln_sic8 ln_sic9 ln_sic10"

foreach i of local ci {
	genicv aftersh `i'
}



g after_security_itbudget = aftersh * ln_s_sw_pres * ln_it_budget
label variable after_security_pres_it_budget "After Stay-at-Home * Security Software Presence * IT Budget"


save "C:\Users\Leting\Documents\Covid-Cyber-Unemploy\stata\county_panel.dta"


* Create state panel 

use stata\state_data.dta
merge m:1 stateabbrev using "stata\ci_state_data.dta"
destring statefips  month ordermonth orderday, replace ignore("NA")
xtset statefips month
xtdescribe

bys statefips: replace ordermonth = ordermonth[_n-1] if ordermonth ==.
bys statefips: replace orderday = orderday[_n-1] if orderday ==.

generate afterstayhome = (month > ordermonth)
save "C:\Users\Leting\Documents\Covid-Cyber-Unemploy\stata\state_panel.dta"

* Label data  -State level 

label variable initclaims_count_regular "Count of initial claims, regular UI only"
notes initclaims_rate_regular : Number of initial claims per 100 people in the 2019 labor force, Regular UI only
label variable initclaims_rate_regular "Number of initial claims per 100 people in the 2019 labor force"
label variable contclaims_count_regular "Count of initial claims "
label variable contclaims_count_regular "Count of continued claims, Regular UI only"
label variable contclaims_rate_regular ": Number of continued claims per 100 people in the 2019 labor force, Regular UI only"
label variable contclaims_rate_regular " Number of continued claims per 100 people in the 2019 labor force, Regular UI "
label variable contclaims_rate_regular "Number of continued claims per 100 people in the 2019 labor force, Regular UI "
label variable initclaims_count_pua "Count of initial claims, PUA (Pandemic Unemployment Assistance) only"
label variable contclaims_count_pua "Count of continued claims, PUA (Pandemic Unemployment Assistance) only"

label variable emp_combined " Employment level for all workers."
label variable emp_combined_inclow "Employment level for low income workers"
label variable emp_combined_incmiddle "Employment level for middle income workers"
label variable emp_combined_inchigh "Employment level for high income workers"
notes emp_combined_incmiddle : (incomes approximately $27,000 to $60,000)
notes emp_combined_inchigh :  (incomes approximately over $60,000).
label variable emp_combined_ss40 ": Employment level for workers in trade, transportation and utilities"
label variable emp_combined_ss40 "Employment level for workers in trade, transportation and utilities"
label variable emp_combined_ss60 "Employment level for workers in professional and business services"
label variable emp_combined_ss65 "Employment level for workers in education and health services "
label variable emp_combined_ss70 " Employment level for workers in leisure and hospitality (NAICS supersector 70)"

label variable spend_acf "spending relative to January 4-31 2020 in accomodation and food service (ACF)"
label variable spend_acf "spending in accomodation and food service (ACF)"
notes spend_acf : relative to January 4-31 2020
label variable spend_acf "Spending in accomodation and food service (ACF)"
label variable spend_aer "Spending in accomodation and food service (ACF)"
label variable spend_aer "Spending in arts, entertainment, and recreation (AER)"
label variable spend_all "Spending in all merchant category codes"
label variable spend_apg "all merchant category codes"
label variable spend_apg "Spending in general merchandise stores (GEN) and apparel and accessories (AAP) MCCs"
label variable spend_grf "Spending in grocery and food store (GRF) "
label variable spend_hcs "Spending in  health care and social assistance (HCS) "
label variable spend_tws "Spending in transportation and warehousing (TWS) "
label variable spend_all_inchigh "spending by consumers living in ZIP codes with high  median income"
label variable spend_all_inclow "spending by consumers living in ZIP codes with middle income"
label variable spend_all_incmiddle "spending by consumers living in ZIP codes with low income"

label variable bg_posts "Average level of job postings"
notes bg_posts :  relative to January 4-31 2020
label variable bg_posts_ss30 "Average level of job postings in manufacturing"
label variable bg_posts_ss55 "Average level of job postings in financial activities "
label variable bg_posts_ss60 "Average level of job postings in professional and business services "
label variable bg_posts_ss65 "Average level of job postings in education and health services"
label variable bg_posts_ss70 "Average level of job postings in leisure and hospitality"
label variable bg_posts_jz1 " requiring little/no preparation"
label variable bg_posts_jz1 " Average level of job postings requiring little/no preparation"
label variable bg_posts_jzgrp12 "Average level of job postings"
label variable bg_posts_jz2 "Average level of job postings"
label variable bg_posts_jz3 "Average level of job postings"
label variable bg_posts_jzgrp345 "Average level of job postings"
label variable bg_posts_jz4 "Average level of job postings"
label variable bg_posts_jz5 "Average level of job postings"
label variable bg_posts_jzgrp12 "Average level of job postings requiring low preparation"
notes bg_posts_jz1 : ONET jobzone level 1
label variable bg_posts_jz2 "Average level of job postings  requiring some preparation"
label variable bg_posts_jz3 "Average level of job postings requiring medium preparation"
label variable bg_posts_jzgrp345 "Average level of job postings requiring high preparation"
label variable bg_posts_jz4 "Average level of job postings requiring considerable preparation"
label variable bg_posts_jz5 "Average level of job postings requiring extensive preparation "

label variable merchants_all " Percent change in number of small businesses open "
label variable merchants_inchigh "Percent change in number of small businesses open in high income ZIP codes"
label variable merchants_all "Percent change in number of small businesses open "
label variable merchants_inclow "Percent change in number of small businesses open in middle income ZIP codes"
label variable merchants_incmiddle "Percent change in number of small businesses open in middle income ZIP codes"
label variable merchants_ss40 "Percent change in number of small businesses open"
label variable merchants_ss40 "Transportation - Percent change in number of small businesses open"
label variable merchants_ss60 "Percent change in number of small businesses open"
label variable merchants_ss65 "Percent change in number of small businesses open"
label variable merchants_ss70 "Percent change in number of small businesses open"
label variable merchants_ss60 "Professional and business services - Percent change in number of small businesses open"
label variable merchants_ss65 "education and health services  - Percent change in number of small businesses open"
label variable merchants_ss65 "Education and health services  - Percent change in number of small businesses op"
label variable merchants_ss70 " Leisure and hospitality - Percent change in number of small businesses open"
label variable merchants_ss70 "Leisure and hospitality - Percent change in number of small businesses open"

label variable revenue_all "Percent change in net revenue for small businesses"
label variable revenue_ss40 "Transportation"
label variable revenue_ss60 "Professional and business services"
label variable revenue_ss65 "Education and health services"
label variable revenue_ss70 "Leisure and hospitality"

label variable test_count "Confirmed COVID-19 tests"
label variable test_rate "Confirmed COVID-19 tests per 100,000 people"
label variable case_count "Confirmed COVID-19 cases"
label variable death_count "Confirmed COVID-19 deaths"
label variable case_rate "Confirmed COVID-19 cases per 100,000 people"
label variable death_rate "Confirmed COVID-19 deaths per 100,000 people"

label variable avg_new_case_count "New confirmed COVID-19 cases"
label variable avg_new_death_rate "New confirmed COVID-19 deaths"
label variable avg_new_case_count "New confirmed COVID-19 cases"
label variable avg_new_case_rate " New confirmed COVID-19 cases per 100,000 people"

save "C:\Users\Leting\Documents\Covid-Cyber-Unemploy\stata\state_panel.dta"


local ci " siteid emple reven salesforce mobile_workers cyber_sum pcs it_budget hardware_budget software_budget services_budget vpn_pres idaccess_sw_pres dbms_pres datawarehouse_sw_pres security_sw_pres no_it_employee1 no_it_employee3 no_it_employee6 no_it_employee4 no_it_employee7 no_it_employee2 no_it_employee5 no_it_employee8 no_it_employee0 sic1 sic2 sic3 sic4 sic5 sic6 sic7 sic8 sic9 sic10 "

foreach i of local ci {
	g ln_`i' = ln(`i'+1)
}

local sic "sic1 sic2 sic3 sic4 sic5 sic6 sic7 sic8 sic9 sic10"

foreach i of local sic {
    g per_`i' = `i'/siteid
}

egen mean_itbudget = mean(it_budget)
g high_itbudget = (it_budget> mean_itbudget )




****************20210114 MSA data & WFH feasibility 

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


******************TODO: USE THE NEW REVISED GEOCROSS_FILE



**************
areg avg_initclaims_count afterstayhome##c.ln_security_sw_pres i.month,  absorb(county) rob
areg emp_combined afterstayhome##c.ln_security_sw_pres i.month,  absorb(county) rob
areg emp_combined_inclow afterstayhome##c.ln_security_sw_pres i.month,  absorb(county) rob
areg emp_combined_incmiddle afterstayhome##c.ln_security_sw_pres i.month,  absorb(county) rob
areg emp_combined_inchigh afterstayhome##c.ln_security_sw_pres i.month,  absorb(county) rob



local depvar  "avg_initclaims_count avg_initclaims_rate emp_combined emp_combined_inclow emp_combined_incmiddle emp_combined_inchigh"

local persic "per_sic1 per_sic2 per_sic3 per_sic4 per_sic5 per_sic6 per_sic7 per_sic8 per_sic9 per_sic10"



foreach i of local depvar {
	foreach j of local persic {
	areg `i' afterstayhome##c.`j' i.month##ln_it_budget  gps_away_from_home avg_new_death_rate avg_new_case_rate , absorb(county) rob
	}
	}



foreach i of local depvar {

	areg `i' afterstayhome##c.ln_sum_cyber_sum i.month,  absorb(county) rob
	areg `i' afterstayhome##c.ln_sum_cyber_sum afterstayhome##c.ln_sum_emple afterstayhome##c.ln_sum_reven i.month,  absorb(county) rob
	areg `i' afterstayhome##c.ln_sum_cyber_sum afterstayhome##c.ln_sum_emple afterstayhome##c.ln_sum_reven  i.month,  absorb(county) rob
	areg `i' afterstayhome afterstayhome##c.ln_sum_cyber_sum afterstayhome##c.ln_sum_emple afterstayhome##c.ln_sum_reven afterstayhome##c.ln_sum_vpn_pres afterstayhome##c.ln_sum_dbms_pres afterstayhome##c.ln_sum_datawarehouse_sw_pres afterstayhome##c.ln_sum_security_sw_pres afterstayhome##c.sum_AG_M_C afterstayhome##c.sum_EDUC afterstayhome##c.sum_F_I_RE  avg_new_death_rate avg_new_case_rate i.month,  absorb(county) rob
	}


foreach i of local depvar {

	areg `i' afterstayhome##c.ln_sum_cyber_sum i.month,  absorb(county) rob
	areg `i' afterstayhome##c.ln_sum_cyber_sum afterstayhome##c.ln_sum_emple afterstayhome##c.ln_sum_reven i.month,  absorb(county) rob
	areg `i' afterstayhome afterstayhome##c.ln_sum_cyber_sum afterstayhome##c.ln_sum_emple afterstayhome##c.ln_sum_reven afterstayhome##c.ln_sum_vpn_pres afterstayhome##c.ln_sum_dbms_pres afterstayhome##c.ln_sum_datawarehouse_sw_pres afterstayhome##c.ln_sum_security_sw_pres afterstayhome##c.sum_AG_M_C afterstayhome##c.sum_EDUC afterstayhome##c.sum_F_I_RE  avg_new_death_rate avg_new_case_rate i.month,  absorb(county) rob
	
	areg `i' afterstayhome##high_cyber i.month,  absorb(county) rob
	areg `i' afterstayhome##high_cyber afterstayhome##c.ln_sum_emple afterstayhome##c.ln_sum_reven i.month,  absorb(county) rob
	areg `i' afterstayhome afterstayhome##high_cyber afterstayhome##c.ln_sum_emple afterstayhome##c.ln_sum_reven afterstayhome##c.ln_sum_vpn_pres afterstayhome##c.ln_sum_dbms_pres afterstayhome##c.ln_sum_datawarehouse_sw_pres afterstayhome##c.ln_sum_security_sw_pres afterstayhome##c.sum_AG_M_C afterstayhome##c.sum_EDUC afterstayhome##c.sum_F_I_RE  avg_new_death_rate avg_new_case_rate i.month,  absorb(county) rob
	
	}
	
	
foreach i of local depvar {

	areg `i' afterstayhome##c.ln_security_sw_pres i.month,  absorb(county) rob
	areg `i' afterstayhome##c.ln_security_sw_pres afterstayhome##c.ln_emple afterstayhome##c.ln_reven i.month,  absorb(county) rob
	areg `i' afterstayhome##c.ln_security_sw_pres##c.ln_it_budget afterstayhome##c.ln_security_sw_pres  afterstayhome##c.ln_it_budget, absorb(county) rob

	
	}


	*2020
	areg  avg_initclaims_rate afterstayhome i.month##c.ln_sum_security_sw_pres i.month##c.ln_sum_emple i.month##c.ln_sum_reven i.month i.month##c.ln_sum_it_budget i.month , absorb(county) rob
areg  avg_initclaims_rate afterstayhome i.month##c.ln_sum_security_sw_pres i.month##c.ln_sum_emple i.month##c.ln_sum_reven i.month i.month##c.ln_sum_it_budget i.month , absorb(county) rob


**
areg emp_combined aftersh##c.teleworkable_manual_emp##c.ln_security_sw_pres   gps_away_from_home avg_new_death_rate avg_new_case_rate i.month,  absorb(county) rob
 areg emp_combined aftersh##c.gps_away_from_home##c.ln_security_sw_pres avg_new_death_rate avg_new_case_rate i.month,  absorb(county) rob