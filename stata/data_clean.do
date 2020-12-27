********************
*Title: COVID 19 and Unemployment 
*Author: Leting Zhang
*Date: 20201210
********************


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
label variable sic4 "(sum) GOVTR"
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

save "C:\Users\Leting\Documents\Covid-Cyber-Unemploy\stata\county_panel.dta"

* Create state panel 

use stata\state_data.dta
merge m:1 stateabbrev using "stata\ci_state_data.dta"
destring statefips  month ordermonth orderday, replace ignore("NA")
xtset statefips month
xtdescribe


save "C:\Users\Leting\Documents\Covid-Cyber-Unemploy\stata\state_panel.dta"


********************* Here 20201226

local sumvar "sum_emple sum_reven sum_salesforce sum_mobile_workers sum_cyber_sum sum_pcs sum_it_budget sum_hardware_budget sum_software_budget sum_services_budget sum_vpn_pres sum_idaccess_sw_pres sum_dbms_pres sum_datawarehouse_sw_pres sum_security_sw_pres sum_AG_M_C sum_EDUC sum_F_I_RE sum_GOVT sum_MANUF sum_MED sum_NON_CL sum_SVCS sum_TR_UTL sum_WHL_RT"


foreach i of local sumvar {
	g ln_`i' = ln(`i'+1)
}





local depvar  "avg_initclaims_count avg_initclaims_rate emp_combined emp_combined_inclow emp_combined_incmiddle emp_combined_inchigh"


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

	*2020
	areg  avg_initclaims_rate afterstayhome i.month##c.ln_sum_security_sw_pres i.month##c.ln_sum_emple i.month##c.ln_sum_reven i.month i.month##c.ln_sum_it_budget i.month , absorb(county) rob
areg  avg_initclaims_rate afterstayhome i.month##c.ln_sum_security_sw_pres i.month##c.ln_sum_emple i.month##c.ln_sum_reven i.month i.month##c.ln_sum_it_budget i.month , absorb(county) rob
