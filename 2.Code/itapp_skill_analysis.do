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
local subtitle " "App Dev" "Ente" "Cloud" "Groupware PC" "Market" "Security"  "Network" "
local filename "result/ittype_skill_median_analyses_20230618.rtf"

*local geo geo_ne geo_ma geo_sh geo_mw geo_sw geo_aw
*local itapp app_per_median enterp_per_median cloud_per_median groupware_per_median market_per_median security_per_median network_per_median

local itapp app_median enterp_median cloud_median groupware_median market_median security_median network_median
est clear

 foreach g of local itapp{
eststo : reghdfe initclaims_rate_regular tre tre##c.`g' `con', absorb(`fe') vce(`vce')
estadd local thfixed "YES"
local nogroup = e(dof_table)[1,1]
estadd local countynum `nogroup'

local interlist `interlist' 1.tre#c.`g' "After Stay at Home * IT Applications"
 }

#delimit;
esttab  _all using "`filename'", r rename(`interlist')
 keep(tre "After Stay at Home * IT Applications"    `con')
		order(tre "After Stay at Home * IT Applications" `con' )	
		title(BAIT)
		label stat(r2 N countynum thfixed,
		fmt( %9.3f %9.0g %9.0g) labels( R-squared Observations "No. Counties" "Week & County FE"))
		 b(3) nogap onecell 
		  interaction("*")
		mtitles(`subtitle')
		nonotes addnote("`clusternote'" "`starnote'")
		starlevels( `starlevel') se ;
	
#delimit cr;

est clear





* Low skill - region analyses

foreach g of local itapp{
eststo `g' : reghdfe initclaims_rate_regular tre tre##c.`g'##c.skill_oc1 `con', absorb(`fe') vce(`vce')
estadd local thfixed "YES"
local nogroup = e(dof_table)[1,1]
estadd local countynum `nogroup'


local threeinterlist `threeinterlist' 1.tre#c.`g'#c.skill_oc1 "After Stay at Home * IT Application * Low Skill"

local interlist `interlist' 1.tre#c.`g' "After Stay at Home * IT Applications"

}

#delimit;
esttab  _all using "`filename'", a rename(`threeinterlist' `interlist')
		keep(tre "After Stay at Home * IT Application * Low Skill" "After Stay at Home * IT Applications"  `con')
		order(tre "After Stay at Home * IT Application * Low Skill" "After Stay at Home * IT Applications"  `con' )
		title("Low Skill")
		label stat(r2 N countynum thfixed,
		fmt( %9.3f %9.0g %9.0g) labels( R-squared Observations "No. Counties" "Week & County FE"))
		 b(3) nogap onecell 
		  interaction("*")
		mtitles(`subtitle')
		nonotes addnote("`clusternote'" "`starnote'")
		starlevels( `starlevel') se ;
	
#delimit cr;

est clear

* Medium skill - region analyses

foreach g of local itapp{
eststo `g' : reghdfe initclaims_rate_regular tre tre##c.`g'##c.skill_oc2 `con' , absorb(`fe') vce(`vce')
estadd local thfixed "YES"
local nogroup = e(dof_table)[1,1]
estadd local countynum `nogroup'


local threeinterlist `threeinterlist' 1.tre#c.`g'#c.skill_oc2 "After Stay at Home * IT Application * Medium Skill"

local interlist `interlist' 1.tre#c.`g' "After Stay at Home * IT Applications"

}


#delimit;
esttab  _all using "`filename'", a rename(`threeinterlist' `interlist') 
	keep(tre "After Stay at Home * IT Application * Medium Skill" "After Stay at Home * IT Applications" `con')
		order(tre "After Stay at Home * IT Application * Medium Skill" "After Stay at Home * IT Applications" `con' )		
		title("Medium Skill")
		label stat(r2 N countynum thfixed,
		fmt( %9.3f %9.0g %9.0g) labels( R-squared Observations "No. Counties" "Week & County FE"))
		 b(3) nogap onecell 
		  interaction("*")
		mtitles(`subtitle')
		nonotes addnote("`clusternote'" "`starnote'")
		starlevels( `starlevel') se ;
	
#delimit cr;

est clear


* High skill - region analyses

foreach g of local itapp{
eststo `g' : reghdfe initclaims_rate_regular tre tre##c.`g'##c.skill_oc3 `con', absorb(`fe') vce(`vce')
estadd local thfixed "YES"
local nogroup = e(dof_table)[1,1]
estadd local countynum `nogroup'

local threeinterlist `threeinterlist' 1.tre#c.`g'#c.skill_oc3 "After Stay at Home * IT Application * High Skill"

local interlist `interlist' 1.tre#c.`g' "After Stay at Home * IT Applications"

}


#delimit;
esttab  _all using "`filename'", a rename(`threeinterlist' `interlist') keep(tre  "After Stay at Home * IT Application * High Skill" "After Stay at Home * IT Applications"
`con')
		order(tre  "After Stay at Home * IT Application * High Skill" "After Stay at Home * IT Applications" `con' )		
		title("High Skill")
		label stat(r2 N countynum thfixed,
		fmt( %9.3f %9.0g %9.0g) labels( R-squared Observations "No. Counties" "Week & County FE"))
		 b(3) nogap onecell 
		  interaction("*")
		mtitles(`subtitle')
		nonotes addnote("`clusternote'" "`starnote'")
		starlevels( `starlevel') se ;
	
#delimit cr;

est clear







