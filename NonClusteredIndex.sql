------ Type on nonClustered Index ------

/*

1. NonClusteredIndex on heap table
2. NonClusteredIndex on Clustered table

** A bookmark in nonClustered index pointing to the complete data row
at heap or clustered table

Lookup :  bookmark lookup is an operation SQL Server performs when it needs to retrieve data that isn't stored in the nonclustered index it's using

1. RID Loookup : when nonClustered index set on heap table
2. Key Lookup : when nonClustered index set on clusterrd table

*/

-- how to reduce the cost of lookup in nonClustered index on clustered table ? 
-- By using 'cover index'



-- Filtered Index --
/*

The main point of a filtered index in SQL Server is:

Index only the rows you frequently query, instead of indexing the entire table.

This can make the index smaller, faster, and cheaper to maintain.

*/

-- how could you control unique value for a field in table ?
-- By using unique nonClustered filtered index

create unique nonclustered index [NCI_Filered_NationalCode] on TSQLV6.sales.Employees 
 where nationalCode <> '' and nationalCode is not null