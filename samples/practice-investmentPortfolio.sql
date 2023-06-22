%  Understanding Databases: Concepts and Practice
%  S. W. Dietrich
%  Chapter 5 SQL: Introduction to Querying
%  Practice Problems: Investment Portfolio

% INVESTMENT PORTFOLIO
% client(taxPayerID, name, address)				primary key: taxPayerID
% stock(sTicker, sName, rating, prinBus, sHigh, sLow, sCurrent, ret1Yr, ret5Yr)		primary key: sTicker
% fundFamily(familyID, company, cAddress)				primary key: familyID
% mutualFund(mTicker, mName, prinObj, mHigh, mLow, mCurrent, yield, familyID)	primary key: mTicker
%   foreign key (familyID) references fundFamily(familyID)
% mutualFundPortfolio(taxPayerID, mTicker, mNumShares)			primary key: taxPayerID, mTicker
%    foreign key (taxPayerID) references client(taxPayerID)
%    foreign key (mTicker) references mutualFund(mTicker)
% stockPortfolio(taxPayerID, sTicker, sNumShares)			primary key: taxPayerID, sTicker
%    foreign key (taxPayerID) references client(taxPayerID)
%    foreign key (sTicker) references stock(sTicker)


% 1	What clients have invested in which 'A' rated stocks? 
%	(taxPayerID, name, sTicker, sName) 

sql1:=
select	C.taxPayerID, C.name, S.sTicker, S.sName
from	client C, stock S, stockPortfolio P
where	S.rating = 'A' and
	S.sTicker = P.sTicker and
	P.taxPayerID = C.taxPayerID;


% 2	Which clients invest in both stocks whose principal business is 
%	'Technology' and mutual funds having growth ('G') as a principal objective?
%	(taxPayerID, name)

technologyClients :=
select 	distinct P.taxPayerID
from 	stock S, stockPortfolio P
where 	S.prinBus = 'Technology' and
	S.sTicker = P.sTicker;

growthClients :=
select 	distinct P.taxPayerID
from 	mutualFund M, mutualFundPortfolio P
where 	M.prinObj = 'G' and
	M.mTicker = P.mTicker;

technologyGrowthClients :=
(select * 
 from	technologyClients)
intersect
(select	*
 from	growthClients);

sql2 :=
select	C.taxPayerID, C.name
from	client C
where	C.taxPayerID in 
	    (select * from technologyGrowthClients);


% 3 	What clients have not invested in mutual funds with income ('I') 
%	as a principal objective? 
%	(taxPayerID, name) 

sql3 :=
select	C.taxPayerID, C.name
from	client C
where	C.taxPayerID not in
	(select	P.taxPayerID
	 from	mutualFund M, mutualFundPortfolio P
	 where	M.prinObj='I' and 
		M.mTicker=P.mTicker);


% 4	Which clients invest in stocks but not in mutual funds? 
%	(taxPayerID, name) 

sql4 :=
select	C.taxPayerID, C.name
from	client C
where	C.taxPayerID in (select SP.taxPayerID from stockPortfolio SP) and
	C.taxPayerID not in (select MP.taxPayerID from mutualFundPortfolio MP);

% 5	Which clients have more than one no-rating ('NR') stock? 
%	(taxPayerID, name)

moreThanOneNRstock := 
select 	 P.taxPayerID, count(*) as numNRstocks
from 	 stock S, stockPortfolio P 
where 	 S.rating='NR' and
	 P.sTicker=S.sTicker 
group by P.taxPayerID
having 	 count(*)>1;

sql5 :=
select 	C.taxPayerID, C.name
from 	client C
where 	C.taxPayerID in 
	(select	M.taxPayerID
	 from	moreThanOneNRstock M);


% 6	Which clients invest in only one mutual fund with stability ('S') 
%	as a principal objective?
%	(taxPayerID, name)

countSmutualFunds := 
select 	 P.taxPayerID, count(*) as numSmutualFunds
from 	 mutualFund M, mutualFundPortfolio P 
where 	 M.prinObj='S' and
	 P.mTicker=M.mTicker 
group by P.taxPayerID;

sql6 :=
select 	C.taxPayerID, C.name
from 	client C, countSmutualFunds S
where 	C.taxPayerID=S.taxPayerID and
	S.numSmutualFunds=1;


% 7	Which mutual funds have the minimum current rate? 
%	(mTicker, mName, mCurrent) 

minMFcurrent :=
select	min(M.mCurrent) as minCurrent
from	mutualFund M;

sql7 :=
select	M.mTicker, M.mName, M.mCurrent
from	mutualFund M
where	M.mCurrent = (select minCurrent from minMFcurrent);


% 8	What clients have invested in all of the mutual funds within the 'Fictitious' fund family? 
%	(taxPayerID, name) 

fictitiousFunds :=
select 	count(*) as numberMutualFunds 
from 	mutualFund M natural join fundFamily F
where 	F.company='Fictitious' ;

clientNumberFictitiousFunds :=
select 	taxPayerID, count(*) as numberMutualFunds
from 	(mutualFundPortfolio natural join mutualFund) natural join fundFamily 
where	company='Fictitious'
group by	taxPayerID;
            
sql8 := 	
select 	C.taxPayerID, C.name
from 	client C natural join clientNumberFictitiousFunds F
where 	F.numberMutualFunds = (select numberMutualFunds from fictitiousFunds);


% 9  For each client that invests in stocks, display the average, minimum 
%	and maximum one-year returns on the stocks they own. Display the 
%	result in ascending order on average one-year returns. 
%	(taxPayerID, name, avgReturn1Yr, minReturn1Yr, maxReturn1Yr) 

sql9 :=
select 	 C.taxPayerID, C.name, avg(S.ret1Yr) as avgReturn1Yr, min(S.ret1Yr) as minReturn1Yr, max(S.ret1Yr) as maxReturn1Yr
from 	 client C, stockPortfolio P, stock S
where 	 C.taxPayerID=P.taxPayerID and P.sTicker=S.sTicker
group by 	C.taxPayerID, C.name
order by 	avgReturn1Yr asc;


% 10	For each client that invests in mutual funds, display the sum of 
%	the number of shares of mutual funds that they own within each 
%	principal objective category. Display the result in descending 
%	order on the number of shares. 
%	(taxPayerID, name, prinObj, numShares)

sumSharesByPrincObj := 
select 	 P.taxPayerID, M.prinObj, sum(P.mNumShares) as numShares
from 	 mutualFundPortfolio P, mutualFund M
where	 P.mTicker=M.mTicker 
group by P.taxPayerID, M.prinObj; 

sql10 :=
select 	 C.taxPayerID, C.name, S.prinObj, S.numShares 
from 	 sumSharesByPrincObj S, client C
where 	 S.taxPayerID=C.taxPayerID
order by 	numShares desc;



