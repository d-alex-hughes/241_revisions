#delimit;
**master_incentives_JPE_jan_2011.do;

**DO FILES FOR CREATING TABLES ;

**table 1 A (Test Scores , Student Attrition);
do stata\Incentives_JPE_table1A.do;

**table 1 B (Teacher Turnover, Teacher Attrition);
do stata\Incentives_JPE_table1B.do;

**table 2 (Main Treatment Effects);
do stata\Incentives_JPE_table2.do;

**table 2 (Student Attrition);
do stata\Incentives_JPE_table2_SA.do;	

**table 3 and 4 (table 3 : Repeat and non-repeat , Table 4 : mcq and non-mcq);

**analysis files;
do stata\Incentives_JPE_table3_table4.do;

**table 5 A;
do stata\Incentives_JPE_table5A.do;

**table 5 B;
do stata\Incentives_JPE_table5B.do;

*table 6;
do stata\Incentives_JPE_table6.do;

**table 7;
do stata\Incentives_JPE_table7.do;

**table 8;
do stata\Incentives_JPE_table8.do;




**Graphs;

**Figure 3;
do stata\Incentives_JPE_Figure_3.do;

**Figure 4;
do stata\Incentives_JPE_Figure_4.do;

**Figure 5;
do stata\Incentives_JPE_Figure_5.do;







