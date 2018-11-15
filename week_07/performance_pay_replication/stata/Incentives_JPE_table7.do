
#delimit;
clear;
set more off;
capture log close;
set logtype text;

log using stata\\logs\\Incentives_JPE_table7.txt, replace;



use data\dta\Incentives_JPE_analysis_starter_file.dta, clear;


local y1_y0_controls "prox_index_y1 infra_index_y1  Male SC ST OBC  parent_literacy_index hh_affluence_index";

local y2_y1_controls "prox_index_y2 infra_index_y2  Male SC ST OBC parent_literacy_index hh_affluence_index";

local y2_y0_controls "prox_index_mean infra_index_mean   Male SC ST OBC parent_literacy_index hh_affluence_index";

	
**keeping only one observation per student per subject (i.e. removing round LEL or HEL as a dimension);
bysort hplstudentkey sub : keep if _n==1;

drop level;

save data\dta\Incentives_JPE_analysis_starter_file_INT.dta, replace;



*table 7: Impact of group incentive vs. individual incentives;




************year 1 on year 0*******;


areg y1_nts_level_mean y0_nts II GI if inlist(school_treatment,1,4,5), absorb(U_MC) cluster(apfschoolcode);
estimates store y1_y0_comb;

test II=GI;

areg y1_nts_level_mean y0_nts II GI if sub==1 & inlist(school_treatment,1,4,5), absorb(U_MC) cluster(apfschoolcode);
estimates store y1_y0_m;

test II=GI;

areg y1_nts_level_mean y0_nts II GI if sub==2 & inlist(school_treatment,1,4,5), absorb(U_MC) cluster(apfschoolcode);
estimates store y1_y0_t;

test II=GI;

**********year 2 on year 1**********;

areg y2_nts_level_mean y1_nts_level_mean II GI if inlist(school_treatment,1,4,5)& cheaters==0, absorb(U_MC) cluster(apfschoolcode);
estimates store y2_y1_comb;

test II=GI;

areg y2_nts_level_mean y1_nts_level_mean II GI if sub==1 & inlist(school_treatment,1,4,5)& cheaters==0, absorb(U_MC) cluster(apfschoolcode);
estimates store y2_y1_m;

test II=GI;

areg y2_nts_level_mean y1_nts_level_mean II GI if sub==2 & inlist(school_treatment,1,4,5)& cheaters==0, absorb(U_MC) cluster(apfschoolcode);
estimates store y2_y1_t;

test II=GI;

*****year 2 on year 0********;

areg y2_nts_level_mean y0_nts II GI if inlist(school_treatment,1,4,5) & cheaters==0, absorb(U_MC) cluster(apfschoolcode);
estimates store y2_y0_comb;

test II=GI;

areg y2_nts_level_mean y0_nts II GI if sub==1 & inlist(school_treatment,1,4,5) & cheaters==0, absorb(U_MC) cluster(apfschoolcode);
estimates store y2_y0_m;

test II=GI;

areg y2_nts_level_mean y0_nts II GI if sub==2 & inlist(school_treatment,1,4,5) & cheaters==0, absorb(U_MC) cluster(apfschoolcode);
estimates store y2_y0_t;

test II=GI;

estout y1_y0_comb  y1_y0_m  y1_y0_t y2_y1_comb  y2_y1_m  y2_y1_t y2_y0_comb  y2_y0_m  y2_y0_t  ,stats(N r2)  cells(b(fmt(3) star) se(par fmt(3)))starlevels(* 0.10 ** 0.05 *** .01 );





log close; 


