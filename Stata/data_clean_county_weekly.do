
**# Import data & panel set 

use "C:\Users\Leting\Documents\Covid-Cyber-Unemploy\Stata\county_week_panel.dta" 
g stayweek = statepolicy_week
replace stayweek = countypolicy_week if countypolicy_week< statepolicy_week
g tre = (week>stayweek)
order stayweek tre, a(countyfips)
sort countyfips week
order week, a(countyfips)
drop if week ==.
xtset countyfips week
xtsum


**# generate event indicator
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



**# Quantile

xtile it_budget_win_percap_quantile = it_budget_win_percap, nq(4)
xtile its_emp_per_cap_quantile = its_emps_all_per_cap, nq(4)
g q4_high_its_pop = ( its_emp_per_cap_quantile == 4 )
g q4_high_it_budget_pop = ( it_budget_win_percap_quantile == 4 )
g q2_high_its_pop = ( its_emp_per_cap_quantile > 2 )
g q2_high_it_budget_pop = ( it_budget_win_percap_quantile > 2 )



areg initclaims_rate_regular tre tre##q4_high_its_pop avg_new_death_rate avg_new_case_rate avg_home_prop i.week, absorb(countyfips) rob
areg initclaims_rate_regular tre tre##q2_high_its_pop avg_new_death_rate avg_new_case_rate avg_home_prop i.week, absorb(countyfips) rob




areg initclaims_rate_regular tre tre##c.its_emps_all_per_cap  avg_new_death_rate avg_new_case_rate avg_home_prop i.week, absorb(countyfips) rob
areg emp_combined tre tre##c.its_emps_all_per_cap  avg_new_death_rate avg_new_case_rate avg_home_prop i.week, absorb(countyfips) rob





