-- Students: Borean Araujo, Mirella Estefania		YUN, EUNSEONG

-- Use database / schema
CREATE DATABASE IF NOT EXISTS UNIVERSITY;
USE UNIVERSITY;

-- Create tables
CREATE TABLE IF NOT EXISTS PROGRAM (
    programID 				INTEGER 		NOT NULL,
    programName 			VARCHAR(40) 	NOT NULL UNIQUE,
    requiredCPs 			INTEGER 		NOT NULL,
    PRIMARY KEY (programID)
);

CREATE TABLE IF NOT EXISTS COURSE (
    courseDescription 		VARCHAR(270) 	NOT NULL,
    courseID 				VARCHAR(10) 	NOT NULL,
    courseName 				VARCHAR(50) 	NOT NULL,
    creditPoints 			INTEGER 		NOT NULL,
    programID				INTEGER			NOT NULL,
    PRIMARY KEY (courseID),
    FOREIGN KEY (programID) REFERENCES PROGRAM(programID)
    
    -- constraint fk_course_program
    -- fore
);

CREATE TABLE IF NOT EXISTS STUDENT (
    studentID 				INTEGER 		NOT NULL,
    firstName 				VARCHAR(15) 	NOT NULL,
    lastName 				VARCHAR(15) 	NOT NULL,
    dob 					DATE			NOT NULL,
	programID				INTEGER			NOT NULL,
    PRIMARY KEY (studentID),
    FOREIGN KEY (programID) REFERENCES PROGRAM(programID)
    
    -- constraint fk_program
    -- foreign key(programID) 
);

CREATE TABLE IF NOT EXISTS PREREQUISITE (	
    advancedCourseID         	VARCHAR(10),
    prerequisiteCourseID		VARCHAR(10),	-- course that is required for another course
    PRIMARY KEY (advancedCourseID, prerequisiteCourseID),
    FOREIGN KEY (advancedCourseID) REFERENCES COURSE(courseID),
    FOREIGN KEY (prerequisiteCourseID) REFERENCES COURSE(courseID)
    
    -- constraint fk_Advanced_Course
    -- foreign key(advancedCourseID) references course(courseID)
    -- on delete cascade
    -- on update cascade,
);

CREATE TABLE IF NOT EXISTS ATTEMPTS (
	studentID    	INTEGER						NOT NULL,
    courseID     	VARCHAR(10) 				NOT NULL,
    year         	SMALLINT 					NOT NULL,
    term         	ENUM('Summer', 'Winter') 	NOT NULL,
    grade        	DECIMAL(4, 0),
    PRIMARY KEY (studentID, courseID, year, term),
    FOREIGN KEY (studentID) REFERENCES STUDENT(studentID),
    FOREIGN KEY (courseID) REFERENCES COURSE(courseID),
    CHECK (grade >= 0 AND grade <= 15)
    
    -- constraint fk_student
    -- foreign key(studentID) references student(studentID),
    
    -- constraint fk_course
    -- foreign
);

-- Insert data
INSERT INTO PROGRAM (programID, programName, requiredCPs) VALUES 
('1', 'Information Engineering', 120),
('2', 'Renewable Energies', 110);

INSERT INTO COURSE (courseID, courseName, courseDescription, creditPoints, programID) VALUES 
(4, 'MA1', 'Mathematics 1', 8, 1),
(9, 'MA2', 'Mathematics 2', 8, 1),
(13, 'SS1', 'Signals and Systems 1', 6, 1),
(15, 'DB', 'Databases', 6, 1);

INSERT INTO STUDENT (studentID, firstName, lastName, dob, programID) VALUES 
(2705338, 'Mirella', 'Borean', '1999-11-18', '1'), 
(123456, 'John', 'Wayne', '1998-05-11', '1'),
(234567, 'Anna', 'Meyer', '1999-02-13', '1');

INSERT INTO PREREQUISITE (advancedCourseID, prerequisiteCourseID) VALUES 
(9, 4),
(13, 9),
(13, 4);

INSERT INTO ATTEMPTS (studentID, courseID, year, term, grade) VALUES 
(123456, 4, 2021, 1, 7),
(123456, 9, 2021, 2, 9),
(123456, 13, 2022, 1, 3),
(123456, 13, 2022, 2, 6);

-- 3. Return all students (first name + last name) that study the program “Information Engineering”.
SELECT firstName, lastName 
FROM STUDENT
WHERE programID = 1;

-- SELECT s.firstName, s.lastName 
-- FROM STUDENT s, program
-- WHERE program.programName = 'Information Engineering' 
-- AND STUDENT.PROGRAMID = PROGRAM.PROGRAMID; -- NEED TO USE WHAT IS ASKING DIRECTLY, NOT 1 (information part of question description)


-- 4. Return the name of all courses that have prerequisite courses.
SELECT DISTINCT courseName 
FROM COURSE, PREREQUISITE
WHERE COURSE.courseID = PREREQUISITE.advancedCourseID;



-- 5. Return the sum of all credit points successfully achieved by student “John Wayne”. Keep in mind that the credit points only count when the student has an attempt with a grade of 5 or more points.
SELECT SUM(grade) 
FROM ATTEMPTS, STUDENT 
WHERE firstName = 'John' AND lastName = 'Wayne' AND grade >= 5; 

-- 6. A student needs to be removed from the database. Write SQL-statements to remove the student with the name “John Wayne” from the database.
DELETE FROM ATTEMPTS
WHERE studentID = (SELECT studentID FROM STUDENT WHERE firstName = 'John' AND lastName = 'Wayne');

DELETE FROM STUDENT 
WHERE firstName = 'John' AND lastName = 'Wayne';
