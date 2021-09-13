/*create library*/
libname new "F:\portfolio\new"; /*store the new data*/
libname raw "F:\portfolio\raw"; /*store the raw data*/

/*import CVS data (raw data): 
dbo_MhbtQsData=QsData,
dbo_MhbtAgentPatient=AP,
dbo_MhbtQsCure=QsCure,
dbo_GenDrugBasic=GDB, 
dbo_HospContractType=Hosp, 
dbo_HospBasic=HospBasic,
*/

%macro impdata(data, name)/des="import data";
proc import
   datafile="&data"
   out=raw.&name
   dbms=csv 
   replace;
   getnames=yes;
   guessingrows=1000 ;
run;
%MEND impdata;
%impdata(F:\Smoking cessation\dbo_MhbtQsData.txt, QsData); /* 3870723 observations, 44 variables*/
%impdata(F:\Smoking cessation\dbo_MhbtAgentPatient.txt, AP); /*1041225 observations, 16 variables*/
%impdata(F:\Smoking cessation\dbo_MhbtQsCure.txt, QsCure); /*3162273 observations, 9 variables*/
%impdata(F:\Smoking cessation\dbo_GenDrugBasic.txt, GDB); /* 60 observations and 10 variables*/
%impdata(F:\Smoking cessation\dbo_HospContractType.txt, Hosp); /* 6445 observations and 5 variables*/
%impdata(F:\Smoking cessation\dbo_HospBasic.txt, HospBasic); /* 6299 observations and 34 variables*/
%impdata(F:\Smoking cessation\short_6.txt, S6); /*283526 observations and 16 variables*/
%impdata(F:\Smoking cessation\long_7B.txt, L7B);/*3000 observations and 41 variables.*/
%impdata(F:\Smoking cessation\long_7B2.txt, L7B2); /*9000 observations and 31 variables*/

proc contents data=raw.L7a;run; /*41000 observations, 36 variables*/

proc catalog catalog=sasmacr;/*check macro*/
    contents;
run;
