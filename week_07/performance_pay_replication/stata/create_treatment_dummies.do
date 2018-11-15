#delimit;


**generate treatment dummies;


**generating treatment dummies for different regressions;

cap rename tre_code treatment_code;

cap tab treatment_code, gen(treatment);

cap tab school_treatment, gen(treatment);

cap tab treatmentcode, gen(treatment);

cap tab treatment, gen(treatment);

cap gen incentive=treatment4==treatment5==0;

cap gen input=treatment2==treatment3==0;

cap gen II=treatment5;

cap gen GI=treatment4;

cap gen VV=treatment2;

cap gen BG=treatment3;

cap gen control=treatment1;

cap gen pure_control=treatment6;