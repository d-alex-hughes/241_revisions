#delimit;
clear;
set more off;
capture log close;
set logtype text;
log using stata\\logs\\Incentives_JPE_table1A.txt, replace;



** DESCRIPTION: will create table 1 (A) of the paper;


**cleaning enrollment in y2 , i.e. kids who should not be in attendance sheets in y2;
use data\dta\y0_y2_assessmentfile.dta, clear;

sort hplstudentkey;

merge hplstudentkey using data\dta\enrollment_cleanup_y1_y2.dta; tab _m; 



drop if _m==3 | _m==2; drop _m;

drop if school_treatment==2 | school_treatment==3 | school_treatment==6 | school_treatment==7 |school_treatment==8;

**first we will creat student attrition;
**we are not calculating y2 on y1 student attrition because
**of the messiness of the deprecation coefficient;
***for  year2 on year0 student attrition will depend on those
***students who did not take ANY year 2 test
***as a fraction of those who took at least 1 year 1 test;

gen student_attrition_y2_y0_vra=.;
gen student_attrition_y1_y0=.;

**present y0;
gen present_y0=1 if y0_present_maths==1 | y0_present_telugu==1;
replace present_y0=0 if y0_present_maths==0 & y0_present_telugu==0;

**present y1;
gen present_y1=1 if y1_lel_present_maths==1 | y1_lel_present_telugu==1 | y1_hel_present_maths==1 | y1_hel_present_telugu==1;
replace present_y1=0 if y1_lel_present_maths==0 & y1_lel_present_telugu==0 & y1_hel_present_maths==0 & y1_hel_present_telugu==0;

**present y2;
gen present_y2=1 if y2_lel_present_maths==1 | y2_lel_present_telugu==1 | y2_hel_present_maths==1 | y2_hel_present_telugu==1;
replace present_y2=0 if y2_lel_present_maths==0 & y2_lel_present_telugu==0 & y2_hel_present_maths==0 & y2_hel_present_telugu==0;


***generate variables needed to calculate student attrition;

**dropout y1;
gen dropout_y1=0 if present_y1==1 & present_y0==1;
replace dropout_y1=1 if present_y1==0 & present_y0==1 ;

**dropout y2 vra;
gen dropout_y2_vra=0 if present_y2==1 & present_y0==1 ;
replace dropout_y2_vra=1 if present_y2==0 & present_y0==1;

***calculating student attrition y2 on y0 with vra (valid reason for absence);

forvalues i=1/7 {;

count if  dropout_y2_vra==1 & school_treatment==`i';
local dropout`num'=r(N);

count if  present_y0==1 & school_treatment==`i' & class_y0!=5 & class_y1!=5;
local present_y0`num'=r(N);

replace student_attrition_y2_y0_vra=(`dropout`num'')/`present_y0`num''
if  school_treatment==`i';

};

***calculating student attrition y1 on y0;

forvalues i=1/7 {;

count if  dropout_y1==1 & school_treatment==`i';
local dropout`num'=r(N);

count if  present_y0==1 & school_treatment==`i' & class_y1!=1;
local present_y0`num'=r(N);

replace student_attrition_y1_y0=(`dropout`num'')/`present_y0`num''
if  school_treatment==`i';

};

gen sa_dummy_y1=1 if present_y0==1 & dropout_y1==1;
replace sa_dummy_y1=0 if present_y0==1 & dropout_y1==0;

gen sa_dummy_y2_vra=1 if present_y0==1 & dropout_y2_vra==1;
replace sa_dummy_y2_vra=0 if present_y0==1 & dropout_y2_vra==0;

save data\dta\temp1.dta, replace;

keep hplstudentkey sa_dummy*;
sort hplstudentkey sa_dummy*;
save data\dta\usc_sa_dummy_merge.dta, replace;

use data\dta\temp1.dta, clear;

bysort school_treatment: keep if _n==1;


clear;




use data\dta\y0_y2_assessmentfile.dta, clear;

**renormalizing baseline totals on treatments 1 , 4 ,and 5;

**Dropping unecessary treatments;
drop if school_treatment==2 | school_treatment==3 | school_treatment==6 | school_treatment==7 |school_treatment==8;

**normalizing y0 scores;
gen y0_nts145_maths=.;
gen y0_nts145_telugu=.;

foreach subject in maths telugu {;
	foreach num of numlist 2/5 {; 
		summ y0_total_`subject' if class_y0==`num';
		local mean=r(mean);
		local sd=r(sd);
		disp `mean';
		disp `sd';
		replace y0_nts145_`subject'=(y0_total_`subject'-`mean')/`sd' if class_y0==`num' ;
	};
};

replace y0_nts145_maths=0 if class_y1==1;
replace y0_nts145_telugu=0 if class_y1==1;

sort hplstudentkey;
merge hplstudentkey using data\dta\usc_sa_dummy_merge.dta;
tab _m;
drop if _m==2;


reg sa_dummy_y1 II GI, cluster(apfschoolcode);
test  II=GI=0;

reg y0_nts145_maths II GI if sa_dummy_y1==1, cluster(apfschoolcode);
test  II=GI=0;

reg y0_nts145_telugu II GI if sa_dummy_y1==1, cluster(apfschoolcode);
test  II=GI=0;

reg sa_dummy_y2_vra II GI if class_y0!=5 & class_y1!=5, cluster(apfschoolcode);
test  II=GI=0;

reg y0_nts145_maths II GI if sa_dummy_y2_vra==1 & class_y0!=5 & class_y1!=5, cluster(apfschoolcode);
test  II=GI=0;

reg y0_nts145_telugu II GI if sa_dummy_y2_vra==1 & class_y0!=5 & class_y1!=5, cluster(apfschoolcode);
test  II=GI=0;





**additional: redoing panel B baseline normalised scores, testing for equality across treatments;

**mean percentage and normalized scores for the three groups;

foreach num of numlist 1 4 5{;

	summ y0_total_maths if school_treatment==`num';
	summ y0_nts145_maths if school_treatment==`num';

	summ y0_total_telugu if school_treatment==`num';
	summ y0_nts145_telugu if school_treatment==`num';

};

reg y0_total_maths II GI , cluster(apfschoolcode);
test  II=GI=0;

reg y0_nts145_maths II GI if  class_y1!=1 , cluster(apfschoolcode) ;
test  II=GI=0;

reg y0_total_telugu II GI , cluster(apfschoolcode);
test  II=GI=0;

reg y0_nts145_telugu II GI if class_y1!=1 , cluster(apfschoolcode) ;
test  II=GI=0;



log close;







 



