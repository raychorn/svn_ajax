CREATE TABLE ##GetAllObjectLinksTemp (id int, ownerPropertyName varchar(50), relatedPropertyName varchar(50))

INSERT INTO ##GetAllObjectLinksTemp (id, ownerPropertyName, relatedPropertyName)
VALUES (-1, 'Choose...', '')

INSERT INTO ##GetAllObjectLinksTemp (id, ownerPropertyName, relatedPropertyName)
SELECT TOP 100 id, ownerPropertyName, relatedPropertyName
FROM objectLinks
ORDER BY ownerPropertyName, relatedPropertyName;

SELECT * FROM ##GetAllObjectLinksTemp

DROP TABLE ##GetAllObjectLinksTemp
