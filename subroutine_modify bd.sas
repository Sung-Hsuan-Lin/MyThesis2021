/*********************************modify birthday**********************************/
/*1562筆id有多筆不同的birthday                                                                                            */
/*以處理1為優先處理方式，如遇無法處理者才使用處理2或處理3方式進行                     */
/*  處理1. 選出現次數最多的生日作為主要生日                                                                  */
/*  處理2. 同筆id, 不同birthday且姓氏相同時，則選第一筆出現的birthday作為該id的生日*/
/*  處理3. 同筆id, 不同birthday且名字相同時，則選第一筆出現的birthday作為該id的生日*/
/* 如以上三種處理方式皆無法分辨該筆id的生日時，則判定同id不同birthday為不同人   */
/********************************************************************************/
proc sort data=new.id_data;by id funcdate;run;
proc sql; /*將id_data檔建立序號*/
   create table row as/*4752290 rows and 22 columns*/
   select monotonic() as row_id, *
   from new.id_data
   order by id, funcdate;
quit;

proc sql; /*5162筆id有不同bd，共56405筆資料*/
   create table bd1 as /*5162 rows and 1 columns*/
   select distinct id
   from (select distinct id, birthday from row)
   group by id
   having count(birthday)>1
   order by id;
quit;

/*處理1. 選出現次數最多的生日作為主要生日---------------------------------------------------------*/
proc sql;/*有4095筆id可以用此方法*/
/*計算每筆bd出現的次數*/
   create table bd2 as /*6199 rows (5162筆id) and 3 columns*/
   select distinct id, birthday, nbd
   from (select *, count(birthday) as nbd from row where id in (select id from bd1) group by id, birthday )
   group by id
   having nbd=max(nbd);

   create table bd3 as /*65194 rows (4095筆id) and 3 columns*/
   select a.row_id, a.id, b.birthday
   from row as a left join bd2 as b
   on a.id=b.id
   where a.id in (select id from bd2 group by id having count(birthday)=1)
   order by a.id, b.birthday;
quit;

/*處理2. 同筆id, 不同birthday且姓氏相同時，則選第一筆出現的birthday作為該id的生日--*/
proc sql; /*有941筆id可用此方法*/
   create table bd4 as/*1155 rows and 4 columns*/
   select distinct a.row_id, a.id, a.birthday, b.name
   from row as a left join raw.ap as b
   on (a.id=b.id) and (a.hospid=b.hospid) and (a.birthday=b.birthday)
   where a.id in (select distinct id from bd2 group by id having count(birthday)>1)
   group by a.id, substr(b.name,1,2)
   having (a.row_id=min(a.row_id))
   order by row_id, id, birthday;

   create table bd5 as/*3193 rows (941筆id) and 3 columns*//**/
   select distinct a.row_id, a.id, b.birthday
   from row as a left join bd4 as b
   on a.id=b.id
   where a.id in (select id from bd4 group by id having count(birthday)=1)
   order by id;
quit;

/*處理3. 同筆id, 不同birthday且名字相同時，則選第一筆出現的birthday作為該id的生日--*/
proc sql;/*有13筆id可以用此方法*/
   create table bd6 as/* 228 rows and 4 columns*/
   select *
   from (select * from bd4 where id not in (select id from bd5))
   group by id, substr(name,3,4)
   having row_id=min(row_id);

   create table bd7 as/*28 rows(13筆id) and 3 columns*//**/
   select a.row_id, a.id, b.birthday
   from row as a left join bd6 as b
   on a.id=b.id
   where a.id in (select id from bd6 group by id having count(birthday)=1);
quit;

/*如以上三種處理方式皆無法分辨該筆id的生日時，則判定同id不同birthday為不同人----*/
proc sql; /*113筆id有多筆birthday表示為不同人*/
   create table bd8 as/* 286 rows and 3 columns*/
   select row_id, id, birthday
   from row
   where id in (select id from bd6 where id not in (select id from bd7));
quit;

/*modify birthday-------------------------------------------------------------------------------------------------*/
data bd9; /*68415 rows and 3 columns*/
   set bd3 bd5 bd7;
run;

proc sql;
   create table bd10 as /*68415 rows and 22 columns*/
   select a.*, b.birthday
   from row (drop=birthday) as a left join bd9 as b
   on a.row_id=b.row_id
   where a.row_id in (select row_id from bd9);

   create table new.bd_data as /*4752290 rows and 22 columns*/
   select *
   from (select * from row where row_id not in (select row_id from bd10))
   union all
   select row_id, hospid, id, birthday, funcdate, FirstTreatDate, CureStage, Cure_Type, 
            SmokeDayNum, SmokeScore, CureWeek, DrugIngredient, cureitem, 
            f1, c1, b3, nct1, nct2, nct3, nqd1, nqd2, nqd3
   from bd10;
quit;

/*刪除不要的暫存檔-------------------------------------------------------------------------------------------*/
%macro bd(n1,n2);
      %do n=&n1 %to &n2;
              proc delete 
                 data=bd&n;
              run;
      %end;
%mend bd;

%bd(1,10);
