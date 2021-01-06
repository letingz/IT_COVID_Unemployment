***********************
** Title: Covid & Employment & IT investment Output
** Date: 20210102
** Author: Leting Zhang
**
************************


cd "C:\Users\Leting\Documents\Covid-Cyber-Unemploy\stata"
local starlevel "* 0.10 ** 0.05 *** 0.01"
local starnote "*** p<0.01, ** p<0.05, * p<0.1"
use "C:\Users\Leting\Documents\Covid-Cyber-Unemploy\stata\county_panel.dta" 

***********************
* Descriptive Analysis
***********************



local desvar avg_initclaims_count avg_initclaims_rate emp_combined emp_combined_inclow emp_combined_incmiddle emp_combined_inchigh afterstayhome ln_it_budget ln_security_sw_pres gps_away_from_home avg_new_death_rate avg_new_case_rate
asdoc sum `desvar'  , stat(mean sd min max) label dec(2) abb(.) save(results.rtf)




***********************
* Regression
***********************


**** Only incorporates time-variant controls:
*** The level of mobilities - gps_away_from_home is positively associated with employment level.	
	

	local depvar  "avg_initclaims_count avg_initclaims_rate  emp_combined emp_combined_inclow emp_combined_incmiddle emp_combined_inchigh"
	foreach i of local depvar {
	eststo: areg `i' afterstayhom gps_away_from_home avg_new_death_rate avg_new_case_rate  i.month,  absorb(county) rob
	estadd local tfixed "YES"
	estadd local hfixed "YES"
	}


#delimit ;

esttab _all using "results2.rtf" , keep( gps_away_from_home avg_new_death_rate avg_new_case_rate ) 
	title(Only Time-variant Controls)
	mti("Unemployment (Count)" "Unemployment (Rate)" "Employment (Combined)" "Employment (Low Income)" "Employment (Middle Income)" "Employment (High Income)")
	label stat( r2 N df_a tfixed hfixed,
		fmt( %9.3f %9.0g %9.0g)labels( R-squared Observations "No. Counties" "Year FE" "County FE"))
	b(3) nogap onecell 
	nonotes addnote("Notes: Robust standard errors are in parentheses" "`starnote'")
	starlevels( `starlevel') se append;
	
#delimit cr;
	
est clear

	

*** 2. Incorporates IT budget interaction term:
*** The level of IT budget marginally increase the overall unemployment rate and lower the employment level only for middle income workers. 

	foreach i of local depvar {
	eststo: areg `i' afterstayhome afterhome_ln_it_budget gps_away_from_home avg_new_death_rate avg_new_case_rate  i.month,  absorb(county) rob
	estadd local tfixed "YES"
	estadd local hfixed "YES"
	}
	
	
#delimit ;

esttab _all using "results2.rtf" , keep(afterstayhome afterhome_ln_it_budget gps_away_from_home avg_new_death_rate avg_new_case_rate ) 
	title(IT budget interaction term)
	mti("Unemployment (Count)" "Unemployment (Rate)" "Employment (Combined)" "Employment (Low Income)" "Employment (Middle Income)" "Employment (High Income)")
	label stat( r2 N df_a tfixed hfixed,
		fmt( %9.3f %9.0g %9.0g)labels( R-squared Observations "No. Counties" "Year FE" "County FE"))
	b(3) nogap onecell 
	nonotes addnote("Notes: Robust standard errors are in parentheses" "`starnote'")
	starlevels( `starlevel') se append;
	
#delimit cr;

est clear
	

*** 3. Incorporates security software presence interaction term:
*** The level of security software presense significantly lower the employment levels for all workers.

	foreach i of local depvar {
	eststo: areg `i' afterstayhome afterhome_ln_security_sw_pres gps_away_from_home avg_new_death_rate avg_new_case_rate  i.month,  absorb(county) rob
	estadd local tfixed "YES"
	estadd local hfixed "YES"
	}
	
	
#delimit ;

esttab _all using "results2.rtf" , keep(afterstayhome afterhome_ln_security_sw_pres gps_away_from_home avg_new_death_rate avg_new_case_rate ) 
	title(Security software presence interaction term)
	mti("Unemployment (Count)" "Unemployment (Rate)" "Employment (Combined)" "Employment (Low Income)" "Employment (Middle Income)" "Employment (High Income)")
	label stat( r2 N df_a tfixed hfixed,
		fmt( %9.3f %9.0g %9.0g)labels( R-squared Observations "No. Counties" "Year FE" "County FE"))
	b(3) nogap onecell 
	nonotes addnote("Notes: Robust standard errors are in parentheses" "`starnote'")
	starlevels( `starlevel') se append;

#delimit cr;

est clear




*** 4. Incorporates both two interaction terms discussed above.	
*** Overall speaking, while IT budget increases employment rate, security software presence lower employment rate. 
	foreach i of local depvar {
	eststo: areg `i'  afterstayhome afterhome_ln_it_budget  afterhome_ln_security_sw_pres gps_away_from_home avg_new_death_rate avg_new_case_rate  i.month,  absorb(county) rob
	estadd local tfixed "YES"
	estadd local hfixed "YES"
	}

#delimit ;

esttab  _all using "results2.rtf" , keep(afterstayhome afterhome_ln_it_budget  afterhome_ln_security_sw_pres gps_away_from_home avg_new_death_rate avg_new_case_rate ) 
	title(Two interaction terms)
	mti("Unemployment (Count)" "Unemployment (Rate)" "Employment (Combined)" "Employment (Low Income)" "Employment (Middle Income)" "Employment (High Income)")
	label stat( r2 N df_a tfixed hfixed,
		fmt( %9.3f %9.0g %9.0g)labels( R-squared Observations "No. Counties" "Year FE" "County FE"))
	b(3) nogap onecell 
	nonotes addnote("Notes: Robust standard errors are in parentheses" "`starnote'")
	starlevels( `starlevel') se append;
	
#delimit cr;
	
	est clear
	
*** 5. Incoporates three-way interactions: 
*** IT budget and security software presence are complementary in increasing employment (all, low come, and income)
	foreach i of local depvar {
	eststo: areg `i'  afterstayhome after_itbudget_secupre afterhome_ln_it_budget  afterhome_ln_security_sw_pres gps_away_from_home avg_new_death_rate avg_new_case_rate  i.month,  absorb(county) rob
	estadd local tfixed "YES"
	estadd local hfixed "YES"
	}
	

	#delimit ;

esttab using "results2.rtf" , keep(afterstayhome after_itbudget_secupre afterhome_ln_it_budget  afterhome_ln_security_sw_pres  gps_away_from_home avg_new_death_rate avg_new_case_rate ) 
	title(Three-way interactions)
	mti("Unemployment (Count)" "Unemployment (Rate)" "Employment (Combined)" "Employment (Low Income)" "Employment (Middle Income)" "Employment (High Income)")
	label stat( r2 N df_a tfixed hfixed,
		fmt( %9.3f %9.0g %9.0g)labels( R-squared Observations "No. Counties" "Year FE" "County FE"))
	b(3) nogap onecell 
	nonotes addnote("Notes: Robust standard errors are in parentheses" "`starnote'")
	starlevels( `starlevel') se append;
	
#delimit cr;
