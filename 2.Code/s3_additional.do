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

coefplot (*), keep(1.tre#c.itbudget1 1.tre#c.itbudget2 1.tre#c.itbudget3 1.tre#c.itbudget4 1.tre#c.itbudget5 1.tre#c.itbudget6 1.tre#c.itbudget7 1.tre#c.itbudget8 1.tre#c.itbudget9 1.tre#c.itbudget10) coeflabels(1.tre#c.itbudget1 = "Hardware" 1.tre#c.itbudget2 = "PC" 1.tre#c.itbudget3 = "Server" 1.tre#c.itbudget4 = "Terminal" 1.tre#c.itbudget5 = "Printer" 1.tre#c.itbudget6 = "Other Hardware" 1.tre#c.itbudget7 = "Storage" 1.tre#c.itbudget8 = "Communication" 1.tre#c.itbudget9 = "Software" 1.tre#c.itbudget10 = "Service")

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





*# Heterogneity 5: Partisanship
	
	
	//local threeinterlist `threeinterlist' 1.tre#c.itbudget`i'#c.industry_emp`j' "After Stay at Home * `it_lab' * Industry"
	
*---------- analyses
	
frame create county_partisan
frame change county_partisan
use "C:\Users\Leting\Documents\2.Covid_IT_Employment\1.Data\3.output_data\county_house_partisan_2018.dta"
local pquan  d_vshare r_vshare 
foreach i of local pquan {
xtile `i'_qtl = `i', nq(4)
g q4_high_`i' = (`i'_qtl == 4)
g q2_high_`i' = (`i'_qtl > 2)
}

g democ_com_id = 1 ==  ( d_vshare > r_vshare )


frame change county_partisan
destring county_fips, g(county)
destring county_fips, g(county) force
drop county_fips
frame change default
drop link
frlink m:1 county, frame(county_partisan) generate(link)
frget q4_high_d_vshare  = q4_high_d_vshare, from(link)
frget  q2_high_d_vshare  =  q2_high_d_vshare, from(link) 
frget democ_com_id  =  democ_com_id, from(link)
*----------
	
est clear
local filename "result/it_partisanship1.rtf"
local starlevel "* 0.10 ** 0.05 *** 0.01"
local starnote "*** p<0.01, ** p<0.05, * p<0.1"
local con "avg_new_death_rate avg_new_case_rate avg_home_prop"
local it_tre q4_high_it_median
local fe county week
local vce rob
local clusternote "Notes: Robust standard errors are reported in parentheses." 
*local countynum N_clust
local df "e(df_a_initial)"

eststo: reghdfe initclaims_rate_regular tre 1.tre##`it_tre'##c.q4_high_d_vshare `con', absorb(`fe') vce(`vce')
estadd local thfixed "YES"
local nogroup = e(dof_table)[1,1]
estadd local countynum `nogroup'

eststo: reghdfe initclaims_rate_regular tre 1.tre##`it_tre'##1.democ_com_id `con', absorb(`fe') vce(`vce')
estadd local thfixed "YES"
local nogroup = e(dof_table)[1,1]
estadd local countynum `nogroup'
	
#delimit ;

esttab  _all using "`filename'", r rename( 1.tre#1.`it_tre'#c.q4_high_d_vshare 
"After Stay at Home * High BAIT * Demoncratic"  1.tre#1.`it_tre'#1.democ_com_id "After Stay at Home * High BAIT * Demoncratic" 1.tre#c.q4_high_d_vshare "After Stay at Home * Demoncratic" 1.tre#1.democ_com_id "After Stay at Home * Demoncratic"  1.tre#1.`it_tre'  "After Stay at Home * High BAIT" ) 
		keep(tre "After Stay at Home * High BAIT * Demoncratic" "After Stay at Home * Demoncratic" "After Stay at Home * High BAIT"  `con')
		order(tre "After Stay at Home * High BAIT * Demoncratic" "After Stay at Home * Demoncratic" "After Stay at Home * High BAIT"    `con')
		label stat(r2 N countynum thfixed,
		fmt( %9.3f %9.0g %9.0g) labels( R-squared Observations "No. Counties" "County & Week FE"))
		 b(3) nogap onecell 
		 	interaction("*")
		nonotes addnote("`clusternote'" "`starnote'")
		starlevels( `starlevel') se ;
	
#delimit cr;

"After Stay at Home * `it_lab' * Occupation"
								"After Stay at Home * Occupation"
									 1.tre#c.itbudget`i' `con'

----------
		local threeinterlist `threeinterlist' 1.tre#c.itbudget`i'#c.skill_oc`j' "After Stay at Home * `it_lab' * Occupation"
		local interlist `interlist' 1.tre#c.skill_oc`j' "After Stay at Home * Occupation"

 county q4_high_d_vshare q2_high_d_vshare democ_com_id
 




---------

if $heter_industry == 1 {

*rename (agriculture construction manufacturing wholesale retail transportation information insurance) industry_emp#, addnumber
est clear

forvalues i  = 1 / 5 {
  
  local it_lab: variable label itbudget`i'

	forvalues j = 1 / 8 {
	
		eststo it`i'_ind`j': reghdfe initclaims_rate_regular tre tre##c.itbudget`i'##c.industry_emp`j' `con' , absorb(`fe') vce(`vce')
		estadd local thfixed "YES"
		local nogroup = e(dof_table)[1,1]
		estadd local countynum `nogroup'
		
		
		local threeinterlist `threeinterlist' 1.tre#c.itbudget`i'#c.industry_emp`j' "After Stay at Home * `it_lab' * Industry"
		local interlist `interlist' 1.tre#c.industry_emp`j' "After Stay at Home * Industry"
	
	}
}

	
	
coefplot (it1*), bylabel(Hardware) || (it2*), bylabel(PC) || (it3*), bylabel(Server) || (it4*), bylabel(Terminal) || (it5*), bylabel(Printer) ||, keep( 1.tre#*c.itbudget*#c.industry_emp* ) xline(0) rename(1.tre#c.itbudget[1-9]#c.industry_emp1 = "Agriculture" 1.tre#c.itbudget[1-9]#c.industry_emp2 = "Construction"  1.tre#c.itbudget[1-9]#c.industry_emp3 = "Manufacture"  1.tre#c.itbudget[1-9]#c.industry_emp4 = "Wholesale"  1.tre#c.itbudget[1-9]#c.industry_emp5 = "Retail"  1.tre#c.itbudget[1-9]#c.industry_emp6 = "Transportation"  1.tre#c.itbudget[1-9]#c.industry_emp7 = "Service"  1.tre#c.itbudget[1-9]#c.industry_emp8 = "Insurance", regex )
             
est clear

forvalues i  = 6 / 10 {
  
  local it_lab: variable label itbudget`i'

	forvalues j = 1 / 8 {
	
		eststo it`i'_ind`j': reghdfe initclaims_rate_regular tre tre##c.itbudget`i'##c.industry_emp`j' `con' , absorb(`fe') vce(`vce')
		estadd local thfixed "YES"
		local nogroup = e(dof_table)[1,1]
		estadd local countynum `nogroup'
		
		
		local threeinterlist `threeinterlist' 1.tre#c.itbudget`i'#c.industry_emp`j' "After Stay at Home * `it_lab' * Industry"
		local interlist `interlist' 1.tre#c.industry_emp`j' "After Stay at Home * Industry"
	
	}
}

	
	
coefplot (it6*), bylabel("Other Hardware") || (it7*), bylabel(Storage) || (it8*), bylabel(Communication) || (it9*), bylabel(Software) || (it10*), bylabel(Service)|| , keep( 1.tre#*c.itbudget*#c.industry_emp* ) xline(0) rename(1.tre#c.itbudget([1-9]|10)#c.industry_emp1 = "Agriculture" 1.tre#c.itbudget([1-9]|10)#c.industry_emp2 = "Construction"  1.tre#c.itbudget([1-9]|10)#c.industry_emp3 = "Manufacture"  1.tre#c.itbudget([1-9]|10)#c.industry_emp4 = "Wholesale"  1.tre#c.itbudget([1-9]|10)#c.industry_emp5 = "Retail"  1.tre#c.itbudget([1-9]|10)#c.industry_emp6 = "Transportation"  1.tre#c.itbudget([1-9]|10)#c.industry_emp7 = "Service"  1.tre#c.itbudget([1-9]|10)#c.industry_emp8 = "Insurance", regex )
             
est clear


}



forvalues i  = 1 / 10 {
 
 
    local it_lab: variable label itbudget`i'


	forvalues j = 1 / 3 {
	
		eststo it`i'_oc`j' :reghdfe initclaims_rate_regular tre tre##c.itbudget`i'##c.skill_oc`j' `con' , absorb(`fe') vce(`vce')
		estadd local thfixed "YES"
		local nogroup = e(dof_table)[1,1]
		estadd local countynum `nogroup'
		
		
		local threeinterlist `threeinterlist' 1.tre#c.itbudget`i'#c.skill_oc`j' "After Stay at Home * `it_lab' * Occupation"
		local interlist `interlist' 1.tre#c.skill_oc`j' "After Stay at Home * Occupation"
	
	}
}
	
	
coefplot (it1_*), bylabel("Hardware") || (it2*), bylabel(Storage) || (it3*), bylabel(Communication) ||  (it4*), bylabel(Terminal) || (it5*), bylabel(Printer) ||  (it6*), bylabel("Other Hardware") || (it7*), bylabel(Storage) || (it8*), bylabel(Communication) || (it9*), bylabel(Software) || (it10*), bylabel(Service)|| , keep( 1.tre#*c.itbudget*#c.skill_oc* ) xline(0) rename(1.tre#c.itbudget([1-9]|10)#c.skill_oc1 = "Low Skill" 1.tre#c.itbudget([1-9]|10)#c.skill_oc2 = "Midlle skill"  1.tre#c.itbudget([1-9]|10)#c.skill_oc3 = "High skill", regex )	
	

             
est clear


**# Six US regions
* New england
g geo_ne = (inlist(state, "CT", "ME", "MA", "NH", "RI", "VT"))
*Mid-Atlantic region
g geo_ma = (inlist(state, "DE", "MD", "NJ", "NY", "PA") )
* South region
g geo_sh = (inlist(state, "AL", "AR", "FL", "GA", "KY", "LA"))
replace geo_sh = (inlist(state, "MS","NC", "SC", "TN", "VA", "WV")) if geo_sh == 0
*Midwest
g geo_mw = (inlist(state, "IL", "IN", "IA", "KS", "MI", "MN","MO"))
replace geo_mw = (inlist(state,  "NE", "ND" ,"OH", "SD","WI" )) if geo_mw == 0
*South West
g geo_sw = (inlist(state, "AZ", "NM", "OK", "TX"))
* American West
g geo_aw = (inlist(state, "AK", "CO", "CA", "HI", "ID" ,"MT"))
replace geo_aw = (inlist(state,  "NV", "OR", "UT", "WA", "WY" )) if geo_aw == 0




local filename "result/report_region_analyses.rtf"

local geo geo_ne geo_ma geo_sh geo_mw geo_sw geo_aw

est clear

 foreach g of local geo{
* Analyses
eststo analysis_`g' : reghdfe initclaims_rate_regular tre tre##`it_tre' `con' if `g' == 1, absorb(`fe') vce(`vce')
estadd local thfixed "YES"
local nogroup = e(dof_table)[1,1]
estadd local countynum `nogroup'
 }

#delimit;
esttab  _all using "`filename'", a ckeep(tre 1.tre#1.`it_tre'    `con')
		order(tre 1.tre#1.`it_tre' `con' )	
		title(BAIT)
		label stat(r2 N countynum thfixed,
		fmt( %9.3f %9.0g %9.0g) labels( R-squared Observations "No. Counties" "Week & County FE"))
		 b(3) nogap onecell 
		  interaction("*")
		mtitles("New England" "Mid-Atlantic" "South" "Midwest" "South West" "American West")
		nonotes addnote("`clusternote'" "`starnote'")
		starlevels( `starlevel') se ;
	
#delimit cr;

est clear






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

	
	
**# Exclude counties at which many public firms loacte


local filename "result/exclude_public_firms20230616.rtf"
local starlevel "* 0.10 ** 0.05 *** 0.01"
local starnote "*** p<0.01, ** p<0.05, * p<0.1"
local con "avg_new_death_rate avg_new_case_rate avg_home_prop"
local it_tre q4_high_it_median
local fe county week
local vce rob
local clusternote "Notes: Robust standard errors are reported in parentheses." 
*local countynum N_clust
local df "e(df_a_initial)"


eststo: reghdfe initclaims_rate_regular tre  tre##`it_tre'  `con' if nopubfirm_qtl!=4 , absorb(`fe') vce(`vce')
	estadd local thfixed "YES"
	local nogroup = e(dof_table)[1,1]
	estadd local countynum `nogroup'
		

eststo: reghdfe initclaims_rate_regular tre  tre##`it_tre'  `con' if sum_qtl!=4 , absorb(`fe') vce(`vce')
	estadd local thfixed "YES"
	local nogroup = e(dof_table)[1,1]
	estadd local countynum `nogroup'
		

	#delimit ;
esttab  _all using "`filename'", replace keep(tre 1.tre#1.`it_tre' `con')
		order(tre 1.tre#1.`it_tre'   `con')
		interaction("*")
		title({\b Table 2. Main Effect})
		mtitles("Exclude counties of a high number of public firms" "Exclude counties of high total assets of public firms")
		label stat( r2 N countynum thfixed,
		fmt( %9.3f %9.0g %9.0g ) labels( R-squared Observations "No. Counties" "County & Week FE"))
		 b(3) nogap onecell 
		nonotes addnote("`clusternote'" "`starnote'")
		nobaselevels 
		starlevels( `starlevel') se ;
	
#delimit cr;
est clear





**# strigency index


* process data



import excel "C:\Users\Leting\Documents\2.Covid_IT_Employment\1.Data\1.raw_data\stringency_index_use.xlsx", sheet("stringency_index (2)") firstrow
drop country_code country_name
reshape long index, i( region_code region_name jurisdiction ) j(date, string)
sort region_code date index
gen date2 = date(date, "DMY")
g week = week(date2 )
g state = substr(region_code, 4,2)
g year = year(date2)
drop if year == 2021
bys region_name week: egen index_weekly = mean( index )
 
 frame change default
frlink m:1 state week, frame(stringency) generate(link1)
frget index_weekly  =  index_weekly, from(link1)
 
 
 
 * analyses
local filename "result/stringency_analysis.rtf"
local starlevel "* 0.10 ** 0.05 *** 0.01"
local starnote "*** p<0.01, ** p<0.05, * p<0.1"
local con "avg_new_death_rate avg_new_case_rate avg_home_prop"
local it_tre q4_high_it_median
local fe county week
local vce rob
local clusternote "Notes: Robust standard errors are reported in parentheses." 
*local countynum N_clust
local df "e(df_a_initial)"

eststo: reghdfe initclaims_rate_regular tre  tre##`it_tre'##c.index_weekly  `con' , absorb(`fe') vce(`vce')
eststo: reghdfe initclaims_rate_regular `it_tre'##c.index_weekly  `con' , absorb(`fe') vce(`vce')

#delimit ;
esttab  _all using "`filename'", r keep(tre index_weekly  1.tre#1.`it_tre'#c.index_weekly  1.tre#1.`it_tre' 1.`it_tre'#c.index_weekly )
		order(tre index_weekly  1.tre#1.`it_tre'#c.index_weekly  1.tre#1.`it_tre' 1.`it_tre'#c.index_weekl)
		interaction("*")
		title({\b Income})
		label stat( r2 N countynum thfixed,
		fmt( %9.3f %9.0g %9.0g ) labels( R-squared Observations "No. Counties" "County & Month FE"))
		 b(3) nogap onecell 
		nobaselevels 
		starlevels( `starlevel') se ;
	
#delimit cr;
est clear


**# control for median house income & revenue

local it_tre q4_high_it_median
local fe county month
local filename "C:/Users/Leting/Documents/2.Covid_IT_Employment/Stata/result/income&revenue_20230621.rtf"
local con "avg_new_death_rate avg_new_case_rate avg_home_prop"

eststo: reghdfe initclaims_rate_regular tre  tre##`it_tre' tre##c.ln_income   `con' , absorb(`fe') vce(`vce')
estadd local thfixed "YES"
local nogroup = e(dof_table)[1,1]
estadd local countynum `nogroup'


eststo: reghdfe initclaims_rate_regular tre tre##`it_tre' tre##c.reven_median `con' , absorb(`fe') vce(`vce')
estadd local thfixed "YES"
local nogroup = e(dof_table)[1,1]
estadd local countynum `nogroup'

#delimit ;
esttab  _all using "`filename'", r keep(tre  1.tre#1.`it_tre' 1.tre#c.ln_income 1.tre#c.reven_median  `con')
		order(tre  1.tre#1.`it_tre' 1.tre#c.ln_income 1.tre#c.reven_median  `con')
		interaction("*")
		title({\b Income & Revenue})
		label stat( r2 N countynum thfixed,
		fmt( %9.3f %9.0g %9.0g ) labels( R-squared Observations "No. Counties" "County & Month FE"))
		 b(3) nogap onecell 
		nobaselevels 
		starlevels( `starlevel') se ;
	
#delimit cr;
est clear
 
 
 **# Moderating role of variance
 
 
 labvars emple_var reven_var it_budget_var  "Var(Employment)" "Var(Revenue)" "Var(IT Budget)"
 
eststo: reghdfe initclaims_rate_regular tre tre##`it_tre'##c.emple_var `con' , absorb(`fe') vce(`vce')
estadd local thfixed "YES"
local nogroup = e(dof_table)[1,1]
estadd local countynum `nogroup'

eststo: reghdfe initclaims_rate_regular tre tre##`it_tre'##c.reven_var `con' , absorb(`fe') vce(`vce')
estadd local thfixed "YES"
local nogroup = e(dof_table)[1,1]
estadd local countynum `nogroup'

eststo: reghdfe initclaims_rate_regular tre tre##`it_tre'##c.it_budget_var `con' , absorb(`fe') vce(`vce')
estadd local thfixed "YES"
local nogroup = e(dof_table)[1,1]
estadd local countynum `nogroup'



local threeinterlist `threeinterlist' 1.tre#1.`it_tre'`i'#c.emple_var "After Stay at Home * HighRBIIT * Variance"  1.tre#1.`it_tre'`i'#c.reven_var "After Stay at Home * HighRBIIT * Variance"  1.tre#1.`it_tre'`i'#c.it_budget_var "After Stay at Home * HighRBIIT * Variance"
local interlist `interlist' 1.tre#c.emple_var "After Stay at Home * Variance"  1.tre#c.reven_var "After Stay at Home * Variance"  1.tre#c.it_budget_var "After Stay at Home * Variance"


#delimit ;
esttab  _all using "`filename'", r keep(tre  1.tre#1.`it_tre' "After Stay at Home * HighRBIIT * Variance" "After Stay at Home * Variance"  )
		order(tre  1.tre#1.`it_tre' "After Stay at Home * HighRBIIT * Variance" "After Stay at Home * Variance"  )
		interaction("*")
		title({\b Variance})
		label stat( r2 N countynum thfixed,
		fmt( %9.3f %9.0g %9.0g ) labels( R-squared Observations "No. Counties" "County & Month FE"))
		 b(3) nogap onecell 
		nobaselevels 
		starlevels( `starlevel') se ;
	
#delimit cr;
est clear
 

**# Monthly analyses


frame copy default countymonth
frame change countymonth
preserve
bys county month: egen tre_month = max( tre )
collapse tre_month initclaims_rate_regular avg_new_death_rate avg_new_case_rate avg_home_prop q4_high_it_median , by(county month)
xtset county month

labvars  tre_month q4_high_it_median initclaims_rate_regular  avg_new_death_rate avg_new_case_rate avg_home_prop "After Stay at Home" "HighBAIT"  "Unemployment Rate"  "COVID Death Rate" "COVID New Case Rate" "Stay at Home Index"


local it_tre q4_high_it_median
local fe county month
local filename "C:/Users/Leting/Documents/2.Covid_IT_Employment/Stata/result/monthly_anlaysis20230610.rtf"

local starlevel "* 0.10 ** 0.05 *** 0.01"
local starnote "*** p<0.01, ** p<0.05, * p<0.1"
local con "avg_new_death_rate avg_new_case_rate avg_home_prop"
local it_tre q4_high_it_median
local vce rob
local clusternote "Notes: Robust standard errors are reported in parentheses." 
*local countynum N_clust
local df "e(df_a_initial)"


eststo: reghdfe initclaims_rate_regular `it_tre'##tre_month `con' , absorb(`fe') vce(rob)
estadd local thfixed "YES"
local nogroup = e(dof_table)[1,1]
estadd local countynum `nogroup'


#delimit ;
esttab  _all using "`filename'", a keep(tre  1.`it_tre'#1.tre_month `con')
		order(tre  1.`it_tre'#1.tre_month  `con')
		interaction("*")
		title({\b Monthly Effect})
		label stat( r2 N countynum thfixed,
		fmt( %9.3f %9.0g %9.0g ) labels( R-squared Observations "No. Counties" "County & Month FE"))
		 b(3) nogap onecell 
		nobaselevels 
		starlevels( `starlevel') se ;
	
#delimit cr;
est clear

*		nonotes addnote("`clusternote'" "`starnote'")

**# normalized IT budget

local it_tre q4_high_it_median
local fe county month
local filename "C:/Users/Leting/Documents/2.Covid_IT_Employment/Stata/result/normalizedIT20230622.rtf"

local starlevel "* 0.10 ** 0.05 *** 0.01"
local starnote "*** p<0.01, ** p<0.05, * p<0.1"
local con "avg_new_death_rate avg_new_case_rate avg_home_prop"
local it_tre q4_high_it_median
local vce rob
local clusternote "Notes: Robust standard errors are reported in parentheses." 
*local countynum N_clust
local df "e(df_a_initial)"

labvars ln_it_per_site  ln_it_per_pop "ln(RBIT per Site)" "ln(RBIT per capita)"

eststo:reghdfe initclaims_rate_regular tre tre##c.ln_it_per_site `con' , absorb(`fe') vce(`vce')
estadd local thfixed "YES"
local nogroup = e(dof_table)[1,1]
estadd local countynum `nogroup'



eststo:reghdfe initclaims_rate_regular tre tre##c.ln_it_per_pop `con' , absorb(`fe') vce(`vce')
estadd local thfixed "YES"
local nogroup = e(dof_table)[1,1]
estadd local countynum `nogroup'

#delimit ;
esttab  _all using "`filename'", a keep(tre  1.tre#c.ln_it_per_site  1.tre#c.ln_it_per_pop   `con')
		order(tre  1.tre#c.ln_it_per_site  1.tre#c.ln_it_per_pop   `con')
		interaction("*")
		title({\b Normalized IT })
		label stat( r2 N countynum thfixed,
		fmt( %9.3f %9.0g %9.0g ) labels( R-squared Observations "No. Counties" "County & Month FE"))
		 b(3) nogap onecell 
		nobaselevels 
		starlevels( `starlevel') se ;
	
#delimit cr;
est clear



**# Incoporate 2021 data

use "C:\Users\Leting\Documents\2.Covid_IT_Employment\1.Data\3.output_data\county_2021.dta" 
drop day_endofweek
drop week
rename week_use week
merge 1:1 county  week using "C:\Users\Leting\Documents\2.Covid_IT_Employment\1.Data\3.output_data\county_month_panel_april_2024_additional.dta"
order week, a(county)
sort county  q4_high_it_median
bys county: replace q4_high_it_median =  q4_high_it_median[1]
sort county week
g tre_2021 = tre
bys county: replace tre_2021 = tre_2021[_n-1] if tre_2021==.
local it_tre q4_high_it_median
local fe county week
local vce rob
reghdfe initclaims_rate_regular tre_2021 tre_2021##q4_high_it_median  , absorb(`fe') vce(`vce')
reghdfe initclaims_rate_regular tre_2021 tre_2021##q4_high_it_median avg_new_death_rate avg_new_case_rate , absorb(`fe') vce(`vce')
reghdfe initclaims_rate_regular tre_2021 tre_2021##q4_high_it_median avg_new_death_rate avg_new_case_rate if week<70 , absorb(`fe') vce(`vce')
reghdfe initclaims_rate_regular tre_2021 tre_2021##q4_high_it_median avg_new_death_rate  if week<70 , absorb(`fe') vce(`vce')
reghdfe initclaims_rate_regular tre_2021 tre_2021##q4_high_it_median avg_new_death_rate  , absorb(`fe') vce(`vce')
reghdfe initclaims_rate_regular tre_2021 tre_2021##q4_high_it_median avg_new_death_rate if week<70 , absorb(`fe') vce(`vce')
reghdfe initclaims_rate_regular tre_2021 tre_2021##q4_high_it_median if week<60 , absorb(`fe') vce(`vce')





