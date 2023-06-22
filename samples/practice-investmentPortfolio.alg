%  Understanding Databases: Concepts and Practice
%  S. W. Dietrich
%  Chapter 3 Relational Algebra
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

alg1 :=
    project taxPayerID, name, sTicker, sName
	( ((select rating='A' (stock)) njoin stockPortfolio) njoin client );


% 2	Which clients invest in both stocks whose principal business is 
%	'Technology' and mutual funds having growth ('G') as a principal objective?
%	(taxPayerID, name)

technologyClients :=
    project taxPayerID 
	( (select prinBus='Technology' (stock)) njoin stockPortfolio );
	
growthClients :=
    project taxPayerID 
	( (select prinObj='G' (mutualFund)) njoin mutualFundPortfolio );

alg2 :=
    project taxPayerID, name
	( (technologyClients intersect growthClients) njoin client );


% 3 	What clients have not invested in mutual funds with income ('I')  as a principal objective? 
%	(taxPayerID, name) 

investI :=
    project taxPayerID
	( (select prinObj='I'(mutualFund)) njoin mutualFundPortfolio );

notInvestI :=
    (project taxPayerID (client)) difference investI;

alg3 := 
    project taxPayerID, name (client njoin notInvestI);


% 4 	Which clients invest in stocks but not in mutual funds? 
%   	 (taxPayerID, name) 

stocksNotMutualFunds :=
	(project taxPayerID (stockPortfolio)) difference
	(project taxPayerID (mutualFundPortfolio));

alg4 :=
    project taxPayerID, name (client njoin stocksNotMutualFunds);


% 5	Which clients have more than one no-rating ('NR') stock? 
%	(taxPayerID, name)

investNR :=
    project taxPayerID, sTicker
	( (select rating='NR' (stock)) njoin stockPortfolio);

investNRCopy(taxPayerIDCopy, sTickerCopy) :=
    investNR;

moreThanOneNR :=
    project taxPayerID
	(select taxPayerID=taxPayerIDCopy and sTicker<>sTickerCopy
		(investNR product investNRCopy));

alg5 :=
    project taxPayerID, name (client njoin moreThanOneNR);


% 6	Which clients invest in only one mutual fund with stability ('S')  as a principal objective?
%	(taxPayerID, name)

investS :=
    project taxPayerID, mTicker
	( (select prinObj='S' (mutualFund)) njoin mutualFundPortfolio);

investSCopy(taxPayerIDCopy, mTickerCopy) :=
    investS;

moreThanOneS :=
    project taxPayerID
	(select taxPayerID=taxPayerIDCopy and mTicker<>mTickerCopy
		(investS product investSCopy));

onlyOneS :=
    (project taxPayerID (investS)) difference moreThanOneS;

alg6 :=
    project taxPayerID, name (client njoin onlyOneS);

% 7	Which mutual funds have the minimum current rate? 
%	(mTicker, mName, mCurrent) 

currentRate := 
    project mCurrent (mutualFund);

currentRateCopy(mCurrentCopy) := 
    currentRate;

notMinimumRate :=
    project mCurrent (select mCurrent > mCurrentCopy 
	(currentRate product currentRateCopy) );

minimumRate :=
    currentRate difference notMinimumRate;

alg7 :=
    project mTicker, mName, mCurrent (mutualFund njoin minimumRate);


% 8	What clients have invested in all of the mutual funds within the 'Fictitious' fund family? 
%	(taxPayerID, name) 

fictitiousFunds :=
    project mTicker ( (select company='Fictitious' (fundFamily)) njoin mutualFund );

clientsTickersAtLeastOneFund :=
    project taxPayerID, mTicker (fictitiousFunds njoin mutualFundPortfolio);

clientsAtLeastOneFund :=
    project taxPayerID (clientsTickersAtLeastOneFund);  

allClientsWithAllFunds :=
    clientsAtLeastOneFund product fictitiousFunds;

clientsNotAllFunds :=
    project taxPayerID 
	(allClientsWithAllFunds difference clientsTickersAtLeastOneFund);
	
clientsAllFunds :=
    clientsAtLeastOneFund difference clientsNotAllFunds;

alg8 :=
    project taxPayerID, name (client njoin clientsAllFunds);



