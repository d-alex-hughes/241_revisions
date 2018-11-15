clear
set more off
capture log close
set logtype text


log using stata\\logs\\Incentives_JPE_Figure_5.txt, replace
*Figure 4_nts: Teacher Fixed Effects
**Figure regresses Teacher Fixed Effects on percentile ranking of Teacher FE using nts scores

use data\dta\Incentives_JPE_analysis_starter_file.dta, clear
tempfile test_score
order apfschoolcode, first
order hplstudentkey, first
order sub, first
order hplteacherkey_y1, last
keep  apfschoolcode  school_treatment hplstudentkey hplteacherkey_y2 y0_nts y1_nts_level_mean y2_nts_level_mean hplteacherkey_y1
*one observation per student
collapse apfschoolcode - hplteacherkey_y1 , by (hplstudentkey)
save "`test_score'"

tempfile teacher2
tempfile teacher_merge
tempfile year2

local it = 1000

**** unique teachers in second year****
keep if   school_treatment == 1 |   school_treatment == 4 |   school_treatment == 5
*deletes observations where there is no observation set
qui drop if y2_nts_level_mean == . | y1_nts_level_mean == . 
contract hplteacherkey_y2
sort hplteacherkey_y2
save "`teacher2'"

****unique teachers in first year****
use "`test_score'"
qui keep if  school_treatment == 1 |  school_treatment == 4 |  school_treatment == 5
*deletes observations where there is no observation set
qui drop if y1_nts_level_mean == . | y0_nts == . 
contract hplteacherkey_y1
rename hplteacherkey_y1 hplteacherkey_y2
sort hplteacherkey_y2

****unique teachers who taught in both first and second year****
*_merge 1: only in hplteacherkey_y1, if 2: only in hplteacherkey_y2, if 3: in both
merge hplteacherkey_y2 using "`teacher2'"
sort hplteacherkey_y2
drop if hplteacherkey_y2 == .
keep if _merge == 3
rename hplteacherkey_y2 hplteacherkey
sort hplteacherkey
drop _merge _freq

*list of teachers that have taught both years
save "`teacher_merge'"

use "`test_score'"
keep  apfschoolcode  school_treatment hplstudentkey hplteacherkey_y2 y2_nts_level_mean y1_nts_level_mean  
rename hplteacherkey_y2 hplteacherkey
merge m:1 hplteacherkey using "`teacher_merge'"
keep if _merge == 3
rename y2_nts_level_mean nts_end
rename y1_nts_level_mean nts_lag

save "`year2'"

use "`test_score'"
keep  apfschoolcode  school_treatment hplstudentkey hplteacherkey_y1 y1_nts_level_mean y0_nts
rename hplteacherkey_y1 hplteacherkey
merge m:1 hplteacherkey using "`teacher_merge'"
keep if _merge == 3
rename y1_nts_level_mean nts_end
rename y0_nts nts_lag
append using "`year2'", gen(test_year)
label define year2 0 "y1 on y0" 1 "y2 on y1"
label values test_year year2
*testyear == 0: observation point is y1 and y0; testyear == 1: observation point is y2 and y1

*creates treatment and control dummy variable
	qui gen ince = 0 if  school_treatment == 1
	qui replace ince = 1 if  school_treatment == 4 |  school_treatment == 5

*fixed effects regression
qui tab hplteacherkey, gen(teacher_fe)


sort hplstudentkey test_year
set seed 1234567890

*******************************************************************************
*final dataset with school_code, treatment_code, teacher_id, test_end, test_lag, teacher_fe indicator variables: filled in zeros for lag scores (811)
save data\dta\Figure_5_nts.dta, replace
*******************************************************************************

******************************Bootstrapped Confidence Interval***************************************************
set matsize 2000

qui egen kernel_range = fill(.01(.01)1)
qui replace kernel_range = . if kernel_range>1
mkmat kernel_range if kernel_range != .
matrix diff = kernel_range

forvalues i = 1(1)`it'{
	
	***sample of the control school teachers, clustering at school level
	use data\dta\Figure_5_nts.dta, clear
	bsample, strata(ince) cluster(apfschoolcode)
	*estimating teacher value add
	regress nts_end nts_lag teacher_fe* , noconst
	
	qui gen beta_fe = .

	forvalues i = 1(1)811{
		qui replace beta_fe = _b[teacher_fe`i'] if teacher_fe`i' == 1
	}	

	*teachers omitted due to multicollinearity
	replace beta_fe = . if beta_fe == 0

	*creates a percentile for Teacher FE
	bysort ince: egen rank = rank(beta_fe), unique
	bysort ince: egen max_rank = max(rank)
	bysort ince: gen percentile = rank/max_rank 
	
	*kernel smoothing regression
	qui egen kernel_range = fill(.01(.01)1)
	qui replace kernel_range = . if kernel_range>1
	lpoly beta_fe percentile if ince == 0 , gen(xcon_b ycon_b) at(kernel_range) nograph
	lpoly beta_fe percentile if ince == 1 , gen(xtre_b ytre_b) at(kernel_range) nograph
	
	mkmat ycon_b if ycon_b !=.
	mkmat ytre_b if ytre_b !=.
	matrix diff = diff, ytre_b-ycon_b
}	


matrix diff = diff'

*each variable is a percentile that is being estimated (can sort by column to get 2.5th and 97.5th confidence interval)
svmat diff
keep diff*

*save data\dta\Figure_5_nts_diff_iterations_nts.dta, replace

matrix conf_int = J(100, 2, 100)
qui drop if _n == 1
*sort each column and save its 25th and 975th place in a matrix
forvalues i = 1(1)100{
	sort diff`i'
	matrix conf_int[`i', 1] = diff`i'[25]
	matrix conf_int[`i', 2] = diff`i'[975]
	
}


*********************************Graphs for control, treatment, difference using true sample data**********************

use data\dta\Figure_5_nts.dta, clear
regress nts_end nts_lag teacher_fe* , noconst

qui gen beta_fe = .

forvalues i = 1(1)811{
	qui replace beta_fe = _b[teacher_fe`i'] if teacher_fe`i' == 1
}	

*teachers omitted due to multicollinearity
replace beta_fe = . if beta_fe == 0

*creates a percentile for Teacher FE
	bysort ince: egen rank = rank(beta_fe), unique
	bysort ince: egen max_rank = max(rank)
	bysort ince: gen percentile = rank/max_rank 

egen kernel_range = fill(0(.01)1)
qui replace kernel_range = . if kernel_range>1

lpoly beta_fe percentile if ince == 0 , gen(xcon_b ycon_b) at (kernel_range) nograph
lpoly beta_fe percentile if ince == 1 , gen(xtre_b ytre_b) at (kernel_range) nograph

qui gen diff =  ytre_b - ycon_b

svmat conf_int

graph twoway (line ycon_b xcon_b, lcolor (blue) lpattern("--.....") legend(lab(1 "Control Teachers")))(line ytre_b xtre_b, lcolor(red) lpattern(longdash) legend(lab(2 "Treatment Teachers")))(line conf_int1 xcon_b, lcolor(black) lpattern(shortdash) legend(lab(3 "95% Confidence Band"))) (line diff xcon_b, lcolor(black) lpattern(solid) legend(lab(4 "Difference"))) (line conf_int2 xcon_b, lcolor(black) lpattern(shortdash) legend(lab(5 " "))), yline(0, lcolor(gs10)) xtitle(Percentile of Teacher Fixed Effect) ytitle(Teacher Fixed Effect) legend(order(1 2 3 4)) saving(Figure_5_nts, replace)

save data\dta\Figure_5_nts.dta, replace

log close


