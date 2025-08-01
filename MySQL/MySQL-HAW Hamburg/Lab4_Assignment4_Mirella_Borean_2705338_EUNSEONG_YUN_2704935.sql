-- Students: Borean Araujo, Mirella Estefania		YUN, EUNSEONG

CREATE SCHEMA IF NOT EXISTS assignment4;
USE assignment4;

-- 1. 
-- Running command in session1
CREATE TABLE IF NOT EXISTS TAB1 (
	id	INTEGER	NOT NULL,
    n	INTEGER,
    PRIMARY KEY (id)
    );
    
SELECT * FROM TAB1;

-- 2. Insert in session1
START TRANSACTION;
INSERT INTO TAB1 (id, n) VALUES
(1, 1), (2, 2), (3,3);

COMMIT;

-- 3. Update value of n = 33 in session 1
START TRANSACTION;

UPDATE TAB1 
SET n = 33
WHERE id = 3;

SELECT * FROM TAB1;

ROLLBACK;










