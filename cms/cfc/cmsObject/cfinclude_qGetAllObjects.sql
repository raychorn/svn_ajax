CREATE TABLE ##GetAllObjectsTemp (id int, objectName varchar(7000))

INSERT INTO ##GetAllObjectsTemp (id, objectName)
VALUES (-1, 'Choose...')

INSERT INTO ##GetAllObjectsTemp (id, objectName)
SELECT TOP 100 id, objectName FROM objects
ORDER BY objectName;

SELECT * FROM ##GetAllObjectsTemp

DROP TABLE ##GetAllObjectsTemp
