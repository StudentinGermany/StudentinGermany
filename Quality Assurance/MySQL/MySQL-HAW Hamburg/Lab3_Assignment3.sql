-- Students: Borean Araujo, Mirella Estefania		YUN, EUNSEONG

create schema COMPANY_lab3_ass7 ;
use COMPANY_lab3_ass7 ;

-- STEP 1: Create tables without foreign keys -----------------------------------------

CREATE TABLE IF NOT EXISTS EMPLOYEE
( 
Fname 			VARCHAR(15) 		NOT NULL ,
Minit 			CHAR,
Lname 			VARCHAR(15) 		NOT NULL ,
Ssn 			CHAR(9) 			NOT NULL,
Bdate 			DATE,
Address 		VARCHAR(50),
Sex 			CHAR,
Salary 			DECIMAL(10,2), 
Super_ssn 		CHAR(9),
Dno 			INT 				NOT NULL,
CONSTRAINT EMPPK PRIMARY KEY (Ssn));

CREATE TABLE IF NOT EXISTS DEPARTMENT
( 
Dname VARCHAR(15) NOT NULL,
Dnumber INT NOT NULL,
Mgr_ssn CHAR(9) NOT NULL,
Mgr_start_date DATE,
Doverhead INT NOT NULL, 
CONSTRAINT DEPTPK PRIMARY KEY (Dnumber) ,
CONSTRAINT DEPTUDNAME UNIQUE (Dname));

CREATE TABLE IF NOT EXISTS DEPT_LOCATIONS
( Dnumber INT NOT NULL,
Dlocation VARCHAR(15) NOT NULL,
CONSTRAINT DEPTLOCPK PRIMARY KEY (Dnumber, Dlocation),
FOREIGN KEY (Dnumber) REFERENCES DEPARTMENT(Dnumber) );

CREATE TABLE IF NOT EXISTS PROJECT
( Pname VARCHAR(15) NOT NULL,
Pnumber INT ,
Plocation VARCHAR(15),
Dnum INT NOT NULL,
PRIMARY KEY (Pnumber),
CONSTRAINT PROJECTUPNAME UNIQUE (Pname),
CONSTRAINT PROJECTFKDNUM FOREIGN KEY (Dnum) REFERENCES DEPARTMENT(Dnumber) );

CREATE TABLE IF NOT EXISTS WORKS_ON
( Essn CHAR(9) NOT NULL,
Pno INT NOT NULL,
Hours DECIMAL(3 ,1),
PRIMARY KEY (Essn , Pno),
FOREIGN KEY (Essn) REFERENCES EMPLOYEE(Ssn),
CONSTRAINT WORKSONFKPNO FOREIGN KEY (Pno) REFERENCES PROJECT(Pnumber) );

CREATE TABLE IF NOT EXISTS DEPENDENT
( Essn CHAR(9) NOT NULL,
Dependent_name VARCHAR(15) NOT NULL,
Sex CHAR,
Bdate DATE,
Relationship VARCHAR(15),
PRIMARY KEY (Essn , Dependent_name),
CONSTRAINT DEPFKESSN FOREIGN KEY (Essn) REFERENCES EMPLOYEE(Ssn) );

-- change column Sex
ALTER TABLE EMPLOYEE
CHANGE COLUMN Sex Sex ENUM('f', 'm', 'd') ;



-- STEP 2: Import Data -----------------------------------------
-- Provided csv-files must be contained in the file system of your Database, e.g., C:\ProgramData\MySQL\MySQL Server 8.0\Data\Company
load data local infile 'C:\\Users\\Mirella\\Documents\\HAW\\IV\\Databases\\Company\\Employee.csv'
into table employee
fields terminated by ';'
lines terminated by '\n'
ignore 1 lines
-- If an employee does not have a supervisor, NULL must be inserted
(Fname, Minit, Lname, Ssn, Bdate, Address, Sex, Salary, @Superssn, Dno)
SET Super_ssn = IF(@Superssn = '', NULL, @Superssn);

load data infile 'department.csv'
into table department
fields terminated by ';'
lines terminated by '\n'
ignore 1 lines
(Dname, Dnumber, Mgr_start_date, Mgr_ssn);

load data infile 'Projects.csv'
into table project
fields terminated by ';'
lines terminated by '\n'
ignore 1 lines
(Pname, Pnumber, Plocation, Dnum);

load data infile 'dept_locations.csv'
into table dept_locations
fields terminated by ';'
lines terminated by '\n'
ignore 1 lines
(Dnumber, Dlocation);

load data infile 'Works_on.csv'
into table works_on
fields terminated by ';'
lines terminated by '\n'
ignore 1 lines
-- If an employee did not worked on the project yet, NULL must be inserted
(Essn, Pno, @hours)
SET hours = IF(@hours = '', NULL, @hours);

load data infile 'dependent.csv'
into table dependent
fields terminated by ';'
lines terminated by '\n'
ignore 1 lines
(Essn, Dependent_name, Sex, Bdate, relationship);

-- STEP 3: Add Foreign Keys -----------------------------------------

ALTER TABLE DEPARTMENT
ADD CONSTRAINT DEPTMGRFK  FOREIGN KEY (Mgr_ssn) REFERENCES EMPLOYEE(Ssn) 
ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE EMPLOYEE
ADD CONSTRAINT EMPFKDNO FOREIGN KEY (Dno) REFERENCES DEPARTMENT(Dnumber) 
ON DELETE RESTRICT ON UPDATE CASCADE;

-- ALTER TABLE EMPLOYEE 
-- ADD CONSTRAINT EMPFKSUPERSSN
-- FOREIGN KEY (Super_ssn) REFERENCES EMPLOYEE(Ssn)
-- ON DELETE SET NULL
-- ON UPDATE CASCADE ; 

-- for task 4
ALTER TABLE EMPLOYEE
ADD CONSTRAINT EMPSUPERFK
FOREIGN KEY (Super_ssn) REFERENCES EMPLOYEE(Ssn)
ON DELETE CASCADE ON UPDATE CASCADE;

-- 1. Retrieve the names of all employees in department 5 who work more than 10 hours per week on a project.
SELECT E.Fname, E.Minit, E.Lname
FROM EMPLOYEE E
JOIN WORKS_ON W ON E.Ssn = W.Essn
WHERE E.Dno = 5 AND W.Hours > 10;

-- 2. List the names of all employees who have a dependent with the same first name as themselves.
SELECT DISTINCT E.Fname,  E.Minit, E.Lname
FROM EMPLOYEE E
JOIN DEPENDENT D ON E.Ssn = D.Essn
WHERE E.Fname = D.Dependent_name;

-- 3. Find the names of all employees who are directly supervised by ‘Franklin Wong’
SELECT E.Fname, E.Minit, E.Lname
FROM EMPLOYEE E
JOIN EMPLOYEE S ON E.Super_ssn = S.Ssn
WHERE S.Fname = 'Franklin' AND S.Lname = 'Wong';

-- 4. 
DELETE FROM EMPLOYEE WHERE Lname = 'Borg' ;
-- Error Code: 1451. Cannot delete or update a parent row: a foreign key constraint fails (`company`.`department`, CONSTRAINT `DEPTMGRFK` FOREIGN KEY (`Mgr_ssn`) REFERENCES `employee` (`Ssn`) ON DELETE RESTRICT ON UPDATE CASCADE)	0.000 sec

-- 5 Retrieve the average salary of all female employees.
SELECT P.Pname, P.Pnumber, SUM(W.Hours) AS Total_Hours
FROM PROJECT P
JOIN WORKS_ON W ON P.Pnumber = W.Pno
GROUP BY P.Pname;

-- 6 Retrieve the average salary of all female employees.
SELECT AVG(Salary) AS Average_Salary
FROM EMPLOYEE
WHERE Sex = 'f';

-- 7 Write SQL statements to create a table EMPLOYEE_BACKUP to back up the EMPLOYEE table shown.
CREATE TABLE EMPLOYEE_BACKUP AS -- this is called a Generated Table. Useful for keeping track of changes 
SELECT * FROM EMPLOYEE;

-- if I create a View instead, the new changes are shown (data is updated automatically), but the table is not updated by itself (have to do it manually)

-- 8 For each department, whose average employee salary is more than $30,000, retrieve the department name and the number of employees working for that department.
SELECT D.Dname, D.Dnumber, COUNT(E.Ssn) AS Employee_Count
FROM DEPARTMENT D
JOIN EMPLOYEE E ON D.Dnumber = E.Dno
GROUP BY D.Dname
HAVING AVG(E.Salary) > 30000;