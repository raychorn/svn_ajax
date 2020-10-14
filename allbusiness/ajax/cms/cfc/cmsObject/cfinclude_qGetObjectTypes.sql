DECLARE @cnt as int

DECLARE @objectClassID as int
DECLARE @className as varchar(50)
DECLARE @classPath as varchar(7000)

DECLARE @dset TABLE (objectClassID int, cnt int, className varchar(50), classPath varchar(7000))

DECLARE class_cursor CURSOR FOR
	SELECT objectClassID, className, classPath
	FROM objectClassDefinitions

OPEN class_cursor

FETCH NEXT FROM class_cursor
INTO @objectClassID, @className, @classPath

WHILE @@FETCH_STATUS = 0
BEGIN
	SELECT @cnt = (SELECT COUNT(objects.id) FROM objects WHERE (objectClassID = @objectClassID))
	INSERT INTO @dset (objectClassID, cnt, className, classPath)
		VALUES (@objectClassID, @cnt, @className, @classPath)

	FETCH NEXT FROM class_cursor
	INTO @objectClassID, @className, @classPath
END

CLOSE class_cursor
DEALLOCATE class_cursor

SELECT * FROM @dset
ORDER BY className
