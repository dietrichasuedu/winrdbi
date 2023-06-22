 % Understanding Databases: Concepts and Practice
% S. W. Dietrich
% Chapter 3 Relational Algebra
% Practice Problems: Web Page

% WEB PAGE 
% webpage (wID, wTitle, wURL, hits)			    primary key: wID
% site (sID, sTitle, sURL)				    primary key: sID
% graphic (gID, gName, gType, src, alt)			    primary key: gID
% document (dID, dName, dType, dDescription, dDate, downloads, wID)    	    primary key: dID
%     foreign key (wID) references webpage(wID)
% internal (sourceID, targetID)			   	     primary key: sourceID, targetID
%     foreign key (sourceID) references webpage(wID)
%     foreign key (sourceID) references webpage(wID)
% external (wID, sID, followed)			    	    primary key: wID, sID
%     foreign key (wID) references webpage(wID) 
%     foreign key (sID) references site(sID)
% displays (wID, gID)				    primary key: wID, gID
%     foreign key (wID) references webpage(wID) 
%     foreign key (gID) references graphic(gID) 


% 1 Which pages contain a link to SQL ('sql') documents?
%    (wID, wTitle)

alg1 := 
    project wID, wTitle ((select dType = 'sql' (document)) njoin webpage);


 
% 2 Which pages display graphics having the name 'understandingbook'?
%    (wID, wTitle)

alg2 := 
    project wID, wTitle (((select gName = 'understandingbook' (graphic)) njoin displays) njoin webpage);


 
% 3 Which pages do not display any graphics?
%    (wID, wTitle)

alg3 := 
     project wID, wTitle (((project wID (webpage)) difference (project wID (displays))) njoin webpage);

 
% 4 Which pages display 'jpg' graphics but not 'gif graphics?
%    (wID, wTitle)

jpgGraphics := 
  project wID ((select gType = 'jpg' (graphic)) njoin displays);

gifGraphics := 
    project wID ((select gType = 'gif' (graphic)) njoin displays);

alg4 := 
    project wID, wTitle (webpage njoin (jpgGraphics difference gifGraphics));

 
% 5 Which pages contain more than one document?
%    (wID, wTitle)

docCopy(dIDcopy, wIDcopy) :=
    project dID, wID (document);

moreThanOneDoc :=
    project wID (select wID = wIDcopy and dID <> dIDcopy (document product docCopy));

alg5 := 
    project wID, wTitle (webpage njoin moreThanOneDoc);

 
% 6 Which pages contain only one link to an external web page?
%    (wID, wTitle)	

externalCopy(wIDcopy, sIDcopy) := 
    project wID, sID (external);

moreThanOneExternal := 
    project wID (select wID = wIDcopy and sID <> sIDcopy (external product externalCopy));

onlyOneExternal := 
    (project wID (external)) difference moreThanOneExternal;

alg6 := 
    project wID, wTitle (webpage njoin onlyOneExternal);

 
% 7 Which pages have the most hits?
%    (wID, wTitle, wURL, hits)

wIDsHits(wIDCopy, hitsCopy) := 
    project wID, hits (webpage);

wIDsNotMax := 
    project wID (select hits < hitsCopy (wIDsHits product webpage));

wIDsMaxHits := 
    (project wID (webpage)) difference wIDsNotMax;

alg7 := 
    wIDsMaxHits njoin webpage;

 
% 8 Which pages display graphics of all graphic types current stored in the database? 
%    (wID, wTitle)

graphicTypes := 
    project gType (graphic); 

atLeastOneGraphicType := 
    project wID (displays);

allPagesAllTypes := 
    (atLeastOneGraphicType product graphicTypes);

notAllGraphicTypes := 
     project wID (allPagesAllTypes difference (project wID, gType (graphic njoin displays)));

alg8 := 
    project wID, wTitle (webpage njoin (atLeastOneGraphicType difference notAllGraphicTypes));

 


