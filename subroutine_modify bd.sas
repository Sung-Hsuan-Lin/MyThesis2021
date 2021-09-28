/*********************************modify birthday**********************************/
/*1562��id���h�����P��birthday                                                                                            */
/*�H�B�z1���u���B�z�覡�A�p�J�L�k�B�z�̤~�ϥγB�z2�γB�z3�覡�i��                     */
/*  �B�z1. ��X�{���Ƴ̦h���ͤ�@���D�n�ͤ�                                                                  */
/*  �B�z2. �P��id, ���Pbirthday�B�m��ۦP�ɡA�h��Ĥ@���X�{��birthday�@����id���ͤ�*/
/*  �B�z3. �P��id, ���Pbirthday�B�W�r�ۦP�ɡA�h��Ĥ@���X�{��birthday�@����id���ͤ�*/
/* �p�H�W�T�سB�z�覡�ҵL�k����ӵ�id���ͤ�ɡA�h�P�w�Pid���Pbirthday�����P�H   */
/********************************************************************************/
proc sort data=new.id_data;by id funcdate;run;
proc sql; /*�Nid_data�ɫإߧǸ�*/
   create table row as/*4752290 rows and 22 columns*/
   select monotonic() as row_id, *
   from new.id_data
   order by id, funcdate;
quit;

proc sql; /*5162��id�����Pbd�A�@56405�����*/
   create table bd1 as /*5162 rows and 1 columns*/
   select distinct id
   from (select distinct id, birthday from row)
   group by id
   having count(birthday)>1
   order by id;
quit;

/*�B�z1. ��X�{���Ƴ̦h���ͤ�@���D�n�ͤ�---------------------------------------------------------*/
proc sql;/*��4095��id�i�H�Φ���k*/
/*�p��C��bd�X�{������*/
   create table bd2 as /*6199 rows (5162��id) and 3 columns*/
   select distinct id, birthday, nbd
   from (select *, count(birthday) as nbd from row where id in (select id from bd1) group by id, birthday )
   group by id
   having nbd=max(nbd);

   create table bd3 as /*65194 rows (4095��id) and 3 columns*/
   select a.row_id, a.id, b.birthday
   from row as a left join bd2 as b
   on a.id=b.id
   where a.id in (select id from bd2 group by id having count(birthday)=1)
   order by a.id, b.birthday;
quit;

/*�B�z2. �P��id, ���Pbirthday�B�m��ۦP�ɡA�h��Ĥ@���X�{��birthday�@����id���ͤ�--*/
proc sql; /*��941��id�i�Φ���k*/
   create table bd4 as/*1155 rows and 4 columns*/
   select distinct a.row_id, a.id, a.birthday, b.name
   from row as a left join raw.ap as b
   on (a.id=b.id) and (a.hospid=b.hospid) and (a.birthday=b.birthday)
   where a.id in (select distinct id from bd2 group by id having count(birthday)>1)
   group by a.id, substr(b.name,1,2)
   having (a.row_id=min(a.row_id))
   order by row_id, id, birthday;

   create table bd5 as/*3193 rows (941��id) and 3 columns*//**/
   select distinct a.row_id, a.id, b.birthday
   from row as a left join bd4 as b
   on a.id=b.id
   where a.id in (select id from bd4 group by id having count(birthday)=1)
   order by id;
quit;

/*�B�z3. �P��id, ���Pbirthday�B�W�r�ۦP�ɡA�h��Ĥ@���X�{��birthday�@����id���ͤ�--*/
proc sql;/*��13��id�i�H�Φ���k*/
   create table bd6 as/* 228 rows and 4 columns*/
   select *
   from (select * from bd4 where id not in (select id from bd5))
   group by id, substr(name,3,4)
   having row_id=min(row_id);

   create table bd7 as/*28 rows(13��id) and 3 columns*//**/
   select a.row_id, a.id, b.birthday
   from row as a left join bd6 as b
   on a.id=b.id
   where a.id in (select id from bd6 group by id having count(birthday)=1);
quit;

/*�p�H�W�T�سB�z�覡�ҵL�k����ӵ�id���ͤ�ɡA�h�P�w�Pid���Pbirthday�����P�H----*/
proc sql; /*113��id���h��birthday��ܬ����P�H*/
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

/*�R�����n���Ȧs��-------------------------------------------------------------------------------------------*/
%macro bd(n1,n2);
      %do n=&n1 %to &n2;
              proc delete 
                 data=bd&n;
              run;
      %end;
%mend bd;

%bd(1,10);
