/************************modify id*************************/
/*1. 9碼id: 126筆                                          */
/*2. 少於9碼id: 4筆                                        */
/*不正確id處理：利用merge_data檔找出可能的正確id             */
/**********************************************************/
proc sql;
  create table w_id as /*156 rows and 22 columns*/
  select *, case when (length(id)=9) and (substr(id,1,1) in ("1", "2")) and (cats(id,birthday) in (select cats(substr(id,2,9),birthday) from new.merge_data where length(id)=10)) then 1
                 when (length(id)=9) and (substr(id,1,1) not in ("1" ,"2")) and (cats(substr(id,1,1),hospid,birthday) in (select cats(substr(id,1,1),hospid,birthday) from new.merge_data where length(id)=10)) then 2
		 when (length(id)<=8) and (cats(hospid,birthday) in (select cats(hospid,birthday) from new.merge_data where length(id)=10)) then 3
		 else . end as fixid
  from new.merge_data
  where calculated fixid^=.;
quit;

%macro fix(table, rule, num)/des="fix id";
  proc sql;
    create table &table as
    select distinct b.id as id2, a.*
    from w_id as a left join new.merge_data as b
    on &rule
    where a.fixid=&num and length(b.id)=10;
  quit;
%mend fix;
%fix(w1, cats(a.id,a.birthday)=cats(substr(b.id,2,9),b.birthday), 1); /*90 rows and 23 columns*/
%fix(w2, cats(substr(a.id,1,1),a.hospid,a.birthday)=cats(substr(b.id,1,1),b.hospid,b.birthday), 2); /*63 rows and 23 columns*/
%fix(w3, cats(a.hospid,a.birthday)=cats(b.hospid,b.birthday), 3); /*4 rows and 23 columns*/

data r_id ; /*156 observations and 23 variables*/
  set w1 w2 w3;
  where id2^="A124355290";
run;

proc sql;
  create table new.id_data as /*4752209 rows and 21 columns*/
  select *
  from new.merge_data
  where id not in (select id from r_id)
  union all
  select hospid, id2 as id, birthday, funcdate, firsttreatdate, curestage, cure_type, 
         smokedaynum, smokescore, cureweek, DrugIngredient, cureitem, 
         f1, c1, b3, nct1, nct2, nct3, nqd1, nqd2, nqd3
  from r_id;
quit;

proc delete 
  data=r_id w1 w2 w3 w_id;
run;
