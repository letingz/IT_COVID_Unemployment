local filename "C:/Users/Leting/Documents/2.Covid_IT_Employment/Stata/result/202404145.rtf"


local starlevel "* 0.10 ** 0.05 *** 0.01"
local starnote "*** p<0.01, ** p<0.05, * p<0.1"
*local con "avg_new_death_rate avg_new_case_rate avg_home_prop"
local con "avg_new_death_rate avg_new_case_rate"

local it_tre q4_high_it_median
local fe county week
local vce rob
local clusternote "Notes: Robust standard errors are reported in parentheses." 
*local countynum N_clust
local df "e(df_a_initial)"

local it_group "app_per_median enterp_per_median cloud_per_median groupware_per_median security_per_median network_per_median"
local industry_group "agriculture construction manufacturing wholesale retail transportation information insurance"
local occupation_group "lowskilloc midskilloc highskilloc"


// eststo:reghdfe initclaims_rate_regular tre_2021 tre_2021##q4_high_it_median  if week<66 , absorb(`fe') vce(`vce')
// estadd local thfixed "YES"
// local nogroup = e(dof_table)[1,1]
// local noweek = e(dof_table)[2,1]
// estadd local countynum `nogroup'
// estadd local weeknum `noweek'
//
//
//
// eststo:reghdfe initclaims_rate_regular tre_2021 tre_2021##q4_high_it_median avg_new_death_rate avg_new_case_rate if week<66 , absorb(`fe') vce(`vce')
// estadd local thfixed "YES"
// local nogroup = e(dof_table)[1,1]
// local noweek = e(dof_table)[2,1]
// estadd local countynum `nogroup'
// estadd local weeknum `noweek'
//
//
//
//
//
//
// eststo:reghdfe initclaims_rate_regular tre_2021 tre_2021##q4_high_it_median avg_new_death_rate avg_new_case_rate if week<74 , absorb(`fe') vce(`vce')
// estadd local thfixed "YES"
// local nogroup = e(dof_table)[1,1]
// local noweek = e(dof_table)[2,1]
// estadd local countynum `nogroup'
// estadd local weeknum `noweek'
//
//
//
//
// #delimit ;
//
//
//
// esttab  _all using "`filename'", a keep(tre_2021 1.tre_2021#1.q4_high_it_median  `con')
// 		order(tre_2021 1.tre_2021#1.q4_high_it_median  `con')
// 		interaction("*")
// 		title({\b Table 2. Main Effect})
// 		mtitles("2021 March" "2021 March" "2021 May")
// 		label stat( r2 N countynum weeknum thfixed,
// 		fmt( %9.3f %9.0g %9.0g ) labels( R-squared Observations "No. Counties" "No.Week" "County & Week FE"))
// 		 b(3) nogap onecell 
// 		nonotes addnote("`clusternote'" "`starnote'")
// 		nobaselevels 
// 		starlevels( `starlevel') se ;
//	
// #delimit cr;
// est clear
//
//




eststo:reghdfe initclaims_rate_regular tre_2021 tre_2021##q4_high_it_median avg_new_case_rate if week<66 , absorb(`fe') vce(`vce')
estadd local thfixed "YES"
local nogroup = e(dof_table)[1,1]
local noweek = e(dof_table)[2,1]
estadd local countynum `nogroup'
estadd local weeknum `noweek'






eststo:reghdfe initclaims_rate_regular tre_2021 tre_2021##q4_high_it_median  avg_new_case_rate if week<74 , absorb(`fe') vce(`vce')
estadd local thfixed "YES"
local nogroup = e(dof_table)[1,1]
local noweek = e(dof_table)[2,1]
estadd local countynum `nogroup'
estadd local weeknum `noweek'




#delimit ;



esttab  _all using "`filename'", a keep(tre_2021 1.tre_2021#1.q4_high_it_median  `con')
		order(tre_2021 1.tre_2021#1.q4_high_it_median  `con')
		interaction("*")
		title({\b Table 2. Main Effect})
		mtitles("2021 March" "2021 March" "2021 May")
		label stat( r2 N countynum weeknum thfixed,
		fmt( %9.3f %9.0g %9.0g ) labels( R-squared Observations "No. Counties" "No.Week" "County & Week FE"))
		 b(3) nogap onecell 
		nonotes addnote("`clusternote'" "`starnote'")
		nobaselevels 
		starlevels( `starlevel') se ;
	
#delimit cr;
est clear