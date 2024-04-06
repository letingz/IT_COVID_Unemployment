local filename "result/subgroup_20230621.rtf"


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

global subgroup 1
global lowskill 0
global heter_industry 0
global heter_occupation 0
global clean 0




**# The impact of subgroups of IT budget
est clear

if $subgroup == 1 {

// local it_sub_budget_log "ln_hw_bmedian ln_pc_bmedian ln_sv_bmedian ln_ter_bmedian ln_pr_bmedian ln_ohw_bmedian ln_sto_bmedian ln_comm_bmedian ln_sw_median ln_ser_median"
//
//
// rename (ln_hw_bmedian ln_pc_bmedian ln_sv_bmedian ln_ter_bmedian ln_pr_bmedian ln_ohw_bmedian ln_sto_bmedian ln_comm_bmedian ln_sw_median ln_ser_median) itbudget#, addnumber


//reference: https://stackoverflow.com/questions/35277846/how-to-batch-rename-variables-in-esttab


* Main effect
forvalues i = 1 / 10 {
	
	eststo: reghdfe initclaims_rate_regular tre tre##c.itbudget`i' `con', absorb(`fe') vce(`vce') 	
	local nogroup = e(dof_table)[1,1]
  	estadd local countynum `nogroup'
	local itlist `itlist' 1.tre#c.itbudget`i' "After Stay at Home * Sub It Budget"
	}



	#delimit ;


esttab  _all using "`filename'",r	 rename(`itlist')
						keep(tre "After Stay at Home * Sub It Budget" `con' )
		order(tre "After Stay at Home * Sub It Budget" `con')
		interaction("*")
		title({\b Table 2. Main Effect})
		mtitles("Hardware" "PC" "Sever"  "Terminal" "Printer" "Other Hardware" "Storage" "Communication Service" "Software" "IT related services")
	    b(3) nogap onecell 
		label stat( r2 N countynum thfixed,
		fmt( %9.3f %9.0g %9.0g ) labels( R-squared Observations "No. Counties" "County & Week FE"))
		starlevels( `starlevel') se ;
	
#delimit cr;
est clear 

* Low skill_oc

forvalues i = 1 / 10 {
	
	eststo: reghdfe initclaims_rate_regular tre tre##c.itbudget`i'##c.skill_oc1 `con', absorb(`fe') vce(`vce') 	
	local nogroup = e(dof_table)[1,1]
  	estadd local countynum `nogroup'
	
	
	local threeinterlist `threeinterlist' 1.tre#c.itbudget`i'#c.skill_oc1 "After Stay at Home * Sub IT budget * Low Skill"

    local interlist1 `interlist1' 1.tre#c.itbudget`i' "After Stay at Home * Sub IT budget"
	 
	local interlist2 `interlist2' 1.tre#c.skill_oc1  "After Stay at Home *  Low Skill"
	
	
	}


	#delimit ;


esttab  _all using "`filename'", append  rename(`threeinterlist' `interlist1' `interlist2')
						keep(tre "After Stay at Home * Sub IT budget * Low Skill" "After Stay at Home * Sub IT budget" "After Stay at Home *  Low Skill" `con' )
		order(tre "After Stay at Home * Sub IT budget * Low Skill" "After Stay at Home * Sub IT budget" "After Stay at Home *  Low Skill" `con')
		interaction("*")
		title({\b  Sub IT - Low Skill})
		mtitles("Hardware" "PC" "Sever"  "Terminal" "Printer" "Other Hardware" "Storage" "Communication Serivce" "Software" "IT related services")
	    b(3) nogap onecell 
		label stat( r2 N countynum thfixed,
		fmt( %9.3f %9.0g %9.0g ) labels( R-squared Observations "No. Counties" "County & Week FE"))
		starlevels( `starlevel') se ;
	
#delimit cr;
est clear 

forvalues i = 1 / 10 {
	
	eststo: reghdfe initclaims_rate_regular tre tre##c.itbudget`i'##c.skill_oc2 `con', absorb(`fe') vce(`vce') 	
	local nogroup = e(dof_table)[1,1]
  	estadd local countynum `nogroup'
	
	
	local threeinterlist `threeinterlist' 1.tre#c.itbudget`i'#c.skill_oc2 "After Stay at Home * Sub IT budget * Mid Skill"

    local interlist1 `interlist1' 1.tre#c.itbudget`i' "After Stay at Home * Sub IT budget"
	 
	local interlist2 `interlist2' 1.tre#c.skill_oc2  "After Stay at Home *  Mid Skill"
	
	
	}


	#delimit ;


esttab  _all using "`filename'", append  rename(`threeinterlist' `interlist1' `interlist2')
						keep(tre "After Stay at Home * Sub IT budget * Mid Skill" "After Stay at Home * Sub IT budget" "After Stay at Home *  Mid Skill" `con' )
		order(tre "After Stay at Home * Sub IT budget * Mid Skill" "After Stay at Home * Sub IT budget" "After Stay at Home *  Mid Skill" `con')
		interaction("*")
		title({\b  Sub IT - Mid Skill})
		mtitles("Hardware" "PC" "Sever"  "Terminal" "Printer" "Other Hardware" "Storage" "Communication Serivce" "Software" "IT related services")
	    b(3) nogap onecell 
		label stat( r2 N countynum thfixed,
		fmt( %9.3f %9.0g %9.0g ) labels( R-squared Observations "No. Counties" "County & Week FE"))
		starlevels( `starlevel') se ;
	
#delimit cr;
est clear 

forvalues i = 1 / 10 {
	
	eststo: reghdfe initclaims_rate_regular tre tre##c.itbudget`i'##c.skill_oc3 `con', absorb(`fe') vce(`vce') 	
	local nogroup = e(dof_table)[1,1]
  	estadd local countynum `nogroup'
	
	
	local threeinterlist `threeinterlist' 1.tre#c.itbudget`i'#c.skill_oc3 "After Stay at Home * Sub IT budget * High Skill"

    local interlist1 `interlist1' 1.tre#c.itbudget`i' "After Stay at Home * Sub IT budget"
	 
	local interlist2 `interlist2' 1.tre#c.skill_oc3  "After Stay at Home *  High Skill"
	
	
	}


	#delimit ;


esttab  _all using "`filename'", append  rename(`threeinterlist' `interlist1' `interlist2')
						keep(tre "After Stay at Home * Sub IT budget * High Skill" "After Stay at Home * Sub IT budget" "After Stay at Home *  High Skill" `con' )
		order(tre "After Stay at Home * Sub IT budget * High Skill" "After Stay at Home * Sub IT budget" "After Stay at Home *  High Skill" `con')
		interaction("*")
		title({\b  Sub IT - High Skill})
		mtitles("Hardware" "PC" "Sever"  "Terminal" "Printer" "Other Hardware" "Storage" "Communication Serivce" "Software" "IT related services")
	    b(3) nogap onecell 
		label stat( r2 N countynum thfixed,
		fmt( %9.3f %9.0g %9.0g ) labels( R-squared Observations "No. Counties" "County & Week FE"))
		starlevels( `starlevel') se ;
	
#delimit cr;
est clear 



}
