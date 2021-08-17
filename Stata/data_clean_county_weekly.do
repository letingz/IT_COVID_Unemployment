
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
*xtsum

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

**# Generate variables

* Event indicator
g event = week - stayweek 
forv tau = 5(-1)1 {
g treatb`tau' = event == -`tau'
la var treatb`tau' "This obs is `tau' years before the treatment"
}
table event
forv tau = 0/5 {
g treata`tau' = event == `tau'
la var treata`tau' "This obs is `tau' years after the treatment"
}


* Month 
recode week (2/5 = 1) (6/9 = 2) (10/14 = 3) (15/18 = 4) (19/22 = 5) (23/26 = 6) (27/30 = 7) (31/35 = 8) (36/40 = 9) (41/44 = 10) (45/49 = 11) (50/53 = 12), g(month)
order month, a(week)


* Quantile

local itquan it_budget_median it_budget_per_emp_median pcs_median pc_per_emp_median its_emps_all its_empstotal_all com_emps_all
foreach i of local itquan {
xtile `i'_qtl = `i', nq(4)
g q4_high_`i' = (`i'_qtl == 4)
g q2_high_`i' = (`i'_qtl > 2)
}


* Log
g ln_com_emp = log( com_emps_all  + 1)
g ln_its_emps = log( its_emps_all  + 1)




save "C:\Users\Leting\Documents\Covid-Cyber-Unemploy\Stata\county_week_panel_july_analysis.dta"


----------------------------------
areg initclaims_rate_regular tre tre##q4_high_its_emp_percap avg_new_death_rate avg_new_case_rate avg_home_prop i.week, absorb(county) rob

areg initclaims_rate_regular tre tre##q2_high_its_emp_percap|q4_high_it_budget_medium|q4_high_it_budget_per_emp_mean|tre#q2_high_it_budget_mean avg_new_death_rate avg_new_case_rate avg_home_prop i.week, absorb(county) rob

areg initclaims_count_regular tre tre##q4_high_its_percap tre##c.population avg_new_death_rate avg_new_case_rate avg_home_prop i.week, absorb(county) rob

areg initclaims_count_regular tre tre##q2_high_it_budget_medium tre##c.population avg_new_death_rate avg_new_case_rate avg_home_prop i.week, absorb(county) rob



areg emp_combined tre tre##q4_high_it_budget_percap avg_new_death_rate avg_new_case_rate avg_home_prop i.week, absorb(county) rob

areg emp_combined tre tre##q4_high_it_budget_mean  avg_new_death_rate avg_new_case_rate avg_home_prop i.week, absorb(county) rob


local it " q4_high_it_budget_mean q2_high_it_budget_mean q4_high_it_budget_per_emp_mean q2_high_it_budget_per_emp_mean q4_high_it_budget_medium q2_high_it_budget_medium "
foreach i of local it {
areg initclaims_rate_regular tre tre##`i' avg_new_death_rate avg_new_case_rate avg_home_prop i.week, absorb(county) rob
}



local var "q4_high_it_budget_pop q2_high_it_budget_pop q4_high_it_budget_percap q2_high_it_budget_percap q4_high_it_budget_mean q2_high_it_budget_mean q4_high_it_budget_per_emp_mean q2_high_it_budget_per_emp_mean q4_high_it_budget_median q2_high_it_budget_median q4_high_its_emps q2_high_its_emps q4_high_its_emp_percap q4_high_its_emptotal_percap q4_high_it_budget_wpop q2_high_it_budget_wpop q4_high_its_empstotal q2_high_its_empstotal"

foreach i of local var {
    
	areg emp_combined_inclow tre tre##`i' `con' i.week, absorb(county) rob
}

**# Label 


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

 labvars initclaims_count_regular initclaims_rate_regular emp_combined avg_new_death_rate avg_new_case_rate avg_home_prop "Unemployment Count" "Unemployment Rate" "Employment Level"  "COVID Death Rate" "COVID New Case Rate" "Stay at Home Index"


label variable number_per_emp_Enterprise_median "Enterprise apps"
label variable number_per_emp_Dev_mdedian "Dev apps"
label variable number_per_emp_Cloud_median "Cloud apps"
label variable number_per_emp_Database_median "Database apps"
label variable number_per_emp_WFH_median "WFH apps"
label variable number_per_emp_Marketing_median "Marketing apps"
label variable number_per_emp_Security_median "Security apps"
label variable number_per_emp_Network_median "Networks"
label variable number_per_emp_Network_median "Networks apps"
 
* Adjecent county 

use "C:\Users\Leting\Documents\Covid-Cyber-Unemploy\Stata\adjacent_county_info.dta" 
joinby county using "C:\Users\Leting\Documents\Covid-Cyber-Unemploy\Stata\county_weekly_ui.dta", unmatched(none)

 
** Table 1: Main analyses

** Continuous


areg initclaims_rate_regular tre tre##c.its_emps_all_per_cap  avg_new_death_rate avg_new_case_rate avg_home_prop i.week, absorb(county) rob
areg emp_combined tre tre##c.its_emps_all_per_cap  avg_new_death_rate avg_new_case_rate avg_home_prop i.week, absorb(county) rob
areg initclaims_count_regular tre tre##c.its_emps_all_per_cap  tre##c.population  avg_new_death_rate avg_new_case_rate avg_home_prop i.week, absorb(county) rob


areg initclaims_rate_regular tre tre##c.its_emps_all_per_cap  avg_new_death_rate avg_new_case_rate avg_home_prop i.week, absorb(county) rob
areg emp_combined tre tre##c.its_emps_all_per_cap  avg_new_death_rate avg_new_case_rate avg_home_prop i.week, absorb(county) rob


* Binary

areg initclaims_count_regular tre tre##c.q2_high_its_pop  tre##c.population  avg_new_death_rate avg_new_case_rate avg_home_prop i.week, absorb(county) rob
areg emp_combined_incmiddle tre tre##c.q2_high_it_budget_pop avg_new_death_rate avg_new_case_rate gps_away_from_home i.week, absorb(county) rob
areg emp_combined_inclow tre tre##c.q2_high_it_budget_pop avg_new_death_rate avg_new_case_rate gps_away_from_home i.week, absorb(county) rob /*?Problematic*/





** Outernal

** Table 2: 


areg initclaims_rate_regular tre tre##c.its_emps_all_per_cap  avg_new_death_rate avg_new_case_rate avg_home_prop i.week, absorb(county) rob
areg emp_combined tre tre##c.its_emps_all_per_cap  avg_new_death_rate avg_new_case_rate avg_home_prop i.week, absorb(county) rob

** Event study

q4_high_it_budget_medium 
q2_high_it_budget_medium



**#Experiment 

* Unemployment rate VS ITS emp : only q4_high_it_budget_wpop q2_high_it_budget_wpop does not work
local it " q4_high_its_emps q2_high_its_emps q4_high_its_emp_percap q4_high_its_emptotal_percap q4_high_it_budget_wpop q2_high_it_budget_wpop q4_high_its_empstotal q2_high_its_empstotal "
foreach i of local it {
qui areg initclaims_rate_regular tre tre##`i' avg_new_death_rate avg_new_case_rate avg_home_prop i.week, absorb(county) rob
est table, keep(tre tre##`i') b se
} 

* Unemployment rate VS IT budget
* Work: q2_high_it_budget_mean q2_high_it_budget_medium q2_high_it_budget_per_emp_mean q4_high_it_budget_mean q4_high_it_budget_medium q4_high_it_budget_per_emp_mean 

local it " q2_high_it_budget_mean q2_high_it_budget_medium q2_high_it_budget_per_emp_mean q2_high_it_budget_percap q2_high_it_budget_pop q2_high_it_budget_wpop q4_high_it_budget_mean q4_high_it_budget_medium q4_high_it_budget_per_emp_mean q4_high_it_budget_percap q4_high_it_budget_pop q4_high_it_budget_wpop "
foreach i of local it {
qui areg initclaims_rate_regular tre tre##`i' avg_new_death_rate avg_new_case_rate avg_home_prop i.week, absorb(county) rob
est table, keep(tre tre##`i') b se
}


*Employment rate vs ITS : only  q4_high_it_budget_wpop q2_high_it_budget_wpop works = = ....
local it " q4_high_its_emps q2_high_its_emps q4_high_its_emp_percap q4_high_its_emptotal_percap q4_high_it_budget_wpop q2_high_it_budget_wpop q4_high_its_empstotal q2_high_its_empstotal "
foreach i of local it {
qui areg emp_combined tre tre##`i' avg_new_death_rate avg_new_case_rate avg_home_prop i.week, absorb(county) rob
est table, keep(tre tre##`i') b se
}

* Employment rate VS IT budget
* Work:  q2_high_it_budget_percap q2_high_it_budget_pop  q2_high_it_budget_wpop q4_high_it_budget_percap q4_high_it_budget_pop q4_high_it_budget_wpop
local it " q2_high_it_budget_mean q2_high_it_budget_medium q2_high_it_budget_per_emp_mean q2_high_it_budget_percap q2_high_it_budget_pop q2_high_it_budget_wpop q4_high_it_budget_mean q4_high_it_budget_medium q4_high_it_budget_per_emp_mean q4_high_it_budget_percap q4_high_it_budget_pop q4_high_it_budget_wpop "
foreach i of local it {
qui areg initclaims_rate_regular tre tre##`i' avg_new_death_rate avg_new_case_rate avg_home_prop i.week, absorb(county) rob
est table, keep(tre tre##`i') b se
}

* Reg save WIDE
tempfile results_tbl
local num = 1
local replace replace
local con "avg_new_death_rate avg_new_case_rate avg_home_prop"
local it "q4_high_it_budget_pop q2_high_it_budget_pop q4_high_it_budget_percap q2_high_it_budget_percap q4_high_it_budget_mean q2_high_it_budget_mean q4_high_it_budget_per_emp_mean q2_high_it_budget_per_emp_mean q4_high_it_budget_medium q2_high_it_budget_medium q4_high_its_emps q2_high_its_emps q4_high_its_emp_percap q4_high_its_emptotal_percap q4_high_it_budget_wpop q2_high_it_budget_wpop q4_high_its_empstotal q2_high_its_empstotal q2_high_its_emptotal_percap q2_high_its_emp_percap"
local dv "initclaims_rate_regular emp_combined initclaims_count_regular"
foreach i of local it  {
    foreach d of local dv {
	    areg `d'  tre tre##`i' `con', absorb(county) rob
		regsave using "`results_tbl'", pval autoid `replace' addlabel(it,"`i'",dv,"`d'") table(col_`num', asterisk(5 1) parentheses(stderr))
		local replace append
		local num = `num'+1
		}
}

use "`results_tbl'", clear
list





*Reg save long

tempfile results_tbl
local replace replace
local con "avg_new_death_rate avg_new_case_rate avg_home_prop"
local it "q4_high_it_budget_pop q2_high_it_budget_pop q4_high_it_budget_percap q2_high_it_budget_percap q4_high_it_budget_mean q2_high_it_budget_mean q4_high_it_budget_per_emp_mean q2_high_it_budget_per_emp_mean q4_high_it_budget_medium q2_high_it_budget_medium q4_high_its_emps q2_high_its_emps q4_high_its_emp_percap q4_high_its_emptotal_percap q4_high_it_budget_wpop q2_high_it_budget_wpop q4_high_its_empstotal q2_high_its_empstotal q2_high_its_emptotal_percap q2_high_its_emp_percap"
local dv "initclaims_rate_regular emp_combined initclaims_count_regular"

foreach i of local it  {
    foreach d of local dv {
	    areg `d'  tre tre##`i' `con', absorb(county) rob
		regsave using "`results_tbl'", pval autoid `replace' addlabel(it,"`i'",dv,"`d'") table(col_`num', asterisk(5 1) parentheses(stderr))
		local replace append
		local num = `num'+1
		}
}


tempfile results
local replace replace
local con "avg_new_death_rate avg_new_case_rate avg_home_prop"
local it "q4_high_it_budget_pop q2_high_it_budget_pop q4_high_it_budget_percap q2_high_it_budget_percap q4_high_it_budget_mean q2_high_it_budget_mean q4_high_it_budget_per_emp_mean q2_high_it_budget_per_emp_mean q4_high_it_budget_medium q2_high_it_budget_medium q4_high_its_emps q2_high_its_emps q4_high_its_emp_percap q4_high_its_emptotal_percap q4_high_it_budget_wpop q2_high_it_budget_wpop q4_high_its_empstotal q2_high_its_empstotal q2_high_its_emptotal_percap q2_high_its_emp_percap"
local dv "initclaims_rate_regular emp_combined initclaims_count_regular"


foreach i of local it  {
    foreach d of local dv {
		areg `d'  tre tre##`i' `con', absorb(county) rob
		regsave tre  using "`results'", pval autoid `replace' addlabel(treat,"`i'",outcome,"`d'") 
		local replace append
	}
}

use "`results'", clear
list


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








