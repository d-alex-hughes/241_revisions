#delimit;
clear;
set more off;
capture log close;
set logtype text;

cd "~/Google Drive/David Reiley-Broockman Field Experiments Class/Data/Teacher Performance Pay - Replication Files/data/dta";

*log using stata\\logs\\Incentives_JPE_table6.txt, replace;

use Incentives_JPE_analysis_starter_file.dta, clear;


preserve;

bysort hplstudentkey sub : keep if _n==1;

drop level;

drop y2_nts_sub_mean y1_nts_sub_mean y0_nts_sub_mean;

**reshaping file to make it wide on subject;

keep hplstudentkey sub y1_nts_evs_sc y1_nts_evs_ss y2_nts_evs_sc y2_nts_evs_ss y0_nts school_treatment U_MC apfschoolcode incentive GI cheaters;


reshape wide y0_nts, i(hplstudentkey) j(sub);


foreach var in  y0_nts  {;
rename `var'1 `var'_maths;
rename `var'2 `var'_telugu;
};

outsheet using "Incentives_JPE_table6_panelA_INT.csv", comma replace

/*

save data\dta\Incentives_JPE_table6_panelA_INT.dta, replace;


**PANEL A;

**y1 on y0;
areg  y1_nts_evs_sc y0_nts_maths y0_nts_telugu incentive if inlist(school_treatment,1,4,5) , absorb(U_MC) cluster(apfschoolcode);
estimates store evs_sc1;

areg  y1_nts_evs_ss y0_nts_maths y0_nts_telugu incentive if inlist(school_treatment,1,4,5) , absorb(U_MC) cluster(apfschoolcode);
estimates store evs_ss1;

**y2 on y0;
areg  y2_nts_evs_sc y0_nts_maths y0_nts_telugu incentive if inlist(school_treatment,1,4,5) & cheaters==0 , absorb(U_MC) cluster(apfschoolcode);
estimates store evs_sc2;

areg  y2_nts_evs_ss y0_nts_maths y0_nts_telugu incentive if inlist(school_treatment,1,4,5) & cheaters==0 , absorb(U_MC) cluster(apfschoolcode);
estimates store evs_ss2;

estout evs_sc1 evs_ss1 evs_sc2 evs_ss2,stats(N r2)  cells(b(fmt(3) star) se(par fmt(3)))starlevels(* 0.10 ** 0.05 *** .01 );

restore;



**PANEL B;

**Reducing the file to one observation per student per subject per year, i.e. removing the level variables;
bysort hplstudentkey sub : keep if _n==1;

drop level;

drop y2_nts_sub_mean y1_nts_sub_mean y0_nts_sub_mean;

keep y1_nts_level_mean y2_nts_level_mean y0_nts  y2_nts_evs y2_nts_evs_sc y2_nts_evs_ss incentive input II GI VV BG control infra_index_mean prox_index_mean  y1_nts_level_mean y2_nts_level_mean y1_nts_evs_sc y1_nts_evs_ss  prox_index_y1 infra_index_y1 prox_index_y2 infra_index_y2  Male SC ST OBC hh_affluence_index parent_literacy_index hplstudentkey class* apfschoolcode  school_treatment U_MC* sub cheaters;


**reshaping file to make it wide on subject;

reshape wide y0_nts y1_nts_level_mean y2_nts_level_mean, i(hplstudentkey) j(sub);


foreach var in  y0_nts  y1_nts_level_mean  y2_nts_level_mean {;
rename `var'1 `var'_maths;
rename `var'2 `var'_telugu;
};

drop class_y0;

**reshaping file to make it long on year;

forvalues i=1/2 {;
rename y`i'_nts_evs_sc nts_evs_sc`i';
rename y`i'_nts_evs_ss nts_evs_ss`i';
rename y`i'_nts_level_mean_maths nts_level_mean_maths`i';
rename y`i'_nts_level_mean_telugu nts_level_mean_telugu`i';
rename class_y`i' class`i';
rename prox_index_y`i' prox_index`i'; 
rename infra_index_y`i' infra_index`i';
};

reshape long nts_evs_sc nts_evs_ss nts_level_mean_maths nts_level_mean_telugu class prox_index infra_index, i(hplstudentkey) j(year);



tsset hplstudentkey year;

gen lag_nts_level_mean_maths=l.nts_level_mean_maths;
gen lag_nts_level_mean_telugu=l.nts_level_mean_telugu;

tab U_MC, gen(U_MC);

replace cheaters=0 if year==1;

save data\dta\Incentives_JPE_table6_panelB_INT.dta, replace;


**step 1 : generate predicted maths and language scores for all schools from a regression of y1 scores on y0 scores for just the control schools;



**YEAR 1;
quietly : reg nts_level_mean_maths y0_nts_maths prox_index infra_index  Male SC ST OBC parent_literacy_index hh_affluence_index U_MC1 - U_MC50  if inlist(school_treatment,1) & year==1 ,  cluster(apfschoolcode);

predict nts_level_mean_mat_pred_y1 if year==1 , xb;
predict nts_level_mean_mat_resid_y1 if year==1, residuals;

quietly : reg nts_level_mean_telugu y0_nts_telugu prox_index infra_index  Male SC ST OBC parent_literacy_index hh_affluence_index U_MC1 - U_MC50  if inlist(school_treatment,1) & year==1 ,  cluster(apfschoolcode);

predict nts_level_mean_tel_pred_y1 if year==1, xb;
predict nts_level_mean_tel_resid_y1 if year==1, residuals;


**YEAR 2;
quietly : reg nts_level_mean_maths y0_nts_maths prox_index infra_index Male SC ST OBC parent_literacy_index hh_affluence_index U_MC1 - U_MC50 if inlist(school_treatment,1) & year==2 & cheaters==0, cluster(apfschoolcode);

predict nts_level_mean_mat_pred_y2 if year==2, xb;
predict nts_level_mean_mat_resid_y2 if year==2, residuals;

quietly : reg nts_level_mean_telugu y0_nts_telugu prox_index infra_index  Male SC ST OBC parent_literacy_index hh_affluence_index U_MC1 - U_MC50  if inlist(school_treatment,1) & year==2 & cheaters==0,  cluster(apfschoolcode);

predict nts_level_mean_tel_pred_y2 if year==2, xb;
predict nts_level_mean_tel_resid_y2 if year==2, residuals;

foreach sub in mat tel {;
gen nts_level_mean_`sub'_pred=nts_level_mean_`sub'_pred_y1 if year==1;
replace  nts_level_mean_`sub'_pred=nts_level_mean_`sub'_pred_y2 if year==2;

gen nts_level_mean_`sub'_resid=nts_level_mean_`sub'_resid_y1 if year==1;
replace  nts_level_mean_`sub'_resid=nts_level_mean_`sub'_resid_y2 if year==2;
};



**step 2 : regress the evs scores on these predicted scores , the residual scores, ;

**(1). Are the spillovers for science / social science larger from gains in math or from gains in reading;


**year 1 and year 2 combined science;
areg nts_evs_sc nts_level_mean_mat_pred nts_level_mean_tel_pred nts_level_mean_mat_resid nts_level_mean_tel_resid if inlist(school_treatment,1), absorb(U_MC) cluster(apfschoolcode);
 
**year 1 and year 2 combined social science;
areg nts_evs_ss nts_level_mean_mat_pred nts_level_mean_tel_pred nts_level_mean_mat_resid nts_level_mean_tel_resid if inlist(school_treatment,1), absorb(U_MC) cluster(apfschoolcode);
 
 
**year 1 science;
areg nts_evs_sc nts_level_mean_mat_pred nts_level_mean_tel_pred nts_level_mean_mat_resid nts_level_mean_tel_resid if inlist(school_treatment,1) & year==1, absorb(U_MC) cluster(apfschoolcode);
 
**year 1 social science;
areg nts_evs_ss nts_level_mean_mat_pred nts_level_mean_tel_pred nts_level_mean_mat_resid nts_level_mean_tel_resid if inlist(school_treatment,1) & year==1, absorb(U_MC) cluster(apfschoolcode);
 
**year 2 science;
areg nts_evs_sc nts_level_mean_mat_pred nts_level_mean_tel_pred nts_level_mean_mat_resid nts_level_mean_tel_resid if inlist(school_treatment,1) & year==2 & cheaters==0, absorb(U_MC) cluster(apfschoolcode);
 
**year 2 social science;
areg nts_evs_ss nts_level_mean_mat_pred nts_level_mean_tel_pred nts_level_mean_mat_resid nts_level_mean_tel_resid if inlist(school_treatment,1) & year==2 & cheaters==0, absorb(U_MC) cluster(apfschoolcode);




**(2). Are the results in social science  and science being stronger in incentive schools just from direct spill overs of higher math and language scores or are they more than just direct spill overs;

gen inc_int_mat_pred=incentive*nts_level_mean_mat_pred;
gen inc_int_tel_pred=incentive*nts_level_mean_tel_pred;

gen inc_int_mat_resid=incentive*nts_level_mean_mat_resid;
gen inc_int_tel_resid=incentive*nts_level_mean_tel_resid;


**WITH INCENTIVE TERMS;

**year 1 science  with incentive dummy and incentive interacted with residuals;
areg nts_evs_sc nts_level_mean_mat_pred nts_level_mean_tel_pred nts_level_mean_mat_resid nts_level_mean_tel_resid incentive inc_int_mat_resid inc_int_tel_resid  if year==1 & inlist(school_treatment,1,4,5), absorb(U_MC) cluster(apfschoolcode);
estimates store reg1;

test nts_level_mean_mat_resid=nts_level_mean_tel_resid;
 
**year 1 social science  with incentive dummy and incentive interacted with residuals;
areg nts_evs_ss nts_level_mean_mat_pred nts_level_mean_tel_pred nts_level_mean_mat_resid nts_level_mean_tel_resid incentive inc_int_mat_resid inc_int_tel_resid  if year==1 & inlist(school_treatment,1,4,5), absorb(U_MC) cluster(apfschoolcode);
estimates store reg2;

test nts_level_mean_mat_resid=nts_level_mean_tel_resid;


**year 2 science  with incentive dummy and incentive interacted with residuals;
areg nts_evs_sc nts_level_mean_mat_pred nts_level_mean_tel_pred nts_level_mean_mat_resid nts_level_mean_tel_resid incentive inc_int_mat_resid inc_int_tel_resid  if year==2 & inlist(school_treatment,1,4,5) & cheaters==0, absorb(U_MC) cluster(apfschoolcode);
estimates store reg3;

test nts_level_mean_mat_resid=nts_level_mean_tel_resid;

 
**year 2 social science  with incentive dummy and incentive interacted with residuals;
areg nts_evs_ss nts_level_mean_mat_pred nts_level_mean_tel_pred nts_level_mean_mat_resid nts_level_mean_tel_resid incentive inc_int_mat_resid inc_int_tel_resid  if year==2 & inlist(school_treatment,1,4,5) & cheaters==0, absorb(U_MC) cluster(apfschoolcode);
estimates store reg4;

test nts_level_mean_mat_resid=nts_level_mean_tel_resid;


estout reg1 reg2 reg3 reg4 ,stats(N r2)  cells(b(fmt(3) star) se(par  fmt(3)))starlevels(* 0.10 ** 0.05 *** .01 );
 
 
**WITHOUT THE INCENTIVE TERMS;


**year 1 science  with incentive dummy and incentive interacted with residuals;
areg nts_evs_sc nts_level_mean_mat_pred nts_level_mean_tel_pred nts_level_mean_mat_resid nts_level_mean_tel_resid incentive  if year==1 & inlist(school_treatment,1,4,5), absorb(U_MC) cluster(apfschoolcode);
estimates store reg1;

test nts_level_mean_mat_resid=nts_level_mean_tel_resid;
 
**year 1 social science  with incentive dummy and incentive interacted with residuals;
areg nts_evs_ss nts_level_mean_mat_pred nts_level_mean_tel_pred nts_level_mean_mat_resid nts_level_mean_tel_resid incentive if year==1 & inlist(school_treatment,1,4,5), absorb(U_MC) cluster(apfschoolcode);
estimates store reg2;

test nts_level_mean_mat_resid=nts_level_mean_tel_resid;


**year 2 science  with incentive dummy and incentive interacted with residuals;
areg nts_evs_sc nts_level_mean_mat_pred nts_level_mean_tel_pred nts_level_mean_mat_resid nts_level_mean_tel_resid incentive if year==2 & inlist(school_treatment,1,4,5) & cheaters==0, absorb(U_MC) cluster(apfschoolcode);
estimates store reg3;

test nts_level_mean_mat_resid=nts_level_mean_tel_resid;

 
**year 2 social science  with incentive dummy and incentive interacted with residuals;
areg nts_evs_ss nts_level_mean_mat_pred nts_level_mean_tel_pred nts_level_mean_mat_resid nts_level_mean_tel_resid incentive if year==2 & inlist(school_treatment,1,4,5) & cheaters==0, absorb(U_MC) cluster(apfschoolcode);
estimates store reg4;

test nts_level_mean_mat_resid=nts_level_mean_tel_resid;


estout reg1 reg2 reg3 reg4 ,stats(N r2)  cells(b(fmt(3) star) se(par  fmt(3)))starlevels(* 0.10 ** 0.05 *** .01 );


log close;
