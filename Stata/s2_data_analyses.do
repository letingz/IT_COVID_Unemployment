
***********************
** Title: Covid & Employment & IT investment Output & Weekly
** Stage: S2- Analyses
** Date: 2021005
** Author: Leting Zhang
**
************************


local starlevel "* 0.10 ** 0.05 *** 0.01"
local starnote "*** p<0.01, ** p<0.05, * p<0.1"
local filename "result/report_08.rtf"
local con "avg_new_death_rate avg_new_case_rate avg_home_prop"
local it_group appdev_median-infra_median 

global output 1







** TODO. 1. use education level as one moderator


**#Correlation Matrx

estpost correlate initclaims_rate_regular tre q4_high_it_budget_median q4_high_its_emps_all ln_it_budget_median  ln_its_emps  `con', matrix listwise
est store c1
esttab * using .\result\correlation.rtf, unstack not nostar noobs compress label replace
esttab * using .\result\correlation_with_significance_level.rtf, unstack not noobs compress label replace

**#  IT Budget
est clear

eststo:areg initclaims_rate_regular tre tre##q4_high_it_budget_median  `con' i.week, absorb(county) rob
estadd local tfixed "YES"
estadd local hfixed "YES"

eststo:areg initclaims_rate_regular tre tre##c.ln_it_budget_median `con' i.week, absorb(county) rob
estadd local tfixed "YES"
estadd local hfixed "YES"

// eststo:areg initclaims_count_regular tre tre##q4_high_it_budget_median tre##c.ln_pop `con' i.week, absorb(county) rob
// estadd local tfixed "YES"
// estadd local hfixed "YES"
//
// eststo:areg initclaims_count_regular tre tre##c.ln_it_budget_median tre##c.ln_pop `con' i.week, absorb(county) rob
// estadd local tfixed "YES"
// estadd local hfixed "YES"

#delimit ;

esttab  _all using "`filename'", replace keep(tre 1.tre#*1.q4_high_it_budget_median 1.tre#c.ln_it_budget_median  1.tre#c.ln_pop  `con')
		order(tre 1.tre#*1.q4_high_it_budget_median 1.tre#c.ln_it_budget_median  1.tre#c.ln_pop  `con')
		title(1. )
		label stat( r2 N df_a tfixed hfixed,
		fmt( %9.3f %9.0g %9.0g) labels( R-squared Observations "No. Counties" "Week FE" "County FE"))
		 b(3) nogap onecell 
		nonotes addnote("Notes: Robust standard errors are in parentheses" "`starnote'")
		starlevels( `starlevel') se ;
	
#delimit cr;
est clear


**# Event study (graph)

est clear
eststo:areg initclaims_rate_regular treatb5- treata5 (treatb5- treata5)##q4_high_it_budget_median   i.week, absorb(county) rob
estadd local tfixed "YES"
estadd local hfixed "YES"
estadd local con "NO" 

eststo:areg initclaims_rate_regular treatb5- treata5 (treatb5- treata5)##q4_high_it_budget_median `con' i.week, absorb(county) rob
estadd local tfixed "YES"
estadd local hfixed "YES"
estadd local con "YES" 
 
 
 #delimit ;

esttab  _all using "`filename'", a keep(treat* 1.treat*#1.q4_high_it_budget_median `con')
		title(2. )
		label stat( r2 N df_a tfixed hfixed,
		fmt( %9.3f %9.0g %9.0g) labels( R-squared Observations "No. Counties" "Week FE" "County FE"))
		 b(3) nogap onecell 
		nonotes addnote("Notes: Robust standard errors are in parentheses" "`starnote'")
		starlevels( `starlevel') se ;
	
#delimit cr;
 est clear
 
 /* coefplot, keep(1.treat*) vertical recast(connected) title("The Impact of High IT Intensity on the Unemployment Rate", size(median))  xlabel(, labsize(tiny))  coeflabels( 1.treatb5#1.q4_high_it_budget_median= "T-5" 1.treatb4#1.q4_high_it_budget_median= "T-4"  1.treatb3#1.q4_high_it_budget_median= "T-3" 1.treatb2#1.q4_high_it_budget_median= "T-2" 1.treatb1#1.q4_high_it_budget_median= "T-1" 1.treata0#1.q4_high_it_budget_median= "T=0" 1.treata1#1.q4_high_it_budget_median= "T+1" 1.treata2#1.q4_high_it_budget_median= "T+2" 1.treata3#1.q4_high_it_budget_median= "T+3" 1.treata4#1.q4_high_it_budget_median= "T+4" 1.treata5#1.q4_high_it_budget_median= "T+5" ) nolabel yline(0, lpattern(dash)) xline(6, lpattern(dash)) xlabel(, labsize(small)) text(1 -0.5 "hahah", fcolor(red)) */

 
**# County- IT service employees 
local filename "report_0510.rtf"
est clear


eststo: areg initclaims_rate_regular tre tre##q4_high_its_emps_all  `con' i.week, absorb(county) rob
estadd local tfixed "YES"
estadd local hfixed "YES"

eststo: areg initclaims_rate_regular tre tre##c.ln_its_emps  `con' i.week, absorb(county) rob
estadd local tfixed "YES"
estadd local hfixed "YES"
	
#delimit ;

esttab  _all using "`filename'", a keep(tre 1.tre#*1.q4_high_its_emps_all 1.tre#*c.ln_its_emps 1.tre#c.ln_pop `con'  )
		title(3. )
		order(tre 1.tre#*1.q4_high_its_emps_all 1.tre#*c.ln_its_emps 1.tre#c.ln_pop `con' )
		label stat( r2 N df_a tfixed hfixed,
		fmt( %9.3f %9.0g %9.0g) labels( R-squared Observations "No. Counties" "Week FE" "County FE"))
		 b(3) nogap onecell 
		nonotes addnote("Notes: Robust standard errors are in parentheses" "`starnote'")
		starlevels( `starlevel') se ;
	
#delimit cr;

est clear



// areg initclaims_rate_regular tre tre##q4_high_it_budget_median  tre tre##q4_high_its_emps_all `con' i.week, absorb(county) rob
// test 1.tre#1.q4_high_it_budget_median 1.tre#1.q4_high_its_emps_all
//
// areg initclaims_rate_regular tre tre##c.ln_it_budget_median tre##c.ln_its_emps  `con' i.week, absorb(county) rob
// test  1.tre#c.ln_it_budget_median  1.tre#c.ln_its_emps




**# Heterogneity 1: demographics
 
local starlevel "* 0.10 ** 0.05 *** 0.01"
local starnote "*** p<0.01, ** p<0.05, * p<0.1"
*local filename "report_06new.rtf"
local con "avg_new_death_rate avg_new_case_rate avg_home_prop"

 
 est clear
 
eststo:areg initclaims_rate_regular tre tre##q4_high_it_budget_median##c.internetper `con' i.week, absorb(county) rob
estadd local tfixed "YES"
estadd local hfixed "YES"

 
eststo:areg initclaims_rate_regular tre tre##q4_high_its_emps_all##c.internetper `con' i.week, absorb(county) rob
estadd local tfixed "YES"
estadd local hfixed "YES"

eststo:areg initclaims_rate_regular tre tre##q4_high_it_budget_median##c.ln_income `con' i.week, absorb(county) rob
estadd local tfixed "YES"
estadd local hfixed "YES"

eststo:areg initclaims_rate_regular tre tre##q4_high_its_emps_all##c.ln_income `con' i.week, absorb(county) rob
estadd local tfixed "YES"
estadd local hfixed "YES"


#delimit ;

esttab  _all using "`filename'", a keep(tre 1.tre#*1.q4_high_it_budget_median#c.internetper 1.tre#1.q4_high_its_emps_all#c.internetper
							1.tre#*1.q4_high_it_budget_median#c.ln_income 1.tre#*1.q4_high_its_emps_all#c.ln_income
										 1.tre#1.q4_high_it_budget_median 1.tre#*1.q4_high_its_emps_all
										1.tre#c.ln_income 1.tre#c.internetper  `con' )
		title(6. )
		order(tre 1.tre#*1.q4_high_it_budget_median#c.internetper 1.tre#1.q4_high_its_emps_all#c.internetper
							1.tre#*1.q4_high_it_budget_median#c.ln_income 1.tre#*1.q4_high_its_emps_all#c.ln_income
										 1.tre#1.q4_high_it_budget_median 1.tre#*1.q4_high_its_emps_all
										 1.tre#c.internetper  1.tre#c.ln_income  `con')		
		label stat( r2 N df_a tfixed hfixed,
		fmt( %9.3f %9.0g %9.0g) labels( R-squared Observations "No. Counties" "Week FE" "County FE"))
		 b(3) nogap onecell 
		nonotes addnote("Notes: Robust standard errors are in parentheses" "`starnote'")
		starlevels( `starlevel') se ;
	
#delimit cr;

est clear

**# Heterogneity 2: IT app groups

 
local starlevel "* 0.10 ** 0.05 *** 0.01"
local starnote "*** p<0.01, ** p<0.05, * p<0.1"
local filename "report_aaaa.rtf"
local con "avg_new_death_rate avg_new_case_rate avg_home_prop"
local it_group "appdev_emp_median enterp_peremp_median cloud_peremp_median productivity_peremp_median marketing_peremp_median collab_peremp_median security_peremp_median infra_peremp_median"
*local it_group "appdev_median enterp_median cloud_median productivity_median marketing_median collab_median security_median infra_median"
 


 
foreach m of local it_group{

	*areg initclaims_rate_regular tre tre## q4_high_it_budget_median##c.`m' `con' i.week, absorb(county) rob
	eststo: areg initclaims_rate_regular tre tre##q4_high_it_budget_median##c.`m' `con' i.week, absorb(county) rob
	estadd local tfixed "YES"
	estadd local hfixed "YES"
	}
	
	
#delimit ;

esttab  _all using "`filename'", a keep(tre //1.tre#*1.q4_high_it_budget_median#c.appdev_emp_median
										    1.tre#*1.q4_high_it_budget_median#c.enterp_peremp_median
											1.tre#*1.q4_high_it_budget_median#c.cloud_peremp_median

											1.tre#*1.q4_high_it_budget_median#c.productivity_peremp_median
											1.tre#*1.q4_high_it_budget_median#c.marketing_peremp_median
											1.tre#*1.q4_high_it_budget_median#c.collab_peremp_median
											
											1.tre#*1.q4_high_it_budget_median#c.security_peremp_median
											1.tre#*1.q4_high_it_budget_median#c.infra_peremp_median
											
											
											
											1.tre#c.appdev_peremp_median
											1.tre#c.enterp_peremp_median
											1.tre#c.cloud_peremp_median
											
											1.tre#c.productivity_peremp_median
											1.tre#c.marketing_peremp_median													
											1.tre#c.collab_peremp_median
											
											1.tre#c.security_peremp_median
											1.tre#c.infra_median
								
											
											
										    1.tre#1.q4_high_it_budget_median 
											
										       `con' )
		title(6. )
			order(tre  						//1.tre#*1.q4_high_it_budget_median#c.appdev_emp_median
										    1.tre#*1.q4_high_it_budget_median#c.enterp_peremp_median
											1.tre#*1.q4_high_it_budget_median#c.cloud_peremp_median

											1.tre#*1.q4_high_it_budget_median#c.productivity_peremp_median
											1.tre#*1.q4_high_it_budget_median#c.marketing_peremp_median
											1.tre#*1.q4_high_it_budget_median#c.collab_peremp_median
											
											1.tre#*1.q4_high_it_budget_median#c.security_peremp_median
											1.tre#*1.q4_high_it_budget_median#c.infra_peremp_median
											
											
											
											1.tre#c.appdev_peremp_median
											1.tre#c.enterp_peremp_median
											1.tre#c.cloud_peremp_median
											
											1.tre#c.productivity_peremp_median
											1.tre#c.marketing_peremp_median													
											1.tre#c.collab_peremp_median
											
											1.tre#c.security_peremp_median
											1.tre#c.infra_median
								
											
											
										    1.tre#1.q4_high_it_budget_median 
											
										       `con'	)		
		label stat( r2 N df_a tfixed hfixed,
		fmt( %9.3f %9.0g %9.0g) labels( R-squared Observations "No. Counties" "Week FE" "County FE"))
		 b(3) nogap onecell 
		nonotes addnote("Notes: Robust standard errors are in parentheses" "`starnote'")
		starlevels( `starlevel') se ;
	
#delimit cr;

est clear
 





if $output == 0 {

**# Heterogneity test 3 industry 


computerper agriculture construction manufacturing wholesale retail transportation information insurance


* Hard to explain
  
local starlevel "* 0.10 ** 0.05 *** 0.01"
local starnote "*** p<0.01, ** p<0.05, * p<0.1"
local filename "report_0510.rtf"
local con "avg_new_death_rate avg_new_case_rate avg_home_prop"
local industry "AG_M_C EDUC F_I_RE GOVT MANUF MED SVCS TR_UTL WHL_RT"
 
foreach m of local industry{
	
	areg initclaims_rate_regular tre tre## q4_high_it_budget_median##c.`m' `con' i.week, absorb(county) rob

	}

	
	
	
		
**# Synthetic Control 
	
* Select sample (has to be strongly balanced in terms of panel setting, dv, and predictor)	

frame copy default synth
frame change synth
* keep county week month state tre initclaims_rate_regular avg_new_death_rate avg_new_case_rate avg_home_prop pattern synth population_per_cap internetper medianhouseholdincome

keep county week month state tre treated initclaims_rate_regular avg_new_death_rate avg_new_case_rate avg_home_prop

* Construct a strongly balanced sample
drop if initclaims_rate_regular == .
xtpatternvar, gen(pattern)
drop if week>44
bys county: g N = _N
table N
drop if N<43
xtset
	

synth_runner initclaims_rate_regular avg_home_prop(10(1)13)  initclaims_rate_regular(10(1)13) , d(treated)

*flacturate p value
synth_runner initclaims_rate_regular avg_home_prop  initclaims_rate_regular(9(1)12) , d(treated) 

synth_runner initclaims_rate_regular avg_home_prop , d(treated)
effect_graphs
pval_graphs
	
	
synth_runner initclaims_rate_regular avg_home_prop(9(1)13)  initclaims_rate_regular(9(1)13) , d(treated)
effect_graphs
pval_graphs


**# GMM Dynamic
 **** NOT USE IT....Static or dynamic model, you can only choose one of them.
 **** (Actually No ... YOU CAN USE BOTH MODELS - BY USING DIFFERENT ASSUMPTIONS)
 
 
xtabond2 initclaims_rate_regular L.initclaims_rate_regular tre tre##q4_high_it_budget_median  `con' i.week, gmm(initclaims_rate_regular,  lag(5 6) collapse eq(d)) gmm(`con', lag(2 4) collapse eq(d)) iv( tre tre##q4_high_it_budget_median i.week, eq(d)) rob two


xtabond2 initclaims_rate_regular L.initclaims_rate_regular tre tre##q4_high_it_budget_median  `con' i.week, gmm(initclaims_rate_regular,  lag(5 6) collapse eq(d)) gmm(`con', lag(2 4) collapse eq(d)) iv( tre tre##q4_high_it_budget_media  i.week) rob two

 	
}



/*
**# Robustness Checks Telework & Com  (robustness)

local con "avg_new_death_rate avg_new_case_rate avg_home_prop"
est clear
 
eststo:areg initclaims_rate_regular tre tre##q4_high_it_budget_median tre##c.teleworkable_emp `con' i.week, absorb(county) rob
estadd local tfixed "YES"
estadd local hfixed "YES"

eststo:areg initclaims_rate_regular tre tre##q4_high_its_emps_all tre##c.teleworkable_emp `con' i.week, absorb(county) rob
estadd local tfixed "YES"
estadd local hfixed "YES"

 
eststo:areg initclaims_rate_regular tre tre##c.ln_its_emps tre##c.ln_com_emps  `con' i.week, absorb(county) rob
estadd local tfixed "YES"
estadd local hfixed "YES" 
 

#delimit ;

esttab  _all using ""`filename'"", a keep(tre 1.tre#* )
		title(7. )
		label stat( r2 N df_a tfixed hfixed,
		fmt( %9.3f %9.0g %9.0g) labels( R-squared Observations "No. Counties" "Week FE" "County FE"))
		 b(3) nogap onecell 
		nonotes addnote("Notes: Robust standard errors are in parentheses" "`starnote'")
		starlevels( `starlevel') se ;
	
#delimit cr;

est clear
*/


// eststo: areg initclaims_rate_regular tre tre##c.ln_its_emps  `con' i.week, absorb(county) rob
// estadd local tfixed "YES"
// estadd local hfixed "YES"
//
// eststo: areg initclaims_count_regular tre  tre##c.ln_its_emps tre##c.ln_pop `con' i.week, absorb(county) rob
// estadd local tfixed "YES"
// estadd local hfixed "YES"
//
// #delimit ;
//
// esttab  _all using "`filename'", a keep(tre 1.tre#*c.ln_its_emps  1.tre#c.ln_pop `con' )
// 		title(4. )
// 		order(tre 1.tre#*c.ln_its_emps  1.tre#c.ln_pop `con')
// 		label stat( r2 N df_a tfixed hfixed,
// 		fmt( %9.3f %9.0g %9.0g) labels( R-squared Observations "No. Counties" "Week FE" "County FE"))
// 		 b(3) nogap onecell 
// 		nonotes addnote("Notes: Robust standard errors are in parentheses" "`starnote'")
// 		starlevels( `starlevel') se ;
//	
// #delimit cr;
//
// est clear


 * Adjacent county
// 
// est clear
// 
// eststo:areg adj_sum_iniclaims_count tre tre##q4_high_its_emps `con' i.week, absorb(county) rob
// estadd local tfixed "YES"
// estadd local hfixed "YES"
//
// eststo:areg adj_sum_iniclaims_count tre tre##c.ln_its_emps `con' i.week, absorb(county) rob
// estadd local tfixed "YES"
// estadd local hfixed "YES"
//
// eststo:areg adj_sum_iniclaims_count tre tre##q4_high_it_budget_median `con' i.week, absorb(county) rob
// estadd local tfixed "YES"
// estadd local hfixed "YES"
//
// #delimit ;
//
// esttab  _all using "`filename'", a keep(tre 1.tre#1.q4_high_its_emps 1.tre#c.ln_its_emps 1.tre#1.q4_high_it_budget_median  )
// 		title(5. )
// 		order(tre 1.tre#1.q4_high_its_emps 1.tre#c.ln_its_emps 1.tre#1.q4_high_it_budget_median  )
// 		label stat( r2 N df_a tfixed hfixed,
// 		fmt( %9.3f %9.0g %9.0g) labels( R-squared Observations "No. Counties" "Week FE" "County FE"))
// 		 b(3) nogap onecell 
// 		nonotes addnote("Notes: Robust standard errors are in parentheses" "`starnote'")
// 		starlevels( `starlevel') se ;
//	
// #delimit cr;
// est clear


*IT moderating effect - The main analyses IT use per employees, the below analyses is use total employee
//
// 


// 
//  **# IT budget & IT service employees 
//
// local starlevel "* 0.10 ** 0.05 *** 0.01"
// local starnote "*** p<0.01, ** p<0.05, * p<0.1"
// local filename "result/report_07.rtf"
// local con "avg_new_death_rate avg_new_case_rate avg_home_prop"
// local it_group "number_per_emp_Dev_median number_per_emp_WFH_median number_per_emp_Network_median number_per_emp_Enterprise_median number_per_emp_Database_median number_per_emp_Security_median  number_per_emp_Cloud_median number_per_emp_Marketing_median  "
//
// eststo: areg initclaims_rate_regular tre tre##q4_high_it_budget_median tre##q4_high_its_emps_all `con' i.week, absorb(county) rob
// estadd local tfixed "YES"
// estadd local hfixed "YES"
//
//
// eststo: areg initclaims_rate_regular tre tre##c.ln_it_budget_median tre##c.ln_its_emps  `con' i.week, absorb(county) rob
// estadd local tfixed "YES"
// estadd local hfixed "YES"
//
// eststo: areg initclaims_rate_regular tre tre##q4_high_it_budget_median##q4_high_its_emps_all `con' i.week, absorb(county) rob
// estadd local tfixed "YES"
// estadd local hfixed "YES"
//
// eststo: areg initclaims_rate_regular tre tre##c.ln_it_budget_median##c.ln_its_emps  `con' i.week, absorb(county) rob
// estadd local tfixed "YES"
// estadd local hfixed "YES"
//
//
// #delimit ;
//
// esttab  _all using "`filename'", a keep(tre 1.tre#*1.q4_high_it_budget_median 1.tre#c.ln_it_budget_median 1.tre#*1.q4_high_its_emps_all 1.tre#*c.ln_its_emps
//              1.tre#1.q4_high_it_budget_median#*1.q4_high_its_emps_all   1.tre#c.ln_it_budget_median#c.ln_its_emps `con'  )
// 		title(3. )
// 		order( tre 1.tre#*1.q4_high_it_budget_median 1.tre#*1.q4_high_its_emps_all 1.tre#c.ln_it_budget_median  1.tre#*c.ln_its_emps
//              1.tre#1.q4_high_it_budget_median#*1.q4_high_its_emps_all   1.tre#c.ln_it_budget_median#c.ln_its_emps `con'  )
// 		label stat( r2 N df_a tfixed hfixed,
// 		fmt( %9.3f %9.0g %9.0g) labels( R-squared Observations "No. Counties" "Week FE" "County FE"))
// 		 b(3) nogap onecell 
// 		nonotes addnote("Notes: Robust standard errors are in parentheses" "`starnote'")
// 		starlevels( `starlevel') se ;
//	
// #delimit cr;
// est clear
//
// 
