%  Understanding Databases: Concepts and Practice
%  S. W. Dietrich
%  Chapter 5 SQL
% Practice Problems: Web Page

% WEB PAGE 
% webpage (wID, wTitle, wURL, hits)			    primary key: wID
% site (sID, sTitle, sURL)				    primary key: sID
% graphic (gID, gName, gType, src, alt)			    primary key: gID
% document (dID, dName, dType, dDescription, dDate, downloads, wID)    	    primary key: dID
%     foreign key (wID) references webpage(wID)
% internal (sourceID, targetID)			    	    primary key: sourceID, targetID
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

sql1 :=
select 	distinct W.wID, W.wTitle
from 	webpage W natural join document D
where 	D.dType = 'sql';



% 2 Which pages display graphics having the name 'understandingbook'?
%    (wID, wTitle)

sql2 :=
select 	distinct W.wID, W.wTitle
from 	(graphic G natural join displays D) natural join webpage W 
where 	G.gName = 'understandingbook';

 
% 3 	Which pages do not display any graphics?
%	(wID, wTitle)

sql3 :=
select 	W.wID, W.wTitle
from 	webpage W 
where 	W.wID not in (select wID from displays);

 
% 4	Which pages display 'jpg' graphics but not 'gif' graphics?
%	(wID, wTitle)

jpgGraphics := 
select 	distinct D.wID
from 	displays D
where 	exists
	 (select *
	  from graphic G 
	  where G.gType = 'jpg' and G.gID = D.gID) ;


gifGraphics := 
select 	distinct D.wID
from 	displays D
where exists
	(select *
	 from graphic G 
	 where G.gType = 'gif' and G.gID = D.gID) ;

sql4 :=
	select W.wID, W.wTitle
	from webpage W 
	where exists (select * from jpgGraphics J where J.wID = W.wID) and
	  not exists (select * from gifGraphics G where G.wID = W.wID);

 
% 5 Which pages contain more than one document?
%    (wID, wTitle)

pagesWithMoreThanOneDoc(wID, cnt) := 
select 	wID, count(*)
from 	document
group by 	wID
having 	count(*) > 1; 

sql5 := 
select 	W.wID, W.wTitle
from 	webpage W natural join pagesWithMoreThanOneDoc P
order by 	W.wID asc;

 
% 6 Which pages contain only one link to an external web page?
%    (wID, wTitle)	

pagesWithOneLink (wID, cnt) := 
select 	wID, count(*)
from 	external
group by	wID
having   count(*) = 1; 

sql6 := 
select 	W.wID, W.wTitle
from 	webpage W natural join pagesWithOneLink P
order by 	W.wID asc;
		
 
% 7 Which pages have the most hits?
%    (wID, wTitle, wURL, hits)

mostHits(maxhits) :=
select	max(hits)
from 	webpage;

sql7 := 
select 	W.wID, W.wTitle, W.wURL, W.hits 
from 	webpage W natural join mostHits M
where	W.hits = M.maxhits;


 
% 8 Which pages display graphics of all graphic types current stored in the database? 
%    (wID, wTitle)

numberOfGraphicTypes := 
select 	count(distinct gType) as gTypeCount
from 	graphic;

numberPageGTypes := 
select 	wID, count(distinct gType) as gTypeCount
from	displays natural join graphic
group by	wID;

sql8 := 
select	W.wID, W.wTitle
from	webpage W natural join numberPageGTypes N
where	N.gTypeCount = (select gTypeCount from numberOfGraphicTypes);

 
% 9   For each webpage and graphic type, give the number of graphics 
%       of that type displayed on that page. Display the results in 
%       ascending order on wID, and within that, in ascending order 
%       on graphic type.
%       (wID, wTitle, gType, cnt)
 
gTypeAndCount (wID, gType, cnt) := 
	select D.wID, G.gType, count(*)
	from displays D natural join graphic G
	group by D.wID, G.gType;

sql9 := 
select 	W.wID, W.wTitle, G.gType, G.cnt
from 	webpage W natural join gTypeAndCount G
order by 	W.wID, G.gType;

 
% 10  For each type of document in the database, determine the average, minimum, and maximum number of downloads.
%           Display the results such that the document type with the highest average download is first.
%          (dType, avgdownloads, mindownloads, maxdownloads)

sql10 := 
select 	dType, avg(downloads) as avgdownloads, 
          	min(downloads) as mindownloads, max(downloads) as maxdownloads 
from	document
group by	dType
order by	avgdownloads desc;


 


