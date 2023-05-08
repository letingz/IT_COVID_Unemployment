
***********************
** Title: Covid & Employment & IT investment Output & Weekly
** Stage: S2- Analyses
** Date: 202205
** Author: Leting Zhang
**
************************

**# One key run some script? 


local filename "result/report_0206journalinter.rtf"

local starlevel "* 0.10 ** 0.05 *** 0.01"
local starnote "*** p<0.01, ** p<0.05, * p<0.1"
local con "avg_new_death_rate avg_new_case_rate avg_home_prop"
local it_tre q4_high_it_median
local fe county week
local vce rob
local clusternote "Notes: Robust standard errors are reported in parentheses." 
*local countynum N_clust
local df "e(df_a_initial)"

local it_group "app_per_median enterp_per_median cloud_per_median groupware_per_median security_per_median network_per_median"
local industry_group "agriculture construction manufacturing wholesale retail transportation information insurance"
local occupation_group "lowskilloc midskilloc highskilloc"

global newITgroup 1  /* 0 = old IT groups; 1 = new IT groups*/
global graph 0 /* 0 = No graphs; 1 = Export graphs*/
global additional 0  /* 0 = no additional analyses; 1 = have additional analyses (e.g., synthetic control)*/
global onlyhetero 1
// eststo: reghdfe initclaims_rate_regular tre tre##`it_tre'##c.inter_index `con' , absorb(`fe') vce(`vce')
//
// #delimit ;
//
//
//
//
//
// esttab  _all using "`filename'", replace keep(tre 1.tre#1.`it_tre'#c.inter_index 1.tre#1.`it_tre' 1.tre#c.inter_index  `con')
// 		order(tre 1.tre#1.`it_tre'#c.inter_index 1.tre#1.`it_tre' 1.tre#c.inter_index  `con')
// 		interaction("*")
// 		title({\b Table 2. Main Effect})
// 		mtitles("Fixed effects" "Fixed effects and control" "Continuous treatment")
// 		label stat( r2 N countynum thfixed,
// 		fmt( %9.3f %9.0g %9.0g ) labels( R-squared Observations "No. Counties" "County & Week FE"))
// 		 b(3) nogap onecell 
// 		nonotes addnote("`clusternote'" "`starnote'")
// 		nobaselevels 
// 		starlevels( `starlevel') se ;
//	
// #delimit cr;
// est clear
//


*local it_group appdev_median-infra_median 



*local clevel county
*local vce cluster `clevel'

*local clusternote "Notes: Robust standard errors are clustered at the `clevel' level in parentheses." 


**# Description analyses

asdoc sum initclaims_rate_regular tre q4_high_it_median ln_it_median `it_group' `industry_group' `occupation_group'  `con' teleworkable_emp ln_com_emp, stat(mean sd min max) label dec(2) tzok save(result/desc.doc)

**# Correlation Matrx

* estpost correlate initclaims_rate_regular tre q4_high_it_median ln_it_median `it_group'  `con' teleworkable_emp ln_com_emp, matrix listwise
* est store c1
*esttab * using .\result\correlation.rtf, unstack not nostar noobs compress label replace
*esttab * using .\result\correlation_with_significance_level.rtf, unstack not noobs compress label replace

**# BAIT

if $onlyhetero == 0 {

est clear

eststo:reghdfe initclaims_rate_regular tre tre##`it_tre' , absorb(`fe') vce(`vce')
estadd local thfixed "YES"
local nogroup = e(dof_table)[1,1]
estadd local countynum `nogroup'

eststo:reghdfe initclaims_rate_regular tre tre##`it_tre' `con' , absorb(`fe') vce(`vce')
estadd local thfixed "YES"
local nogroup = e(dof_table)[1,1]
estadd local countynum `nogroup'

eststo:reghdfe initclaims_rate_regular tre tre##c.ln_it_median `con', absorb(`fe') vce(`vce')
estadd local thfixed "YES"
local nogroup = e(dof_table)[1,1]
estadd local countynum `nogroup'

#delimit ;



esttab  _all using "`filename'", replace keep(tre 1.tre#1.`it_tre' 1.tre#c.ln_it_median  `con')
		order(tre 1.tre#1.`it_tre' 1.tre#c.ln_it_median   `con')
		interaction("*")
		title({\b Table 2. Main Effect})
		mtitles("Fixed effects" "Fixed effects and control" "Continuous treatment")
		label stat( r2 N countynum thfixed,
		fmt( %9.3f %9.0g %9.0g ) labels( R-squared Observations "No. Counties" "County & Week FE"))
		 b(3) nogap onecell 
		nonotes addnote("`clusternote'" "`starnote'")
		nobaselevels 
		starlevels( `starlevel') se ;
	
#delimit cr;
est clear

**#  Relative Time Model - Event study (graph)


// local starlevel "* 0.10 ** 0.05 *** 0.01"
// local starnote "*** p<0.01, ** p<0.05, * p<0.1"
// local filename "result/relative.rtf"
// local con "avg_new_death_rate avg_new_case_rate avg_home_prop"
// local it_group appdev_median-infra_median 
//
// global output 1 /*no syntehtic control or other analyses*/
// global newITgroup 0  /* 0 = old IT groups; 1 = new IT groups*/
//


est clear


eststo:reghdfe initclaims_rate_regular treatb6backward treatb5-treatb1 treata1-treata5 treata6forward (treatb6backward treatb5-treatb1 treata1-treata5 treata6forward )##`it_tre' , absorb(`fe') vce(`vce')
estadd local thfixed "YES"
local nogroup = e(dof_table)[1,1]
estadd local countynum `nogroup'
estadd local con "NO"

eststo:reghdfe initclaims_rate_regular treatb6backward treatb5-treatb1 treata1-treata5 treata6forward (treatb6backward treatb5-treatb1 treata1-treata5 treata6forward )##`it_tre' `con', absorb(`fe') vce(`vce')
estadd local thfixed "YES"
local nogroup = e(dof_table)[1,1]
estadd local countynum `nogroup'
estadd local con "YES"


#delimit ;

esttab  _all using "`filename'", a keep(treat* 1.treat*#1.`it_tre' `con')
		title({\b Table 3. Relative-time Model})
		label stat( r2 N countynum thfixed,
		fmt( %9.3f %9.0g %9.0g) labels( R-squared Observations "No. Counties" "County & Week FE"))
		 b(3) nogap onecell 
		 interaction("*")
		mtitles("Fixed effects" "Fixed effects and control" "Continuous treatment")
		nonotes addnote("`clusternote'" "`starnote'")
		starlevels( `starlevel') se ;
	
#delimit cr;
 est clear

reghdfe initclaims_rate_regular treatb6backward treatb5-treatb1 treata1-treata5 treata6forward (treatb6backward treatb5-treatb1 treata1-treata5 treata6forward )##`it_tre' `con', absorb(`fe') vce(`vce')
 
// set scheme s1mono
// coefplot, keep(1.treat*) vertical recast(connected) title("The Impact of High BAIT on Unemployment Rates", size(median))  xlabel(, labsize(tiny))  coeflabels(1.treatb6backward#1.`it_tre'= "T-6" 1.treatb5#1.`it_tre'= "T-5" 1.treatb4#1.`it_tre'= "T-4"  1.treatb3#1.`it_tre'= "T-3" 1.treatb2#1.`it_tre'= "T-2" 1.treatb1#1.`it_tre'= "T-1" 1.treata0#1.`it_tre'= "T=0" 1.treata1#1.`it_tre'= "T+1" 1.treata2#1.`it_tre'= "T+2" 1.treata3#1.`it_tre'= "T+3" 1.treata4#1.`it_tre'= "T+4" 1.treata5#1.`it_tre'= "T+5" 1.treata6forward#1.`it_tre'= "T+6" ) nolabel yline(0, lpattern(dash)) xline(6.5, lpattern(dash)) xlabel(, labsize(small)) text(1 -0.5 "hahah", fcolor(red))
// graph export "C:\Users\Leting\Documents\2.Covid_IT_Employment\3.Report\relative_time.emf", as(emf) name("Graph")



**# CEM


eststo:reghdfe initclaims_rate_regular tre tre##`it_tre' `con' if cem_weight_relax !=0 , absorb(`fe') vce(`vce')
estadd local thfixed "YES"
local nogroup = e(dof_table)[1,1]
estadd local countynum `nogroup'

eststo:reghdfe initclaims_rate_regular tre tre##`it_tre' `con' if cem_weight_strict !=0 , absorb(`fe') vce(`vce')
estadd local thfixed "YES"
local nogroup = e(dof_table)[1,1]
estadd local countynum `nogroup'

// eststo:reghdfe initclaims_rate_regular tre tre##`it_tre' `con' if cem_weights_10bins !=0 , absorb(`fe') vce(`vce')
// estadd local thfixed "YES"

eststo: reghdfe initclaims_rate_regular tre tre##`it_tre' `con' if cem_weight_auto !=0 , absorb(`fe') vce(`vce')
estadd local thfixed "YES"
local nogroup = e(dof_table)[1,1]
estadd local countynum `nogroup'
** Use the default binning algorithm,  "sturges" for Sturge's rule

#delimit ;

esttab  _all using "`filename'", a keep(tre 1.tre#*1.`it_tre' )
		title({\b Table 4. Coarsened Exact Matching Analyses})
		label stat(r2 N countynum thfixed,
		fmt( %9.3f %9.0g %9.0g) labels( R-squared Observations "No. Counties" "County & Week FE"))
		 b(3) nogap onecell 
		 	interaction("*")
		mtitles("CEM 1" "CEM 2" "CEM 3")
		nonotes addnote("`clusternote'" "`starnote'")
		starlevels( `starlevel') se ;
	
#delimit cr;
est clear


**# Alternative measurements
// 
//  local starlevel "* 0.10 ** 0.05 *** 0.01"
// local starnote "*** p<0.01, ** p<0.05, * p<0.1"
// local filename "result/report_10.rtf"
// local con "avg_new_death_rate avg_new_case_rate avg_home_prop"
// local it_group appdev_median-infra_median 
//
// global output 1 /*no synthetic control or other analyses*/
// global newITgroup 0  /* 0 = old IT groups; 1 = new IT groups*/


est clear

eststo: reghdfe initclaims_rate_regular tre tre##q4_high_its_emps_all, absorb(`fe') vce(`vce')
estadd local thfixed "YES"
local nogroup = e(dof_table)[1,1]
estadd local countynum `nogroup'

eststo: reghdfe initclaims_rate_regular tre tre##q4_high_its_emps_all  `con', absorb(`fe') vce(`vce')
estadd local thfixed "YES"
local nogroup = e(dof_table)[1,1]
estadd local countynum `nogroup'

eststo: reghdfe initclaims_rate_regular tre tre##c.ln_its_emps  `con', absorb(`fe') vce(`vce')
estadd local thfixed "YES"
local nogroup = e(dof_table)[1,1]
estadd local countynum `nogroup'


#delimit ;

esttab  _all using "`filename'", a keep(tre 1.tre#1.q4_high_its_emps_all 1.tre#c.ln_its_emps  `con')
		order(tre 1.tre#1.q4_high_its_emps_all 1.tre#c.ln_its_emps  `con')
		title({\b Table 5. Alternative Measurement - IT Service Employees})
		interaction("*")
		mtitles("Fixed effects" "Fixed effects and control" "Continuous treatment")
		label stat( r2 N countynum thfixed,
		fmt( %9.3f %9.0g %9.0g) labels( R-squared Observations "No. Counties" "County & Week FE"))
		 b(3) nogap onecell 
		nonotes addnote("`clusternote'" "`starnote'")
		starlevels( `starlevel') se ;
	
#delimit cr;
est clear


 
**# Robustness Checks Telework & Com  (robustness)

frame change default

local con "avg_new_death_rate avg_new_case_rate avg_home_prop"
est clear

eststo:reghdfe initclaims_rate_regular tre tre##`it_tre' tre##c.teleworkable_emp `con', absorb(`fe') vce(`vce')
estadd local thfixed "YES"
local nogroup = e(dof_table)[1,1]
estadd local countynum `nogroup'

eststo:reghdfe initclaims_rate_regular tre tre##q4_high_its_emps_all tre##c.teleworkable_emp `con', absorb(`fe') vce(`vce')
estadd local thfixed "YES"
local nogroup = e(dof_table)[1,1]
estadd local countynum `nogroup'

eststo:reghdfe initclaims_rate_regular tre tre##c.ln_its_emps tre##c.ln_com_emp  `con' , absorb(`fe') vce(`vce')
estadd local thfixed "YES"
local nogroup = e(dof_table)[1,1]
estadd local countynum `nogroup'


#delimit ;

esttab  _all using "`filename'", a keep(tre 1.tre#*1.`it_tre' 1.tre#*1.q4_high_its_emps_all  1.tre#*c.teleworkable_emp 1.tre#c.ln_its_emps 1.tre#c.ln_com_emp )
		title({\b Robustness - Telework Index and IT Equipment Employees})
		label stat(r2 N countynum thfixed,
		fmt( %9.3f %9.0g %9.0g) labels( R-squared Observations "No. Counties" "County & Week FE"))
		 b(3) nogap onecell 
		 	interaction("*")
		mtitles("Telework index" "Telework index" "Placebo test")
		nonotes addnote("`clusternote'" "`starnote'")
		starlevels( `starlevel') se ;
	
#delimit cr;
est clear

}

**# Heterogneity 1: IT app groups


* codebook it_median_qtl

// coefplot (`it_group'), keep(1.tre#1.q4_high_it_median#c.Dev_median 1.tre#1.q4_high_it_median#c.Enterprise_median 1.tre#1.q4_high_it_median#c.Cloud_median 1.tre#1.q4_high_it_median#c.WFH_median 1.tre#1.q4_high_it_median#c.Marketing_median 1.tre#1.q4_high_it_median#c.Security_median   1.tre#1.q4_high_it_median#c.Network_median  ) xline(0)  coeflabels(1.tre#1.q4_high_it_median#c.Dev_median = "Dev" 1.tre#1.q4_high_it_median#c.Enterprise_median = "Enterprise" 1.tre#1.q4_high_it_median#c.Cloud_median = "Cloud" 1.tre#1.q4_high_it_median#c.WFH_median = "WFH" 1.tre#1.q4_high_it_median#c.Marketing_median = "Marketing"   1.tre#1.q4_high_it_median#c.Security_median = "Security" 1.tre#1.q4_high_it_median#c.Network_median = "Network")



// local it_group "number_per_emp_Dev_median number_per_emp_Enterprise_median"
//
// foreach m of local it_group{
// 	reghdfe initclaims_rate_regular tre tre##`it_tre'##c.`m' `con', absorb(`fe') vce(rob)
// 	estimate store `m'
// }


* coefplot (`it_group', label(bivariate)), keep(1.tre#1.q4_high_it_median#c.number_per_emp_Dev_median 1.tre#1.q4_high_it_median#c.number_per_emp_Enterprise_median) xline(0)



* Per employee


local it_group "app_per_median enterp_per_median cloud_per_median groupware_per_median security_per_median network_per_median"		

foreach m of local it_group{
	eststo: reghdfe initclaims_rate_regular tre tre##`it_tre'##c.`m' `con', absorb(`fe') vce(`vce')
	estadd local thfixed "YES"
	local nogroup = e(dof_table)[1,1]
	estadd local countynum `nogroup'
	}
	
eststo: reghdfe initclaims_rate_regular tre tre##`it_tre'##c.app_per_median-network_per_median `con', absorb(`fe') vce(`vce')
	estadd local thfixed "YES"
	local nogroup = e(dof_table)[1,1]
	estadd local countynum `nogroup'
	
	
#delimit ;

esttab  _all using "`filename'", a keep(tre 1.tre#*1.`it_tre'#c.app_per_median
										    1.tre#*1.`it_tre'#c.enterp_per_median
											1.tre#*1.`it_tre'#c.cloud_per_median

											1.tre#*1.`it_tre'#c.groupware_per_median
										
											1.tre#*1.`it_tre'#c.security_per_median
											1.tre#*1.`it_tre'#c.network_per_median
											
											
											
											1.tre#c.app_per_median
											1.tre#c.enterp_per_median
											1.tre#c.cloud_per_median
											
											1.tre#c.groupware_per_median
																					
											
											1.tre#c.security_per_median
											1.tre#c.network_per_median
								
											
											
										    1.tre#1.`it_tre' 
											
										       `con' )
		title(1. )
			order(tre  						1.tre#*1.`it_tre'#c.app_per_median
										    1.tre#*1.`it_tre'#c.enterp_per_median
											1.tre#*1.`it_tre'#c.cloud_per_median

											1.tre#*1.`it_tre'#c.groupware_per_median
									
											
											1.tre#*1.`it_tre'#c.security_per_median
											1.tre#*1.`it_tre'#c.network_per_median										
											
											1.tre#c.app_per_median
											1.tre#c.enterp_per_median
											1.tre#c.cloud_per_median
											
											1.tre#c.groupware_per_median
									
											1.tre#c.security_per_median
											1.tre#c.network_per_median
															
											
										    1.tre#1.`it_tre' 
											
										       `con'	)		
		label stat( r2 N countynum thfixed,
		fmt( %9.3f %9.0g %9.0g) labels( R-squared Observations "No. Counties" "Week & County FE"))
		 b(3) nogap onecell 
		nonotes addnote("`clusternote'" "`starnote'")
		starlevels( `starlevel') se ;
	
#delimit cr;

est clear


* use this new code
coefplot (*), keep( 1.tre#*1.q4_high_it_median#c.app_per_median 1.tre#*1.q4_high_it_median#c.enterp_per_median 1.tre#*1.q4_high_it_median#c.cloud_per_median 1.tre#*1.q4_high_it_median#c.groupware_per_median 1.tre#*1.q4_high_it_median#c.security_per_median) xline(0) coeflabels (1.tre#*1.q4_high_it_median#c.app_per_median = "Apps" 1.tre#*1.q4_high_it_median#c.enterp_per_median = "Enterprise" 1.tre#*1.q4_high_it_median#c.cloud_per_median = "Cloud" 1.tre#*1.q4_high_it_median#c.groupware_per_median = "Groupware" 1.tre#*1.q4_high_it_median#c.security_per_median = "Security")


				

 
if $graph == 1 {
	
	coefplot (app_per_median, keep(1.tre#1.q4_high_it_median#c.app_median) mcolor(navy) ciopts(color(navy)) ) (Cloud_median, keep(1.tre#1.q4_high_it_median#c.Cloud_median) mcolor(navy) ciopts(color(navy)) ) (Network_median, keep(1.tre#1.q4_high_it_median#c.Network_median) mcolor(navy) ciopts(color(navy)))( WFH_median, keep(1.tre#1.q4_high_it_median#c.WFH_median) mcolor(navy) ciopts(color(navy)))(Marketing_median, keep(1.tre#1.q4_high_it_median#c.Marketing_median) mcolor(navy) ciopts(color(navy)))  (Enterprise_median, keep(1.tre#1.q4_high_it_median#c.Enterprise_median) mcolor(orange) ciopts(color(orange)))  (Security_median, keep(1.tre#1.q4_high_it_median#c.Security_median) mcolor(orange) ciopts(color(orange))), xline(0)  coeflabels(1.tre#1.q4_high_it_median#c.Dev_median = "Dev" 1.tre#1.q4_high_it_median#c.Enterprise_median = "Enterprise" 1.tre#1.q4_high_it_median#c.Cloud_median = "Cloud" 1.tre#1.q4_high_it_median#c.WFH_median = "Productivity" 1.tre#1.q4_high_it_median#c.Marketing_median = "Marketing"   1.tre#1.q4_high_it_median#c.Security_median = "Security" 1.tre#1.q4_high_it_median#c.Network_median = "Network") legend(off) 
}

 

//
// **# Heterogneity 2: skill-level
// 
// est clear
//
// eststo:reghdfe initclaims_rate_regular tre tre##`it_tre'##c.internetper `con', absorb(`fe') vce(`vce')
// estadd local thfixed "YES"
// local nogroup = e(dof_table)[1,1]
// estadd local countynum `nogroup'
//
// eststo:reghdfe initclaims_rate_regular tre tre##`it_tre'##c.ln_income `con', absorb(`fe') vce(`vce')
// estadd local thfixed "YES"
// local nogroup = e(dof_table)[1,1]
// estadd local countynum `nogroup'
//
// eststo:reghdfe initclaims_rate_regular tre tre##`it_tre'##c.bachelorhigherper `con' , absorb(`fe') vce(`vce')
// estadd local thfixed "YES"
// local nogroup = e(dof_table)[1,1]
// estadd local countynum `nogroup'
//
// eststo:reghdfe initclaims_rate_regular tre tre##`it_tre'##c.internetper tre##`it_tre'##c.ln_income tre##`it_tre'##c.bachelorhigherper `con' , absorb(`fe') vce(`vce')
// estadd local thfixed "YES"
// local nogroup = e(dof_table)[1,1]
// estadd local countynum `nogroup'
//
//
// #delimit;
// esttab  _all using "`filename'", a keep(tre 1.tre#*1.`it_tre'#c.internetper 1.tre#*1.`it_tre'#c.ln_income 1.tre#*1.`it_tre'#c.bachelorhigherper
// 										    1.tre#c.internetper  1.tre#c.ln_income 1.tre#c.bachelorhigherper 
// 											 1.tre#1.`it_tre' `con')
// 		title(Skill-level)
// 		order(tre 1.tre#*1.`it_tre'#c.internetper 1.tre#*1.`it_tre'#c.ln_income 1.tre#*1.`it_tre'#c.bachelorhigherper
// 										    1.tre#c.internetper  1.tre#c.ln_income 1.tre#c.bachelorhigherper 
// 											 1.tre#1.`it_tre' `con' )		
// 		label stat(r2 N countynum thfixed,
// 		fmt( %9.3f %9.0g %9.0g) labels( R-squared Observations "No. Counties" "Week & County FE"))
// 		 b(3) nogap onecell 
// 		  interaction("*")
// 		mtitles("Household Internet access" "Income" "Education (above bachelor)")
// 		nonotes addnote("`clusternote'" "`starnote'")
// 		starlevels( `starlevel') se ;
//	
// #delimit cr;
//
// est clear
// 
 
**# Heterogneity 2: industry composition 
 
 
est clear

 
eststo:reghdfe initclaims_rate_regular tre tre##`it_tre'##c.agriculture `con' , absorb(`fe') vce(`vce')
estadd local thfixed "YES"
local nogroup = e(dof_table)[1,1]
estadd local countynum `nogroup'

eststo:reghdfe initclaims_rate_regular tre tre##`it_tre'##c.construction `con' , absorb(`fe') vce(`vce')
estadd local thfixed "YES"
local nogroup = e(dof_table)[1,1]
estadd local countynum `nogroup'

eststo:reghdfe initclaims_rate_regular tre tre##`it_tre'##c.manufacturing `con' , absorb(`fe') vce(`vce')
estadd local thfixed "YES"
local nogroup = e(dof_table)[1,1]
estadd local countynum `nogroup'

eststo:reghdfe initclaims_rate_regular tre tre##`it_tre'##c.wholesale `con', absorb(`fe') vce(`vce')
estadd local thfixed "YES"
local nogroup = e(dof_table)[1,1]
estadd local countynum `nogroup'

eststo:reghdfe initclaims_rate_regular tre tre##`it_tre'##c.retail `con', absorb(`fe') vce(`vce')
estadd local thfixed "YES"
local nogroup = e(dof_table)[1,1]
estadd local countynum `nogroup'

eststo:reghdfe initclaims_rate_regular tre tre##`it_tre'##c.transportation `con', absorb(`fe') vce(`vce')
estadd local thfixed "YES"
local nogroup = e(dof_table)[1,1]
estadd local countynum `nogroup'

eststo:reghdfe initclaims_rate_regular tre tre##`it_tre'##c.information `con', absorb(`fe') vce(`vce')
estadd local thfixed "YES"
local nogroup = e(dof_table)[1,1]
estadd local countynum `nogroup'

eststo:reghdfe initclaims_rate_regular tre tre##`it_tre'##c.insurance `con', absorb(`fe') vce(`vce')
estadd local thfixed "YES"
local nogroup = e(dof_table)[1,1]
estadd local countynum `nogroup'

eststo:reghdfe initclaims_rate_regular tre tre##`it_tre'##c.agriculture-insurance `con', absorb(`fe') vce(`vce')
estadd local thfixed "YES"
local nogroup = e(dof_table)[1,1]
estadd local countynum `nogroup'




#delimit ;

esttab  _all using "`filename'", a keep(tre 1.tre#*1.`it_tre'#c.agriculture 1.tre#*1.`it_tre'#c.construction 
											1.tre#*1.`it_tre'#c.manufacturing 1.tre#*1.`it_tre'#c.wholesale 
											1.tre#*1.`it_tre'#c.wholesale 1.tre#*1.`it_tre'#c.retail
											1.tre#*1.`it_tre'#c.transportation 1.tre#*1.`it_tre'#c.information
											1.tre#*1.`it_tre'#c.insurance
											
											1.tre#c.agriculture 1.tre#c.construction 
											1.tre#c.manufacturing 1.tre#c.wholesale 
											1.tre#c.wholesale 1.tre#c.retail
											1.tre#c.transportation 1.tre#c.information
											1.tre#c.insurance 
											 1.tre#1.`it_tre'
											
											`con' )
		title(6. )
		order(tre 1.tre#*1.`it_tre'#c.agriculture 1.tre#*1.`it_tre'#c.construction 
											1.tre#*1.`it_tre'#c.manufacturing 1.tre#*1.`it_tre'#c.wholesale 
											1.tre#*1.`it_tre'#c.wholesale 1.tre#*1.`it_tre'#c.retail
											1.tre#*1.`it_tre'#c.transportation 1.tre#*1.`it_tre'#c.information
											1.tre#*1.`it_tre'#c.insurance
											
											1.tre#c.agriculture 1.tre#c.construction 
											1.tre#c.manufacturing 1.tre#c.wholesale 
											1.tre#c.wholesale 1.tre#c.retail
											1.tre#c.transportation 1.tre#c.information
											1.tre#c.insurance
											 1.tre#1.`it_tre'
											
											`con' )		
		label stat( r2 N countynum thfixed,
		fmt( %9.3f %9.0g %9.0g) labels( R-squared Observations "No. Counties" "County & Week FE"))
		 b(3) nogap onecell 
		nonotes addnote("`clusternote'" "`starnote'")
		starlevels( `starlevel') se ;
	
#delimit cr;

est clear


**# Heterogneity 3: Occupations of skill levels

// if $occupation == 1 {
//	
// local filename "result/report_0204journalnewcupation.rtf"
//
// local starlevel "* 0.10 ** 0.05 *** 0.01"
// local starnote "*** p<0.01, ** p<0.05, * p<0.1"
// local con "avg_new_death_rate avg_new_case_rate avg_home_prop"
// local it_tre q4_high_it_median
// local fe county week
// local vce rob
// local clusternote "Notes: Robust standard errors are reported in parentheses." 
//
// local df "e(df_a_initial)"
//
// local occ_group "job_manag job_bus_fin job_com_math job_arch_engin job_life_phy job_com_socser job_legal"
//
// foreach m of local occ_group{
// 	eststo: reghdfe initclaims_rate_regular tre tre##`it_tre'##c.`m' `con', absorb(`fe') vce(`vce')
// 	estadd local thfixed "YES"
// 	local nogroup = e(dof_table)[1,1]
// 	estadd local countynum `nogroup'
// 	}
//	
//	
// eststo: reghdfe initclaims_rate_regular tre tre##`it_tre'##c.job_manag-job_legal `con', absorb(`fe') vce(`vce')
// estadd local thfixed "YES"
// local nogroup = e(dof_table)[1,1]
// estadd local countynum `nogroup'
//	
// *1.tre#*1.`it_tre'#c.job_bus_fin
//
// #delimit ;
//
// esttab  _all using "`filename'", a keep(tre 1.tre#*1.`it_tre'#c.job_manag 
// 											1.tre#*1.`it_tre'#c.job_com_math 1.tre#*1.`it_tre'#c.job_arch_engin
// 											1.tre#*1.`it_tre'#c.job_life_phy 1.tre#*1.`it_tre'#c.job_com_socser
// 											1.tre#*1.`it_tre'#c.job_legal 
//											
// 											1.tre#c.job_manag 1.tre#c.job_bus_fin
// 											1.tre#c.job_com_math 1.tre#c.job_arch_engin
// 											1.tre#c.job_life_phy 1.tre#c.job_com_socser
// 											1.tre#c.job_legal 
//											
//											
//											
// 											 1.tre#1.`it_tre'
//											
// 											`con' )
// 		title(6. )
// 		order(tre 1.tre#*1.`it_tre'#c.job_manag 1.tre#*1.`it_tre'#c.job_bus_fin 
// 											1.tre#*1.`it_tre'#c.job_com_math 1.tre#*1.`it_tre'#c.job_arch_engin
// 											1.tre#*1.`it_tre'#c.job_life_phy 1.tre#*1.`it_tre'#c.job_com_socser
// 											1.tre#*1.`it_tre'#c.job_legal 
//											
// 											1.tre#c.job_manag 1.tre#c.job_bus_fin 
// 											1.tre#c.job_com_math 1.tre#c.job_arch_engin
// 											1.tre#c.job_life_phy 1.tre#c.job_com_socser
// 											1.tre#c.job_legal 
//											
//											
//											
// 											 1.tre#1.`it_tre'
//											
// 											`con'  )		
// 		label stat( r2 N countynum thfixed,
// 		fmt( %9.3f %9.0g %9.0g) labels( R-squared Observations "No. Counties" "County & Week FE"))
// 		 b(3) nogap onecell
// 		nonotes addnote("`clusternote'" "`starnote'")
// 		starlevels( `starlevel') se ;
//	
// #delimit cr;
//
// est clear
//
//
// local filename "result/report_0209.rtf"
//
// local starlevel "* 0.10 ** 0.05 *** 0.01"
// local starnote "*** p<0.01, ** p<0.05, * p<0.1"
// local con "avg_new_death_rate avg_new_case_rate avg_home_prop"
// local it_tre q4_high_it_median
// local fe county week
// local vce rob
// local clusternote "Notes: Robust standard errors are reported in parentheses." 
// *local countynum N_clust
// local df "e(df_a_initial)"
//
// local it_group "app_per_median enterp_per_median cloud_per_median groupware_per_median security_per_median network_per_median"

//
// global newITgroup 1  /* 0 = old IT groups; 1 = new IT groups*/
// global graph 0 /* 0 = No graphs; 1 = Export graphs*/
// global additional 0  /* 0 = no additional analyses; 1 = have additional analyses (e.g., synthetic control)*/
// global onlyhetero 1

	
eststo: reghdfe initclaims_rate_regular tre tre##`it_tre'##c.lowskilloc `con', absorb(`fe') vce(`vce')
estadd local thfixed "YES"
local nogroup = e(dof_table)[1,1]
estadd local countynum `nogroup'

eststo: reghdfe initclaims_rate_regular tre tre##`it_tre'##c.midskilloc `con', absorb(`fe') vce(`vce')
estadd local thfixed "YES"
local nogroup = e(dof_table)[1,1]
estadd local countynum `nogroup'
	
eststo: reghdfe initclaims_rate_regular tre tre##`it_tre'##c.highskilloc `con', absorb(`fe') vce(`vce')
estadd local thfixed "YES"
local nogroup = e(dof_table)[1,1]
estadd local countynum `nogroup'


eststo: reghdfe initclaims_rate_regular tre tre##`it_tre'##c.lowskilloc-highskilloc `con', absorb(`fe') vce(`vce')
estadd local thfixed "YES"
local nogroup = e(dof_table)[1,1]
estadd local countynum `nogroup'

#delimit;
esttab  _all using "`filename'", a keep(tre 1.tre#*1.`it_tre'#c.lowskilloc 1.tre#*1.`it_tre'#c.midskilloc 1.tre#*1.`it_tre'#c.highskilloc
											 1.tre#c.lowskilloc 1.tre#c.midskilloc 1.tre#c.highskilloc 1.tre#1.`it_tre'    `con')
		title(Skill Occupations)
		order(tre 1.tre#*1.`it_tre'#c.lowskilloc 1.tre#*1.`it_tre'#c.midskilloc 1.tre#*1.`it_tre'#c.highskilloc
											 1.tre#c.lowskilloc 1.tre#c.midskilloc 1.tre#c.highskilloc  1.tre#1.`it_tre' `con' )		
		label stat(r2 N countynum thfixed,
		fmt( %9.3f %9.0g %9.0g) labels( R-squared Observations "No. Counties" "Week & County FE"))
		 b(3) nogap onecell 
		  interaction("*")
		mtitles("Low-skill" "Middle-skill" "High-skill")
		nonotes addnote("`clusternote'" "`starnote'")
		starlevels( `starlevel') se ;
	
#delimit cr;

est clear
 
	

**# Additional Analyses: Philly & Graphs

if $additional == 1{
	

**# Philly Case


frame copy default phi
frame change phi
frame pwf
codebook cem_strata_strict cem_strata_relax if county == 42101

keep if county == 42101 | county == 36005

twoway  (line initclaims_rate_regular week if county == 42101,  color(blue) ) (line initclaims_rate_regular week if county == 36005, color(red)) , legend(on order(1 "Philadelphia (PA)" 2 "Bronx (NY)" ))

graph export "C:\Users\Leting\Documents\2.Covid_IT_Employment\3.Report\phillycase.emf", as(emf) name("Graph") replace
* San fan county  =  6075	



// **# Graphs

 graph hbox app_per_median-network_per_median, nooutsides

	}

	
	

*# Achive analyses

//
// global newITgroup 1
//
// if $newITgroup == 0 {
//	
//
//		
// local starlevel "* 0.10 ** 0.05 *** 0.01"
// local starnote "*** p<0.01, ** p<0.05, * p<0.1"
// local filename "result/itgroups.rtf"
// local con "avg_new_death_rate avg_new_case_rate avg_home_prop"
// local it_group1 "number_per_emp_Dev_median  number_per_emp_Cloud_median number_per_emp_WFH_mediannumber_per_emp_Network_median"
//
// foreach m of local it_group{
//
// 	eststo: areg initclaims_rate_regular tre tre##`it_tre'##c.`m' `con' i.week, absorb(county) rob
// 	estadd local tfixed "YES"
// 	estadd local hfixed "YES"
// 	}
//	
//	
// #delimit ;
// esttab  _all using "`filename'", a keep(tre 1.tre#*1.`it_tre'#c.number_per_emp_Dev_median
//										   
// 											1.tre#*1.`it_tre'#c.number_per_emp_Cloud_median
//
//										
// 											1.tre#*1.`it_tre'#c.number_per_emp_WFH_median
//								
//											
//						
// 											1.tre#*1.`it_tre'#c.number_per_emp_Network_median
//											
//											
//											
// 											1.tre#c.number_per_emp_Dev_median
//									
// 											1.tre#c.number_per_emp_Cloud_median
//											
//								
// 											1.tre#c.number_per_emp_WFH_median												
//
//					
// 											1.tre#c.number_per_emp_Network_median
//								
//											
//											
// 										    1.tre#1.`it_tre' 
//											
// 										       `con' )
// 		title(3. )
// 			order(tre  					tre 1.tre#*1.`it_tre'#c.number_per_emp_Dev_median
//								
// 											1.tre#*1.`it_tre'#c.number_per_emp_Cloud_median
//
//							
// 											1.tre#*1.`it_tre'#c.number_per_emp_WFH_median
//											
//							
// 											1.tre#*1.`it_tre'#c.number_per_emp_Network_median
//											
//											
//											
// 											1.tre#c.number_per_emp_Dev_median
//		
// 											1.tre#c.number_per_emp_Cloud_median
//											
//						
// 											1.tre#c.number_per_emp_WFH_median												
//							
//						
// 											1.tre#c.number_per_emp_Network_median
//								
//											
//											
// 										    1.tre#1.`it_tre' 
//											
// 										       `con'	)		
// 		label stat( r2 N df_a tfixed hfixed,
// 		fmt( %9.3f %9.0g %9.0g) labels( R-squared Observations "No. Counties" "Week FE" "County FE"))
// 		 b(3) nogap onecell 
// 		 interaction("*")
// 		mtitles("Dev Apps" "SaaS"  "Groupware & PCs" "Hardware Infrastructure")
// 		 nonotes addnote("`clusternote'" "`starnote'")
// 		starlevels( `starlevel') se ;
//	
// #delimit cr;
//
// est clear
// 
//
// 
// local it_group2 "number_per_emp_Enterprise_median  number_per_emp_Database_median security_peremp_median number_per_emp_Marketing_median"
//	
//
// foreach m of local it_group{
//
// 	eststo: areg initclaims_rate_regular tre tre##`it_tre'##c.`m' `con' i.week, absorb(county) rob
// 	estadd local tfixed "YES"
// 	estadd local hfixed "YES"
// 	}
//	
//	
// #delimit ;
//
// esttab  _all using "`filename'", a keep(tre 
// 										    1.tre#*1.`it_tre'#c.number_per_emp_Enterprise_median
//							
//
// 											1.tre#*1.`it_tre'#c.number_per_emp_Database_median
//											
//											
// 											1.tre#*1.`it_tre'#c.security_peremp_median
//											
// 											1.tre#*1.`it_tre'#c.number_per_emp_Marketing_median
//											
//											
//											
//									
// 											1.tre#c.number_per_emp_Enterprise_median
//											
// 											1.tre#c.number_per_emp_Database_median
//			
// 											1.tre#c.security_peremp_median
//											
// 											1.tre#c.number_per_emp_Marketing_median
//											
//								
// 											1.tre#c.number_per_emp_Network_median
//								
//											
//											
// 										    1.tre#1.`it_tre' 
//											
// 										       `con' )
// 		title(4. )
// 			order(tre  					tre 
// 										    1.tre#*1.`it_tre'#c.number_per_emp_Enterprise_median
//										
//
// 											1.tre#*1.`it_tre'#c.number_per_emp_Database_median
//								
//								
//											
// 											1.tre#*1.`it_tre'#c.security_peremp_median
//											
// 											1.tre#*1.`it_tre'#c.number_per_emp_Marketing_median
//											
//											
//											
//									
// 											1.tre#c.number_per_emp_Enterprise_median
//								
//											
// 											1.tre#c.number_per_emp_Database_median
//																		
//											
// 											1.tre#c.security_peremp_median
//							
// 											1.tre#c.number_per_emp_Marketing_median
//											
//											
// 										    1.tre#1.`it_tre' 
//											
// 										       `con'	)		
// 		label stat( r2 N df_a tfixed hfixed,
// 		fmt( %9.3f %9.0g %9.0g) labels( R-squared Observations "No. Counties" "Week FE" "County FE"))
// 		 b(3) nogap onecell 
// 		 interaction("*")
// 		mtitles("Dev Apps" "Enterprise software" "SaaS" "Database" "Groupware & PCs" "Digital Marketing" "Cybersecurity" "Hardware Infrastructure")
// 		 nonotes addnote("`clusternote'" "`starnote'")
// 		starlevels( `starlevel') se ;
//	
// #delimit cr;
//
// est clear
//	
//	
// }
//
//

//
//
// **# Archive
//
//
// local it_group "app_median enterp_median cloud_median groupware_median market_median security_median network_median"
//
//
// foreach m of local it_group{
// 	reghdfe initclaims_rate_regular tre tre##`it_tre'##c.`m' `con', absorb(`fe') vce(`vce')
// 	estimate store `m'
// }
//	
// #delimit ;
//
// esttab  _all using "`filename'", a keep(tre 1.tre#*1.`it_tre'#c.app_median
// 										    1.tre#*1.`it_tre'#c.enterp_median
// 											1.tre#*1.`it_tre'#c.cloud_median
//
// 											1.tre#*1.`it_tre'#c.groupware_median
// 											1.tre#*1.`it_tre'#c.market_median
//											
// 											1.tre#*1.`it_tre'#c.security_median
// 											1.tre#*1.`it_tre'#c.network_median
//											
//											
//											
// 											1.tre#c.app_median
// 											1.tre#c.enterp_median
// 											1.tre#c.cloud_median
//											
// 											1.tre#c.groupware_median
// 											1.tre#c.market_median													
//											
// 											1.tre#c.security_median
// 											1.tre#c.network_median
//								
//											
//											
// 										    1.tre#1.`it_tre' 
//											
// 										       `con' )
// 		title(1. )
// 			order(tre  						1.tre#*1.`it_tre'#c.app_median
// 										    1.tre#*1.`it_tre'#c.enterp_median
// 											1.tre#*1.`it_tre'#c.cloud_median
//
// 											1.tre#*1.`it_tre'#c.groupware_median
// 											1.tre#*1.`it_tre'#c.market_median
//										
// 											1.tre#*1.`it_tre'#c.security_median
// 											1.tre#*1.`it_tre'#c.network_median
//											
//											
//											
// 											1.tre#c.app_median
// 											1.tre#c.enterp_median
// 											1.tre#c.cloud_median
//											
// 											1.tre#c.groupware_median
// 											1.tre#c.market_median												
//											
// 											1.tre#c.security_median
// 											1.tre#c.network_median
//								
//											
//											
// 										    1.tre#1.`it_tre' 
//											
// 										       `con'	)		
// 		label stat( r2 N `countynum' thfixed,
// 		fmt( %9.3f %9.0g %9.0g) labels( R-squared Observations "No. Counties" "Week & County FE"))
// 		 b(3) nogap onecell 
// 		nonotes addnote("`clusternote'" "`starnote'")
// 		starlevels( `starlevel') se ;
//	
// #delimit cr;
//
// est clear	
//	
// if $graph == 1 {
//	
// 	coefplot (appdev_median, keep(1.tre#1.q4_high_it_median#c.appdev_median) mcolor(navy) ciopts(color(navy)) ) (Cloud_median, keep(1.tre#1.q4_high_it_median#c.Cloud_median) mcolor(navy) ciopts(color(navy)) ) (Network_median, keep(1.tre#1.q4_high_it_median#c.Network_median) mcolor(navy) ciopts(color(navy)))( WFH_median, keep(1.tre#1.q4_high_it_median#c.WFH_median) mcolor(navy) ciopts(color(navy)))(Marketing_median, keep(1.tre#1.q4_high_it_median#c.Marketing_median) mcolor(navy) ciopts(color(navy)))  (Enterprise_median, keep(1.tre#1.q4_high_it_median#c.Enterprise_median) mcolor(orange) ciopts(color(orange)))  (Security_median, keep(1.tre#1.q4_high_it_median#c.Security_median) mcolor(orange) ciopts(color(orange))), xline(0)  coeflabels(1.tre#1.q4_high_it_median#c.Dev_median = "Dev" 1.tre#1.q4_high_it_median#c.Enterprise_median = "Enterprise" 1.tre#1.q4_high_it_median#c.Cloud_median = "Cloud" 1.tre#1.q4_high_it_median#c.WFH_median = "Productivity" 1.tre#1.q4_high_it_median#c.Marketing_median = "Marketing"   1.tre#1.q4_high_it_median#c.Security_median = "Security" 1.tre#1.q4_high_it_median#c.Network_median = "Network") legend(off) 
// }
//

