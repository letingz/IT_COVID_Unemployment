******* County population  ********
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
local subtitle " "Low Pop" "Medium Pop" "High Pop" "
local filename "result/county_pop_results.rtf"



**** data processing *******
* categorize county size quantile based on population


// xtile pop_qtl = population, nq(4)
// g pop1 = (pop_qtl == 1)
// g pop2 = (pop_qtl == 2 |pop_qtl == 3 )
// g pop3 = (pop_qtl == 4)


**** regression_q

local pop pop1 pop2 pop3
est clear

 foreach g of local pop{
eststo : reghdfe initclaims_rate_regular tre tre##`it_tre' `con' if `g' == 1, absorb(`fe') vce(`vce')
estadd local thfixed "YES"
local nogroup = e(dof_table)[1,1]
estadd local countynum `nogroup'
 }

#delimit;
esttab  _all using "`filename'", a keep(tre 1.tre#1.`it_tre'    `con')
		order(tre 1.tre#1.`it_tre' `con' )	
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

foreach g of local pop{
eststo analysis_`g' : reghdfe initclaims_rate_regular tre tre##`it_tre'##c.skill_oc1 `con' if `g' == 1, absorb(`fe') vce(`vce')
estadd local thfixed "YES"
local nogroup = e(dof_table)[1,1]
estadd local countynum `nogroup'

}

#delimit;
esttab  _all using "`filename'", a keep(tre 1.tre#*1.`it_tre'#c.skill_oc1  1.tre#1.`it_tre' `con')
		order(tre 1.tre#*1.`it_tre'#c.skill_oc1 1.tre#c.skill_oc1  1.tre#1.`it_tre' `con' )
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

foreach g of local pop{
eststo analysis_`g' : reghdfe initclaims_rate_regular tre tre##`it_tre'##c.skill_oc2 `con' if `g' == 1, absorb(`fe') vce(`vce')
estadd local thfixed "YES"
local nogroup = e(dof_table)[1,1]
estadd local countynum `nogroup'
}


#delimit;
esttab  _all using "`filename'", a keep(tre 1.tre#1.`it_tre'#c.skill_oc2 1.tre#c.skill_oc2   1.tre#1.`it_tre' `con')
		order(tre 1.tre#1.`it_tre'#c.skill_oc2 1.tre#c.skill_oc2   1.tre#1.`it_tre' `con' )		
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


* High skill - pop analyses

foreach g of local pop{
eststo analysis_`g' : reghdfe initclaims_rate_regular tre tre##`it_tre'##c.skill_oc3 `con' if `g' == 1, absorb(`fe') vce(`vce')
estadd local thfixed "YES"
local nogroup = e(dof_table)[1,1]
estadd local countynum `nogroup'
}


#delimit;
esttab  _all using "`filename'", a keep(tre 1.tre#*1.`it_tre'#c.skill_oc3  1.tre#c.skill_oc3  1.tre#1.`it_tre' `con')
		order(tre 1.tre#*1.`it_tre'#c.skill_oc3  1.tre#c.skill_oc3  1.tre#1.`it_tre' `con' )		
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







