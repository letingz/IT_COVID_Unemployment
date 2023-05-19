local starlevel "* 0.10 ** 0.05 *** 0.01"
local starnote "*** p<0.01, ** p<0.05, * p<0.1"
local con "avg_new_death_rate avg_new_case_rate avg_home_prop"
local it_tre q4_high_it_median
local fe county week
local vce rob
local clusternote "Notes: Robust standard errors are reported in parentheses." 
*local countynum N_clust
local df "e(df_a_initial)"

local filename "report20230515.rtf"

local it_group "app_per_median enterp_per_median cloud_per_median groupware_per_median security_per_median network_per_median"
local industry_group "agriculture construction manufacturing wholesale retail transportation information insurance"
local occupation_group "lowskilloc midskilloc highskilloc"



**# Covid19 -  moderating effect
*local renamevar 1.tre#1.`it_tre'#c.avg_new_case_rate 1.tre#1.`it_tre'  "After Stay at Home * Hight BAIT * Covid Numbers" 1.tre#1.`it_tre'#c.avg_new_case_rate 1.tre#1.`it_tre' "" 
local keepvar tre 1.tre#1.`it_tre'#c.avg_new_case_rate  1.tre#1.`it_tre'#c.avg_new_death_rate   1.tre#c.avg_new_case_rate  1.tre#c.avg_new_death_rate 1.tre#1.`it_tre'  `con'
local title "COVID's moderating effect'"
local subtitle "" ""


eststo : reghdfe initclaims_rate_regular tre tre##`it_tre'##c.avg_new_case_rate `con', absorb(`fe') vce(`vce')
estadd local thfixed "YES"
local nogroup = e(dof_table)[1,1]
estadd local countynum `nogroup'


eststo : reghdfe initclaims_rate_regular tre tre##`it_tre'##c.avg_new_death_rate `con', absorb(`fe') vce(`vce')
estadd local thfixed "YES"
local nogroup = e(dof_table)[1,1]
estadd local countynum `nogroup'


#delimit;
esttab  _all using "`filename'", r 
		keep(`keepvar')
		order(`keepvar')	
		label stat(r2 N countynum thfixed,
		fmt( %9.3f %9.0g %9.0g) labels( R-squared Observations "No. Counties" "Week & County FE"))
		 b(3) nogap onecell 
		  interaction("*")
		 	title(BAIT) 
		mtitles(`subtitle')
		nonotes addnote("`clusternote'" "`starnote'")
		starlevels( `starlevel') se ;
	
#delimit cr;

est clear






**# Regional analyses
 

local starlevel "* 0.10 ** 0.05 *** 0.01"
local starnote "*** p<0.01, ** p<0.05, * p<0.1"
local con "avg_new_death_rate avg_new_case_rate avg_home_prop"
local it_tre q4_high_it_median
local fe county week
local vce rob
local clusternote "Notes: Robust standard errors are reported in parentheses." 
*local countynum N_clust
local df "e(df_a_initial)"

local filename "report20230515region.rtf"

local it_group "app_per_median enterp_per_median cloud_per_median groupware_per_median security_per_median network_per_median"
local industry_group "agriculture construction manufacturing wholesale retail transportation information insurance"
local occupation_group "lowskilloc midskilloc highskilloc"


est clear


 
local subtitle " "Mid-Atlantic" "South" "Midwest" "South West" "American West" "
local geo  geo_ma geo_sh geo_mw geo_sw geo_aw
est clear

*BAIT

local keepvar tre 1.tre#1.`it_tre'    `con'

 foreach g of local geo{
eststo : reghdfe initclaims_rate_regular tre tre##`it_tre' `con' if `g' == 1, absorb(`fe') vce(`vce')
estadd local thfixed "YES"
local nogroup = e(dof_table)[1,1]
estadd local countynum `nogroup'
 }

#delimit;
esttab  _all using "`filename'", r keep(`keepvar')
		order(`keepvar' )	
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

local keepvar tre 1.tre#*1.`it_tre'#c.skill_oc1  1.tre#1.`it_tre' 1.tre#c.skill_oc1 `con'

foreach g of local geo{
eststo analysis_`g' : reghdfe initclaims_rate_regular tre tre##`it_tre'##c.skill_oc1 `con' if `g' == 1, absorb(`fe') vce(`vce')
estadd local thfixed "YES"
local nogroup = e(dof_table)[1,1]
estadd local countynum `nogroup'

}

#delimit;
esttab  _all using "`filename'", a keep(`keepvar')
		order(`keepvar')
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

local keepvar tre 1.tre#1.`it_tre'#c.skill_oc2 1.tre#1.`it_tre'   1.tre#c.skill_oc2  `con'

foreach g of local geo{
eststo analysis_`g' : reghdfe initclaims_rate_regular tre tre##`it_tre'##c.skill_oc2 `con' if `g' == 1, absorb(`fe') vce(`vce')
estadd local thfixed "YES"
local nogroup = e(dof_table)[1,1]
estadd local countynum `nogroup'
}


#delimit;
esttab  _all using "`filename'", a keep(`keepvar')
		order(`keepvar')		
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

local keepvar tre 1.tre#*1.`it_tre'#c.skill_oc3  1.tre#1.`it_tre'  1.tre#c.skill_oc3 `con'

foreach g of local geo{
eststo analysis_`g' : reghdfe initclaims_rate_regular tre tre##`it_tre'##c.skill_oc3 `con' if `g' == 1, absorb(`fe') vce(`vce')
estadd local thfixed "YES"
local nogroup = e(dof_table)[1,1]
estadd local countynum `nogroup'
}


#delimit;
esttab  _all using "`filename'", a keep(`keepvar')
		order(`keepvar' )		
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















