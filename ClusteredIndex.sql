------ all Type of Index in SQL Server ------

/*

1. Clustered Index
2. Non Clustered Index
3. Full  Text Index
4. XML Index
5. Spatial Index
6. Column Stored Index

Heap Table : Is a table that has no clustered Index
Heap Table Pages : Managed by IAM (Index Allocated Map) Page that hold the address on heap pages

When use heap table : 

Heaps are ideal for tables that are frequently truncated and reloaded, such as staging tables that serve as a temporary landing zone for data.
Because data is inserted without enforcing a strict order, inserts into a heap are often faster than inserting into a clustered index.
This makes them excellent for large, bulk insert operations in an ETL process where the data will be quickly read, transformed, and then moved to its final destination

*/

-- get list of all indexes

select * from sys.indexes

-- list tables with the heap type indexes

select OBJECT_NAME(OBJECT_ID),* from sys.indexes where type_desc = 'HEAP'

-- check the info of heap table

select id, rows, FirstIAM from sys.sysindexes where id = OBJECT_ID('Error02002')
