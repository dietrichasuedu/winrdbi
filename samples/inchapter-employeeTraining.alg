%  Understanding Databases: Concepts and Practice
%  S. W. Dietrich
%  Chapter 3 Relational Algebra
%  Queries: In Chapter

% EMPLOYEE TRAINING 
% employee(eID, eLast, eFirst, eTitle, eSalary)      primary key: eID
% technologyArea(aID, aTitle, aURL, aLeadID)      primary key: aID
%    foreign key (aLeadID) references employee(eID)
% trainingCourse(cID, cTitle, cHours, areaID)        primary key: cID
%    foreign key (areaID) references technologyArea(aID) 
% takes(eID, cID, tDate)                                           primary key: eID, cID
%    foreign key (eID) references employee(eID)
%    foreign key (cID) references trainingCourse(cID)


% 3.2.1 Filtering

% Table 3.3: Relational Algebra Sample Filtering Queries

% Which employees are managers, i.e., have the title ‘Manager’?
alg_Managers :=
	select eTitle='Manager' (employee);

%What employee titles appear in the database?
alg_Titles :=
	project eTitle (employee);

% End Table 3.3 -------------------------------------------------------

alg_ManagerNames :=
	project eLast, eFirst (select eTitle = 'Manager' (employee));

% 3.2.2 Sets

% Table 3.5: Relational Algebra Sample Set Queries

% Which employees are managers or project leads?
alg_ManagerOrProjectLead := 
	(project eID (select eTitle='Manager' (employee))) union
	(project eID (select eTitle='Project Lead' (employee)));

% Which managers have not taken any courses?
alg_ManagersNoCourses := 
	(project eID (select eTitle='Manager' (employee))) difference
	(project eID (takes));

% Which managers have taken a training course?
alg_ManagersTookCourses := 
	(project eID (select eTitle='Manager' (employee))) intersect	
	(project eID (takes));

% End Table 3.5 ------------------------------------------------------------------

% 3.2.3 Joins

alg_employeeTrainingCoursePossibilities := 
	(project eID (employee) ) product (project cID (trainingCourse));

alg_empsCoursesDidNotTake := 
	alg_employeeTrainingCoursePossibilities difference 
	(project eID, cID (takes));

% Note: There is no syntax for theta-join in WinRDBI. Use its equivalent definition.
alg_employeeLeads := 
	select eID=aLeadID (employee product technologyArea);

alg_CourseTitleOfferings := 
	project cTitle, tDate (trainingCourse njoin takes);

% Division: WinRDBI does not support the division operator. See Self-Check Answers for sample Employee Training division query. 

% 3.3 Relational Completeness

% Table 3.7: Relational Algebra Summary of Fundamental Employee Training Queries 

q_selection := 
	select eTitle = 'Manager' (employee); 

q_projection :=
	project eTitle (employee);

q_union := 
	(project eID (select eTitle='Manager'(employee))) union (project eID (select eTitle='Project Lead'(employee))) ;

q_difference := 
	(project eID (select eTitle='Manager'(employee)))  difference (project eID (takes));

q_product := 
	(project eID (employee)) product (project cID (trainingCourse));

% End Table 3.7 -----------------------------------------------------------------------------------------


% Table 3.9: Relational Algebra Summary of Additional Employee Training Queries 

q_intersection := 
	(project eID (select eTitle='Manager'(employee)))  intersect (project eID (takes));
	
% WinRDBI does not support syntax for a theta join. Use equivalent definition with fundamental relational algebra operators. 
q_theta_join :=
	select eID=aLeadID (employee product technologyArea);
	
q_naturaljoin := 
	project cTitle, tDate (trainingCourse njoin takes); 

% q_division: WinRDBI does not support a division operator. See Self-Check Answers for sample Employee Training division query. 

% End Table 3.9 -----------------------------------------------------------------------------------------


% Aggregation and Grouping 

% Employees who have the minimum salary 
empSal := project eSalary (employee);
empSalCopy(eSalaryCopy) := empSal;
empSalNotMin := project eSalary (select  eSalary>eSalaryCopy  (empSal product empSalCopy));
empSalMin := empSal difference empSalNotMin;
employeesMinSalary := employee njoin empSalMin;

% Minimum employee salary for each title in the database
empSalTitle := project eTitle,eSalary (employee);
empSalTitleCopy(eTitleCopy, eSalaryCopy) := empSalTitle;
empSalTitleNotMin := project eTitle,eSalary (select eTitle=eTitleCopy and eSalary>eSalaryCopy(empSalTitle product empSalTitleCopy));
empSalTitleMin := empSalTitle difference empSalTitleNotMin;

% Employees who took courses in more than one technology area
eIDaIDs(eID, aID) := project eID,areaID (takes njoin trainingCourse);
eIDaIDsCopy(eIDCopy, aIDCopy) := eIDaIDs;
eIDsMoreThanOne := project eID (select eID=eIDCopy and aID<>aIDCopy (eIDaIDs product eIDaIDsCopy));

% 3.4 Query Optimization

alg_db01_version1 := 
	project eLast,eFirst ((select cID='DB01' (takes)) njoin employee);

alg_db01_version2 := 
	project eLast,eFirst (select cID='DB01' (takes njoin employee));

alg_db01_version1_projections :=
	project eLast,eFirst 
		( (project eID (select cID='DB01' (takes))) njoin 
		  (project eID, eLast, eFirst (employee)) );