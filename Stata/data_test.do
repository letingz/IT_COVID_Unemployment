
********************
*Title: COVID 19 and Unemployment - Graph & Test
*Author: Leting Zhang
*Date: 20210221
********************

************************
* Package: 
* ssc install subsetplot
*
*************************

**** Test parallel trend
* Reference
* https://www.statalist.org/forums/forum/general-stata-discussion/general/1514276-parallel-trends-assumption-in-difference-in-difference-estimation


use "C:\Users\Leting\Documents\Covid-Cyber-Unemploy\stata\county_panelnew.dta" 

/*indicators for the treated group and the control group */
bys county: egen home = max(aftersh) 

//  FITTED TRENDS COMPARISON
regress avg_initclaims_rate home##c.month
margins home, at(month = (1 (1) 3))
marginsplot, name(marginsplot, replace)


//  SUBSETPLOT METHOD (-ssc install subsetplot-, by Nick Cox)
subsetplot scatter avg_initclaims_rate month, by(home)
graph rename subsetplot, replace

//  PLOT OF GROUP MEANS OVER YEARS

collapse (mean) avg_initclaims_rate, by(month home )
reshape wide avg_initclaims_rate , i(month) j( home )
graph twoway connect avg_initclaims_rate* month, sort name(group_means, replace)


// Use its_emps_high as treatment
g its_emps_high = ( county_its_emps_prop>0.0029716 )

regress avg_initclaims_rate its_emps_high##c.month
margins its_emps_high , at(month = (1 (1) 3))
marginsplot, name(marginsplot, replace)


subsetplot scatter avg_initclaims_rate month, by( its_emps_high )
graph rename subsetplot, replace

collapse (mean) avg_initclaims_rate, by(month its_emps_high )
reshape wide avg_initclaims_rate , i(month) j( its_emps_high )
graph twoway connect avg_initclaims_rate* month, sort name(group_means, replace)

// Use home x its_emps_high as treatment
g home_its_emps_high = home* its_emps_high

regress avg_initclaims_rate home_its_emps_high##c.month
margins home_its_emps_high, at(month = (1 (1) 3))
marginsplot, name(marginsplot, replace)


subsetplot scatter avg_initclaims_rate month, by( home_its_emps_high )
graph rename subsetplot, replace



# powerful

collapse (mean) avg_initclaims_rate, by(month its_emps_high  home)
 g type = 0 if home == 0 & its_emps_high==0
replace type = 1 if home == 1 & its_emps_high==0
replace type = 2 if home == 0 & its_emps_high==1
replace type = 3 if home == 1 & its_emps_high==1

drop home its_emps_high
reshape wide avg_initclaims_rate , i(month) j( home )
graph twoway connect avg_initclaims_rate* month, sort name(group_means, replace)