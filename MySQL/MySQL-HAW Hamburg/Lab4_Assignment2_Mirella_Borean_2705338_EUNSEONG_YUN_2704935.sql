-- Students: Borean Araujo, Mirella Estefania		YUN, EUNSEONG

-- Create SCHEMA GEOGRAPHY
CREATE SCHEMA GEOGRAPHY;
USE GEOGRAPHY;

-- Create Countries table
CREATE TABLE Countries (
    CountryID INT PRIMARY KEY,
    CountryName VARCHAR(50),
    Population INT,
    CapitalCity VARCHAR(50)
);

-- Insert sample data into Countries table
INSERT INTO Countries (CountryID, CountryName, Population, CapitalCity)
VALUES
    (1, 'USA', 331002651, 'Washington, D.C.'),
    (2, 'Brazil', 212993603, 'Brasília'),
    (3, 'China', 1444216107, 'Beijing'),
    (4, 'India', 1380004385, 'New Delhi'),
    (5, 'Russia', 145912025, 'Moscow'),
    (6, 'Australia', 25499884, 'Canberra'),
    (7, 'Canada', 37742154, 'Ottawa'),
    (8, 'Argentina', 45195774, 'Buenos Aires'),
    (9, 'Germany', 83783942, 'Berlin'),
    (10, 'France', 65273511, 'Paris'),
    (11, 'Japan', 126476461, 'Tokyo'),
    (12, 'South Africa', 59308690, 'Pretoria'),
    (13, 'Mexico', 128932753, 'Mexico City'),
    (14, 'Egypt', 104258327, 'Cairo'),
    (15, 'Saudi Arabia', 34813871, 'Riyadh'),
    (16, 'Nigeria', 206139587, 'Abuja'),
    (17, 'United Kingdom', 67886011, 'London'),
    (18, 'Italy', 60461826, 'Rome');

-- Create Continents table
CREATE TABLE Continents (
    ContinentID INT PRIMARY KEY,
    ContinentName VARCHAR(50)
);

-- Insert sample data into Continents table
INSERT INTO Continents (ContinentID, ContinentName)
VALUES
    (1, 'North America'),
    (2, 'South America'),
    (3, 'Asia'),
    (4, 'Europe'),
    (5, 'Africa'),
    (6, 'Oceania');

-- Create Cities table
CREATE TABLE Cities (
    CityID INT PRIMARY KEY,
    CityName VARCHAR(50),
    CountryID INT,
    Population INT,
    FOREIGN KEY (CountryID) REFERENCES Countries(CountryID)
);

-- Insert sample data into Cities table
INSERT INTO Cities (CityID, CityName, CountryID, Population)
VALUES
    (1, 'New York City', 1, 8336817),
    (2, 'Rio de Janeiro', 2, 6718903),
    (3, 'Beijing', 3, 21706917),
    (4, 'Mumbai', 4, 12442373),
    (5, 'Moscow', 5, 12615882),
    (6, 'Sydney', 6, 5312163),
    (7, 'Toronto', 7, 2731571),
    (8, 'Buenos Aires', 8, 3054305),
    (9, 'Berlin', 9, 3669491),
    (10, 'Paris', 10, 2148271),
    (11, 'Tokyo', 11, 37393129),
    (12, 'Pretoria', 12, 741651),
    (13, 'Mexico City', 13, 9209944),
    (14, 'Cairo', 14, 10230350),
    (15, 'Riyadh', 15, 6937374),
    (16, 'Abuja', 16, 2149524),
    (17, 'London', 17, 8982256),
    (18, 'Rome', 18, 2870493);

-- Create Rivers table
CREATE TABLE Rivers (
    RiverID INT PRIMARY KEY,
    RiverName VARCHAR(50),
    Length INT,
    CountryID INT,
    FOREIGN KEY (CountryID) REFERENCES Countries(CountryID)
);

-- Insert sample data into Rivers table
INSERT INTO Rivers (RiverID, RiverName, Length, CountryID)
VALUES
    (1, 'Mississippi', 6275, 1),
    (2, 'Amazon', 6575, 2),
    (3, 'Yangtze', 6300, 3),
    (4, 'Ganges', 2525, 4),
    (5, 'Volga', 3530, 5),
    (6, 'Murray-Darling', 3751, 6),
    (7, 'Mackenzie', 1738, 7),
    (8, 'Paraná', 4880, 8),
    (9, 'Rhine', 1233, 9),
    (10, 'Seine', 777, 10),
    (11, 'Shinano', 367, 11),
    (12, 'Orange', 2200, 12),
    (13, 'Grijalva', 480, 13),
    (14, 'Nile', 6650, 14),
    (15, 'Wadi Hanifah', 160, 15),
    (16, 'Niger', 4184, 16),
    (17, 'Thames', 346, 17),
    (18, 'Tiber', 405, 18);

-- Create Mountains table
CREATE TABLE Mountains (
    MountainID INT PRIMARY KEY,
    MountainName VARCHAR(50),
    Height INT,
    CountryID INT,
    FOREIGN KEY (CountryID) REFERENCES Countries(CountryID)
);

-- Insert sample data into Mountains table
INSERT INTO Mountains (MountainID, MountainName, Height, CountryID)
VALUES
    (1, 'Denali', 6190, 1),
    (2, 'Pico da Neblina', 2995, 2), 
    (3, 'Everest', 8848, 3),  
    (4, 'Kangchenjunga', 8586, 4),  
    (5, 'Ural Mountains', 1895, 5),
    (6, 'Australian Alps', 2228, 6),
    (7, 'Canadian Rockies', 3954, 7),
    (8, 'Aconcagua', 6962, 8),  
    (9, 'Zugspitze', 2962, 9),  
    (10, 'Mont Blanc', 4808, 10),
    (11, 'Mount Fuji', 3776, 11),
    (12, 'Drakensberg', 3482, 12),
    (13, 'Popocatepetl', 5452, 13),
    (14, 'Mount Sinai', 2285, 14),
    (15, 'Asir Mountains', 3133, 15),
    (16, 'Kufena Mountain', 936, 16),
    (17, 'Ben Nevis', 1345, 17),
    (18, 'Gran Sasso', 2912, 18);

-- Create Languages table
CREATE TABLE Languages (
    LanguageID INT PRIMARY KEY,
    LanguageName VARCHAR(50)
);

-- Insert sample data into Languages table
INSERT INTO Languages (LanguageID, LanguageName)		-- count as separate
VALUES
    (1, 'English'),
    (2, 'Portuguese'),
    (3, 'Mandarin'),
    (4, 'Hindi'),
    (5, 'Russian'),
    (6, 'English (Australian)'),
    (7, 'English (Canadian)'),
    (8, 'Spanish'),
    (9, 'German'),
    (10, 'French'),
    (11, 'Japanese'),
    (12, 'Afrikaans'),
    (13, 'Spanish'),
    (14, 'Arabic'),
    (15, 'Arabic'),
    (16, 'Hausa'),
    (17, 'English'),
    (18, 'Italian');

-- Create CountryLanguages table
CREATE TABLE CountryLanguages (
    CountryID INT,
    LanguageID INT,
    PRIMARY KEY (CountryID, LanguageID),
    FOREIGN KEY (CountryID) REFERENCES Countries(CountryID),
    FOREIGN KEY (LanguageID) REFERENCES Languages(LanguageID)
);

-- Insert sample data into CountryLanguages table
INSERT INTO CountryLanguages (CountryID, LanguageID)
VALUES
    (1, 1),
    (2, 2),
    (3, 3),
    (4, 4),
    (5, 5),
    (6, 6),
    (7, 7),
    (8, 8),
    (9, 9),
    (10, 10),
    (11, 11),
    (12, 12),
    (13, 13),
    (14, 14),
    (15, 15),
    (16, 16),
    (17, 17),
    (18, 18);

-- 1. Show capital of Germany	--> doing this
SELECT CapitalCity 
FROM Countries
WHERE CountryName = 'Germany';

-- 2. List all cities in the USA	--> doing this
SELECT ci.*
FROM Cities ci
JOIN Countries as c ON c.CountryID = ci.CountryID
WHERE c.CountryName = 'Germany';

	-- only New York City

-- 3. Find capitals and populations of all countries with names beginning with the letter "C"	--> doing this
SELECT CapitalCity, Population
FROM Countries
WHERE CountryName LIKE 'C%';	-- should be Canada and China: Ottawa and Beijing

-- 4. All rivers that are longer than 4000 km
SELECT RiverName
FROM Rivers
WHERE Length > 4000;

-- 5. Identify the highest mountains in descending order of height
SELECT MountainName, Height
FROM Mountains
ORDER BY Height DESC;

-- 6. List all cities with a population over 5 million in descending order of population
SELECT CityName, Population 
FROM Cities
WHERE Population > 5000000
ORDER BY Population DESC;

-- 7. Add new language "Swahili" and country "Kenya" with CountryID 19. Then link the language and the country in table COUNTRYLANGUAGES.
-- Write query displaying all information about the country "Kenya" and the language "Swahili" that checks the completeness of the data

-- Add new language "Swahili"
INSERT INTO Languages (LanguageID, LanguageName)
VALUES (19, 'Swahili');

-- Add new country "Kenya"
INSERT INTO Countries (CountryID, CountryName, Population, CapitalCity)
VALUES (19, 'Kenya', 57532493, 'Nairobi');

-- Linking language "Swahili" with country "Kenya"
INSERT INTO CountryLanguages (CountryID, LanguageID)
VALUES (19, 19);

-- Query displaying all information about the country "Kenya" and the language "Swahili" 
SELECT c.CountryID, c.CountryName, c.Population, c.CapitalCity, l.languageID, l.languageName
FROM Countries c
JOIN CountryLanguages cl ON c.CountryID = cl.CountryID
JOIN Languages l ON cl.languageID = l.languageID
WHERE c.CountryName = 'Kenya' AND l.languageName = 'Swahili';

SELECT c.*, l.*
FROM Countries c
JOIN CountryLanguages cl ON c.CountryID = cl.CountryID
JOIN Languages l ON cl.languageID = l.languageID
WHERE c.CountryName = 'Kenya' AND l.languageName = 'Swahili';

-- 8. Create a list of languages spoken in more than one country
SELECT l.languageName
FROM Languages l
JOIN CountryLanguages cl ON l.languageID = cl.languageID
GROUP BY l.languageName
HAVING COUNT(cl.CountryID) > 1;

	-- from another team
	SELECT LanguageName, COUNT(Countryid) AS SpokenInCountries  FROM v_CountryDetails
	GROUP BY LanguageName
	HAVING SpokenInCountries > 1;
    
    -- Difference between WHERE and HAVING: we make a condition for GROUP on languages, so I need a "having".  

-- 9. Display highest mountain in each country
SELECT c.CountryName, m.MountainName, m.Height
FROM Countries c
JOIN Mountains m ON c.CountryID = m.CountryID
WHERE m.Height = (
	SELECT MAX(Height)
    FROM Mountains
    WHERE CountryID = c.CountryID
);

	-- another solution
	SELECT c.CountryID, countryname, MountainName AS highest_mountain, height
    FROM mountains m 
    JOIN countries c ON m.countryid = c.countryid
    WHERE height IN (
		SELECT max(HEIGHT)
		FROM mountains
		GROUP BY CountryID);

-- 10. Create view V_LARGEST_CITY_AND_HIGHEST_MOUNTAIN that shows for each country the name of the country, the name of the most populated
-- city, the population of this city, the name of the highest mountain and the height of this mountain

CREATE VIEW V_LARGEST_CITY_AND_HIGHEST_MOUNTAIN AS
SELECT c.CountryName, ci.CityName AS LargestCity, ci.Population AS CityPopulation,
		m.MountainName AS HighestMountain, m.Height AS MountainHeight
FROM Countries c

LEFT JOIN Cities ci ON c.CountryID = ci.CountryID AND ci.Population = (
	SELECT MAX(Population)
    FROM Cities
    WHERE CountryID = c.CountryID
)
LEFT JOIN Mountains m ON c.CountryID = m.CountryID AND m.Height = (
	SELECT MAX(Height)
    FROM Mountains
    WHERE CountryID = c.CountryID
);

SELECT * FROM V_LARGEST_CITY_AND_HIGHEST_MOUNTAIN;

-- 11. Insert, delete and update tuples in the view V_LARGEST_CITY_AND_HIGHEST_MOUNTAIN. Which operations (INSERT, DELETE, and UPDATE) can be
-- executed and which not? Explain your answer

INSERT INTO V_LARGEST_CITY_AND_HIGHEST_MOUNTAIN (CountryName, LargestCity, CityPopulation, HighestMountain, MountainHeight)
VALUES ('Venezuela', 'Caracas', 2991730, 'Pico Bolivar', 4979);
-- Cannot be executed because the view is based on multiple tables, and includes the aggregate function MAX.

DELETE FROM V_LARGEST_CITY_AND_HIGHEST_MOUNTAIN WHERE CountryName = 'Australia';
-- Cannot be executed because the view is based on multiple tables.

UPDATE V_LARGEST_CITY_AND_HIGHEST_MOUNTAIN 
SET LargestCity = 'Hamburg'
WHERE CountryName = 'Germany';
-- Cannot be executed because the view includes the aggregate function MAX and joins from different tables.