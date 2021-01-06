
***********************
** Title: Covid & Employment & IT investment Output
** Date: 20210105
** Author: Leting Zhang
**
************************


cd "C:\Users\Leting\Documents\Covid-Cyber-Unemploy\stata"
local starlevel "* 0.10 ** 0.05 *** 0.01"
local starnote "*** p<0.01, ** p<0.05, * p<0.1"
*use "C:\Users\Leting\Documents\Covid-Cyber-Unemploy\stata\county_panel.dta" 

***********************
* Descriptive Analysis
***********************



local depvar  "emp_combined emp_combined_inclow emp_combined_incmiddle emp_combined_inchigh avg_initclaims_count avg_initclaims_rate "


foreach i of local depvar {	
	
	eststo: areg `i' aftersh aftersh_ln_security_sw_pres i.month,  absorb(county) rob
	estadd local tfixed "YES"
	estadd local hfixed "YES"
	
	eststo: areg `i' aftersh aftersh_ln_security_sw_pres gps_away_from_home i.month,  absorb(county) rob
	estadd local tfixed "YES"
	estadd local hfixed "YES"
	
	eststo: areg `i' aftersh aftersh_ln_security_sw_pres gps_away_from_home avg_new_death_rate avg_new_case_rate  i.month,  absorb(county) rob
	estadd local tfixed "YES"
	estadd local hfixed "YES"
	
	eststo: areg `i' aftersh aftersh_ln_security_sw_pres aftersh_ln_emple aftersh_ln_reven gps_away_from_home avg_new_death_rate avg_new_case_rate i.month,  absorb(county) rob
	estadd local tfixed "YES"
	estadd local hfixed "YES"
	
	eststo: areg `i' aftersh aftersh_ln_it_budget aftersh_ln_emple aftersh_ln_reven gps_away_from_home avg_new_death_rate avg_new_case_rate  i.month,  absorb(county) rob
	estadd local tfixed "YES"
	estadd local hfixed "YES"
	
	eststo: areg `i' aftersh aftersh_ln_security_sw_pres aftersh_ln_it_budget aftersh_ln_s_budget aftersh_ln_emple aftersh_ln_reven aftersh_ln_vpn_pres aftersh_ln_dbms_pres aftersh_ln_dw_sw_pres aftersh_ln_sic1 aftersh_ln_sic2 aftersh_ln_sic3 gps_away_from_home  avg_new_death_rate avg_new_case_rate i.month,  absorb(county) rob
	estadd local tfixed "YES"
	estadd local hfixed "YES"
	

	eststo: areg `i' aftersh after_security_pres_it_budget aftersh_ln_security_sw_pres aftersh_ln_it_budget  aftersh_ln_s_budget  aftersh_ln_emple aftersh_ln_reven aftersh_ln_vpn_pres aftersh_ln_dbms_pres aftersh_ln_dw_sw_pres aftersh_ln_sic1 aftersh_ln_sic2 aftersh_ln_sic3   gps_away_from_home avg_new_death_rate avg_new_case_rate i.month,  absorb(county) rob
	estadd local tfixed "YES"
	estadd local hfixed "YES"
	
	
	
	#delimit ;

esttab _all using "demo_new.rtf" , drop( *.month ) 
	title()
	label stat( r2 N df_a tfixed hfixed,
		fmt( %9.3f %9.0g %9.0g)labels( R-squared Observations "No. Counties" "Year FE" "County FE"))
	b(3) nogap onecell 
	nonotes addnote("Notes: Robust standard errors are in parentheses" "`starnote'")
	starlevels( `starlevel') se append;
	
#delimit cr;
	
est clear
	
	}
	
	
