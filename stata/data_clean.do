********************
*Title: COVID 19 and Unemployment 
*Author: Leting Zhang
*Date: 20201210
********************


clear
* Import county data
import delimited data\output\county_raw.csv, varnames(1) 
drop v1
destring emp_combined emp_combined_inclow emp_combined_incmiddle emp_combined_inchigh avg_initclaims_count avg_initclaims_rate ordermonth orderday case_count death_count case_rate death_rate avg_new_case_count  avg_new_death_rate avg_new_case_rate, replace force
order statename, b( stateabbrev )
order statename ordermonth orderday , b( emp_combined )
rename countyfips county
save stata\county_panel.dta, replace

clear
* Import CI data
import delimited data\output\ci_raw.csv
drop v1

destring cyber_sum pcs it_budget hardware_budget software_budget services_budget vpn_pres idaccess_sw_pres dbms_pres datawarehouse_sw_pres security_sw_pres ,replace ignore("NA")
destring county_pop2019, replace force
order statename stateabbrev county_pop2019, b( siteid )
tabulate it_staff , generate(no_it_employee)
rename no_it_employee2 no_it_employee12
rename no_it_employee3 no_it_employee13
rename no_it_employee6 no_it_employee2
rename no_it_employee12 no_it_employee3
rename no_it_employee5 no_it_employee15
rename no_it_employee7 no_it_employee5
rename no_it_employee13 no_it_employee6
rename no_it_employee15 no_it_employee7

save stata\ci_raw.dta


* Create CI county level data

local site_sum_var "emple reven salesforce mobile_workers cyber_sum pcs it_budget hardware_budget software_budget services_budget vpn_pres idaccess_sw_pres dbms_pres datawarehouse_sw_pres security_sw_pres"
local sic "AG-M-C EDUC F-I-RE GOVT MANUF  MED NON-CL SVCS TR-UTL WHL-RT"

bys county: egen site_number = count( siteid )


foreach i of local site_sum_var {
	bys county: egen sum_`i' = sum(`i')
	}

foreach i of local sic {
	local j = subinstr("`i'", "-", "_", .)
	bys county: egen sum_`j' = count(siteid/ (sicgrp == "`i'")) 
}



compress
save "stata\ci_raw_sum_county.dta", replace

keep county statename stateabbrev county_pop2019 sum_emple sum_reven sum_salesforce sum_mobile_workers sum_cyber_sum sum_pcs sum_it_budget sum_hardware_budget sum_software_budget sum_services_budget sum_vpn_pres sum_idaccess_sw_pres sum_dbms_pres sum_datawarehouse_sw_pres sum_security_sw_pres sum_AG_M_C sum_EDUC sum_F_I_RE sum_GOVT sum_MANUF sum_MED sum_NON_CL sum_SVCS sum_TR_UTL sum_WHL_RT
duplicates drop
save "stata\ci_county_panel.dta"

clear
* Merge
use "stata\county_panel.dta" 
merge m:1 county using "stata\ci_county_panel.dta"
destring county month, replace ignore("NA")
xtset county month
xtdescribe

by county: replace stateabbrev = stateabbrev[_n-1] if stateabbrev == "NA"
by county: replace statename = statename[_n-1] if statename == "NA"
by county: replace ordermonth = ordermonth[_n-1] if ordermonth ==.
generate afterstayhome = (month > ordermonth)
egen mean_cyber = mean( sum_cyber_sum )
g high_cyber = ( sum_cyber_sum >mean_cyber )

local sumvar "sum_emple sum_reven sum_salesforce sum_mobile_workers sum_cyber_sum sum_pcs sum_it_budget sum_hardware_budget sum_software_budget sum_services_budget sum_vpn_pres sum_idaccess_sw_pres sum_dbms_pres sum_datawarehouse_sw_pres sum_security_sw_pres sum_AG_M_C sum_EDUC sum_F_I_RE sum_GOVT sum_MANUF sum_MED sum_NON_CL sum_SVCS sum_TR_UTL sum_WHL_RT"


foreach i of local sumvar {
	g ln_`i' = ln(`i'+1)
}

save "stata\panel202012.dta"


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

