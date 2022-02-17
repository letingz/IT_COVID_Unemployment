
***********************
** Title: Covid & Employment & IT investment Output & Weekly
** Stage: S1- Data cleaning & Experiment 
** Date: 202112
** Author: Leting Zhang
**
************************


**# Import data & panel set 

use "C:\Users\Leting\Documents\2.Covid_IT_Employment\Stata\county_week_panel_dec.dta" 

*frame drop matching
compress

g stayweek = statepolicy_week
replace stayweek = countypolicy_week if countypolicy_week< statepolicy_week
g tre = (week>stayweek)
order stayweek tre, a(countyfips)
sort countyfips week
duplicates drop
order week, a(countyfips)
drop if week ==.
xtset countyfips week
*encode state, g(state_code)
rename countyfips county
rename *, lower


**# Generate variables

* Quantile - Treatment

local itquan it_median it_per_median its_emps_all its_empstotal_all
foreach i of local itquan {
xtile `i'_qtl = `i', nq(4)
g q4_high_`i' = (`i'_qtl == 4)
g q2_high_`i' = (`i'_qtl > 2)
}


* Event indicator
g event = week - stayweek + 1
forv tau = 5(-1)1 {
g treatb`tau' = event == -`tau'
la var treatb`tau' "T - `tau'"
}
forv tau = 0/5 {
g treata`tau' = event == `tau'
la var treata`tau' "T + `tau'"
}

g treata6forward = (event>5)
g treatb6backward = (event<-5)

label variable treata0 "T=0"
label variable treata6forward "T + 6 Forward"
label variable treatb6backward "T - 6 Backward"

order treatb6backward , b( treatb5 )

g treated = tre*q4_high_it_median

* Month 
recode week (2/5 = 1) (6/9 = 2) (10/14 = 3) (15/18 = 4) (19/22 = 5) (23/26 = 6) (27/30 = 7) (31/35 = 8) (36/40 = 9) (41/44 = 10) (45/49 = 11) (50/53 = 12), g(month)
order month, a(week)


* Log
local logvar it_median com_emps_all its_emps_all 

g ln_com_emp = log( com_emps_all  + 1)
g ln_its_emps = log( its_emps_all  + 1)
g ln_it_median = log(it_median + 1)
g ln_pop = log(population+1)
g ln_income = log(medianhouseholdincome+1)



* Merge business interdependence data
drop _merge
merge m:1 county using "C:\Users\Leting\Documents\2.Covid_IT_Employment\Stata\county_business_interdependence.dta"
* Merge occupation data
drop _merge
merge m:1 county using "C:\Users\Leting\Documents\2.Covid_IT_Employment\Stata\oews_use.dta"
codebook tot_emp_manag_occ loc_quotient_manag_occ jobs_1000_manag_occ
drop tot_emp_manag_occ-loc_quotient_trans_oc
rename jobs_1000* job*


**# Matching variables

frame copy default matching
frame change matching
frame pwf


local usevar "it_median q4_high_it_median  population medianhouseholdincome internetper totalhousehold emple_median reven_median agriculture construction manufacturing wholesale retail transportation information insurance"
 
 
local matchvar "population medianhouseholdincome internetper totalhousehold emple_median reven_median agriculture construction manufacturing wholesale retail transportation information insurance"
 
* Keep the key indicators and matched variables
keep county  `usevar'
duplicates drop
drop if q4_high_it_median == .


cem population(#10) medianhouseholdincome(#10) internetper(#5) totalhousehold(#5) emple_median(#5) reven_median(#5) agriculture(#3) construction(#3) manufacturing(#3) wholesale(#3) retail(#3) transportation(#3) information(#3) insurance(#3) ,tre( q4_high_it_median )
g cem_strata_strict = cem_strata
g cem_weight_strict = cem_weights

cem population(#5) medianhouseholdincome(#5) internetper(#5) totalhousehold(#5) emple_median(#5) reven_median(#5) agriculture(#3) construction(#3) manufacturing(#3) wholesale(#3) retail(#3) transportation(#3) information(#3) insurance(#3) ,tre( q4_high_it_median )
g cem_strata_relax = cem_strata
g cem_weight_relax = cem_weights



cem population medianhouseholdincome internetper totalhousehold emple_median information ,tre( q4_high_it_median )
g cem_strata_auto = cem_strata
g cem_weight_auto = cem_weights


frame change default
frlink m:1 county, frame(matching) generate(link)

frget cem_strata_strict  = cem_strata_strict, from(link)
frget cem_weight_strict  = cem_weight_strict, from(link)

frget cem_strata_relax  =  cem_strata_relax, from(link)
frget cem_weight_relax  = cem_weight_relax, from(link)

frget cem_strata_auto =  cem_strata_auto, from(link)
frget cem_weight_auto  = cem_weight_auto, from(link)



**# Label 


labvars initclaims_rate_regular  avg_new_death_rate avg_new_case_rate avg_home_prop "Unemployment Rate"  "COVID Death Rate" "COVID New Case Rate" "Stay at Home Index"



labvars tre q4_high_it_median q4_high_its_emps_all ln_it_median ln_its_emps  "After Stay at Home" "HighBAIT" "HighBAIT (IT Service Employees)" "BAIT" "BAIT (IT Service Employees)"

labvars teleworkable_emp ln_com_emp  "Telework index" "IT Equipment Employees" 

labvars internetper ln_income bachelorhigherper   "Internet Coverage" "Household Income" "Education Level (Bachelor Degree)"


labvars app_median-network_median "App Dev" "Enterprise App " "Cloud Solution" "Groupware and PC" "Digital Marketing/Commerce" "Security" "Network"

labvars app_per_median-network_per_median "App Dev" "Enterprise App " "Cloud Solution" "Groupware and PC" "Digital Marketing/Commerce" "Security" "Network"


labvars agriculture construction manufacturing wholesale retail transportation information insurance "Agriculture Employees" "Construction Employees" "Manufacturing Employees" "Wholesalfe Employees" "Retail Employees" "Trans Employees" "Services Employees" "Insurance Employees"
 


  
labvars jobs_1000_manag_occ jobs_1000_bus_fin_oc jobs_1000_com_math_oc jobs_1000_arch_engin_oc jobs_1000_life_phy_oc  "Management" "Business and Financial Operations" "Computer and Mathematical" "Architecture and Engineering" "Life, Physical, and Social Science"
		
labvars jobs_1000_com_socser_oc jobs_1000_legal_oc jobs_1000_edu_lib_oc jobs_1000_art_sport_oc jobs_1000_health_oc  "Community and Social Service" "Legal" "Educational Instruction and Library" "Arts, Design, Entertainment, Sports, and Media" "Healthcare Practitioners"

labvars jobs_1000_health_sup_oc jobs_1000_protect_oc jobs_1000_food_ser_oc jobs_1000_buil_clean_oc jobs_1000_percare_ser_oc  "Healthcare Support" "Protective Service" "Food Preparation and Serving Related" "Building and Grounds Cleaning and Maintenance" "Personal Care and Service"
		
labvars jobs_1000_sale_oc jobs_1000_off_admin_oc jobs_1000_farm_fish_oc jobs_1000_construct_oc jobs_1000_inst_mainte_oc  "Sales and Related" "Office and Administrative Support" "Farming, Fishing, and Forestry" "Construction and Extraction" "Installation, Maintenance, and Repair"

labvars jobs_1000_prodct_oc jobs_1000_trans_oc "Production" "Transportation and Material Moving"
