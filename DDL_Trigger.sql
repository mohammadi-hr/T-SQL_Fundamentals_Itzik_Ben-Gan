------ DDL Triggers ------

-- Usage : 
-- 1. Database Level DDL Triggers :
	-- Audit Schema change
	-- prevent unauthorized schema change
	-- Enfore naming convensions
	-- Maintain history of stored procedure changes
-- 2.Server level DDL Triggers

create trigger ddl_db_tigger on database
for drop_table ,alter_table
as
	raiserror('you can not drop or alter table',16,1)
	rollback
go

drop table sales.orders2

disable trigger ddl_db_tigger on database

------- get database level and system level triggers info ------

select * from sys.trigger_event_types

select * from sys.trigger_events

select * from sys.triggers

select * from sys.trigger_event_types where type_name = 'DDL_DATABASE_LEVEL_EVENTS'
select * from sys.trigger_event_types where type = 10001

-- Log DDL Changes best practices --

create schema DBA 

create table DBA.DDL_Logs 
(
	LogId int identity(1,1) not null,
	EventTime datetime ,
	EventType nvarchar(200) ,
	ObjectName nvarchar(200) ,
	QueryText nvarchar(max) ,
	ExecutedBy nvarchar(200) ,
	HostName nvarchar(200) 
)

if exists(select * from sys.triggers where name = 'TRG_DDL_Logs')
	drop trigger TRG_DDL_Logs on database
go

create trigger TRG_DDL_Logs on database
for DDL_DATABASE_LEVEL_EVENTS
as
	declare @EventTime datetime
	declare @EventType nvarchar(200)
	declare @ObjectName nvarchar(200)
	declare @QueryText nvarchar(max)
	declare @ExecutedBy nvarchar(200)
	declare @HostName nvarchar(200)
	declare @Data XML
	set @data = EVENTDATA()
	select	
		@EventTime = GETDATE(),
		@EventType = @Data.value('(/EVENT_INSTANCE/EventType)[1]', 'nvarchar(200)') ,
		@ObjectName = @Data.value('(/EVENT_INSTANCE/ObjectName)[1]', 'nvarchar(200)') ,
		@QueryText = @Data.value('(/EVENT_INSTANCE/TSQLCommand)[1]', 'nvarchar(max)') , 
		@ExecutedBy = USER_NAME() ,
		@HostName = HOST_NAME()
		insert into DBA.DDL_Logs
		(
		 [EventTime]
		,[EventType]
		,[ObjectName]
		,[QueryText]
		,[ExecutedBy]
		,[HostName]
		)
		 values
		 (
		  @EventTime 
		 ,@EventType 
		 ,@ObjectName 
		 ,@QueryText 
		 ,@ExecutedBy 
		 ,@HostName
		)
go

-- Test TRG_DDL_Logs Trigger --

create table dbo.TestDDLTrigger
(
	LogId int identity(1,1),
	LogName nvarchar(200)
)

drop table dbo.TestDDLTrigger

select * from DBA.DDL_Logs
