
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


-- how to create an encrypted view

create view testPackageView
with encryption 
as
select p.UserContainerId,ps.NumberOfMonthTitle from Master_TPS_ECommerce..Package P
join Master_TPS_ECommerce..PackageSalesAmount PS
on P.PackageSalesAmountId = PS.id

GO

-- if you use * for view and the main tables alter so you have to use :

sp_refreshview 'dbo.testPackageView'

-- better solution : use schemabinding

create view dbo.testPackageView
with schemabinding
as
select p.id as packageId,ps.id packageSalesAmountId,p.UserContainerId,ps.NumberOfMonthTitle,ps.BasePackageTypeId
from dbo.Package P
join dbo.PackageSalesAmount PS
on P.PackageSalesAmountId = PS.id

GO

-- what is index view and why use it ?
-- In SQL Server, an indexed view is essentially a view whose result is physically materialized and stored as an index.

create unique clustered index [PackageViewMaterialized] on dbo.testPackageView(packageId,packageSalesAmountId)

drop view dbo.testPackageView
