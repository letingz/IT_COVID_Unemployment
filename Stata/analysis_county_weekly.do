
***********************
** Title: Covid & Employment & IT investment Output & Weekly
** Stage: S2- Analyses
** Date: 2021005
** Author: Leting Zhang
**
************************


local starlevel "* 0.10 ** 0.05 *** 0.01"
local starnote "*** p<0.01, ** p<0.05, * p<0.1"
local filename "result/report_07.rtf"
local con "avg_new_death_rate avg_new_case_rate avg_home_prop"
local it_group "number_per_emp_Dev_median number_per_emp_Enterprise_median number_per_emp_Cloud_median number_per_emp_Database_median number_per_emp_WFH_median number_per_emp_Marketing_median number_per_emp_Security_median number_per_emp_Network_median"

** TODO. 1. use education level as one moderator
** TODO. Other moderaors

areg initclaims_rate_regular tre tre##q4_high_it_budget_median##c.emple_median `con' i.week, absorb(county) rob



**#Correlation Matrx

estpost correlate initclaims_rate_regular tre q4_high_it_budget_median q4_high_its_emps ln_it_budget_median  ln_its_emps  `con', matrix listwise
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

eststo:areg initclaims_count_regular tre tre##q4_high_it_budget_median tre##c.ln_pop `con' i.week, absorb(county) rob
estadd local tfixed "YES"
estadd local hfixed "YES"

eststo:areg initclaims_count_regular tre tre##c.ln_it_budget_median tre##c.ln_pop `con' i.week, absorb(county) rob
estadd local tfixed "YES"
estadd local hfixed "YES"

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


eststo: areg initclaims_rate_regular tre tre##q4_high_its_emps  `con' i.week, absorb(county) rob
estadd local tfixed "YES"
estadd local hfixed "YES"

eststo: areg initclaims_rate_regular tre tre##c.ln_its_emps  `con' i.week, absorb(county) rob
estadd local tfixed "YES"
estadd local hfixed "YES"

eststo: areg initclaims_count_regular tre tre##q4_high_its_emps tre##c.ln_pop `con' i.week, absorb(county) rob
estadd local tfixed "YES"
estadd local hfixed "YES"

eststo: areg initclaims_count_regular tre  tre##c.ln_its_emps tre##c.ln_pop `con' i.week, absorb(county) rob
estadd local tfixed "YES"
estadd local hfixed "YES"
	
	
#delimit ;

esttab  _all using "`filename'", a keep(tre 1.tre#*1.q4_high_its_emps 1.tre#*c.ln_its_emps 1.tre#c.ln_pop `con'  )
		title(3. )
		order(tre 1.tre#*1.q4_high_its_emps 1.tre#*c.ln_its_emps 1.tre#c.ln_pop `con' )
		label stat( r2 N df_a tfixed hfixed,
		fmt( %9.3f %9.0g %9.0g) labels( R-squared Observations "No. Counties" "Week FE" "County FE"))
		 b(3) nogap onecell 
		nonotes addnote("Notes: Robust standard errors are in parentheses" "`starnote'")
		starlevels( `starlevel') se ;
	
#delimit cr;

est clear

**# IT budget & IT service employees 

local starlevel "* 0.10 ** 0.05 *** 0.01"
local starnote "*** p<0.01, ** p<0.05, * p<0.1"
local filename "result/report_07.rtf"
local con "avg_new_death_rate avg_new_case_rate avg_home_prop"
local it_group "number_per_emp_Dev_median number_per_emp_WFH_median number_per_emp_Network_median number_per_emp_Enterprise_median number_per_emp_Database_median number_per_emp_Security_median  number_per_emp_Cloud_median number_per_emp_Marketing_median  "

eststo: areg initclaims_rate_regular tre tre##q4_high_it_budget_median  tre tre##q4_high_its_emps `con' i.week, absorb(county) rob
estadd local tfixed "YES"
estadd local hfixed "YES"


eststo: areg initclaims_rate_regular tre tre##c.ln_it_budget_median tre##c.ln_its_emps  `con' i.week, absorb(county) rob
estadd local tfixed "YES"
estadd local hfixed "YES"

eststo: areg initclaims_rate_regular tre tre##q4_high_it_budget_median##q4_high_its_emps `con' i.week, absorb(county) rob
estadd local tfixed "YES"
estadd local hfixed "YES"

eststo: areg initclaims_rate_regular tre tre##c.ln_it_budget_median##c.ln_its_emps  `con' i.week, absorb(county) rob
estadd local tfixed "YES"
estadd local hfixed "YES"


#delimit ;

esttab  _all using "`filename'", a keep(tre 1.tre#*1.q4_high_it_budget_median 1.tre#c.ln_it_budget_median 1.tre#*1.q4_high_its_emps 1.tre#*c.ln_its_emps
             1.tre#1.q4_high_it_budget_median#*1.q4_high_its_emps   1.tre#c.ln_it_budget_median#c.ln_its_emps `con'  )
		title(3. )
		order( tre 1.tre#*1.q4_high_it_budget_median 1.tre#*1.q4_high_its_emps 1.tre#c.ln_it_budget_median  1.tre#*c.ln_its_emps
             1.tre#1.q4_high_it_budget_median#*1.q4_high_its_emps   1.tre#c.ln_it_budget_median#c.ln_its_emps `con'  )
		label stat( r2 N df_a tfixed hfixed,
		fmt( %9.3f %9.0g %9.0g) labels( R-squared Observations "No. Counties" "Week FE" "County FE"))
		 b(3) nogap onecell 
		nonotes addnote("Notes: Robust standard errors are in parentheses" "`starnote'")
		starlevels( `starlevel') se ;
	
#delimit cr;
est clear


areg initclaims_rate_regular tre tre##q4_high_it_budget_median  tre tre##q4_high_its_emps `con' i.week, absorb(county) rob
test 1.tre#1.q4_high_it_budget_median 1.tre#1.q4_high_its_emps

areg initclaims_rate_regular tre tre##c.ln_it_budget_median tre##c.ln_its_emps  `con' i.week, absorb(county) rob
test  1.tre#c.ln_it_budget_median  1.tre#c.ln_its_emps




**# Heterogneity 1: demographics
 
 local starlevel "* 0.10 ** 0.05 *** 0.01"
local starnote "*** p<0.01, ** p<0.05, * p<0.1"
local filename "report_06.rtf"
local con "avg_new_death_rate avg_new_case_rate avg_home_prop"
local it_group "number_per_emp_Dev_median number_per_emp_WFH_median number_per_emp_Network_median number_per_emp_Enterprise_median number_per_emp_Database_median number_per_emp_Security_median  number_per_emp_Cloud_median number_per_emp_Marketing_median  "
 
 est clear
 
eststo:areg initclaims_rate_regular tre tre##q4_high_it_budget_median##c.internetper `con' i.week, absorb(county) rob
estadd local tfixed "YES"
estadd local hfixed "YES"

 
eststo:areg initclaims_rate_regular tre tre##q4_high_its_emps##c.internetper `con' i.week, absorb(county) rob
estadd local tfixed "YES"
estadd local hfixed "YES"

eststo:areg initclaims_rate_regular tre tre##q4_high_it_budget_median##c.ln_income `con' i.week, absorb(county) rob
estadd local tfixed "YES"
estadd local hfixed "YES"

eststo:areg initclaims_rate_regular tre tre##q4_high_its_emps##c.ln_income `con' i.week, absorb(county) rob
estadd local tfixed "YES"
estadd local hfixed "YES"


#delimit ;

esttab  _all using "`filename'", a keep(tre 1.tre#*1.q4_high_it_budget_median#c.internetper 1.tre#1.q4_high_its_emps#c.internetper
							1.tre#*1.q4_high_it_budget_median#c.ln_income 1.tre#*1.q4_high_its_emps#c.ln_income
										 1.tre#1.q4_high_it_budget_median 1.tre#*1.q4_high_its_emps
										1.tre#c.ln_income 1.tre#c.internetper  `con' )
		title(6. )
		order(tre 1.tre#*1.q4_high_it_budget_median#c.internetper 1.tre#1.q4_high_its_emps#c.internetper
							1.tre#*1.q4_high_it_budget_median#c.ln_income 1.tre#*1.q4_high_its_emps#c.ln_income
										 1.tre#1.q4_high_it_budget_median 1.tre#*1.q4_high_its_emps
										 1.tre#c.internetper  1.tre#c.ln_income  `con')		
		label stat( r2 N df_a tfixed hfixed,
		fmt( %9.3f %9.0g %9.0g) labels( R-squared Observations "No. Counties" "Week FE" "County FE"))
		 b(3) nogap onecell 
		nonotes addnote("Notes: Robust standard errors are in parentheses" "`starnote'")
		starlevels( `starlevel') se ;
	
#delimit cr;

est clear

**# Heterogneity 2: IT app groups

* Form 1: 8 columns 

local starlevel "* 0.10 ** 0.05 *** 0.01"
local starnote "*** p<0.01, ** p<0.05, * p<0.1"
local filename "report_0510.rtf"
local con "avg_new_death_rate avg_new_case_rate avg_home_prop"
local it_group "number_per_emp_Dev_median number_per_emp_WFH_median number_per_emp_Network_median number_per_emp_Enterprise_median number_per_emp_Database_median number_per_emp_Security_median  number_per_emp_Cloud_median number_per_emp_Marketing_median  "

*************TODO CHANGE median -> MEDIAN
 
foreach m of local  it_group {

	*areg initclaims_rate_regular tre tre## q4_high_it_budget_median##c.`m' `con' i.week, absorb(county) rob
	eststo: areg initclaims_rate_regular tre tre## q4_high_it_budget_median##c.`m' `con' i.week, absorb(county) rob
	estadd local tfixed "YES"
	estadd local hfixed "YES"
	}
	
	
#delimit ;

esttab  _all using "`filename'", a keep(tre 1.tre#*1.q4_high_it_budget_median#c.number_per_emp_Dev_median
										    1.tre#*1.q4_high_it_budget_median#c.number_per_emp_WFH_median
											1.tre#*1.q4_high_it_budget_median#c.number_per_emp_Network_median

											1.tre#*1.q4_high_it_budget_median#c.number_per_emp_Enterprise_median
											1.tre#*1.q4_high_it_budget_median#c.number_per_emp_Database_median
											1.tre#*1.q4_high_it_budget_median#c.number_per_emp_Security_median
											
											1.tre#*1.q4_high_it_budget_median#c.number_per_emp_Cloud_median
											1.tre#*1.q4_high_it_budget_median#c.number_per_emp_Marketing_median
											
											
											
											1.tre#c.number_per_emp_Dev_median
											1.tre#c.number_per_emp_WFH_median
											1.tre#c.number_per_emp_Network_median
											
											1.tre#c.number_per_emp_Enterprise_median
											1.tre#c.number_per_emp_Database_median													
											1.tre#c.number_per_emp_Security_median
											
											1.tre#c.number_per_emp_Cloud_median
											1.tre#c.number_per_emp_Marketing_median
								
											
											
										    1.tre#1.q4_high_it_budget_median 
											
										       `con' )
		title(6. )
			order(tre 1.tre#*1.q4_high_it_budget_median#c.number_per_emp_Dev_median
										    1.tre#*1.q4_high_it_budget_median#c.number_per_emp_WFH_median
											1.tre#*1.q4_high_it_budget_median#c.number_per_emp_Network_median

											1.tre#*1.q4_high_it_budget_median#c.number_per_emp_Enterprise_median
											1.tre#*1.q4_high_it_budget_median#c.number_per_emp_Database_median
											1.tre#*1.q4_high_it_budget_median#c.number_per_emp_Security_median
											
											1.tre#*1.q4_high_it_budget_median#c.number_per_emp_Cloud_median
											1.tre#*1.q4_high_it_budget_median#c.number_per_emp_Marketing_median
						
												
											1.tre#c.number_per_emp_Dev_median
											1.tre#c.number_per_emp_WFH_median
											1.tre#c.number_per_emp_Network_median
											
											1.tre#c.number_per_emp_Enterprise_median
											1.tre#c.number_per_emp_Database_median													
											1.tre#c.number_per_emp_Security_median
											
											1.tre#c.number_per_emp_Cloud_median
											1.tre#c.number_per_emp_Marketing_median			
											
										    1.tre#1.q4_high_it_budget_median 
											
										     `con' 	)		
		label stat( r2 N df_a tfixed hfixed,
		fmt( %9.3f %9.0g %9.0g) labels( R-squared Observations "No. Counties" "Week FE" "County FE"))
		 b(3) nogap onecell 
		nonotes addnote("Notes: Robust standard errors are in parentheses" "`starnote'")
		starlevels( `starlevel') se ;
	
#delimit cr;

est clear


* Form 2: 3 + 5 columns	
 
 
 
local starlevel "* 0.10 ** 0.05 *** 0.01"
local starnote "*** p<0.01, ** p<0.05, * p<0.1"
local filename "report_0510.rtf"
local con "avg_new_death_rate avg_new_case_rate avg_home_prop"
local it_group_1 "number_per_emp_Dev_median number_per_emp_WFH_median number_per_emp_Network_median "
local it_group_2 " number_per_emp_Enterprise_median number_per_emp_Database_median number_per_emp_Security_median  number_per_emp_Cloud_median number_per_emp_Marketing_median "

*************TODO CHANGE median -> MEDIAN
 
foreach m of local  it_group_1 {

	*areg initclaims_rate_regular tre tre## q4_high_it_budget_median##c.`m' `con' i.week, absorb(county) rob
	eststo: areg initclaims_rate_regular tre tre## q4_high_it_budget_median##c.`m' `con' i.week, absorb(county) rob
	estadd local tfixed "YES"
	estadd local hfixed "YES"
	}
	
	
#delimit ;

esttab  _all using "`filename'", a keep(tre 1.tre#1.q4_high_it_budget_median 

											1.tre#*1.q4_high_it_budget_median#c.number_per_emp_Dev_median
											1.tre#c.number_per_emp_Dev_median
											
										    1.tre#*1.q4_high_it_budget_median#c.number_per_emp_WFH_median
											1.tre#c.number_per_emp_WFH_median
											
											1.tre#*1.q4_high_it_budget_median#c.number_per_emp_Network_median
											1.tre#c.number_per_emp_Network_median										
										       `con' )
							title(6. )
							order(tre 1.tre#1.q4_high_it_budget_median 

											1.tre#*1.q4_high_it_budget_median#c.number_per_emp_Dev_median
											1.tre#c.number_per_emp_Dev_median
											
										    1.tre#*1.q4_high_it_budget_median#c.number_per_emp_WFH_median
											1.tre#c.number_per_emp_WFH_median
											
											1.tre#*1.q4_high_it_budget_median#c.number_per_emp_Network_median
											1.tre#c.number_per_emp_Network_median										
										       `con' 	)		
		label stat( r2 N df_a tfixed hfixed,
		fmt( %9.3f %9.0g %9.0g) labels( R-squared Observations "No. Counties" "Week FE" "County FE"))
		 b(3) nogap onecell 
		nonotes addnote("Notes: Robust standard errors are in parentheses" "`starnote'")
		starlevels( `starlevel') se ;
	
#delimit cr;

est clear


foreach m of local  it_group_2 {
	
	eststo: areg initclaims_rate_regular tre tre## q4_high_it_budget_median##c.`m' `con' i.week, absorb(county) rob
	estadd local tfixed "YES"
	estadd local hfixed "YES"
	}
	
#delimit ;	
	
esttab  _all using "`filename'", a keep(tre 1.tre#*1.q4_high_it_budget_median 

											1.tre#*1.q4_high_it_budget_median#c.number_per_emp_Enterprise_median
											1.tre#c.number_per_emp_Enterprise_median
											
											1.tre#*1.q4_high_it_budget_median#c.number_per_emp_Database_median
											1.tre#c.number_per_emp_Database_median	
													
											1.tre#*1.q4_high_it_budget_median#c.number_per_emp_Security_median
											1.tre#c.number_per_emp_Security_median
											
											1.tre#*1.q4_high_it_budget_median#c.number_per_emp_Cloud_median
											1.tre#c.number_per_emp_Cloud_median
											
											1.tre#*1.q4_high_it_budget_median#c.number_per_emp_Marketing_median					
											1.tre#c.number_per_emp_Marketing_median											
										       `con' )
		title(6. )
								order(tre 1.tre#*1.q4_high_it_budget_median 

											1.tre#*1.q4_high_it_budget_median#c.number_per_emp_Enterprise_median
											1.tre#c.number_per_emp_Enterprise_median
											
											1.tre#*1.q4_high_it_budget_median#c.number_per_emp_Database_median
											1.tre#c.number_per_emp_Database_median	
													
											1.tre#*1.q4_high_it_budget_median#c.number_per_emp_Security_median
											1.tre#c.number_per_emp_Security_median
											
											1.tre#*1.q4_high_it_budget_median#c.number_per_emp_Cloud_median
											1.tre#c.number_per_emp_Cloud_median
											
											1.tre#*1.q4_high_it_budget_median#c.number_per_emp_Marketing_median					
											1.tre#c.number_per_emp_Marketing_median											
										       `con' 	)		
		label stat( r2 N df_a tfixed hfixed,
		fmt( %9.3f %9.0g %9.0g) labels( R-squared Observations "No. Counties" "Week FE" "County FE"))
		 b(3) nogap onecell 
		nonotes addnote("Notes: Robust standard errors are in parentheses" "`starnote'")
		starlevels( `starlevel') se ;
	
#delimit cr;

est clear	
	
	

 * Alternative model
 **** NOT USE IT....Static or dynamic model, you can only choose one of them.
xtabond2 initclaims_rate_regular L.initclaims_rate_regular tre tre##q4_high_it_budget_median  `con' i.week, gmm(initclaims_rate_regular,  lag(5 6) collapse eq(d)) gmm(`con', lag(2 3) collapse eq(d)) iv( tre tre##q4_high_it_budget_median i.week, eq(d)) rob two

 
 * Telework & Com  (robustness)
 local con "avg_new_death_rate avg_new_case_rate avg_home_prop"
 
est clear
 
eststo:areg initclaims_rate_regular tre tre##q4_high_it_budget_median tre##c.teleworkable_emp `con' i.week, absorb(county) rob
estadd local tfixed "YES"
estadd local hfixed "YES"

eststo:areg initclaims_rate_regular tre tre##q4_high_its_emps tre##c.teleworkable_emp `con' i.week, absorb(county) rob
estadd local tfixed "YES"
estadd local hfixed "YES"

 
eststo:areg initclaims_rate_regular tre tre##c.ln_its_emps tre##c.ln_com_emps  `con' i.week, absorb(county) rob
estadd local tfixed "YES"
estadd local hfixed "YES" 
 

#delimit ;

esttab  _all using "a.rtf", a keep(tre 1.tre#* )
		title(7. )
		label stat( r2 N df_a tfixed hfixed,
		fmt( %9.3f %9.0g %9.0g) labels( R-squared Observations "No. Counties" "Week FE" "County FE"))
		 b(3) nogap onecell 
		nonotes addnote("Notes: Robust standard errors are in parentheses" "`starnote'")
		starlevels( `starlevel') se ;
	
#delimit cr;

est clear


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


