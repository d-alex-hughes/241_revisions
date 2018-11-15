#delimit;
clear;
set more off;
capture log close;
set logtype text;

log using stata\\logs\\Incentives_JPE_table2.txt, replace;


use data\dta\Incentives_JPE_analysis_starter_file.dta, clear;


local y1_y0_controls "prox_index_y1 infra_index_y1  Male SC ST OBC  parent_literacy_index hh_affluence_index";

local y2_y1_controls "prox_index_y2 infra_index_y2  Male SC ST OBC parent_literacy_index hh_affluence_index";

local y2_y0_controls "prox_index_mean infra_index_mean   Male SC ST OBC parent_literacy_index hh_affluence_index";


	
**keeping only one observation per student per subject (i.e. removing round LEL or HEL as a dimension);
bysort hplstudentkey sub : keep if _n==1;

drop level;

save data\dta\Incentives_JPE_analysis_starter_file_INT.dta, replace;

areg y1_nts_level_mean y0_nts incentive if inlist(school_treatment,1,4,5)  , absorb(U_MC) cluster(apfschoolcode);
estimates store y1_y0_comb_nc;

areg y1_nts_level_mean y0_nts incentive `y1_y0_controls' if inlist(school_treatment,1,4,5)  , absorb(U_MC) cluster(apfschoolcode);
estimates store y1_y0_comb_c;

areg y2_nts_level_mean y1_nts_level_mean incentive if inlist(school_treatment,1,4,5) & cheaters==0, absorb(U_MC) cluster(apfschoolcode);
estimates store y2_y1_comb_nc;

areg y2_nts_level_mean y1_nts_level_mean incentive `y1_y0_controls' if inlist(school_treatment,1,4,5) & cheaters==0, absorb(U_MC) cluster(apfschoolcode);
estimates store y2_y1_comb_c;

areg y2_nts_level_mean y0_nts incentive if inlist(school_treatment,1,4,5) & cheaters==0, absorb(U_MC) cluster(apfschoolcode);
estimates store y2_y0_comb_nc;

areg y2_nts_level_mean y0_nts incentive `y1_y0_controls' if inlist(school_treatment,1,4,5) & cheaters==0, absorb(U_MC) cluster(apfschoolcode);
estimates store y2_y0_comb_c;


estout y1_y0_comb_nc y1_y0_comb_c y2_y1_comb_nc y2_y1_comb_c y2_y0_comb_nc y2_y0_comb_c , stats(N r2) keep(y0_nts y1_nts_level_mean incentive) cells(b(fmt(3)) se(par star fmt(3)))starlevels(* 0.10 ** 0.05 *** .01 ) ;




*********MATHS***********;


areg y1_nts_level_mean y0_nts incentive if sub==1 & inlist(school_treatment,1,4,5)  , absorb(U_MC) cluster(apfschoolcode);
estimates store  y1_y0_m_nc;

areg y1_nts_level_mean y0_nts incentive `y1_y0_controls' if sub==1 & inlist(school_treatment,1,4,5)  , absorb(U_MC) cluster(apfschoolcode);
estimates store  y1_y0_m_c;

areg y2_nts_level_mean y1_nts_level_mean incentive if sub==1 & inlist(school_treatment,1,4,5) & cheaters==0, absorb(U_MC) cluster(apfschoolcode);
estimates store  y2_y1_m_nc;

areg y2_nts_level_mean y1_nts_level_mean incentive `y1_y0_controls' if sub==1 & inlist(school_treatment,1,4,5) & cheaters==0, absorb(U_MC) cluster(apfschoolcode);
estimates store  y2_y1_m_c;

areg y2_nts_level_mean y0_nts incentive if sub==1 & inlist(school_treatment,1,4,5) & cheaters==0, absorb(U_MC) cluster(apfschoolcode);
estimates store  y2_y0_m_nc;

areg y2_nts_level_mean y0_nts incentive `y1_y0_controls' if sub==1 & inlist(school_treatment,1,4,5) & cheaters==0, absorb(U_MC) cluster(apfschoolcode);
estimates store  y2_y0_m_c;

estout y1_y0_m_nc y1_y0_m_c y2_y1_m_nc y2_y1_m_c y2_y0_m_nc y2_y0_m_c  ,stats(N r2) keep(y0_nts y1_nts_level_mean incentive) cells(b(fmt(3)) se(par star fmt(3)))starlevels(* 0.10 ** 0.05 *** .01 );



***********TELUGU*************;


areg y1_nts_level_mean y0_nts incentive if sub==2 & inlist(school_treatment,1,4,5) , absorb(U_MC) cluster(apfschoolcode);
estimates store  y1_y0_t_nc;

areg y1_nts_level_mean y0_nts incentive `y1_y0_controls' if sub==2 & inlist(school_treatment,1,4,5)  , absorb(U_MC) cluster(apfschoolcode);
estimates store  y1_y0_t_c;

areg y2_nts_level_mean y1_nts_level_mean incentive if sub==2 & inlist(school_treatment,1,4,5) & cheaters==0, absorb(U_MC) cluster(apfschoolcode);
estimates store  y2_y1_t_nc;

areg y2_nts_level_mean y1_nts_level_mean incentive `y1_y0_controls' if sub==2 & inlist(school_treatment,1,4,5) & cheaters==0, absorb(U_MC) cluster(apfschoolcode);
estimates store  y2_y1_t_c;

areg y2_nts_level_mean y0_nts incentive if sub==2 & inlist(school_treatment,1,4,5) & cheaters==0, absorb(U_MC) cluster(apfschoolcode);
estimates store  y2_y0_t_nc;

areg y2_nts_level_mean y0_nts incentive `y1_y0_controls' if sub==2 & inlist(school_treatment,1,4,5) & cheaters==0, absorb(U_MC) cluster(apfschoolcode);
estimates store  y2_y0_t_c;

estout y1_y0_t_nc y1_y0_t_c y2_y1_t_nc y2_y1_t_c y2_y0_t_nc y2_y0_t_c  ,stats(N r2) keep(y0_nts y1_nts_level_mean incentive) cells(b(fmt(3)) se(par star fmt(3)))starlevels(* 0.10 ** 0.05 *** .01 );



log close;





