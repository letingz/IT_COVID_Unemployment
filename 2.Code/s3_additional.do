local filename "result/subgroup_20230414.rtf"


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

**# program control
global newITgroup 0  /* 0 = old IT groups; 1 = new IT groups*/

global subgroup 0
global lowskill 0
global heter_industry 0
global heter_occupation 0
global clean 0

**#

// . label variable itbudget1 "Hardware Budget"
//
// . label variable itbudget2 "PC Budget"
//
// . label variable itbudget3 "Server Budget"
//
// . label variable itbudget4 "Terminal Budget"
//
// . label variable itbudget9 "Software Budget"
//
// . label variable itbudget8 "Communication Budget"
//
// . label variable itbudget7 "Storage Budget"
//
// . label variable itbudget6 "Other Hardware Budget"
//
// . label variable itbudget5 "Printer Budget"




**# The impact of subgroups of IT budget


if $subgroup == 1 {

// local it_sub_budget_log "ln_hw_bmedian ln_pc_bmedian ln_sv_bmedian ln_ter_bmedian ln_pr_bmedian ln_ohw_bmedian ln_sto_bmedian ln_comm_bmedian ln_sw_median ln_ser_median"
//
//
// rename (ln_hw_bmedian ln_pc_bmedian ln_sv_bmedian ln_ter_bmedian ln_pr_bmedian ln_ohw_bmedian ln_sto_bmedian ln_comm_bmedian ln_sw_median ln_ser_median) itbudget#, addnumber


//reference: https://stackoverflow.com/questions/35277846/how-to-batch-rename-variables-in-esttab

forvalues i = 1 / 10 {
	
	eststo: reghdfe initclaims_rate_regular tre tre##c.itbudget`i' `con', absorb(`fe') vce(`vce') 	
	local nogroup = e(dof_table)[1,1]
  	estadd local countynum `nogroup'
	local itlist `itlist' 1.tre#c.itbudget`i' itbudget
	}



	#delimit ;


esttab  _all using "`filename'", append 	 rename(`itlist')
						keep(tre itbudget )
		order(tre itbudget)
		interaction("*")
		title({\b Table 2. Main Effect})
		mtitles("Hardware" "PC" "Sever"  "Terminal" "Printer" "Other Hardware" "Storage" "Communication Serivce" "Software" "IT related services")
	
		label stat( r2 N countynum thfixed,
		fmt( %9.3f %9.0g %9.0g ) labels( R-squared Observations "No. Counties" "County & Week FE"))
		starlevels( `starlevel') se ;
	
#delimit cr;
est clear 



}


if $lowskill == 1 {
	

**# The role of low-skills workers proportion

reghdfe initclaims_rate_regular tre tre##`it_tre'##c.lowskilloc `con', absorb(`fe') vce(`vce')

reghdfe initclaims_rate_regular tre tre##c.lowskilloc `con', absorb(`fe') vce(`vce')

reghdfe initclaims_rate_regular treatb6backward treatb5-treatb1 treata1-treata5 treata6forward (treatb6backward treatb5-treatb1 treata1-treata5 treata6forward )##c.lowskilloc `con', absorb(`fe') vce(`vce')
}




**# Heterogenity  -  Industry

if $heter_industry == 1 {

*rename (agriculture construction manufacturing wholesale retail transportation information insurance) industry_emp#, addnumber

forvalues i  = 1 / 10 {
  
  local it_lab: variable label itbudget`i'
  est clear

	forvalues j = 1 / 8 {
	
		eststo:reghdfe initclaims_rate_regular tre tre##c.itbudget`i'##c.industry_emp`j' `con' , absorb(`fe') vce(`vce')
		estadd local thfixed "YES"
		local nogroup = e(dof_table)[1,1]
		estadd local countynum `nogroup'
		
		
		local threeinterlist `threeinterlist' 1.tre#c.itbudget`i'#c.industry_emp`j' "After Stay at Home * `it_lab' * Industry"
		local interlist `interlist' 1.tre#c.industry_emp`j' "After Stay at Home * Industry"
	
	}
	
	#delimit ;

esttab  _all using "`filename'", a rename(`threeinterlist' `interlist')
								keep(tre "After Stay at Home * `it_lab' * Industry" 
									     "After Stay at Home * Industry"
									 1.tre#c.itbudget`i' `con' )
								title("Heterogeneity Analyses of `it_lab':" Industry )
								order(tre "After Stay at Home * `it_lab' * Industry" 
									     "After Stay at Home * Industry"
									 1.tre#c.itbudget`i' `con')		
		label stat( r2 N countynum thfixed,
		fmt( %9.3f %9.0g %9.0g) labels( R-squared Observations "No. Counties" "County & Week FE"))
		 b(3) nogap onecell 
		 interaction("*") 
		nonotes addnote("`clusternote'" "`starnote'")
		mtitles("Agriculture" "Construction" "Manufacturing" "Wholesale" "Retail" "Transport" "Information" "Insurance")
		starlevels( `starlevel') se ;
	
#delimit cr;

est clear
	
	
}

	
	
}


**# Heterogenity  -  Occupation

if $heter_occupation == 1 {
	
*rename (lowskilloc midskilloc highskilloc) skill_oc#, addnumber

forvalues i  = 1 / 10 {
 
  est clear
    local it_lab: variable label itbudget`i'


	forvalues j = 1 / 3 {
	
		eststo:reghdfe initclaims_rate_regular tre tre##c.itbudget`i'##c.skill_oc`j' `con' , absorb(`fe') vce(`vce')
		estadd local thfixed "YES"
		local nogroup = e(dof_table)[1,1]
		estadd local countynum `nogroup'
		
		
		local threeinterlist `threeinterlist' 1.tre#c.itbudget`i'#c.skill_oc`j' "After Stay at Home * `it_lab' * Occupation"
		local interlist `interlist' 1.tre#c.skill_oc`j' "After Stay at Home * Occupation"
	
	}
	
	#delimit ;

esttab  _all using "`filename'", a rename(`threeinterlist' `interlist')
								keep(tre "After Stay at Home * `it_lab' * Occupation"
								"After Stay at Home * Occupation"
									 1.tre#c.itbudget`i' `con' )
								title("Heterogeneity Analyses of `it_lab':" Skill Level of Occupations )
								order(tre "After Stay at Home * `it_lab' * Occupation"
								"After Stay at Home * Occupation"
									 1.tre#c.itbudget`i' `con')
								
		label stat( r2 N countynum thfixed,
		fmt( %9.3f %9.0g %9.0g) labels( R-squared Observations "No. Counties" "County & Week FE"))
		 b(3) nogap onecell 
		 interaction("*")
		 mtitles("Low-skill" "Middle-skill" "High-skill")
		nonotes addnote("`clusternote'" "`starnote'")
		starlevels( `starlevel') se ;
	
#delimit cr;

est clear	
	
}

	

}




**# Generate Dense Low-skill  County indicators

// if $clean == 0 {
// xtile lowskill_qtl  = skill_oc1, nq(4)
// g q4_high_lowskill = (lowskill_qtl == 4)
// g q2_high_lowskill = (lowskill_qtl > 2 & lowskill_qtl!=. )
// replace  q4_high_lowskill =. if skill_oc1 ==.
// replace  q2_high_lowskill =. if skill_oc1 ==.
//
//
// **# Process county partisanship data
// preserve
// keep if year == 2016
// g vote_share = candidatevotes/ totalvotes
// xtile demo_qtl = vote_share if party == "DEMOCRAT" , nq(4)
// xtile other_qtl = vote_share if party == "OTHER" , nq(4)
// xtile rep_qtl = vote_share if party == "REPUBLICAN" , nq(4)
// g party_qtl = demo_qtl
// replace party_qtl = rep_qtl if party_qtl ==.
// replace party_qtl = other_qtl if party_qtl ==.
// g democratic = 1 if party_qtl >2 & party == "DEMOCRAT"
// replace democratic = 0 if democratic == .
// keep if  party == "DEMOCRAT"
// keep county_name county_fips democratic
// duplicates drop
// drop if county ==.
// save "C:\Users\Leting\Documents\2.Covid_IT_Employment\1.Data\2.intermediate_data\use_county_democratic.dta" 
// }



local filename "result/subgroup_partisanship.rtf"

	**# Heterogneity 5: Partisanship

eststo: reghdfe initclaims_rate_regular tre tre##`it_tre'##democratic `con', absorb(`fe') vce(`vce')
estadd local thfixed "YES"
local nogroup = e(dof_table)[1,1]
estadd local countynum `nogroup'
	
#delimit ;

esttab  _all using "`filename'", a keep(tre 1.tre#1.`it_tre'#1.democratic  1.tre#1.`it_tre' 1.tre#1.democratic `con')
		order(tre 1.tre#1.`it_tre'#1.democratic  1.tre#1.`it_tre' 1.tre#1.democratic `con')
		label stat(r2 N countynum thfixed,
		fmt( %9.3f %9.0g %9.0g) labels( R-squared Observations "No. Counties" "County & Week FE"))
		 b(3) nogap onecell 
		 	interaction("*")
		nonotes addnote("`clusternote'" "`starnote'")
		starlevels( `starlevel') se ;
	
#delimit cr;
est clear
