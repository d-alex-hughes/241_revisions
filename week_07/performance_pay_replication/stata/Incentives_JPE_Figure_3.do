

clear
set more off
capture log close
set logtype text
*cd c:\aprest\aprest
log using stata\\logs\\Incentives_JPE_Figure_3.txt, replace
**Figure regresses year 2 endline score on percentile of endline score using nts scores

use data\dta\Incentives_JPE_analysis_starter_file.dta, clear

set matsize 2000

*number of iterations
local it = 1000

keep  sub  school_treatment hplstudentkey apfschoolcode class_y1 class_y2  y2_nts_level_mean y1_nts_level_mean y0_nts  
*keep class_y1_2_int_y0_nts - class_y2_5_int_y0_nts (IRT vars) 
keep if  school_treatment == 1 |  school_treatment == 4 |  school_treatment == 5

*creates treatment and control dummy variable
	qui gen ince = 0 if  school_treatment == 1
	qui replace ince = 1 if  school_treatment == 4 |  school_treatment == 5

*one score per student per year (mean across subject)
order apfschoolcode, first
order  hplstudentkey, first
collapse apfschoolcode -  ince, by(hplstudentkey)
*Puts observations in order of treatment and then baseline scores
	qui sort ince y2_nts_level_mean


sort hplstudentkey 
set seed 1234567890
save data\dta\bootstrap_Figure_3.dta, replace


******************************Bootstrapped Confidence Interval***************************************************

qui egen kernel_range = fill(.01(.01)1)
qui replace kernel_range = . if kernel_range>1
mkmat kernel_range if kernel_range != .
matrix diff = kernel_range
matrix x = kernel_range


forvalues i = 1(1)`it'{
	
	***sample of the control schools, clustering at school level
	use data\dta\bootstrap_Figure_3.dta, clear
	*dropping observations with no schoolcode 
	drop if apfschoolcode == . 
	drop if y2_nts_level_mean == . 
	bsample, strata(ince) cluster(apfschoolcode)

	*creating percentile rankings
	bysort ince: egen rank = rank(y2_nts_level_mean), unique
	bysort ince: egen max_rank = max(rank)
	bysort ince: gen percentile = rank/max_rank 
	
	
	drop max_rank rank
	
	egen kernel_range = fill(.01(.01)1)
	qui replace kernel_range = . if kernel_range>1

	*regressing endline scores on percentile rankings
	lpoly y2_nts_level_mean percentile if ince == 0 , gen(xcon_b2 y2_con_b) at (kernel_range) nograph
	lpoly y2_nts_level_mean percentile if ince == 1 , gen(xtre_b2 y2_tre_b) at (kernel_range) nograph

	mkmat y2_tre_b if y2_tre_b != . 
	mkmat y2_con_b if y2_con_b != . 
	matrix diff = diff, y2_tre_b - y2_con_b
	
}	

matrix diff = diff'

*each variable is a percentile that is being estimated (can sort by column to get 2.5th and 97.5th confidence interval)
svmat diff
keep diff* 

matrix conf_int = J(100, 2, 100)
qui drop if _n == 1
*sort each column (percentile) and saving 25th and 975th place in a matrix
forvalues i = 1(1)100{
	sort diff`i'
	matrix conf_int[`i', 1] = diff`i'[25]
	matrix conf_int[`i', 2] = diff`i'[975]
	
}
*******************Graphs for control, treatment, and difference using actual data (BASELINE)*************************************
use data\dta\bootstrap_Figure_3.dta, clear
  
*y2 vs y0 graph: 
*creates a percentile variable for control students
	drop if y2_nts_level_mean == . 

	bysort ince: egen rank = rank(y2_nts_level_mean), unique
	bysort ince: egen max_rank = max(rank)
	bysort ince: gen percentile = rank/max_rank 
	
	drop max_rank rank
		
	egen kernel_range = fill(.01(.01)1)
	qui replace kernel_range = . if kernel_range>1

lpoly y2_nts_level_mean percentile if ince == 0 , gen(xcon_b2 y2_con_b) at (kernel_range) nograph
lpoly y2_nts_level_mean percentile if ince == 1 , gen(xtre_b2 y2_tre_b) at (kernel_range) nograph

gen diff = y2_tre_b - y2_con_b

*variables for confidence interval bands
svmat conf_int

graph twoway (line y2_con_b xcon_b2, lcolor(blue) lpattern("--.....") legend(lab(1 "Control"))) (line y2_tre_b xtre_b2, lcolor(red) lpattern(longdash) legend(lab(2 "Treatment"))) (line diff xcon_b2, lcolor(black) lpattern(solid) legend(lab(3 "Difference"))) (line conf_int1 xcon_b2, lcolor(black) lpattern(shortdash) legend(lab(4 "95% Confidence Band"))) (line conf_int2 xcon_b2, lcolor(black) lpattern(shortdash) legend(lab(5 "95% Confidence Band"))) ,yline(0, lcolor(gs10)) xtitle(Percentile of Endline Score) ytitle(Year 2 Endline Score) legend(order(1 2 3 4)) saving(Incentives_JPE_Figure_3, replace)


save data\dta\Incentives_JPE_Figure_3.dta, replace
log close
