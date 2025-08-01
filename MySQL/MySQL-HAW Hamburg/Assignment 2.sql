-- Use database / schema
CREATE DATABASE IF NOT EXISTS TECHNOLOGY_SUPPORT_COMPANY;
USE TECHNOLOGY_SUPPORT_COMPANY;

-- Create tables
CREATE TABLE IF NOT EXISTS STAFF ( 
	Staff_id		INTEGER			NOT NULL,
    Lname			VARCHAR(15)		NOT NULL,
    Fname			VARCHAR(15)		NOT NULL,
    PRIMARY KEY (Staff_id)
);

CREATE TABLE IF NOT EXISTS CUSTOMER (
	Customer_id		INTEGER			NOT NULL,
    Username		VARCHAR(20)		NOT NULL	UNIQUE,
    Fname			VARCHAR(15)		NOT NULL,
    Lname			VARCHAR(15)		NOT NULL,
    Email			VARCHAR(254)	NOT NULL	UNIQUE,
    Bdate			DATE,
    PRIMARY KEY (Customer_id)
);

CREATE TABLE IF NOT EXISTS REQUEST (
	Request_id		INTEGER												NOT NULL,
    Req_description	VARCHAR(270)										NOT NULL,
    Status			ENUM('Open', 'In_progress', 'On_hold', 'Closed')	NOT NULL,
    Date 			DATE												NOT NULL,
    PRIMARY KEY (Request_id),
    Customer_id 	INTEGER,
    FOREIGN KEY (Customer_id) REFERENCES CUSTOMER(Customer_id)
);

CREATE TABLE IF NOT EXISTS HANDLES (
	Request_id INTEGER,
    Staff_id INTEGER,
    PRIMARY KEY (Request_id, Staff_id),
    FOREIGN KEY (Request_id) REFERENCES REQUEST(Request_id),
    FOREIGN KEY (Staff_id) REFERENCES STAFF(Staff_id)
);

CREATE TABLE IF NOT EXISTS INTERACTS (
	Customer_id		INTEGER			NOT NULL,
    Staff_id		INTEGER			NOT NULL,
    PRIMARY KEY (Customer_id, Staff_id),
    FOREIGN KEY (Customer_id) REFERENCES CUSTOMER(Customer_id),
    FOREIGN KEY (Staff_id) REFERENCES STAFF(Staff_id)
);

-- Insert data
INSERT INTO STAFF (Staff_id, Lname, Fname) VALUES
(5, 'Borean', 'Mirella'),
(7, 'Brown', 'Gerard');

INSERT INTO CUSTOMER (Customer_id, Username, Fname, Lname, Email, Bdate) VALUES
(17, 'Maria123', 'Maria', 'Johnson', 'mariajohnson@hotmail.com', '1998-10-14'),
(16, 'ThisIsAUsername', 'John', 'Way', 'john.way@gmail.com', '1980-05-21');

INSERT INTO REQUEST (Request_id, Req_description, Status, Date, Customer_id) VALUES
(10, 'Unable to log in to account', 'Open', '2024-05-20', 17), 
(12, 'Card is getting declined', 'Closed', '2024-04-02', 16);

INSERT INTO HANDLES (Request_id, Staff_id) VALUES
(10, 7),
(12, 5);

INSERT INTO INTERACTS (Customer_id, Staff_id) VALUES
(16, 5),
(17, 7);