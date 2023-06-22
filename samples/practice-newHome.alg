 %   Understanding Databases: Concepts and Practice
 %   S. W. Dietrich
 %   Chapter 3 Relational Algebra
 %   Practice Problems: New Home 

% NEW HOME
% homebuilder(hID, hName, hStreet, hCity, hZip, hPhone)	primary key: hID
% model(hID, mID, mName, sqft, story)		primary key: hID, mID
%     foreign key (hID) references homebuilder(hID)
% subdivision(sName, sCity, sZip)		primary key: sName 
% offered(sName, hID, mID, price)		primary key: sName, hID, mID
%     foreign key (sName) references subdivision(sName),
%     foreign key (hID, mID) references model(hID, mID) 
% lot(sName, lotNum, lStAddr, lSize, lPremium)	primary key: sName, lotNum
%     foreign key (sName) references subdivision(sName) 
% sold(sName, lotNum, hID, mID, status)		primary key: sName, lotNum 
%     foreign key (sName, hID, mID) references offered(sName, hID, mID),
%     foreign key (sName, lotNum) references lot(sName, lotNum) 


% 1. Are there subdivisions that only offer single-story homes?
%    (sName, sCity, sZip)

subdivisionsOfferSingle :=
	project sName (offered njoin (select story=1(model) ) );

subdivisionsOfferOther :=
	project sName (offered njoin (select story<>1 (model) ) );

alg1 := subdivision njoin (subdivisionsOfferSingle difference subdivisionsOfferOther);


% 2. List all the homebuilders who offer single-story models with at least 2000 square feet in subdivisions located in "Tempe". 
%     (hName, hPhone)

homebuildersOffering :=
	project hID, sName
		((select story=1 and sqft>2000 (model)) njoin offered);

tempeSubdivisions :=
	project sName (select sCity='Tempe' (subdivision));

alg2 :=
	project hName, hPhone (homebuilder njoin 
		(homebuildersOffering njoin tempeSubdivisions) );


% 3. Which lots in the "Terraces" subdivision are available i.e. not sold? 
%     (lotNum, lStAddr, lSize, lPremium)


allTerracesLots := project sName,lotNum (select sName='Terraces' (lot));

soldTerracesLots := project sName,lotNum (select sName='Terraces' (sold));

availableTerracesLots := allTerracesLots difference soldTerracesLots;

alg3 :=	project lotNum, lStAddr, lSize, lPremium
		(availableTerracesLots njoin lot);	


% 4. Which model(s) are not currently offered in any subdivision? 
%     (hName, mName)

allModels := project hID, mID (model);

offeredModels := project hID, mID (offered);

alg4 :=	project hName, mName 
	    (((allModels difference offeredModels) njoin model) njoin homebuilder);	

%------------------------------------------------------------------------
% 5	Which subdivisions offer models from more than one homebuilder?
%	(sName, sCity, sZip)

offersBuilder := project sName, hID (offered);

offersBuilderCopy(sNameCopy, hIDCopy) := offersBuilder;

offersMoreThanOneBuilder := 
	project sName (select sName=sNameCopy and hID<>hIDCopy
		(offersBuilder product offersBuilderCopy));

alg5 :=	offersMoreThanOneBuilder njoin subdivision;

%------------------------------------------------------------------------
% 6	Which models are offered in only one subdivision? 
%	(hName, mName)

offersModel := project hID, mID, sName (offered);

offersModelCopy(hIDCopy, mIDCopy, sNameCopy) := offersModel;

offeredMoreThanOneSubdivision :=
    project hID, mID
	(select hID=hIDCopy and mID=mIDCopy and sName<>sNameCopy
	    (offersModel product offersModelCopy));

offeredOnlyOneSubdivision :=
    (project hID, mID (offersModel)) difference offeredMoreThanOneSubdivision;

alg6 :=
    project hName, mName ((offeredOnlyOneSubdivision njoin model) njoin homebuilder);

%------------------------------------------------------------------------
% 7	Which model(s) offered in the "Foothills" subdivision 
%	has the maximum square footage? 
%	(hName, mName, sqft)

foothillsModels := 
    project  hID, hName, mID, mName, sqft 
	(((select sName='Foothills' (offered)) njoin model) njoin homebuilder);

foothillsSqft :=  project sqft (foothillsModels);

foothillsSqftCopy(sqftCopy) := foothillsSqft;

notMaxFoothillsSqft :=
    project sqft (select sqft<sqftCopy (foothillsSqft product foothillsSqftCopy));

maxFoothillsSqft := foothillsSqft difference notMaxFoothillsSqft;

alg7 :=
    project hName, mName, sqft
	(maxFoothillsSqft njoin foothillsModels);


%------------------------------------------------------------------------
% 8	Which subdivision offers all the models by the homebuilder "Homer"? 
%	(sName, sCity, sZip)

homerHID := project hID (select hName='Homer' (homebuilder));

homerModels := project hID,mID (homerHID njoin model);

offersHomerModels := project sName, hID, mID (homerModels njoin offered);

% All combinations of subdivisions (offering a Homer model) with all Homer models
allsNameWithAllHModels := (project sName (offersHomerModels)) product homerModels;

% Find subdivisions that do not offer some Homer model
sNameNotSomeHModel := 
	project sName (allsNameWithAllHModels difference offersHomerModels);
               
alg8 := subdivision njoin
	((project sName (offersHomerModels)) difference sNameNotSomeHModel);
         
%---------------------------End New Home Enterprise-------------------------------
