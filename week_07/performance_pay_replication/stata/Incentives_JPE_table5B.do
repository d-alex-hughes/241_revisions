#delimit;
clear;
set more off;
capture log close;
set logtype text;

log using stata\\logs\\Incentives_JPE_table5B.txt, replace;


use data\dta\Incentives_JPE_analysis_starter_file.dta, clear;
	
**keeping only one observation per student per subject (i.e. removing round LEL or HEL as a dimension);
bysort hplstudentkey sub : keep if _n==1;

drop level;

**renaming variables;
rename  t_educ_level_completed_y1 t_education_y1;
rename  t_educ_level_completed_y2 t_education_y2;
rename t_training_qualif_y2 t_training_y2;
rename t_training_qualif_y1 t_training_y1;

**generating mean of absence on same day and previous day;
egen tabsent_y2_year2=rmean(tabsent1_y2 tabsent2_y2);
egen tabsent_y1_year1=rmean(tabsent1_y1 tabsent2_y1);

**fixing teacher service variable;
replace t_service_y2=. if t_service_y2==2006;
replace t_service_y1=. if t_service_y1==2006;

replace t_education_y1=. if t_education_y1==5;
replace t_education_y2=. if t_education_y2==5;

replace t_training_y1=. if t_training_y1==5;
replace t_training_y2=. if t_training_y2==5;

**reshaping file for stacked regressions;
foreach var in t_education t_training t_service t_salary t_gender  tact_teach tact_active  teacher_group t_deg {;
rename `var'_y2 `var'2;
rename `var'_y1 `var'1;
};

rename tabsent_y1_year1 tabsent_y1; 
rename tabsent_y2_year2 tabsent_y2; 

rename tabsent_y1 tabsent1;
rename tabsent_y2 tabsent2;

rename y2_nts_level_mean nts2;
rename y1_nts_level_mean nts1;
rename y0_nts bl_nts;

reshape long t_deg t_education t_training t_service t_salary t_gender  tact_teach tact_active tabsent teacher_group nts , i(hplstudentkey sub) j(year);

egen id=group(hplstudentkey sub);
tsset id year;


gen lagged_nts=l.nts;

replace lagged_nts=bl_nts if year==1;


keep apfschoolcode U_MC school_treatment hplstudentkey sub year t_deg t_education t_training t_service t_salary t_gender  tact_teach tact_active tabsent nts lagged_nts teacher_group cheaters incentive;

replace cheaters=0 if cheaters==1 & year==1;

save data\dta\Incentives_JPE_table5_panelB_INT.dta, replace;

**generating interaction terms;
gen log_t_salary=log(t_salary);


foreach var in t_education t_training t_service t_gender log_t_salary tact_teach tact_active tabsent t_deg {;
gen `var'_int_inc=`var'*incentive;
disp "`var'";
areg nts lagged_nts incentive `var' `var'_int_inc if inlist(school_treatment,1,4,5) & cheaters!=1 & teacher_group!=1 & inlist(t_deg,1,2), absorb(U_MC) cluster(apfschoolcode);
estimates store `var';
};

estout t_education t_training t_service t_gender log_t_salary tact_teach tact_active tabsent, stats(N r2) cells(b(fmt(3)) se(par star fmt(3)))starlevels(* 0.10 ** 0.05 *** .01 ) ;

**WITH CTs;

foreach var in t_education t_training t_service t_gender log_t_salary tact_teach tact_active tabsent t_deg {;
disp "`var'";
areg nts lagged_nts incentive `var' `var'_int_inc if inlist(school_treatment,1,4,5) & cheaters!=1 & teacher_group!=1, absorb(U_MC) cluster(apfschoolcode);
estimates store `var';
};

estout t_education t_training t_service t_gender log_t_salary tact_teach tact_active tabsent, stats(N r2) cells(b(fmt(3)) se(par star fmt(3)))starlevels(* 0.10 ** 0.05 *** .01 ) ;



log close;