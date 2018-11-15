#delimit;
clear;
set more off;
capture log close;
set logtype text;
log using stata\\logs\\Incentives_JPE_table1B.txt, replace;


** DESCRIPTION: will create table 1 (B) teacher turnover and teacher attrition;


**Year 2 formatting;

use data\dta\teacher_class_y2.dta, clear;



replace apf_code=30105 if apf_code==31807;

drop if class=="NULL";
replace deg_y2="" if deg_y2=="NULL";
destring deg_y2, replace;

bysort hplteacherkey: keep if _n==1;
cap rename c3 deg_y2;
rename apf_code apfschoolcode;
keep apfschoolcode  hplteacherkey deg_y2;
sort apfschoolcode;

save data\dta\teacher_class_y2_for_table_1B, replace;

**merging treatment for table 1 (B);



*merging y2 teacher_class with school_treatment;

use data\dta\teacher_class_y2_for_table_1B;
merge apfschoolcode using data\dta\apf_treatmentcode;
tab _m;

do stata\create_int_umc.do;
drop if U_MC==112;

cap rename treatment_code school_treatment;

**Creating treatment dummys for balanced attrtition and turnover regression**;

tabulate school_treatment, gen(treatment);
gen II=treatment5;
gen GI=treatment4;

cap rename tre_code school_treatment;

**for the 1 , 4 ,5 version we are dropping all treatments except 1 , 4 and 5;

drop if _m==2;
drop _m;
drop if school_treatment==2 | school_treatment==3 | school_treatment==6 | school_treatment==7;
drop treatment2 treatment3 treatment6 treatment7;

sort hplteacherkey;
save data\dta\teacher_class_y2_for_table_1B, replace;

keep apfschoolcode hplteacherkey deg_y2 school_treatment;
rename school_treatment Treatment;
sort hplteacherkey;
save data\dta\temp1.dta, replace;

use data\dta\teacher_class_y1.dta, clear;

do stata\create_int_umc.do;
drop if U_MC==112;

rename treatment Treatment;
rename p_a_e P_A_E;
rename p_a_b P_A_B;
rename p_t P_T;
rename gt GT;
ren t_d1 T_D1;
ren t_d2 T_D2;
ren t_d3 T_D3;
ren t_d4 T_D4;
ren t_d5 T_D5;
rename teacher_code Teacher_Code;
drop if hplteacherkey=="NULL";
destring hplteacherkey, replace;
rename apf_school_code apfschoolcode;


foreach var of varlist P_A_E P_A_B P_T GT {;
cap replace `var'="" if `var'=="NULL";
cap destring `var' , replace;
};

keep if inlist(Treatment,1,4,5);
sort Teacher_Code;

sort hplteacherkey;

merge hplteacherkey using data\dta\temp1.dta, update;

tab _m;







*****************YEAR 2 OVER YEAR 1*****************;

**generating present at beginning of the year, end of year and through the year for year 2 in comparison to year 1;

**teachers at the end of year 1 are also teachers at the beginning of year 2;
gen P_A_B_Y2_Y1=P_A_E;


**teachers who have stayed through year 2 are teachers who are in BOTH KM's and VA's file and may or may not be there at the start of the project year 0 but are defintiely there in the beginnng of year 2 (end of year 1);
gen P_T_Y2_Y1=1 if _m==3 & P_A_B_Y2_Y1==1;


**teachers there at the end of year 2 are teachers who are either there from the start of year 2 to the end of year 2 (P_T_Y2_Y1=1) OR teachers who are only there in the year 2 file;
gen P_A_E_Y2_Y1=1 if P_T_Y2_Y1==1 | _m==2;




**we need to also consider where we put zeros;
**since we are only considering y2 over y1 for this part we don't want zeros for ALL teachers in this master file;
**we would like blanks if the teachers came in year 0 and left;
**we replace teacher_throughout_y1_y2=0 if the teacher
**IS there at the END of year 1 but not at the end of year 2 ;
replace P_T_Y2_Y1=0 if _m==1 & P_A_E==1; 

**we also replaced teacher y2 y1 throughout = 0 if teacher is there in the end of year 2 but was not there from year 1 end to year 2 end;
replace P_T_Y2_Y1=0 if  _m==2;


**for zero at the end of year 2 we do the following;
replace P_A_E_Y2_Y1=0 if P_A_B_Y2_Y1==1 & P_T_Y2_Y1!=1;



**************YEAR 2 OVER YEAR 0*************;


**generating present at beginning of the year, end of year and through the year for year 2 in comparison to year 0;

**teachers at the beginning of the project year 0;
gen P_A_B_Y2_Y0=P_A_B;

**teachers who have stayed through 2 years of the whole project are teachers who are in BOTH KM's and VA's file and who did not leave and comeback;
gen P_T_Y2_Y0=1 if _m==3 & P_T==1 ;

**teachers there at the end of year 2 are teachers who are either there through out (_m==3) OR teachers who are only there in the year 2 file;
gen P_A_E_Y2_Y0=1 if _m==3 | _m==2;

**we need to also consider where we put zeros;
**since we are considering y2 over y0 for this part if a teacher is not there for BOTH periods y0 t0 y1 and y1 to y2 we can give them a zero;
replace P_T_Y2_Y0=0 if P_T_Y2_Y0!=1;

**for zero at the end of year 2 we do the following: they should have zero for being present at the end if they were present in the beginning and NOT present throughout;
replace P_A_E_Y2_Y0=0 if P_A_B_Y2_Y0==1 & P_T_Y2_Y0!=1;


**We do not need treatments 2 and 3 (BG and VV);
drop if T_D2==1 | T_D3==1;

**replacing G_T when it is blank;
replace GT=1 if deg_y2==1 & GT==. | deg_y2==2 & GT==.;
replace GT=0 if deg_y2!=1 & deg_y2!=2 & GT==.;



**teacher turnover and attrition;

bysort Treatment: egen P_T_no=sum(P_T) if GT==1;
bysort Treatment: egen P_A_B_no=sum(P_A_B) if GT==1;
bysort Treatment: egen P_A_E_no=sum(P_A_E) if GT==1;

bysort Treatment: egen P_T_Y2_Y1_no=sum(P_T_Y2_Y1) if GT==1;
bysort Treatment: egen P_A_B_Y2_Y1_no=sum(P_A_B_Y2_Y1) if GT==1;
bysort Treatment: egen P_A_E_Y2_Y1_no=sum(P_A_E_Y2_Y1) if GT==1;

bysort Treatment: egen P_T_Y2_Y0_no=sum(P_T_Y2_Y0) if GT==1;
bysort Treatment: egen P_A_B_Y2_Y0_no=sum(P_A_B_Y2_Y0) if GT==1;
bysort Treatment: egen P_A_E_Y2_Y0_no=sum(P_A_E_Y2_Y0) if GT==1;

**y1 on y0;

gen teacher_attrition_y1_y0=.;
gen teacher_turnover_y1_y0=.;

foreach num of numlist 1 4 5 {;
replace teacher_attrition_y1_y0=P_T_no/P_A_B_no if Treatment==`num';
replace teacher_turnover_y1_y0=P_T_no/P_A_E_no if Treatment==`num';
};

**y2 on y1;

gen teacher_attrition_y2_y1=.;
gen teacher_turnover_y2_y1=.;

foreach num of numlist 1 4 5 {;
replace teacher_attrition_y2_y1=P_T_Y2_Y1_no/P_A_B_Y2_Y1_no if Treatment==`num';
replace teacher_turnover_y2_y1=P_T_Y2_Y1_no/P_A_E_Y2_Y1_no if Treatment==`num';
};

**y2 on y0;

gen teacher_attrition_y2_y0=.;
gen teacher_turnover_y2_y0=.;

foreach num of numlist 1 4 5 {;
replace teacher_attrition_y2_y0=P_T_Y2_Y0_no/P_A_B_Y2_Y0_no if Treatment==`num';
replace teacher_turnover_y2_y0=P_T_Y2_Y0_no/P_A_E_Y2_Y0_no if Treatment==`num';
};


save data\dta\temp2.dta, replace;
drop if GT==0;
bysort Treatment: keep if _n==1;

list Treatment teacher_attrition* teacher_turnover*;



clear;



use data\dta\temp2.dta;


**recreating treatment dummies;
drop T_D*;

gen T_D1=Treatment==1;
gen T_D4=Treatment==4;
gen T_D5=Treatment==5;


***regressions;

**year 1 on year 0;

**attrition;
reg  P_T  T_D1 T_D4 T_D5 if  GT==1 & P_A_B==1 & (Treatment==1|Treatment ==4|Treatment ==5), nocons;
test T_D1=T_D4=T_D5;

**turnover;
reg  P_T  T_D1 T_D4 T_D5 if  GT==1 & P_A_E==1 & (Treatment==1|Treatment ==4|Treatment ==5), nocons;
test T_D1=T_D4=T_D5;


**year 2 on year 0;

**attrition;
reg  P_T_Y2_Y0  T_D1 T_D4 T_D5 if  GT==1 & P_A_B_Y2_Y0==1 & (Treatment==1|Treatment==4|Treatment==5), nocons;
test T_D1=T_D4=T_D5;

**turnover;
reg  P_T_Y2_Y0  T_D1 T_D4 T_D5 if  GT==1 & P_A_E_Y2_Y0==1 & (Treatment==1|Treatment==4|Treatment==5), nocons;
test T_D1=T_D4=T_D5;



log close;