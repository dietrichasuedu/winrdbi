%  Understanding Databases: Concepts and Practice
%  S. W. Dietrich
%  Chapter 5 SQL: An Introduction to Querying
%  Abstract Division Example
%
%  abTable(a,b)
%       primary key (a, b)
%  bTable(b)
%       primary key (b)


sql_divisionExistential :=
  select 	distinct T.a
  from 	abTable T
  where 	not exists 	
	(select * 
	 from    bTable B
	 where not exists
		(select * 
		 from abTable AB
		 where AB.a=T.a and AB.b=B.b));


sql_CountAB :=
  select 	AB.a, count(distinct AB.b) as related_bs
  from 	abTable AB
  where 	AB.b in (select b from bTable)
  group by 	AB.a;

sql_CountB := 
  select count(distinct b) as b_Count 
  from bTable;

sql_divisionCounting :=
  select 	C.a
  from 	sql_CountAB C
  where 	C.related_bs = (select b_Count from sql_CountB);
