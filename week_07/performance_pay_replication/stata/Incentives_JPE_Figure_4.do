

clear
set more off
capture log close
set logtype text
*cd c:\aprest\aprest
log using stata\\logs\\Incentives_JPE_Figure_4.txt, replace
*Figure regresses normalized test score in year 2 on baseline percentile score using nts scores

use data\dta\Incentives_JPE_analysis_starter_file.dta, clear

set matsize 2000

*number of iterations for bootstrap confidence bands
local it = 1000

keep  sub  school_treatment hplstudentkey apfschoolcode class_y1 class_y2  y2_nts_level_mean y1_nts_level_mean y0_nts  
keep if  school_treatment == 1 |  school_treatment == 4 |  school_treatment == 5

*creates  school_treatment and control dummy variable
	qui gen ince = 0 if  school_treatment == 1
	qui replace ince = 1 if  school_treatment == 4 |  school_treatment == 5

*one score per student per year (mean across subject)
order apfschoolcode, first
order  hplstudentkey, first
collapse apfschoolcode -  ince, by(hplstudentkey)
*Puts observations in order of treatment and then baseline scores
	qui sort ince y0_nts hplstudentkey

set seed 1234567890	

save data\dta\bootstrap_Figure_4.dta, replace


******************************Bootstrapped Confidence Interval***************************************************

qui egen kernel_range = fill(.01(.01)1)
qui replace kernel_range = . if kernel_range>1
mkmat kernel_range if kernel_range != .
matrix diff = kernel_range
matrix x = kernel_range


forvalues i = 1(1)`it'{
	
	***sampling with replacement of the control schools, clustering at school level
	use data\dta\bootstrap_Figure_4.dta, clear
	*Dropping observations with no schoolcode or test scores
	drop if apfschoolcode == . 
	drop if y2_nts_level_mean == . 
	*dropping class 1 and 2 in endline becuase of no baseline scores
	drop if class_y2 == 2 | class_y2 == 1
	bsample, strata(ince) cluster(apfschoolcode)

	*creating percentile rank by baseline scores
	bysort ince: egen rank = rank(y0_nts), unique
	bysort ince: egen max_rank = max(rank)
	bysort ince: gen percentile = rank/max_rank 
	
	drop max_rank rank
   
    egen kernel_range = fill(.01(.01)1)
	qui replace kernel_range = . if kernel_range>1

	*regressing endline scores on baseline percentile
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
*sort each column/percentile and save its 25th and 975th place in a matrix
forvalues i = 1(1)100{
	sort diff`i'
	matrix conf_int[`i', 1] = diff`i'[25]
	matrix conf_int[`i', 2] = diff`i'[975]
}


*******************Graphs for control, treatment, and difference using actual data (BASELINE)*************************************
use data\dta\bootstrap_Figure_4.dta, clear
  
*y2 vs y0 graph: 
*creates a percentile variable for control students
	drop if y2_nts_level_mean == . 

	*dropping class 2 and 1 -- no baseline
	drop if class_y2 == 1 | class_y2 == 2

	bysort ince: egen rank = rank(y0_nts), unique
	bysort ince: egen max_rank = max(rank)
	bysort ince: gen percentile = rank/max_rank 
	
	drop max_rank rank

	egen kernel_range = fill(.01(.01)1)
	qui replace kernel_range = . if kernel_range>1

lpoly y2_nts_level_mean percentile if ince == 0 , gen(xcon_b2 y2_con_b) at (kernel_range) nograph
lpoly y2_nts_level_mean percentile if ince == 1 , gen(xtre_b2 y2_tre_b) at (kernel_range) nograph

*difference between endline for treatment schools and control schools at each percentile
gen diff = y2_tre_b - y2_con_b


svmat conf_int

graph twoway (line y2_con_b xcon_b2, lcolor(blue) lpattern("--.....") legend(lab(1 "Control"))) (line y2_tre_b xtre_b2, lcolor(red) lpattern(longdash) legend(lab(2 "Treatment"))) (line diff xcon_b2, lcolor(black) lpattern(solid) legend(lab(3 "Difference"))) (line conf_int1 xcon_b2, lcolor(black) lpattern(shortdash) legend(lab(4 "95% Confidence Band"))) (line conf_int2 xcon_b2, lcolor(black) lpattern(shortdash) legend(lab(5 "95% Confidence Band"))) ,yline(0, lcolor(gs10)) xtitle(Percentile of Baseline Score) ytitle(Year 2 Endline Score) legend(order(1 2 3 4)) saving(Figure_4, replace)


save data\dta\Incentives_JPE_Figure_4.dta, replace

log close
