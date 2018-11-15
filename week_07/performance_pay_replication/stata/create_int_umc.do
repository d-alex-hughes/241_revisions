#delimit ;


**Date: Februrary 18, 2008;
**description: this file creates mandal code;
cap drop U_MC;
cap gen U_MC=int(apfschoolcode/100);
cap gen U_MC=int(apf_code/100);
cap gen U_MC=int(apf_school_code/100);