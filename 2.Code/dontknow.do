
local filename "result/variance_20230709.rtf"


local starlevel "* 0.10 ** 0.05 *** 0.01"
local starnote "*** p<0.01, ** p<0.05, * p<0.1"
local con "avg_new_death_rate avg_new_case_rate avg_home_prop"
local it_tre q4_high_it_median
local fe county week
local vce rob
local clusternote "Notes: Robust standard errors are reported in parentheses." 
*local countynum N_clust
local df "e(df_a_initial)"

 
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
 

 
local threeinterlist 1.tre#1.`it_tre'#c.emple_var "After Stay at Home * HighRBIIT * Variance"  1.tre#1.`it_tre'#c.reven_var "After Stay at Home * HighRBIIT * Variance"  1.tre#1.`it_tre'#c.it_budget_var "After Stay at Home * HighRBIIT * Variance"
local interlist  1.tre#c.emple_var "After Stay at Home * Variance"  1.tre#c.reven_var "After Stay at Home * Variance"  1.tre#c.it_budget_var "After Stay at Home * Variance"


#delimit ;
esttab  _all using "`filename'", r rename(`threeinterlist' `interlist')
		keep(tre  1.tre#1.`it_tre' "After Stay at Home * HighRBIIT * Variance" "After Stay at Home * Variance"  )
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