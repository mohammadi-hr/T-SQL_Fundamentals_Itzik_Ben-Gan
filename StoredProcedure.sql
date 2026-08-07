-- how to see stored procedure query

sp_helptext '[dbo].[SP_GetPreInvoiceFinalPrice]'

select OBJECT_NAME(id), * from sys.syscomments

select OBJECT_DEFINITION(OBJECT_ID('[dbo].[SP_GetPreInvoiceFinalPrice]')) as SP_Context