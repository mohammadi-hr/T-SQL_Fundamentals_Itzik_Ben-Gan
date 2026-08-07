
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

 -- how to check that a view depends on which tables

 sp_depends '[dbo].[UserCollaborator]'
 go

 select *,
		OBJECT_NAME(referenced_major_id) 
	from sys.sql_dependencies
	where OBJECT_ID = OBJECT_ID('[dbo].[UserCollaborator]')
GO

