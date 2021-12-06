
***********************
** Title: Covid & Employment & IT investment Output & Weekly
** Stage: S1- Data cleaning & Experiment 
** Date: 202107
** Author: Leting Zhang
**
************************


**# Import data & panel set 

use "C:\Users\Leting\Documents\Covid-Cyber-Unemploy\Stata\county_week_panel_july.dta" 
compress

g stayweek = statepolicy_week
replace stayweek = countypolicy_week if countypolicy_week< statepolicy_week
g tre = (week>stayweek)
order stayweek tre, a(countyfips)
sort countyfips week
order week, a(countyfips)
drop if week ==.
xtset countyfips week
encode state, g(state_code)
rename countyfips county
rename *, lower

* rename it_budget_county_win_mean it_budget_cwin_mean

**# Merge dataset

drop _merge
merge m:1 county using "C:\Users\Leting\Documents\Covid-Cyber-Unemploy\Stata\county_demographic.dta"

drop _merge
merge m:1 county using "C:\Users\Leting\Documents\Covid-Cyber-Unemploy\Stata\msa_teleworkable.dta"

order abb, b(stayweek)
rename abb state
order avg_new_case_count avg_new_death_rate avg_new_case_rate avg_home_prop avg_work_prop avg_median_home, a( emp_combined_inchigh )
order gps_away_from_home, b(spend_all)
order spend_all, b(merchants_all)
order teleworkable_manual_emp teleworkable_manual_wage teleworkable_emp teleworkable_wage, a( gps_residential )
order population, b(totalhousehold)


* Add industry data
drop _merge
merge m:1 county using "C:\Users\Leting\Documents\2.Covid_IT_Employment\Stata\county_industry.dta"



* Quantile

local itquan it_budget_median it_budget_per_emp_median pcs_median pc_per_emp_median its_emps_all its_empstotal_all com_emps_all
foreach i of local itquan {
xtile `i'_qtl = `i', nq(4)
g q4_high_`i' = (`i'_qtl == 4)
g q2_high_`i' = (`i'_qtl > 2)
}

* Merge old IT groups

drop _merge
merge m:1 county using "C:\Users\Leting\Documents\2.Covid_IT_Employment\Stata\county_earlier_ITGroups.dta"


**# Generate variables

* Event indicator
g event = week - stayweek 
forv tau = 5(-1)1 {
g treatb`tau' = event == -`tau'
la var treatb`tau' "T - `tau'"
}
table event
forv tau = 0/5 {
g treata`tau' = event == `tau'
la var treata`tau' "T + `tau'"
}



g treatb6 = (event== -6)
order treatb6, b(treatb5)

label variable treata0 "T=0"
label variable treata6forward "T + 6 forward"

g treata6forward = (event>5)

g treatb6backward = (event<-5)
g treatb5backward = (event<-4)
g treatb4backward = (event<-3)

order treatb6backward treatb5backward treatb4backward, b( treatb5 )

g treated = tre*q4_high_it_budget_median

* Month 
recode week (2/5 = 1) (6/9 = 2) (10/14 = 3) (15/18 = 4) (19/22 = 5) (23/26 = 6) (27/30 = 7) (31/35 = 8) (36/40 = 9) (41/44 = 10) (45/49 = 11) (50/53 = 12), g(month)
order month, a(week)


* Log
local logvar it_budget_median com_emps_all its_emps_all 
foreach i of local 

g ln_com_emp = log( com_emps_all  + 1)
g ln_its_emps = log( its_emps_all  + 1)
g ln_it_budget_median = log(it_budget_median + 1)
g ln_pop = log(population+1)
g ln_income = log(medianhouseholdincome+1)

*save "C:\Users\Leting\Documents\Covid-Cyber-Unemploy\Stata\county_week_panel_july_analysis.dta"
save "C:\Users\Leting\Documents\Covid-Cyber-Unemploy\Stata\county_week_panel_aug_analysis.dta"



labvars initclaims_count_regular initclaims_rate_regular emp_combined avg_new_death_rate avg_new_case_rate avg_home_prop "Unemployment Count" "Unemployment Rate" "Employment Level"  "COVID Death Rate" "COVID New Case Rate" "Stay at Home Index"

 
labvars appdev_peremp_median-infra_peremp_median "App Dev" "Enterprise App " "Cloud Solution" "Personal Productivity" "Digital Marketing/Commerce" "Collaboration" "Security" "Infrastructure"
labvars appdev_median-infra_median "App Dev" "Enterprise App " "Cloud Solution" "Personal Productivity" "Digital Marketing/Commerce" "Collaboration" "Security" "Infrastructure"

labvars number_per_emp_Dev_median-number_per_emp_Network_median  "App Dev" "Enterprise Software" "Software-as-a-Service" "Database"  "Groupware and PCs" "Digital Marketing and E-business"  "Cybersecurity" "Hardware Infrastructure"

 
* Employee industry distribution percentage 
labvars agriculture construction manufacturing wholesale retail transportation information insurance "Agriculture Employees" "Construction Employees" "Manufacturing Employees" "Wholesalfe Employees" "Retail Employees" "Trans Employees" "Services Employees" "Insurance Employees"
  
  
**# Matching variables

frame copy default psm
frame change psm
frame pwf

order countyname, a(county)

preserve

local usevar "it_budget_median q4_high_it_budget_median countyname  population medianhouseholdincome internetper totalhousehold emple_median reven_median agriculture construction manufacturing wholesale retail transportation information insurance"
 
local matchvar "population medianhouseholdincome internetper totalhousehold emple_median reven_median agriculture construction manufacturing wholesale retail transportation information insurance"
 
* Keep the key indicators and matched variables
keep county  `usevar'
duplicates drop
drop if q4_high_it_budget_median == .


cem population(#10) medianhouseholdincome(#10) internetper(#5) totalhousehold(#5) emple_median(#5) reven_median(#5) agriculture(#3) construction(#3) manufacturing(#3) wholesale(#3) retail(#3) transportation(#3) information(#3) insurance(#3) ,tre( q4_high_it_budget_median )

g cem_strata_strict = cem_strata
g cem_weight_strict = cem_weightss

cem population(#5) medianhouseholdincome(#5) internetper(#5) totalhousehold(#5) emple_median(#5) reven_median(#5) agriculture(#3) construction(#3) manufacturing(#3) wholesale(#3) retail(#3) transportation(#3) information(#3) insurance(#3) ,tre( q4_high_it_budget_median )
g cem_strata_relax = cem_strata
g cem_weight_relax = cem_weights



cem population(#10) medianhouseholdincome(#10) internetper(#10) totalhousehold(#10) emple_median(#10) reven_median(#10) agriculture(#5) construction(#5) manufacturing(#5) wholesale(#5) retail(#5) transportation(#5) information(#5) insurance(#5) ,tre( q4_high_it_budget_median )

frame change default
frlink m:1 county, frame(psm) generate(link)

frget cem_strata_strict  = cem_strata_strict, from(link)
frget cem_weight_strict  = cem_weight_strict, from(link)

frget cem_strata_relax  =  cem_strata_relax, from(link)
frget cem_weight_relax  = cem_weight_relax, from(link)

frget cem_weights_10bins  = cem_weights_10bins, from(link)


keep if cem_strata_strict == 117 | cem_strata_relax == 27

* Philadelphia county number = 42101
frame copy default phi
frame change phi
frame pwf
codebook cem_strata_strict cem_strata_relax if county == 42101

keep if cem_strata_strict == 117 | cem_strata_relax == 27


twoway  (line initclaims_rate_regular week if county == 42101) (line initclaims_rate_regular week if county == 36005) , legend(on order(1 "Philly" 2 "Bronx" ))



* San fan county  =  6075
keep if cem_strata_strict == 112 | cem_strata_relax == 81



**# Label 


labvars tre q4_high_it_budget_median q4_high_its_emps_all "After Stay at Home" "HighBAIT" "HighBAIT (IT Service Employees)"


label variable ln_it_budget_median "BAIT"

label variable ln_its_emps "Alternative BAIT (IT Service Employees)"


label variable internetper "Internet Coverage"

label variable ln_income "Household Income"

label var teleworkable_emp  "Telework index"

label var ln_com_emp "IT equipment employees"


// local var 'initclaims_count_regular initclaims_rate_regular emp_combined avg_new_death_rate avg_new_case_rate avg_home_prop '
// local label  '" "Unemployment Count" "Unemployment Rate" "Employment Level"  "COVID Death Rate" "COVID New Case Rate" "Stay at Home Index" '
//
// local n : word count `label'
//
// forvalues i = 1/`n' {
//     local a: word `i' of `var'
// 	local b: word `i' of `label'
//     label var `a' "`b''"
//	
// }
//



**# Try frames

frame create ciall
frames dir
frame change ciall
import delimited "C:\Users\Leting\Documents\Covid-Cyber-Unemploy\1.Data\2.intermediate_data\ci_all_summary_data.csv"
frame put county it_budget* , into(itbudget)
frame change itbudget
local it " it_budget_mean it_budget_per_emp_mean it_budget_medium it_budget_per_emp_medium it_budget_sum it_budget_per_emp_sum it_budget_sum_per_site it_budget_per_emp_sum_per_site "
foreach i of local it {
xtile `i'_quantile = `i', nq(4)
g q4_high_`i' = ( `i'_quantile  == 4)
g q2_high_`i' = ( `i'_quantile >2)
}

* Merge two frames - using  tempfile 

frame put count q* , into(new_indicator)
frame change default
frlink m:1 county, frame(new_indicator)
tempfile hold /*It is necessary to use tempfile*/
frame change new_indicator
frame new_indicator: save `hold', replace
frame change default
drop _merge
merge m:1 county using `hold'


frame change ciall
frame put county *median, into(median_var)
frame change default
frlink m:1 county, frame(median_var)
tempfile hold
frame change median_var
frame median_var:save `hold', replace
frame change default
merge m:1 county using `hold'








