DROP DATABASE IF EXISTS BAR_OWNER;

-- Use database / schema
CREATE DATABASE IF NOT EXISTS BAR_OWNER;
USE BAR_OWNER;

-- Create tables
CREATE TABLE IF NOT EXISTS BAR (
    Bname 				VARCHAR(50) 	NOT NULL UNIQUE,
    Address 			VARCHAR(30) 	NOT NULL UNIQUE,
    PRIMARY KEY (Bname, Address)
);

CREATE TABLE IF NOT EXISTS DRINK (
	Id					VARCHAR(10)		NOT NULL UNIQUE,
    Dname				VARCHAR(20)		NOT NULL,
    PRIMARY KEY (Id)
);

CREATE TABLE IF NOT EXISTS DRINK_INGREDIENTS ( -- forgot to include in report!!
	Drink_id			VARCHAR(10)		NOT NULL,
    Drink_ingredients	VARCHAR(60)		NOT NULL,
    PRIMARY KEY (Drink_id, Drink_ingredients),
    FOREIGN KEY (Drink_id) REFERENCES DRINK(Id)
    ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS DRINK_PRICE ( -- forgot to include in report!!
	Drink_id			VARCHAR(10)		NOT NULL,
    Drink_price			DECIMAL(10,2)	NOT NULL,
    PRIMARY KEY (Drink_id, Drink_price),
    FOREIGN KEY (Drink_id) REFERENCES DRINK(Id)
    ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS BARTENDER (
	Bt_ssn				CHAR(9)			NOT NULL UNIQUE,
    Salary				DECIMAL(10,2)	NOT NULL,
    Address				VARCHAR(30)		NOT NULL,
    Phone				VARCHAR(15),
    Fname				VARCHAR(15)		NOT NULL,
    Lname				VARCHAR(15)		NOT NULL,
    -- bar id
    PRIMARY KEY (Bt_ssn) 
);

CREATE TABLE IF NOT EXISTS OFFERS (
	Bar_name			VARCHAR(50) 	NOT NULL,
    Bar_address			VARCHAR(30)		NOT NULL,
    Drink_id			VARCHAR(10)		NOT NULL,
    PRIMARY KEY (Bar_name, Bar_address, Drink_id),
    FOREIGN KEY (Bar_name, Bar_address) REFERENCES BAR (Bname, Address),
    FOREIGN KEY (Drink_id) REFERENCES DRINK (Id)
    ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS NEEDS (
	Bartender_ssn		CHAR(9)			NOT NULL,
    Bar_name			VARCHAR(50) 	NOT NULL,
    PRIMARY KEY (Bartender_ssn, Bar_name),
    FOREIGN KEY (Bartender_ssn) REFERENCES BARTENDER (Bt_ssn),
    FOREIGN KEY (Bar_name) REFERENCES BAR (Bname)
);

CREATE TABLE IF NOT EXISTS WORKS_WITH (
	Bt_ssn_1			CHAR(9)			NOT NULL,
    Bt_ssn_2			CHAR(9)			NOT NULL,
    PRIMARY KEY (Bt_ssn_1, Bt_ssn_2),
    FOREIGN KEY (Bt_ssn_1) REFERENCES BARTENDER (Bt_ssn),
    FOREIGN KEY (Bt_ssn_2) REFERENCES BARTENDER (Bt_ssn)
);

-- Insert data
INSERT INTO BAR (Bname, Address) VALUES
('Brand New Bar', 'Berliner Tor 7, Hamburg'), ('Another Brand New Bar', 'Barmbek 1, Hamburg');

INSERT INTO BARTENDER (Bt_ssn, Salary, Address, Phone, Fname, Lname) VALUES
(123456789, 1500.00, 'Berliner Tor 5', 0161234567, 'Mirella', 'Borean'),
(123456780, 1500.00, 'Berliner Tor 5', 0167654321, 'Ayden', 'Yun'),
(123458769, 1500.00, 'Berliner Tor 7', 0167642342, 'Harry', 'Horan'),
(123456790, 1500.00, 'Berliner Tor 7', 0167234532, 'Gerard', 'Naerob');

INSERT INTO DRINK (Id, Dname) VALUES
(1, 'Iced Fritz'), 
(2, 'Simple Fritz');

INSERT INTO DRINK_INGREDIENTS (Drink_id, Drink_ingredients) VALUES
(1, 'Fritz-Kola and ice'), 
(2, 'Fritz-Kola');

INSERT INTO DRINK_PRICE (Drink_id, Drink_price) VALUES
(1, 2.5),
(2, 2.5);

INSERT INTO NEEDS (Bartender_ssn, Bar_name) VALUES
(123456789, 'Brand New Bar'), 
(123456780, 'Brand New Bar');

INSERT INTO OFFERS (Bar_name, Bar_address, Drink_id) VALUES
('Brand New Bar', 'Berliner Tor 7, Hamburg', 1), 
('Brand New Bar', 'Berliner Tor 7, Hamburg', 2), 
('Another Brand New Bar', 'Barmbek 1, Hamburg', 1),
('Another Brand New Bar', 'Barmbek 1, Hamburg', 2);

INSERT INTO WORKS_WITH (Bt_ssn_1, Bt_ssn_2) VALUES
(123456789, 123456780), 
(123458769, 123456790);
