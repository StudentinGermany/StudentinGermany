-- Assignment: Shipping Company
-- Students: Borean Araujo, Mirella Estefania		YUN, EUNSEONG

CREATE schema Lab3_ShippingCompany; 
Use  Lab3_ShippingCompany; 

CREATE TABLE Harbour
  (harbourID 		INT 			NOT NULL,
   location 		VARCHAR(32) 	NOT NULL,
   establishedIn 	date,
   PRIMARY KEY (harbourID) ); 
   
CREATE TABLE Sailor
  (sailorID 		INT 			NOT NULL,
   lastName 		VARCHAR(32),
   dob 				date,
   trainedAt 		INT,
   primary key (sailorID),
   foreign key (trainedAT) references Harbour(harbourID));

CREATE TABLE Ship
  (shipID 			INT 			NOT NULL,
   name 			VARCHAR(32),
   grossWeight 		INT,
   launchDate 		date,
   baseHarbour 		INT,
   primary key (shipID),
   foreign key (baseHarbour) references Harbour(harbourID));
   
CREATE TABLE hire
  (sailorID 		INT 			NOT NULL,
   shipID 			INT 			NOT NULL,
   startOfService 	date,
   annualSalary 	INT,
   primary key (sailorID, shipID),
   foreign key (sailorID) references Sailor(sailorID),
   foreign key (shipID) references ship(shipID));


INSERT INTO Harbour
VALUES ( 123, 'Hamburg','1189-01-01'); 

INSERT INTO Harbour
VALUES ( 234, 'Amsterdam','1200-01-01'); 

INSERT INTO Harbour
VALUES ( 345, 'Rotterdam','1898-01-01');

INSERT INTO Sailor
VALUES ( 12, 'Meyer','2002-02-03', 123);

INSERT INTO Sailor
VALUES ( 13, 'Smith','2005-02-03', 123);

INSERT INTO Sailor
VALUES ( 14, 'Jones','2012-02-08', 123);

INSERT INTO Sailor
VALUES ( 18, 'James','2015-02-08', 123);

INSERT INTO Sailor
VALUES ( 15, 'Ranger','2022-02-03', 234);

-- Weight in weight ton
INSERT INTO Ship
VALUES ( 45, 'Ship1',53.800, '2007-02-03',  123);

INSERT INTO Ship
VALUES ( 46, 'Ship2',55.800, '2015-02-03',  123);

INSERT INTO Ship
VALUES ( 47, 'Ship3',51.800, '2018-08-03',  234);

INSERT INTO Hire
VALUES ( 12, 45, '2010-08-03',  45000);

INSERT INTO Hire
VALUES ( 13, 45, '2012-08-03',  47000);

INSERT INTO Hire
VALUES ( 14, 45, '2012-08-03',  42000);

INSERT INTO Hire
VALUES ( 15, 47, '2012-08-03',  41000);

INSERT INTO Hire
VALUES ( 18, 46, '2011-08-03',  40500);


-- 1. Create a SQL-query that returns the dob (date of birth) of sailors in descending order that were hired on August 3rd, 2012.
SELECT s.dob 
FROM Sailor s 
JOIN Hire h ON s.sailorID = h.sailorID 
WHERE h.startOfService = '2012-08-03' -- connect hire and sailor tables
ORDER BY s.dob DESC;

-- 2. Create a SQL-query that returns all information of sailors that were hired between July 3rd, 2011, and September 3rd, 2012, and whose last name starts with a ‘J’.
SELECT *
FROM Sailor s
JOIN Hire h ON s.sailorID = h.sailorID
WHERE (startOfService >= '2012-07-03' AND startOfService <= '2012-09-03') AND (s.lastName LIKE 'J%');

-- 3. Create a SQL-query that returns for each ship the sum of the annual salary of every sailor who is hired for that ship.
SELECT sh.shipID, sh.name, SUM(h.annualSalary) AS TotalAnnualSalary
FROM Ship sh
JOIN Hire h ON sh.shipID = h.shipID
GROUP BY sh.shipID, sh.name HAVING TotalAnnualSalary <= 42000;

-- having and where: if we want to show sum of salary, we cannot filter this out in where. 

-- Table (that's its name)
-- if we have 	SailorID	ShipID	Salary
-- 				123			1		20000
-- 				234			1		20000
-- 				345			1		20000	
-- 				456			2		20000
-- 				567			2		20000

-- and we have
SELECT Count(SailorID), SUM(Salary), ShipID
FROM Table
WHERE SALARY <= 42000
GROUP BY ShipID
HAVING SUM(Salary) <= 42000; 

-- result of WHERE (without having): excludes touples, and groups by SHIP ID. We always execute WHERE before
-- Ship		Count		SUM
-- 1		3			60000
-- 2		2			40000

-- result of HAVING without the WHERE: sum of Ship 1 would be 90000, which is not smaller than 42000. only groups that have a sum of salary that have a sum of 42000 are displayed
-- Ship		Count		SUM
-- 2		2			40000

-- Joining these two tables is
-- Ship		Count		SUM
-- 1		2			4000
-- 2		2			40000

-- 4. Create a SQL-query that returns the shipId, ship name and the number of sailors who are hired on the ship and earn maximum 42.000$. 
SELECT sh.shipID, sh.name, COUNT(h.sailorID) AS NumberOfSailors
From Ship sh
JOIN Hire h ON sh.shipID = h.shipID
WHERE h.annualSalary <= 42000
GROUP BY sh.shipID;