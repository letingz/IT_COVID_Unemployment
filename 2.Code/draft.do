local starlevel "* 0.10 ** 0.05 *** 0.01"
local starnote "*** p<0.01, ** p<0.05, * p<0.1"
local con "avg_new_death_rate avg_new_case_rate avg_home_prop"
local it_tre q4_high_it_median
local fe county week
local vce rob
local clusternote "Notes: Robust standard errors are reported in parentheses." 
*local countynum N_clust
local df "e(df_a_initial)"

local filename report20230515exclude_pub.rtf

local it_group "app_per_median enterp_per_median cloud_per_median groupware_per_median security_per_median network_per_median"
local industry_group "agriculture construction manufacturing wholesale retail transportation information insurance"
local occupation_group "lowskilloc midskilloc highskilloc"


local keepvar 1.tre 1.tre#1.`it_tre' `con'
local subtitle "Number of public firms" "Total assests of public firms"

est clear

eststo: reghdfe initclaims_rate_regular tre  tre##`it_tre'  `con' if nopubfirm_qtl!=4 , absorb(`fe') vce(`vce')
estadd local thfixed "YES"
local nogroup = e(dof_table)[1,1]
estadd local countynum `nogroup'

eststo: reghdfe initclaims_rate_regular tre  tre##`it_tre'  `con' if sum_qtl!=4 , absorb(`fe') vce(`vce') 
estadd local thfixed "YES"
local nogroup = e(dof_table)[1,1] 
estadd local countynum `nogroup' 

#delimit;
esttab  _all using "`filename'", r keep(`keepvar') 
		order(`keepvar' )		
		title("Exclude counties of a higher number of public firms")
		label stat(r2 N countynum thfixed,
		fmt( %9.3f %9.0g %9.0g) labels( R-squared Observations "No. Counties" "Week & County FE"))
		 b(3) nogap onecell 
		  interaction("*")
		mtitles(`subtitle')
		nonotes addnote("`clusternote'" "`starnote'")
		starlevels( `starlevel') se ;
	
#delimit cr;

est clear

