#delimit;
clear;
set more off;
capture log close;
set logtype text;

*log using stata\\logs\\Incentives_JPE_table5A.txt, replace;

cd "~/Google Drive/David Reiley-Broockman Field Experiments Class/Data/Teacher Performance Pay - Replication Files/data/dta";
use Incentives_JPE_analysis_starter_file.dta, clear;

**keeping only one observation per student per subject (i.e. removing round LEL or HEL as a dimension);
bysort hplstudentkey sub : keep if _n==1;

*outsheet apfschoolcode - tact_teach_y2 school_enrollment_y1 - U_MC using "Incentives_JPE_HTEs.csv", comma replace;

**Log School Enrollment;
gen log_schl_enroll_y2_int_inc=log_schl_enrollment_y2*incentive;
gen log_schl_enroll_y1_int_inc=log_schl_enrollment_y1*incentive;

**Proximity;
gen prox_index_mean_int_inc=prox_index_mean*incentive;
gen prox_index_y2_int_inc=prox_index_y2*incentive;
gen prox_index_y1_int_inc=prox_index_y1*incentive;

**Infrastructure;
gen infra_index_mean_int_inc=infra_index_mean*incentive;
gen infra_index_y2_int_inc=infra_index_y2*incentive;
gen infra_index_y1_int_inc=infra_index_y1*incentive;


**Household Affluence,  Parent Literacy and Baseline Score;

foreach var of varlist hh_affluence_index parent_literacy_index y0_nts  {;
gen `var'_int_inc=`var'*incentive;
disp "`var'";

};

**Caste;

gen SC_ST=SC==ST==0;
gen SC_ST_int_inc=SC_ST*incentive; 

**Male;
gen Male_int_inc=Male*incentive;

save data\dta\Incentives_JPE_table5_panelA_INT.dta, replace;

**********************PART II***********************;

**REGRESSIONS AND TESTING HYPOTHESES FOR HETEROGENOUS TREATMENT EFFECTS;

**y2 on y0;
disp "Log School Enrollment Year 2";
areg y2_nts_level_mean y0_nts incentive log_schl_enrollment_y2 log_schl_enroll_y2_int_inc if inlist(school_treatment,1,4,5) & cheaters==0, absorb(U_MC) cluster(apfschoolcode);
estimates store log_schl_enr_y2;

**y1 on y0;
disp "Log School Enrollment Year 1";
areg y1_nts_level_mean y0_nts incentive log_schl_enrollment_y1 log_schl_enroll_y1_int_inc if inlist(school_treatment,1,4,5) , absorb(U_MC) cluster(apfschoolcode);
estimates store log_schl_enr_y1;


**y2 on y0;
disp "Infrastructure Index Year 2";
areg y2_nts_level_mean y0_nts incentive infra_index_y2 infra_index_y2_int_inc if inlist(school_treatment,1,4,5) & cheaters==0, absorb(U_MC) cluster(apfschoolcode);
estimates store infra_y2;

**y1 on y0;
disp "Infra Index y1";
areg y1_nts_level_mean y0_nts incentive infra_index_y1 infra_index_y1_int_inc if inlist(school_treatment,1,4,5) , absorb(U_MC) cluster(apfschoolcode);
estimates store infra_y1;

**y2 on y0;
disp "Proximity Index Year 2";
areg y2_nts_level_mean y0_nts incentive prox_index_y2 prox_index_y2_int_inc if inlist(school_treatment,1,4,5) & cheaters==0, absorb(U_MC) cluster(apfschoolcode);
estimates store proxy_y2;

**y1 on y0;
disp "prox Index y1";
areg y1_nts_level_mean y0_nts incentive prox_index_y1 prox_index_y1_int_inc if inlist(school_treatment,1,4,5) , absorb(U_MC) cluster(apfschoolcode);
estimates store proxy_y1;

**y2 on y0;
disp "household affluence index";
areg y2_nts_level_mean y0_nts  incentive hh_affluence_index hh_affluence_index_int_inc if inlist(school_treatment,1,4,5) & cheaters==0, absorb(U_MC) cluster(apfschoolcode);
estimates store hh_asset_y2;

**y1 on y0;
disp "household affluence index";
areg y1_nts_level_mean y0_nts  incentive hh_affluence_index hh_affluence_index_int_inc if inlist(school_treatment,1,4,5) , absorb(U_MC) cluster(apfschoolcode);
estimates store hh_asset_y1;

**y2 on y0;
disp "parent literacy";
areg y2_nts_level_mean y0_nts  incentive parent_literacy_index parent_literacy_index_int_inc if inlist(school_treatment,1,4,5) & cheaters==0, absorb(U_MC) cluster(apfschoolcode);
estimates store parent_lit_y2;

**y1 on y0;
disp "parent literacy";
areg y1_nts_level_mean y0_nts  incentive parent_literacy_index parent_literacy_index_int_inc if inlist(school_treatment,1,4,5) , absorb(U_MC) cluster(apfschoolcode);
estimates store parent_lit_y1;

**y2 on y0;
disp "baseline score";
areg y2_nts_level_mean y0_nts  incentive y0_nts_int_inc if inlist(school_treatment,1,4,5) & cheaters==0, absorb(U_MC) cluster(apfschoolcode);
estimates store bl_score_y2;

**y1 on y0;
disp "baseline score";
areg y1_nts_level_mean y0_nts  incentive y0_nts_int_inc if inlist(school_treatment,1,4,5), absorb(U_MC) cluster(apfschoolcode);
estimates store bl_score_y1;


**y2 on y0;
disp "SC/ST";
areg y2_nts_level_mean y0_nts  incentive SC_ST SC_ST_int_inc if inlist(school_treatment,1,4,5) & cheaters==0, absorb(U_MC) cluster(apfschoolcode);
estimates store SC_ST_y2;

**y1 on y0;
disp "SC/ST";
areg y1_nts_level_mean y0_nts  incentive SC_ST SC_ST_int_inc if inlist(school_treatment,1,4,5) , absorb(U_MC) cluster(apfschoolcode);
estimates store SC_ST_y1;


**y2 on y0;
disp "Male";
areg y2_nts_level_mean y0_nts  incentive Male Male_int_inc if inlist(school_treatment,1,4,5) & cheaters==0, absorb(U_MC) cluster(apfschoolcode);
estimates store gender_y2;

**y1 on y0;
disp "Male";
areg y1_nts_level_mean y0_nts  incentive Male Male_int_inc if inlist(school_treatment,1,4,5) , absorb(U_MC) cluster(apfschoolcode);
estimates store gender_y1;

estout log_schl_enr_y2 proxy_y2 infra_y2 hh_asset_y2  parent_lit_y2  SC_ST_y2  gender_y2 bl_score_y2 , stats(N r2)  cells(b(fmt(3)) se(par star fmt(3)))starlevels(* 0.10 ** 0.05 *** .01 );
estout log_schl_enr_y1 proxy_y1 infra_y1 hh_asset_y1  parent_lit_y1  SC_ST_y1  gender_y1 bl_score_y1 , stats(N r2)  cells(b(fmt(3)) se(par star fmt(3)))starlevels(* 0.10 ** 0.05 *** .01 );

log close;
