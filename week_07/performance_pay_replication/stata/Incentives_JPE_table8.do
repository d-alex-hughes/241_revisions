#delimit;
clear;
set more off;
capture log close;

set logtype text;
log using stata\\logs\\Incentives_JPE_table8.txt, replace;

**description : table 7 of the JPE Incentives paper;

**teacher absence and activity;
use data\dta\teacher_short_y1_y2.dta, clear;

label define absence 0 "Present" 1 "Absent";	

	tab teacher_activity, gen(tact_);
	
	gen tabsent1=tact_7;
	label var tabsent1 "Teacher is absent on the day of the data collection";
	label val tabsent1 absence;
	**incorporating information from first three rounds in year 1;
	** extra7: {TIS_old: 7. Is the teacher in school today [1: Yes, 2: No]};
	replace tabsent1=1 if extra7==2;
	replace tabsent1=0 if extra7==1;
	
	gen tabsent2=1 if t_status_previous_day==2; ** Previous day leave;
	replace tabsent2=0 if t_status_previous_day==1;
	label var tabsent2 "Teacher is absent on the day _before_  data collection (from school register)";
	label val tabsent2 absence;
	
	gen tabsent3=1 if teacher_signed_attendance==2; ** sameday attendance register not signed;
	replace tabsent3=0 if teacher_signed_attendance==1;
	label var tabsent3 "Teacher's signature in attendance register for the day on which data was collected";
	label val tabsent3 absence;
	
** creating indicator variable for active teaching;
	gen tact_active=1 if inlist(teacher_activity,1);
	replace tact_active=0 if inlist(teacher_activity,2,3,4,5,6,7);
	label var tact_active "Teacher is actively teaching (teacher_activity=1)";
	label define active 0 "Not Actively Teaching" 1 "Actively Teaching";
	label val tact_active active;
	
** creating indicator variable for active or passive teaching;
	gen tact_teach=1 if inlist(teacher_activity,1,2);
	replace tact_teach=0 if inlist(teacher_activity,3,4,5,6,7);
	label var tact_teach "Teacher is either actively or passively teaching (teacher_activity=1;teacher_activity=2)";
** creating indicator variable for teacher idleness;
	gen tact_idle=1 if inlist(teacher_activity,3,4);
	replace tact_idle=0 if inlist(teacher_activity,1,2,5,6,7);
	label var tact_idle "Teacher is not teaching (teacher_activity=3;teacher_activity=4)";
** creating indicator variable for administrative work/MC accompaniment;
	gen tact_admin=1 if inlist(teacher_activity,5,6);
	replace tact_admin=0 if inlist(teacher_activity,1,2,3,4,7);
	label var tact_admin "Teacher is doing administrative work in the school (teacher_activity=5;teacher_activity=6)";
** creating indicator variables for types of teacher idleness from c8;
	tab teacher_activity_if_not_teach, gen(teacher_activity_if_not_teach);
** creating indicator variable for teacher on official duty from c10 and c16;
	gen toffice1=1 if inlist(t_off_status_if_not_in_schl,1);
	replace toffice1=0 if inrange(t_off_status_if_not_in_schl,2,13);
	label var toffice1 "Teacher is on leave for official teaching related duty (training, meeting etc.)";
	** previous day status;	
	gen toffice2=1 if inlist(t_stat_prev_day_if_absent,1);
	replace toffice2=0 if inrange(t_stat_prev_day_if_absent,2,13);
	label var toffice2 "Teacher was on leave on the day _before_ data was collected for official teaching related duty (training, meeting etc.)";
	
** creating indicator variable for teacher on training from c11;
	gen ttrain=1 if inlist(t_off_teaching_related_duty,2,3);
	replace ttrain=0 if inlist(t_off_teaching_related_duty,1,4,5,6);
	label var ttrain "Teacher is on leave to attend training";
	
** creating indicator variable for teacher leaves from c10, c13 c16;
	gen tleave1=1 if inlist(t_off_status_if_not_in_schl,8);
	replace tleave1=0 if inlist(t_off_status_if_not_in_schl,1,2,3,4,5,6,7,9,10,11,12,13);
	label var tleave1 "Teacher is on authorized leave";
	** previous day authorised leave;
	gen tleave2=1 if inlist(t_off_status_if_not_in_schl,8);
	replace tleave2=0 if inlist(t_off_status_if_not_in_schl,1,2,3,4,5,6,7,9,10,11,12,13);
	label var tleave2 "Teacher was on authorized leave on the day _before_ data was collected";
	
	tab t_reasons_for_leave_request, gen(tleave_);
	

rename treatment_code school_treatment;
do stata\create_int_umc.do;

gen incentive=1 if inlist(school_treatment,4,5);
replace incentive=0 if school_treatment==1;

foreach v of var tabsent1 tact_active  {;
areg  `v' incentive if inlist(school_treatment,1,4,5) , absorb(U_MC) cluster(apfschoolcode);
};


clear;


use data\dta\teacher_interviews_y1_y2.dta, clear;

do stata\create_treatment_dummies.do;
do stata\create_int_umc.do;

rename treatmentcode school_treatment;

gen Prep=special_prep_assessment==1;

gen HW=extra_hmwk==1;
label var HW "More Homework";
gen CW=extra_clswork==2;
label var CW "More Classwork";
gen EC=extra_teaching_after_cls==3;
label var EC "Extra Coaching Classes";
gen Exams=extra_practice_papers==4;
label var Exams "Gave Practice Tests";
gen SA_WS= extra_atten_weaker_stud==5;
label var SA_WS "Special Attention to Weaker Students";
egen EAC = rsum( HW CW EC Exams SA_WS);
label var EAC "Extra Activity Count";

foreach v of var Prep - EAC {;
eststo: areg  `v' incentive if inlist(school_treatment,1,4,5), absorb(U_MC) cluster(apfschoolcode);
estimates store `v';

};



estimates table Prep  HW CW EC Exams SA_WS;



gen motivation=motivation_increased_incentives==1; 
replace motivation=1 if motivation_increased_incentives==2;
gen sixth_pay_com=opinon_6th_pay_com==2;
replace sixth_pay_com=1 if opinon_6th_pay_com==3;
replace sixth_pay_com=1 if opinon_6th_pay_com==4;
gen favorable_idea=opinion_performance_based_pay==1;
replace favorable_idea=1 if opinion_performance_based_pay==2;
gen scale_up=opinion_aprest_inc_program	==1;

table motivation if incentive==1, row;
table sixth_pay_com if incentive==1, row;
table favorable_idea if incentive==1, row;
table scale_up if incentive==1, row;



**Next section is the Relationship between test scores and teacher behaviors reported in table 8;

use data\dta\teacher_interviews_y1_y2.dta, clear;

do stata\create_treatment_dummies.do;
do stata\create_int_umc.do;

gen Prep=special_prep_assessment==1;
gen HW=extra_hmwk==1;
label var HW "More Homework";
gen CW=extra_clswork==2;
label var CW "More Classwork";
gen EC=extra_teaching_after_cls==3;
label var EC "Extra Coaching Classes";
gen Exams=extra_practice_papers==4;
label var Exams "Gave Practice Tests";
gen SA_WS= extra_atten_weaker_stud==5;
label var SA_WS "Special Attention to Weaker Students";
egen EAC = rsum( HW CW EC Exams SA_WS);
label var EAC "Extra Activity Count";
keep hplteacherkey year Prep - EAC;
save data\dta\temp1.dta, replace;

**YEAR 1;
keep if year==1;
foreach var of varlist hplteacherkey-EAC {;
rename `var' `var'_y1;
};
keep hplteacherkey Prep - EAC ;
sort hplteacherkey_y1;
save data\dta\teach_int_char_y1.dta, replace;

**YEAR 2; 
use data\dta\temp1.dta, clear;
keep if year==2;
foreach var of varlist hplteacherkey - EAC {;
rename `var' `var'_y2;
};
keep hplteacherkey Prep - EAC ;
sort hplteacherkey_y2;
save data\dta\teach_int_char_y2.dta, replace;


use data\dta\Incentives_JPE_analysis_starter_file.dta, clear;
sort hplteacherkey_y1;
merge hplteacherkey_y1 using data\dta\teach_int_char_y1.dta; tab _m; drop _m;
sort hplteacherkey_y2;
merge hplteacherkey_y2 using data\dta\teach_int_char_y2.dta; tab _m; drop _m;

bysort hplstudentkey sub : keep if _n==1;

drop level;


foreach i in y1 y2 {; 
ren Prep_`i' t_special_test_prep_`i';
ren HW_`i' t_extra_hmwk_`i';
ren CW_`i' t_extra_clswk_`i';
ren EC_`i' t_extra_class_teach_`i';
ren Exams_`i' t_extra_pract_exams_`i';
ren SA_WS_`i' t_extra_attent_weakstud_`i';
};




**TEACHER ABSENCE AND ACTIVITY VARIABLES;

egen tabsent_y2=rmean(tabsent1_y2 tabsent2_y2);
egen tabsent_y1=rmean(tabsent1_y1 tabsent2_y1);

save data\dta\temp1.dta, replace;
drop if school_treatment==6 | school_treatment==7;

keep hplstudentkey y2_nts_level_mean y1_nts_level_mean sub   tabsent_y2 tact_active_y2
t_extra_hmwk_y2 t_extra_clswk_y2 t_extra_class_teach_y2
t_extra_pract_exams_y2 t_extra_attent_weakstud_y2 t_special_test_prep_y2
school_treatment cheaters U_MC apfschoolcode incentive input II GI teacher_group_y2 t_deg_y2;

rename y2_nts_level_mean y_nts;
rename y1_nts_level_mean y_lagged_nts;
rename tabsent_y2 tabsent;
rename tact_active_y2 tact_active;
rename t_extra_hmwk_y2 t_extra_hmwk;
rename t_extra_clswk_y2 t_extra_clswk;
rename t_extra_class_teach_y2 t_extra_class_teach;
rename t_extra_pract_exams_y2 t_extra_pract_exams;
rename t_extra_attent_weakstud_y2 t_extra_attent_weakstud;
rename t_special_test_prep_y2 t_special_test_prep;
rename teacher_group_y2 teacher_group;
rename t_deg_y2 t_deg;

gen year=2;

save data\dta\stacked_format_table8_regressions_y2.dta, replace;

use data\dta\temp1.dta, clear;

drop if school_treatment==6 | school_treatment==7;



keep hplstudentkey y1_nts_level_mean y0_nts sub   tabsent_y1 tact_active_y1
t_extra_hmwk_y1 t_extra_clswk_y1 t_extra_class_teach_y1
t_extra_pract_exams_y1 t_extra_attent_weakstud_y1 t_special_test_prep_y1
school_treatment cheaters U_MC apfschoolcode incentive input II GI teacher_group_y1 t_deg_y1;

rename y1_nts_level_mean y_nts;
rename y0_nts y_lagged_nts;
rename tabsent_y1 tabsent;
rename tact_active_y1 tact_active;
rename t_extra_hmwk_y1 t_extra_hmwk;
rename t_extra_clswk_y1 t_extra_clswk;
rename t_extra_class_teach_y1 t_extra_class_teach;
rename t_extra_pract_exams_y1 t_extra_pract_exams;
rename t_extra_attent_weakstud_y1 t_extra_attent_weakstud;
rename t_special_test_prep_y1 t_special_test_prep;
rename teacher_group_y1 teacher_group;
rename t_deg_y1 t_deg;

gen year=1;

save data\dta\stacked_format_table8_regressions_y1.dta, replace;

clear;

use data\dta\stacked_format_table8_regressions_y2.dta;
append using data\dta\stacked_format_table8_regressions_y1.dta;

replace cheaters=0 if year==1;

order  tabsent tact_active t_special_test_prep -  t_extra_attent_weakstud;

foreach var of varlist tabsent -  t_extra_attent_weakstud {;

disp "regression of y(t) on y(t-1) and process variable: `var'";

areg y_nts y_lagged_nts `var' if inlist(school_treatment,1,4,5) &  cheaters!=1 & teacher_group!=1, absorb(U_MC) cluster(apfschoolcode);
estimates store `var';

};


estout tabsent tact_active t_special_test_prep t_extra_hmwk t_extra_clswk t_extra_class_teach t_extra_pract_exams t_extra_attent_weakstud, starlevels(* 0.10 ** 0.05 *** .01 ) cells(b(fmt(3) star));


log close;
