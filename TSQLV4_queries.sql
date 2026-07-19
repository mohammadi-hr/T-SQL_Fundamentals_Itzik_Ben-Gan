--237 window functions
select ROW_NUMBER() OVER (PARTITION BY orderid order by qty) as row,
	orderid, productid, qty, unitprice,
	sum(unitprice*qty) over (partition by orderid order by qty rows between unbounded preceding and current row) as running_total
from TSQLV4.sales.OrderDetails
order by orderid,qty

select top 1 * from TSQLV4.Sales.Orders

-- create a chamsi table date ---------------------------------------

WITH numberSequence AS
(
	SELECT TOP (365*150) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) - 1 AS n
	from sys.all_objects
	cross join sys.all_columns
)
SELECT 
	DATEADD(DAY, n, '2000-01-01') AS GregorianDate,
	FORMAT(DATEADD(DAY, n, '2000-01-01'), 'yyyy','fa') AS PersianYear,
	FORMAT(dATEADD(DAY, n ,  '2000-01-01') , 'MM', 'fa') AS PersianMonth,
	FORMAT(dATEADD(DAY, n ,  '2000-01-01') , 'dd', 'fa') AS PersianDay,
	FORMAT(dATEADD(DAY, n ,  '2000-01-01') , 'yyy/MM/dd', 'fa') AS PersianDateStringSlash,
	FORMAT(dATEADD(DAY, n ,  '2000-01-01') , 'yyy-MM-dd', 'fa') AS PersianDateStringDash,
	FORMAT(dATEADD(DAY, n ,  '2000-01-01') , 'MMM', 'fa') AS PersianMonthName
	INTO Sales.PersianCalendar
	from numberSequence;
GO

SELECT * FROM sales.PersianCalendar

GO

-- create view from customer orders (Total qty per month for each customer)

create view [Sales].[CusQtyMonthlyPersian]
	with schemabinding
AS
select --dateadd(month, datediff(month,cast('19000101' as date), o.orderdate),cast('19000101' as date)) as orderMonth
		pcal.PersianDateStringDash
		,o.custid,sum(od.qty) as totalQTY
from Sales.OrderDetails od
join Sales.Orders o
on od.orderid = o.orderid
join sales.PersianCalendar pcal
on cast(pcal.GregorianDate as date) = o.orderdate
group by o.custid, pcal.PersianDateStringDash
	--dateadd(month, datediff(month,cast('19000101' as date), o.orderdate),cast('19000101' as date))
GO

select *
from Sales.ORDERS o
join sales.PersianCalendar pc
on o.orderdate = cast(pc.GregorianDate as date)

SELECT * FROM Sales.CusQtyMonthly

GO

-- Create view 'orderValues' : sum of order details

create view [Sales].[OrderValPersian]
	with schemabinding
as
select	o.orderid, o.custid, o.empid, o.orderdate, pc.PersianDateStringSlash
		,cast(sum((od.qty * od.unitprice) * (1 - od.discount)) as numeric(12,2)) as val
		,sum(od.qty) as qty
from sales.orders o
join sales.OrderDetails od
on o.orderid = od.orderid
join sales.PersianCalendar pc
on pc.GregorianDate = o.orderdate
group by o.orderid, o.custid, o.empid, o.orderdate, pc.PersianDateStringSlash


-- 239 : Ranking window functions


select format(o.orderdate , 'yyyy-MM') as month, pc.categoryname, o.custid, count(o.orderid) as totalOrders
from sales.Orders o
join sales.OrderDetails od
on o.orderid = od.orderid
join production.Products p
on od.productid = p.productid
join Production.Categories pc
on pc.categoryid = p.categoryid
group by format(o.orderdate , 'yyyy-MM')  , pc.categoryname, o.custid

-- 1. ROW_NUMBER() 2.RANK() 3.DENSE_RANK() 4. NTILE()
-- Q1 : how many of each user orders belongs to each product category

select format(o.orderdate , 'yyyy-MM') as month, pc.categoryname, o.custid,sum(od.qty * od.unitprice * (1 - od.discount)) as val
		,ROW_NUMBER() over (partition by o.custid order by pc.categoryname) as cnt
		,rank() over (partition by o.custid order by pc.categoryname) as rank_
		,dense_rank() over (partition by o.custid order by pc.categoryname) as dense_rank_
		,NTILE(3) over (partition by o.custid order by sum(od.qty * od.unitprice * (1 - od.discount))) as ntile_
from sales.Orders o
join sales.OrderDetails od
on o.orderid = od.orderid
join production.Products p
on od.productid = p.productid
join Production.Categories pc
on pc.categoryid = p.categoryid
group by format(o.orderdate , 'yyyy-MM') , pc.categoryname, o.custid
order by custid,cnt
GO

-- offset window functions
-- LAG(column_name [, offset] [, default_value]) OVER (PARTITION BY ... ORDER BY ...)
-- LEAD(column_name [, offset] [, default_value]) OVER (PARTITION BY ... ORDER BY ...)
-- Q1 : for each customer deremine the next and previous order id and  it's time

select o.orderid, o.orderdate, o.custid
		, ROW_NUMBER() OVER (PARTITION BY o.custid order by o.orderid) as orderNo
		, LAG(o.orderdate,1,NULL) OVER (PARTITION BY o.custid order by custid, o.orderid) AS previousOrder
		, DATEDIFF(DAY, LAG(o.orderdate,1,NULL) OVER (PARTITION BY o.custid order by custid, o.orderid), o.orderdate) as daysUntilThisOrder
		, LEAD(o.orderdate,1,NULL) OVER (PARTITION BY o.custid order by custid, o.orderid) AS nextOrder
		, DATEDIFF(DAY, o.orderdate, LEAD(o.orderdate,1,NULL) OVER (PARTITION BY o.custid order by custid, o.orderid)) as daysAfterThisOrder
from Sales.orders o
order by o.custid,orderNo

-- How to select ROW_NUMBER() in Where clause

select * from 
(
	select ROW_NUMBER() OVER (ORDER BY totalQTY) as row,* from Sales.CusQtyMonthly
) R
where R.row between 100 and 150

-- cume_dist() window function --


-- percent_rank() window function --


-- Window Frames --

-- Q : Calculate Running Total 'orders totalvalue' From 2 Month Ago Until Now (use window frame)

select YEAR(orderdate), MONTH(orderdate),empid,
		SUM(val) OVER (
			ORDER BY YEAR(orderdate), MONTH(orderdate)
			ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
		) as TotalEmpSales		
from Sales.OrderValues


------------------------ Grouopig Set | Cube | Rollup ------------------------

-- Report 1
select  o.empid
		, o.custid
		, cast( sum(od.qty * od.unitprice * (1- od.discount)) as numeric(12,2)) as totalOrderVal
from Sales.Orders o
join Sales.OrderDetails od
on o.orderid = od.orderid
group by o.empid
		, o.custid

-- Report 2

select o.empid
		, cast(sum(od.qty * od.unitprice * (1- od.discount)) as numeric(12,2)) as totlaOrderVal
from Sales.orders o
join sales.OrderDetails od
on o.orderid = od.orderid
group by o.empid

-- Reprt 3

select o.custid
		, cast(sum(od.qty * od.unitprice * (1- od.discount)) as numeric(12,2)) as totlaOrderVal
from Sales.orders o
join sales.OrderDetails od
on o.orderid = od.orderid
group by o.custid

-- Report 4

select cast(sum(qty * unitprice * (1- discount)) as numeric(12,2)) as totlaOrderVal
from Sales.OrderDetails

-- Q :  What if I need all four report in a one report ? 
-- A1 : use UNION ALL
-- A2 : The GROUPING SETS subclause

------------------- The GROUPING SETS subclause ---------------------

select o.empid
		, o.custid
		, cast(sum(qty * unitprice * (1- discount)) as numeric(12,2)) as totlaOrderVal
from Sales.orders o
join Sales.OrderDetails od
on o.orderid = od.orderid
group by 
	GROUPING SETS (
		(empid, custid),
		(empid),
		(custid),
		()
	)

	-- Grouping ID | CUBE --

select GROUPING_ID(empid, custid)
		, empid
		, custid
		, cast(sum(qty * unitprice * (1- discount)) as numeric(12,2)) as totalOrderVal
	from Sales.Orders O
	join Sales.OrderDetails OD
	on O.orderid = OD.orderid
	group by
		cube(empid, custid)

	-- Roll UP --

select YEAR(o.orderdate) as [year],
		MONTH(o.orderdate) as [month],
		DAY(o.orderdate) as [day],
		o.custid, 
		o.empid,
		cast(sum(od.qty * od.unitprice * (1- od.discount)) as numeric(12,2)) as totalOrderVal
	from Sales.Orders O
	join Sales.OrderDetails OD
	on O.orderid = OD.orderid
	group by 
		rollup(			
			YEAR(o.orderdate),
			MONTH(o.orderdate),
			DAY(o.orderdate),
			o.custid, 
			o.empid
		)


	-- PIVOT --

select distinct empid from Sales.Orders

select custid, [1],[2],[3],[4],[5],[6],[7],[8],[9]
from (
	select custid, empid, qty --cast(sum(od.qty * od.unitprice * (1- od.discount)) as numeric(12,2)) as total
	from Sales.orders o
	join sales.orderdetails od
	on o.orderid = od.orderid
) as ord
pivot(sum(qty) for empid in ([1],[2],[3],[4],[5],[6],[7],[8],[9])) as t

-- Chapter 8. Data modification (Data Manipulation Language (DML))
-- Inserting data :
	
	--  Insert Values (Single and MultiRow Values) : حتما نام فیزیکی ستون ها قید گردد تا از درج اشتباه داده در ستون غیر مرتبط جلوگیری شود
	
	--  Insert Select
	--  Insert EXEC
	--  Select Into 
	--  Bulk Insert

USE TSQLV4;
GO
DROP TABLE IF EXISTS dbo.Orders;
GO
CREATE TABLE dbo.Orders
(
orderid INT NOT NULL
	CONSTRAINT PK_Orders PRIMARY KEY,
orderdate DATE NOT NULL
	CONSTRAINT DFT_orderdate DEFAULT(SYSDATETIME()),
empid INT NOT NULL,
custid VARCHAR(10) NOT NULL
);

insert into dbo.Orders(orderid, empid, custid) values (1010, 10, 'A')
GO

select * from dbo.Orders
GO

--		ACID (Transaction) : Buffer Pool > Log File (ldf) > Data Pages (mdf)


INSERT INTO dbo.Orders
(orderid, orderdate, empid, custid)
VALUES
(10003, '20160213', 4, 'B'),
(10004, '20160214', 1, 'A'),
(10005, '20160213', 1, 'C'),
(10006, '20160215', 3, 'C')

GO

--		TVC (Table-value Constructor) VS #Temp Table

SELECT * 
FROM (
	VALUES
	(10003, '20160213', 4, 'B'),
	(10004, '20160214', 1, 'A'),
	(10005, '20160213', 1, 'C'),
	(10006, '20160215', 3, 'C')
) O(orderid, orderdate, empid, custid)



