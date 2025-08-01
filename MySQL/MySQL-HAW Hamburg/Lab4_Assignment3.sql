-- Students: Borean Araujo, Mirella Estefania		YUN, EUNSEONG

use COMPANY_lab ;

-- 1.
CREATE VIEW V_SENIORS AS
SELECT *
FROM employee
WHERE Salary > 4000
WITH CHECK OPTION;

SELECT * FROM V_SENIORS;

-- Update salary of one employee in view
UPDATE V_SENIORS
SET salary = 50000
WHERE Ssn = '123456789';

-- Update salary of one employee in table
UPDATE EMPLOYEE
SET salary = 50000
WHERE Ssn = '123456789';

-- Insert new employees into view
INSERT INTO V_SENIORS (Fname, Minit, Lname, Ssn, Bdate, Address, Sex, Salary, Super_ssn, Dno) VALUES 
('Mirella', 'E', 'Borean', '697654321', '1999-11-18', 'Hamburg', 'f', 60000, NULL, 1), 
('Ayden', ' ', 'Yun', '765432123', '1993-01-13', 'Hamburg', 'm', 60001, NULL, 1);

-- Insert new employees into base table
INSERT INTO employee (Fname, Minit, Lname, Ssn, Bdate, Address, Sex, Salary, Super_ssn, Dno) VALUES 
('Ayden', ' ', 'Yun', '765432123', '1993-01-13', 'Hamburg', 'm', 60001, NULL, 1),
('Eunseong', ' ', 'Yun', '765432124', '1993-01-13', 'Hamburg', 'm', 60000, NULL, 1);

-- Delete tuples in view
DELETE FROM V_SENIORS
WHERE Ssn = '697654321';

DELETE FROM V_SENIORS
WHERE Ssn = '765432123';
SELECT * FROM V_SENIORS;

-- Delete tuples in table
DELETE FROM EMPLOYEE
WHERE Ssn = '765432124';

DELETE FROM EMPLOYEE
WHERE Ssn = '765432123';

SELECT * FROM EMPLOYEE;

-- 2. Write a trigger that limits all salary increases to 50%. Also create statements to check the correct behavior of the triggers.
DROP TRIGGER LIMIT_SALARY_INCREASE;
DELIMITER |
CREATE TRIGGER LIMIT_SALARY_INCREASE
BEFORE UPDATE ON EMPLOYEE
FOR EACH ROW
BEGIN
    IF NEW.Salary > OLD.Salary * 1.5 THEN
        SET NEW.Salary = OLD.Salary * 1.5;
    END IF;
END;
|
DELIMITER ;

-- Testing the trigger
-- Valid update
UPDATE EMPLOYEE
SET Salary = Salary * 1.4
WHERE Ssn = '123456789';

SELECT * FROM EMPLOYEE;

-- Invalid update 
UPDATE EMPLOYEE
SET Salary = Salary * 2
WHERE Ssn = '123456789';

-- 3. Write a trigger that enforces the policy that salaries may never decrease. 
DROP TRIGGER PREVENT_SALARY_DECREASE;
DELIMITER |
CREATE TRIGGER PREVENT_SALARY_DECREASE
BEFORE UPDATE ON EMPLOYEE
FOR EACH ROW
BEGIN
    IF NEW.Salary < OLD.Salary THEN
        SET NEW.Salary = OLD.Salary;
    END IF;
END;
|
DELIMITER ;

-- Test case: Attempt to decrease salary
UPDATE EMPLOYEE
SET Salary = Salary - 1000
WHERE Ssn = '123456789';

SELECT * FROM EMPLOYEE WHERE Ssn = '123456789';

-- 4. Alter table department
ALTER TABLE DEPARTMENT	-- adding new column to department table
ADD COLUMN TotalSalary DECIMAL(10, 2) DEFAULT 0;

UPDATE DEPARTMENT  -- update values of new column, selecting sum of salaries
SET TotalSalary = (	
    SELECT SUM(Salary)
    FROM EMPLOYEE
    WHERE EMPLOYEE.Dno = DEPARTMENT.Dnumber
);

-- Trigger for maintaining value of column when hiring a new employee 
DELIMITER |
CREATE TRIGGER UPDATE_TOTAL_SALARY_AFTER_INSERT  
AFTER INSERT ON EMPLOYEE
FOR EACH ROW
BEGIN
    UPDATE DEPARTMENT
    SET TotalSalary = (
        SELECT SUM(Salary)
        FROM EMPLOYEE
        WHERE EMPLOYEE.Dno = DEPARTMENT.Dnumber
    )
    WHERE Dnumber = NEW.Dno;
END;
|
DELIMITER ;

-- Trigger for maintaining value of column when deleting an employee 
DROP TRIGGER UPDATE_TOTAL_SALARY_AFTER_DELETE;
DELIMITER |
CREATE TRIGGER UPDATE_TOTAL_SALARY_AFTER_DELETE
AFTER DELETE ON EMPLOYEE
FOR EACH ROW
BEGIN
    UPDATE DEPARTMENT
    SET TotalSalary = (
        SELECT SUM(Salary)
        FROM EMPLOYEE
        WHERE EMPLOYEE.Dno = DEPARTMENT.Dnumber
    )
    WHERE Dnumber = OLD.Dno;
END;
|
DELIMITER ;

-- Trigger for maintaining value of column when updating an employee
DELIMITER |
CREATE TRIGGER UPDATE_TOTAL_SALARY_AFTER_UPDATE
AFTER UPDATE ON EMPLOYEE
FOR EACH ROW
BEGIN
    -- Update the department's TotalSalary if the department has changed
    IF OLD.Dno != NEW.Dno THEN
        UPDATE DEPARTMENT
        SET TotalSalary = (
            SELECT SUM(Salary)
            FROM EMPLOYEE
            WHERE EMPLOYEE.Dno = DEPARTMENT.Dnumber
        )
        WHERE Dnumber = OLD.Dno;
        UPDATE DEPARTMENT
        SET TotalSalary = (
            SELECT SUM(Salary)
            FROM EMPLOYEE
            WHERE EMPLOYEE.Dno = DEPARTMENT.Dnumber
        )
        WHERE Dnumber = NEW.Dno;
    ELSE 	-- Update the same department's TotalSalary if only the salary has changed
        UPDATE DEPARTMENT
        SET TotalSalary = (
            SELECT SUM(Salary)
            FROM EMPLOYEE
            WHERE EMPLOYEE.Dno = DEPARTMENT.Dnumber
        )
        WHERE Dnumber = NEW.Dno;
    END IF;
END;
|
DELIMITER ;

SELECT * FROM department;

-- Testing
-- Insert a new employee
INSERT INTO EMPLOYEE (Fname, Minit, Lname, Ssn, Bdate, Address, Sex, Salary, Super_ssn, Dno)
VALUES ('Estefania', 'M', 'Araujo', '112233445', '1999-11-18', 'Hamburg', 'f', 10000, NULL, 1);

SELECT * FROM DEPARTMENT;

DELETE FROM EMPLOYEE WHERE Ssn = '112233445';
