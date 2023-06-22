%  Understanding Databases: Concepts and Practice
%  S. W. Dietrich
%  Chapter 5 SQL: Introduction to Querying
%  Queries in Chapter
  
% EMPLOYEE TRAINING 
% employee(eID, eLast, eFirst, eTitle, eSalary)      primary key: eID
% technologyArea(aID, aTitle, aURL, aLeadID)      primary key: aID
%    foreign key (aLeadID) references employee(eID)
% trainingCourse(cID, cTitle, cHours, areaID)        primary key: cID
%    foreign key (areaID) references technologyArea(aID) 
% takes(eID, cID, tDate)                                           primary key: eID, cID
%    foreign key (eID) references employee(eID)
%    foreign key (cID) references trainingCourse(cID)



%  5.2 Fundamental Query Expressions

%  Table 5.1: SQL Sample Queries with 1 Table

%  sql_Managers: 
%  Which employees are managers, i.e., have the title `Manager'? 
%  (eLast, eFirst) 

sql_Managers :=
select 	eLast, eFirst
from 	employee
where 	eTitle = 'Manager';

%  sql_TitleDB01:
%  What is the title of the course with unique id `DB01'?
%  (cTitle) 

sql_TitleDB01 :=
select 	cTitle
from 	trainingCourse
where 	cID = 'DB01';

%  sql_TakesDB01:
%  Which employees took the course with unique id `DB01'?
%  (eID) 

sql_TakesDB01 :=
select 	eID
from 	takes
where 	cID = 'DB01';

%  sql_DatabaseLead:
%  What is the employee id of the lead of the `Database' technology area?
%  (aLeadID) 


sql_DatabaseLead :=
select 	aLeadID
from 	technologyArea
where 	aTitle = 'Database';

%  end Table 5.1 --------------------------------------------------------

sql_ManagersAlphabetical :=
select 	eLast, eFirst
from 	employee
where 	eTitle = 'Manager'
order by eLast;

% WinRDBI has a known issue - it can only sort all columns in the same order 
sql_TitlesAscSalariesDesc :=
select 	eTitle, eSalary
from 	employee
order by	eTitle, eSalary; 
% order by 	eTitle asc, eSalary desc;

%  Table 5.2 Reflection Queries for Table 5.1
reflection_sql_Managers :=
select 	eTitle, eLast, eFirst
from 	employee
order by	 eTitle, eLast, eFirst;

reflection_sql_TitleDB01 :=
select cID, cTitle
from trainingCourse
order by cID;

reflection_sql_TakesDB01 :=
select cID, eID
from takes
order by cID, eID;


reflection_sql_DatabaseLead :=
select aTitle, aLeadID
from technologyArea
order by aTitle;

%  end Table 5.2 --------------------------------------------------------

%  Table 5.3: SQL Sample Queries with 2 Tables
%  sql_NamesTookDB01:
%  Which employees took the course with unique id `DB01'?
%  (eLast, eFirst) 

sql_NamesTookDB01 := 
select 	E.eLast, E.eFirst
from 	employee E, takes T
where 	E.eID = T.eID and T.cID = 'DB01';

%  sql_DatesIntroDB:
%  Which dates was the course titled 'Introduction to Databases' offered?
%  (tDate) 

sql_DatesIntroDB :=
select 	distinct T.tDate
from 	takes T, trainingCourse C
where 	T.cID = C.cID and
		C.cTitle = 'Introduction to Databases';

%  sql_DatabaseCourses:
%  What courses are offered in the 'Database' technology area?
%  (cID, cTitle, cHours) 

sql_DatabaseCourses :=
select 	C.cID, C.cTitle, C.cHours
from 	trainingCourse C, technologyArea A
where 	C.areaID = A.aID and A.aTitle = 'Database';

%  sql_NamesAreaLead:
%  Which employees lead technology areas? 
%  (eLast, eFirst) 

sql_NamesAreaLead :=
select 	E.eLast, E.eFirst
from 	employee E, technologyArea A
where 	E.eID = A.aLeadID;

%  end Table 5.3 --------------------------------------------------------

%  Table 5.4: SQL Refection Queries with 2 Tables

reflection_sql_NamesTookDB01 :=
select 	T.cID, E.eLast, E.eFirst
from 	employee E, takes T
where 	E.eID = T.eID
order by 	T.cID, E.eLast, E.eFirst;

reflection_sql_DatesIntroDB :=
select 	C.cTitle, T.tDate
from 	takes T, trainingCourse C
where 	T.cID = C.cID
order by 	C.cTitle, T.tDate;

reflection_sql_DatabaseCourses :=
select 	A.aID, C.cID, C.cTitle, C.cHours
from 	trainingCourse C, technologyArea A
where 	C.areaID = A.aID
order by 	A.aID, C.cID, C.cTitle;

reflection_sql_NamesAreaLead :=
select 	A.aLeadID, E.eLast, E.eFirst
from 	employee E, technologyArea A
where  	 E.eID = A.aLeadID
order by	 A.aLeadID;

%  end Table 5.4 --------------------------------------------------------

sql_DatabaseCourses_JoinOn :=
select 	C.cID, C.cTitle, C.cHours
from 	trainingCourse C join technologyArea A on C.areaID = A.aID
where 	A.aTitle = 'Database';

sql_NamesTookDB01_NaturalJoin :=
select 	E.eLast, E.eFirst
from 	employee E natural join takes T
where 	T.cID = 'DB01';

sql_EmpsTookDatabaseCourses :=
select 	distinct T.eID
from 	(technologyArea A join trainingCourse C on A.aID = C.areaID) natural join takes T
where 	A.aTitle = 'Database'
order by T.eID;

%  5.3 Nested Queries

%  Table 5.5: Which employees have taken a training course?

sql_empsTookCoursesUnnestedWhere := 
select 	distinct E.eID, E.eLast, E.eFirst
from 	employee E, takes T
where 	E.eID = T.eID;

sql_empsTookCoursesUnnestedJoin :=
select 	distinct E.eID, E.eLast, E.eFirst
from 	employee E join takes T on E.eID = T.eID;

sql_empsTookCoursesNestedCorrelated :=
select 	E.eID, E.eLast, E.eFirst
from 	employee E
where 	exists (select * from takes T where T.eID = E.eID);

sql_empsTookCoursesNestedUncorrelated :=
select 	E.eID, E.eLast, E.eFirst
from 	employee E
where 	E.eID in (select T.eID from takes T);

%  end Table 5.5 --------------------------------------------------------

sql_WRONG_empsNoCourses :=
select distinct E.eID, E.eLast, E.eFirst
from employee E join takes T on E.eID <> T.eID;

%  Table 5.6: Which employees have not taken a training course?

sql_empsNoCoursesNestedCorrelated :=
select E.eID, E.eLast, E.eFirst
from employee E
where not exists (select * from takes T where T.eID = E.eID);

sql_empsNoCoursesNestedUncorrelated := 
select E.eID, E.eLast, E.eFirst
from employee E
where E.eID not in (select T.eID from takes T);

%  end Table 5.6 --------------------------------------------------------

sql_dbCoursesEquality :=
select 	C.cID, C.cTitle, C.cHours
from 	trainingCourse C
where 	C.areaID =
		(select A.aID
		 from 	technologyArea A
		 where 	A.aTitle = 'Database');
         
%  5.4 Set Operators

%  Table 5.7: Example SQL Queries for Set Operators

sql_ManagersUnionProjectLeads :=
select E.eID from employee E where E.eTitle='Manager'
union
select E.eID from employee E where E.eTitle='Project Lead';


sql_ManagersExceptCourses := 
(select E.eID from employee E where E.eTitle='Manager')
except
(select T.eID from takes T);

sql_ManagersIntersectCourses :=
(select E.eID from employee E where E.eTitle='Manager')
intersect
(select T.eID from takes T);

%  end Table 5.7 --------------------------------------------------------

%  Table 5.8: Alternative Example SQL Queries for Set Operators

sql_ManagersOrProjectLeads :=
select E.eID
from employee E
where E.eTitle='Manager' or E.eTitle='Project Lead';

sql_ManagersNoCourses :=
select 	E.eID
from 	employee E
where 	E.eTitle='Manager' and
		E.eID not in (select T.eID from takes T);

sql_ManagersTookCourses :=
select 	E.eID
from 	employee E
where 	E.eTitle='Manager' and
		exists (select * from takes T where E.eID = T.eID);

%  end Table 5.8 --------------------------------------------------------
        
 %  5.5 Aggregation and Grouping
 
 sql_SalariesAggregationExample :=
select 	min(E.eSalary), max(E.eSalary), avg(E.eSalary), sum(E.eSalary), count(*)
from 	employee E;

sql_SalariesAggregationExampleRenaming :=
select 	min(E.eSalary) as minsal, max(E.eSalary) as maxsal, avg(E.eSalary) as avgsal, sum(E.eSalary) as totalsal, count(*) as empcount
from 	employee E;

%  sql_EmployeesWithMinSalary:
% select 	*
% from 	employee E
% where 	E.eSalary = (select min(M.eSalary) from employee M);

%  sql_EmployeesLessThanAvgSalary:
% select 	*
% from 	employee E
% where 	E.eSalary < (select avg(M.eSalary) from employee M)
% order by 	E.eSalary desc;

sql_CountEmployeesTookCourses :=
select 	count(distinct T.eID) as empcount
from 	takes T ;

sql_CountManagersTookCourses :=
select 	count(distinct T.eID) as mgrcount
from 	takes T natural join employee E 
where 	E.eTitle = 'Manager';

sql_SalaryInfoByTitle :=
select 	E.eTitle, min(E.eSalary) as mintitle, max(E.eSalary) as maxtitle, avg(E.eSalary) as avgtitle
from 	employee E
group by E.eTitle;

sql_SalariesByTitle :=
select 	E.eTitle, E.eSalary
from 	employee E
order by E.eTitle, E.eSalary;

sql_CountByTitleTookCourses :=
select 	E.eTitle, count(distinct T.eID) as emptookcoursescount
from 	takes T natural join employee E
group by E.eTitle;

sql_CourseOfferingCount :=
select T.cID, T.tDate, count(*) as emptookoffering
from takes T
group by T.cID, T.tDate;

%  MySQL recognizes the column renaming in the having clause
sql_having := 
select 	E.eTitle, count(distinct T.eID) as emptookcoursescount
from 	takes T join employee E on T.eID = E.eID
group by 	E.eTitle
having	 emptookcoursescount >= 4;

%  5.6 Querying with NULL Values -- WinRDBI does not support null values

%  inserts a new technology area without courses or leads 
%  insert into technologyArea values ('NU','NO TITLE','NO URL', null);

%  sql_AreasWithoutLeads:
%  select aTitle
%  from   technologyArea
%  where  aLeadID is null;

%  sql_CountAreasWithLeads:
%  select count(aLeadID) as arealeadcount
%  from   technologyArea;

%  sql_AreaTitlesWithLead:
%  select A.aTitle, E.eLast, E.eFirst
%  from technologyArea A left outer join employee E on A.aLeadID = E.eID
%  order by A.aTitle;

sql_countEmpCourses :=
select T.eID, count(*) as coursecount
from   takes T
group by T.eID;

sql_countEmpNoCourses :=
select E.eID, 0 as coursecount
from  employee E
where E.eID not in (select T.eID from takes T);

%  sql_countEmpCoursesLeftOuterJoin:
%  select E.eID, count(T.cID) as coursecount
%  from   employee E left outer join takes T on E.eID = T.eID
%  group by E.eID;

%  sql_EmpLeftOuterJoinTakes:
%  select *
%  from employee E left outer join takes T on E.eID = T.eID
%  order by E.eID;

%  Special Topic: Arithmetic Expressions

sql_RaiseSalaries := 
select   1.02 * sum(E.eSalary) as totalwithraise
from     employee E;

%  5.7 Relational Completeness

%  Table 5.10 Summary of Fundamental Employee Training Queries

q_select :=
select * from employee E where E.eSalary > 100000;

 q_project :=
select distinct E.eLast, E.eFirst, E.eTitle from employee E;

q_union :=
select E.eID from employee E where E.eTitle='Manager'
union
select E.eID from employee E where E.eTitle='Project Lead';

q_difference := 
(select E.eID from employee E where E.eTitle='Manager')
except
(select T.eID from takes T);


q_CartesianProduct :=
select E.eID, C.cID from employee E, trainingCourse C;

%  end Table 5.10 --------------------------------------------------------

%  Table 5.11: SQL Summary of Additional Employee Training Queries

q_intersect :=
select E.eID from employee E where E.eTitle='Manager'
intersect
select T.eID from takes T;

q_join :=
select *
from employee E join technologyArea A on E.eID=A.aLeadID;

q_naturaljoin := 
select distinct C.cTitle, T.tDate
from trainingCourse C natural join takes T;

%  end Table 5.11 --------------------------------------------------------

