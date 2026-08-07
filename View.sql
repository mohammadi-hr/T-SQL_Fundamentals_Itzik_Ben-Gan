
/*
View is recognized also as following names:
	1. Stored query
	2. Virtual table
	3. Saved select
	4. Named query


*/

-- What is materialized view ? 

-- check the view source

sp_helptext 'dbo.pakages'

select * from INFORMATION_SCHEMA.VIEWS
 where TABLE_NAME = 'dbo.pakages'

 select * 
 from sys.sql_modules
 where OBJECT_ID = OBJECT_ID('dbo.pakages')

