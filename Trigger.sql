-- After Trigger --

create trigger trg_Employees on HR.Employees
after insert
as
 select * from inserted
go

-- check the trigger`s info

sp_helptrigger 'HR.Employees'
go

select * from sys.triggers
go

select * from sys.trigger_events
go

-- check the source of created trigger

sp_helptext 'HR.trg_Employees'
go

select * from hr.Employees

insert into hr.Employees values ('Mohammadi',
								 'Hamidreza',
								 'Data Engineer',
								 'Mr.',
								 '1988-08-08',
								 '2025-01-01',
								 'St.' ,
								 'London',
								 null,
								 1012212,
								 'Netherlands',
								 '(0098)912',
								 1
								 )

------ Alter Trigger and create a trigger to avoid any change in HR.Employees table ------

if exists(select * from sys.triggers where name = 'trg_Employees')
	drop trigger hr.trg_employees
go

create trigger trg_employees on HR.Employees
after insert,update,delete
as 
	rollback transaction
go

insert into hr.Employees values ('Mohammadi',
								 'Hamidreza',
								 'Data Engineer',
								 'Mr.',
								 '1988-08-08',
								 '2025-01-01',
								 'St.' ,
								 'London',
								 null,
								 1012212,
								 'Netherlands',
								 '(0098)912',
								 1
								 )

delete from hr.Employees where empid = 10

------ create a history changes of table records ------

select * from Production.Products

-- create a history table

if OBJECT_ID('Production.ProductsHistory') > 0
 drop table Production.ProductsHistory
go

create table Production.ProductsHistory
(
	id int identity,
	productid int not null,
	productname nvarchar(40) not null,
	supplierid int not null,
	categoryid int not null,
	unitprice money not null,
	discontinued bit not null,
	actionType nvarchar(20) not null,
	actionDate datetime,
	primary key nonclustered (id)
)
go

-- create a clustered index on histoty table

create clustered index IX_Clustered on Production.ProductsHistory (productid, categoryid)
go

-- check clustered index created
sp_helpindex 'Production.ProductsHistory'
go

-- create trigger for insert action
create trigger trg_insert on production.products
after insert
as 
	insert into 
	Production.ProductsHistory (productid,
								productname,
								supplierid,
								categoryid,
								unitprice,
								discontinued,
								actionType,
								actionDate
								) 
	select productid,productname,supplierid,categoryid,unitprice,discontinued,'INSERT',GETDATE() from inserted
go

-- create trigger for update action
create trigger trg_update_products on production.products
after update
as
	insert into Production.ProductsHistory (productid,
											productname,
											supplierid,
											categoryid,
											unitprice,
											discontinued,
											actionType,
											actionDate
											)
	select productid,productname,supplierid,categoryid,unitprice,discontinued,'UPDATE_OLD',GETDATE() from deleted
	insert into Production.ProductsHistory (productid,
											productname,
											supplierid,
											categoryid,
											unitprice,
											discontinued,
											actionType,
											actionDate
											)
	select productid,productname,supplierid,categoryid,unitprice,discontinued,'UPDATE_NEW',GETDATE() from inserted
go

-- create a tigger for delete action

create trigger trg_delete_products on production.products
after delete
as 
insert into Production.ProductsHistory (productid,
										productname,
										supplierid,
										categoryid,
										unitprice,
										discontinued,
										actionType,
										actionDate
										)
select productid,productname,supplierid,categoryid,unitprice,discontinued,'DELETE',GETDATE() from deleted


-- test the created triggers

insert into Production.Products(productname,
								supplierid,
								categoryid,
								unitprice,
								discontinued						
										)values ('FuelTank', 10, 1, 1200, 1)

select * from Production.ProductsHistory


-- create a trigger that forbbidden deleting customers that have more than one orders

select top 5 * from Sales.Customers
select top 5 * from Sales.Orders

select * into sales.customers2 from Sales.Customers

create trigger trg_delete_cust_limit on sales.customers2
after delete
as
declare @custID int
select @custID = custid from deleted
	if(
		select count(orderid) from Sales.orders2 where custid = @custID 
	) > 1
	begin
		print 'this customer can`t be deleted'
		rollback tran
	end
go

-- test deleting customer with more than one order

select custid, count(orderid) as totalOrders
	from Sales.Orders2
	group by custid
	having(count(orderid)) > 1

delete from sales.customers2 where custid = 4
	
-- create a trigger to limit update action in some field of the table

create trigger trg_limit_update_custid on sales.orders2
after update
as
	if update(custid)
	begin
		print 'this field can not be updated'
		rollback tran
		return
	end
go

update sales.orders2 set custid = 2 where orderid = 2