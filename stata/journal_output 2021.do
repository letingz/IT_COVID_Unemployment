*** Title: COVID, IT Investment, and Unemployment
*** Author: Leting Zhang
*** Date: 202021



***********************
* Descriptive analyses*
***********************

local dep emp_combined emp_combined_inclow emp_combined_incmiddle emp_combined_inchigh avg_initclaims_rate avg_initclaims_count 
local indep aftersh ln_it_budget ln_sw_budget ln_hw_budget ln_security_sw_pres ln_reven ln_emple  
local control teleworkable_emp gps_away_from_home avg_new_death_rate avg_new_case_rate

global tables "result"
asdoc sum `dep' `indep' `control' , stat(mean sd min max) label dec(2) tzok save($tables\desc.doc)



