-- Use database / schema
CREATE DATABASE IF NOT EXISTS UNIVERSITY;
USE UNIVERSITY;

-- Create tables
CREATE TABLE IF NOT EXISTS STUDY_PROGRAM (
    Program_id 			VARCHAR(4) 		NOT NULL,
    Prog_name 			VARCHAR(40) 	NOT NULL UNIQUE,
    Req_credit_points 	INTEGER 		NOT NULL,
    PRIMARY KEY (Program_id)
);

CREATE TABLE IF NOT EXISTS COURSE (
    Course_description 	VARCHAR(270) 	NOT NULL,
    Course_id 			VARCHAR(10) 	NOT NULL,
    Course_name 		VARCHAR(50) 	NOT NULL,
    Credit_points 		INTEGER 		NOT NULL,
    PRIMARY KEY (Course_id)
);

CREATE TABLE IF NOT EXISTS STUDENT (
    Student_id 			INTEGER 		NOT NULL,
    Fname 				VARCHAR(15) 	NOT NULL,
    Lname 				VARCHAR(15) 	NOT NULL,
    Bdate 				DATE,			
    Year_enrollment 	SMALLINT 		NOT NULL,
    PRIMARY KEY (Student_id)
);

CREATE TABLE IF NOT EXISTS PREREQUISIT (	
    Course_id         	VARCHAR(10) 	NOT NULL,
    Prereq_course_id	VARCHAR(10) 	NOT NULL,	-- course that is required for another course
    PRIMARY KEY (Course_id, Prereq_course_id),
    FOREIGN KEY (Course_id) REFERENCES COURSE(Course_id),
    FOREIGN KEY (Prereq_course_id) REFERENCES COURSE(Course_id)
);

CREATE TABLE IF NOT EXISTS ATTEMPTS (
	Student_id    	INTEGER						NOT NULL,
    Course_id     	VARCHAR(10) 				NOT NULL,
    Year         	SMALLINT 					NOT NULL,
    Term         	ENUM('Summer', 'Winter') 	NOT NULL,
    Grade        	DECIMAL(4, 0),
    PRIMARY KEY (Student_id, Course_id),
    FOREIGN KEY (Student_id) REFERENCES STUDENT(Student_id),
    FOREIGN KEY (Course_id) REFERENCES COURSE(Course_id),
    CHECK (Grade >= 0 AND Grade <= 15)
);

CREATE TABLE IF NOT EXISTS ENROLLS_IN (
    Student_id      INTEGER       NOT NULL,
    Program_id      VARCHAR(2)    NOT NULL,
    PRIMARY KEY (Student_id, Program_id),
    FOREIGN KEY (Student_id) REFERENCES STUDENT(Student_id),
    FOREIGN KEY (Program_id) REFERENCES STUDY_PROGRAM(Program_id)
);

-- Insert data
INSERT INTO STUDY_PROGRAM (Program_id, Prog_name, Req_credit_points) VALUES 
('IE', 'Information Engineering', 210);

INSERT INTO COURSE (Course_id, Course_name, Course_description, Credit_points) VALUES 
('MA1', 'Mathematics 1', 'This unit presents an introduction to the fundamentals of Differential Calculus for single argument functions and to linear algebra. Many applications and solution techniques are presented.', 8), 
('MA2', 'Mathematics 2', 'This unit presents an introduction to the fundamentals of integral calculus, multiple argument functions, differential equations and stochastics. Many applications and solution techniques are presented.', 8);

INSERT INTO STUDENT (Student_id, Fname, Lname, Bdate, Year_enrollment) VALUES 
(2705338, 'Mirella', 'Borean', '1999-11-18', '2023'), 
(2709843, 'Liam', 'P', '1993-08-29', '2024');

INSERT INTO PREREQUISIT (Course_id, Prereq_course_id) VALUES 
('MA2', 'MA1');

INSERT INTO ATTEMPTS (Student_id, Course_id, Year, Term, Grade) VALUES 
(2705338, 'MA1', 2023, 'Winter', 9.00),  -- Valid grade
(2709843, 'MA2', 2024, 'Summer', 15.00);  -- Valid grade

-- (1234568, '2', 2024, 'Summer', 20.00); -- Invalid grade
