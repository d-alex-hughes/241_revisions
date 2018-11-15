#delimit;
clear;
set more off;

capture log close;
set logtype text;
log using stata\\logs\Incentives_JPE_table3_table4.txt, replace;


use data\dta\Incentives_JPE_analysis_starter_file.dta, clear;

bysort hplstudentkey sub : keep if _n==1;

replace y0_nts=0 if class_y2==2;
replace y0_nts=0 if class_y1==1;

keep hplstudentkey  y0_nts repeat_perc_with_HEL* non_repeat_perc_with_HEL*  incentive school_treatment U_MC apfschoolcode sub class_y1 class_y2;



forvalues i=1/2 {;
rename repeat_perc_with_HEL_y`i' repeat_perc_with_HEL`i';
rename non_repeat_perc_with_HEL_y`i' non_repeat_perc_with_HEL`i';
rename class_y`i' class`i';
};



reshape long repeat_perc_with_HEL non_repeat_perc_with_HEL class , i(hplstudentkey sub) j(year);


gen cheaters=0;
	replace cheaters=1 if apfschoolcode==41904 & class==5 & year==2;
	replace cheaters=1 if apfschoolcode==42112 & year==2;


**REPEAT QUESTIONS WITH HEL;


rename repeat_perc_with_HEL perc1;
rename non_repeat_perc_with_HEL perc0;

reshape long perc , i(hplstudentkey year sub) j(repeat);

gen non_repeat=repeat==0;
gen inc_int_repeat=incentive*repeat;
gen inc_int_non_repeat=incentive*non_repeat;

save data\dta\Incentives_JPE_table3_INT.dta, replace;

areg perc  repeat  inc_int_non_repeat inc_int_repeat y0_nts if inlist(school_treatment,1,4,5) & year==1 & cheaters==0, absorb(U_MC) cluster(apfschoolcode);
estimates store y1;
test inc_int_repeat=inc_int_non_repeat;
estadd scalar pvalue=r(p);

areg perc  repeat  inc_int_non_repeat inc_int_repeat y0_nts if inlist(school_treatment,1,4,5) & year==2 & cheaters==0, absorb(U_MC) cluster(apfschoolcode);
estimates store y2;
test inc_int_repeat=inc_int_non_repeat;
estadd scalar pvalue=r(p);

areg perc  repeat  inc_int_non_repeat inc_int_repeat y0_nts if sub==1 & inlist(school_treatment,1,4,5) & year==1 & cheaters==0, absorb(U_MC) cluster(apfschoolcode);
estimates store y1_m;
test inc_int_repeat=inc_int_non_repeat;
estadd scalar pvalue=r(p);

areg perc  repeat  inc_int_non_repeat inc_int_repeat y0_nts if sub==1 & inlist(school_treatment,1,4,5) & year==2 & cheaters==0, absorb(U_MC) cluster(apfschoolcode);
estimates store y2_m;
test inc_int_repeat=inc_int_non_repeat;
estadd scalar pvalue=r(p);

areg perc  repeat  inc_int_non_repeat inc_int_repeat y0_nts if sub==2 & inlist(school_treatment,1,4,5) & year==1 & cheaters==0, absorb(U_MC) cluster(apfschoolcode);
estimates store y1_t;
test inc_int_repeat=inc_int_non_repeat;
estadd scalar pvalue=r(p);

areg perc  repeat  inc_int_non_repeat inc_int_repeat y0_nts if sub==2 & inlist(school_treatment,1,4,5) & year==2 & cheaters==0, absorb(U_MC) cluster(apfschoolcode);
estimates store y2_t;
test inc_int_repeat=inc_int_non_repeat;
estadd scalar pvalue=r(p);

estout  y1 y2 y1_m y2_m y1_t y2_t  ,title("repeat questions with HEL") stats(N r2 pvalue, fmt(0 2 3)) cells(b(fmt(3) star) se(par fmt(3))) starlevels(* 0.10 ** 0.05 *** .01 );












use data\dta\Incentives_JPE_analysis_starter_file.dta, clear;

bysort hplstudentkey sub : keep if _n==1;

replace y0_nts=0 if class_y2==2;
replace y0_nts=0 if class_y1==1;

keep hplstudentkey  y0_nts mcq_perc* non_mcq_perc*  incentive school_treatment U_MC apfschoolcode sub class_y1 class_y2;



forvalues i=1/2 {;
rename mcq_perc_y`i' mcq_perc`i';
rename non_mcq_perc_y`i' non_mcq_perc`i';
rename class_y`i' class`i';
};



reshape long mcq_perc non_mcq_perc class , i(hplstudentkey sub) j(year);


gen cheaters=0;
	replace cheaters=1 if apfschoolcode==41904 & class==5 & year==2;
	replace cheaters=1 if apfschoolcode==42112 & year==2;


**MULTIPLE CHOICE QUESTIONS;

keep hplstudentkey  y0_nts mcq non_mcq incentive year school_treatment U_MC apfschoolcode sub cheaters;


rename mcq_perc perc1;
rename non_mcq_perc perc0;

reshape long perc , i(hplstudentkey year sub) j(mcq);

gen non_mcq=mcq==0;
gen inc_int_mcq=incentive*mcq;
gen inc_int_non_mcq=incentive*non_mcq;


save data\dta\Incentives_JPE_table4_INT.dta, replace;

forvalues i=1/2 {;
areg perc  mcq  inc_int_non_mcq inc_int_mcq y0_nts if inlist(school_treatment,1,4,5) & year==`i' & cheaters==0, absorb(U_MC) cluster(apfschoolcode);
estimates store y`i';
test inc_int_mcq=inc_int_non_mcq;
estadd scalar pvalue=r(p);
};

forvalues i=1/2 {;
areg perc  mcq  inc_int_non_mcq inc_int_mcq y0_nts if sub==1 &  inlist(school_treatment,1,4,5) & year==`i' & cheaters==0, absorb(U_MC) cluster(apfschoolcode);
estimates store y`i'_m;
test inc_int_mcq=inc_int_non_mcq;
estadd scalar pvalue=r(p);
};

forvalues i=1/2 {;
areg perc  mcq  inc_int_non_mcq inc_int_mcq y0_nts if sub==2 & inlist(school_treatment,1,4,5) & year==`i' & cheaters==0, absorb(U_MC) cluster(apfschoolcode);
estimates store y`i'_t;
test inc_int_mcq=inc_int_non_mcq;
estadd scalar pvalue=r(p);
};

estout  y1 y2 y1_m y2_m y1_t y2_t  ,title("mcq questions") stats(N r2 pvalue, fmt(0 2 3)) cells(b(fmt(3) star) se(par fmt(3))) starlevels(* 0.10 ** 0.05 *** .01 );





log close;

