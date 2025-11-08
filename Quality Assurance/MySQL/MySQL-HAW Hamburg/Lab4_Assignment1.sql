-- Students: Borean Araujo, Mirella Estefania		YUN, EUNSEONG

CREATE DATABASE IF NOT EXISTS Chemistry;
USE Chemistry;

-- Table: Elements
CREATE TABLE IF NOT EXISTS Elements (
    ElementID 		INT 			PRIMARY KEY,
    Symbol 			VARCHAR(2) 		NOT NULL,
    Name 			VARCHAR(50) 	NOT NULL,
    AtomicNumber 	INT 			NOT NULL,
    AtomicWeight 	DECIMAL(8, 4) 	NOT NULL
);

-- Table: Compounds
CREATE TABLE IF NOT EXISTS Compounds (
    CompoundID 	INT 		PRIMARY KEY,
    Name 		VARCHAR(50) NOT NULL,
    Formula 	VARCHAR(50) NOT NULL
);

-- Table: Reactions
CREATE TABLE IF NOT EXISTS Reactions (
    ReactionID 		INT 		PRIMARY KEY,
    Name 			VARCHAR(50) NOT NULL,
    Description 	TEXT
);

-- Table: Laboratories
CREATE TABLE IF NOT EXISTS Laboratories (
    LabID 			INT 			PRIMARY KEY,
    LabName 		VARCHAR(50) 	NOT NULL,
    Location 		VARCHAR(100) 	NOT NULL
);

-- Table: Researchers
CREATE TABLE IF NOT EXISTS Researchers (
    ResearcherID 	INT 		PRIMARY KEY,
    FirstName 		VARCHAR(50) NOT NULL,
    LastName 		VARCHAR(50) NOT NULL,
    LabID 			INT,
    FOREIGN KEY (LabID) REFERENCES Laboratories(LabID)
);

-- Table: ChangeLog
CREATE TABLE IF NOT EXISTS ChangeLog (
    LogID 				INT 	PRIMARY KEY 	AUTO_INCREMENT,
    ChangeDescription 	TEXT,
    ChangeDate 			DATETIME
);

-- Sample Data
-- Elements
INSERT INTO Elements (ElementID, Symbol, Name, AtomicNumber, AtomicWeight) VALUES
(1, 'H', 'Hydrogen', 1, 1.008),
(2, 'O', 'Oxygen', 8, 15.999),
(3, 'Na', 'Sodium', 11, 22.990),
(4, 'Cl', 'Chlorine', 17, 35.453),
(5, 'C', 'Carbon', 6, 12.011),
(6, 'N', 'Nitrogen', 7, 14.007),
(7, 'Fe', 'Iron', 26, 55.845),
(8, 'Cu', 'Copper', 29, 63.546),
(9, 'Au', 'Gold', 79, 196.967),
(10, 'Ag', 'Silver', 47, 107.868);

-- Compounds
INSERT INTO Compounds (CompoundID, Name, Formula) VALUES
(1, 'Water', 'H2O'),
(2, 'Sodium Chloride', 'NaCl'),
(3, 'Carbon Dioxide', 'CO2'),
(4, 'Methane', 'CH4'),
(5, 'Ethanol', 'C2H5OH'),
(6, 'Acetic Acid', 'CH3COOH'),
(7, 'Ammonia', 'NH3'),
(8, 'Sulfuric Acid', 'H2SO4'),
(9, 'Glucose', 'C6H12O6'),
(10, 'Calcium Carbonate', 'CaCO3');

-- Reactions
INSERT INTO Reactions (ReactionID, Name, Description) VALUES
(1, 'Combustion of Hydrogen', 'Reaction of hydrogen with oxygen to form water.'),
(2, 'Photosynthesis', 'Conversion of carbon dioxide and water into glucose and oxygen using sunlight.'),
(3, 'Respiration', 'Conversion of glucose and oxygen into carbon dioxide and water to release energy.'),
(4, 'Rusting of Iron', 'Reaction of iron with oxygen and moisture to form rust (iron oxide).'),
(5, 'Neutralization', 'Reaction between an acid and a base to form water and a salt.');

-- Laboratories
INSERT INTO Laboratories (LabID, LabName, Location) VALUES
(1, 'ChemLab1', 'Building A, Room 66'),
(2, 'ChemLab2', 'Building A, Room 21'),
(3, 'ChemLab3', 'Building A, Room 12'),
(4, 'ChemLab4', 'Building B, Room 4'),
(5, 'ChemLab5', 'Building B, Room 5');

-- Researchers
INSERT INTO Researchers (ResearcherID, FirstName, LastName, LabID) VALUES
(1, 'Jonathan', 'Meyer', 1),
(2, 'Angelika', 'Schmidt', 2),
(3, 'Sabine', 'Thorsten', 3),
(4, 'Heike', 'Osterbaum', 4),
(5, 'Michael', 'Günther', 5);

-- 1. Transaction to insert two new elements in table ELEMENTS and new connection in table COMPOUNDS along with changes in CHANGELOG
BEGIN;

-- Insert two new elements
INSERT INTO Elements (ElementID, Symbol, Name, AtomicNumber, AtomicWeight) VALUES
(11, 'Mg', 'Magnesium', 12, 24.305),
(12, 'Al', 'Aluminum', 13, 26.982);

-- Insert a new compound
INSERT INTO Compounds (CompoundID, Name, Formula) VALUES
(11, 'Magnesium Oxide', 'MgO');

-- Log the changes
INSERT INTO ChangeLog (ChangeDescription, ChangeDate) VALUES
('Inserted new element: Magnesium', NOW()),
('Inserted new element: Aluminum', NOW()),
('Inserted new compound: Magnesium Oxide', NOW());

SELECT * FROM ELEMENTS;
SELECT * FROM COMPOUNDS;
SELECT * FROM CHANGELOG;

-- Commit or rollback based on success
-- COMMIT; 
ROLLBACK;

SET transaction isolation level SERIALIZABLE;
SET transaction isolation level repeatable read;
SET transaction isolation level READ committed;
SET transaction isolation level READ UNCOMMITTED;

SELECT * FROM ELEMENTS;
SELECT * FROM COMPOUNDS;
SELECT * FROM CHANGELOG;

-- 2. Transaction to add a new lab into LABORATORIES, a new researcher into RESEARCHERS, and new reactions discovered by them into REACTIONS
BEGIN;

-- Insert a new lab
INSERT INTO Laboratories (LabID, LabName, Location) VALUES
(6, 'ChemLab6', 'Building C, Room 101');

-- Insert a new researcher
INSERT INTO Researchers (ResearcherID, FirstName, LastName, LabID) VALUES
(6, 'Sophia', 'Neumann', 6);

-- Insert two new reactions
INSERT INTO Reactions (ReactionID, Name, Description) VALUES
(6, 'Reaction A', 'Description of Reaction A discovered by Sophia Neumann.'),
(7, 'Reaction B', 'Description of Reaction B discovered by Sophia Neumann.');

-- Log the changes
INSERT INTO ChangeLog (ChangeDescription, ChangeDate) VALUES
('Inserted new lab: ChemLab6', NOW()),
('Inserted new researcher: Sophia Neumann', NOW()),
('Inserted new reaction: Reaction A', NOW()),
('Inserted new reaction: Reaction B', NOW());

SELECT * FROM LABORATORIES;
SELECT * FROM RESEARCHERS;
SELECT * FROM REACTIONS;
SELECT * FROM CHANGELOG;

-- Commit the transaction if no errors occur
-- COMMIT;
ROLLBACK;

-- 3. Create view about researchers 
CREATE VIEW V_RESEARCHERS_DETAILS AS
	SELECT 	r.ResearcherID, CONCAT(r.FirstName, ' ', r.LastName) AS FullName, l.LabName, l.Location
	FROM 	Researchers r
	JOIN 	Laboratories l
	ON 		r.LabID = l.LabID;

SELECT * FROM V_RESEARCHERS_DETAILS;

-- 4. Trying to insert, delete and update tuples
-- INSERT INTO V_RESEARCHERS_DETAILS (ResearcherID, FullName, LabName, Location)
-- VALUES (7, 'John Doe', 'ChemLab7', 'Building D, Room 202');

-- This operation cannot be executed because the view is based on a join between two tables.

-- DELETE FROM V_RESEARCHERS_DETAILS WHERE ResearcherID = 1;

-- This operation cannot be executed because the view is based on a join, and deleting a row from the view would require deleting rows from multiple tables.

-- UPDATE V_RESEARCHERS_DETAILS
-- SET FullName = 'Mirella Borean'
-- WHERE ResearcherID = 1;

-- This operation cannot be executed because the FullName column is derived from a concatenation of two other columns.