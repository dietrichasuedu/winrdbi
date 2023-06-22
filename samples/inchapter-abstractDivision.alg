%  Understanding Databases: Concepts and Practice
%  S. W. Dietrich
%  Chapter 3 Relational Algebra
%  Abstract Division Example
%
%  abTable(a,b)
%       primary key (a, b)
%  bTable(b)
%       primary key (b)
%
%  Query: Find the a's that are related to all of the b's in the bTable


% Division in one step

alg_divisionOneStep :=
    (project a (abTable)) difference 
	(project a ( ( (project a (abTable)) product bTable) difference abTable));

% Division broken down into multiple steps

aTable := project a (abTable);

allaWithAllb := aTable product bTable;

aNotRelatedToSomeb := project a (allaWithAllb difference abTable);

aRelatedToAllb := aTable difference aNotRelatedToSomeb;
