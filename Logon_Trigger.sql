------ Logon Triggers ------

create table DBA.Logon_Trigger 
(
	LoginUser varchar(200),
	HostName varchar(200),
	ApplicationName varchar(200),
	ClientIP varchar(100),
	SessionID int,
	LoginTime datetime,
)

DROP TRIGGER IF EXISTS LogonAuditTrigger ON ALL SERVER
GO

create trigger LogonAuditTrigger
on all server
for logon
as
begin
	
	set nocount on;


	declare @LoginName varchar(200)
	declare @HostName varchar(200)
	declare @ApplicationName varchar(200)
	declare @ClientIP varchar(100)
	declare @SessionID int
	declare @LoginTime datetime
	declare @LogonTrigger XML
	
	begin try

	set @LogonTrigger = EVENTDATA()
	set @LoginName = @LogonTrigger.value('(/EVENT_INSTANCE/LoginName)[1]','varchar(200)')
	set @HostName = HOST_NAME()
	set @ApplicationName = APP_NAME()
	set @ClientIP = @LogonTrigger.value('(/EVENT_INSTANCE/ClientHost)[1]','varchar(100)')
	set @LoginTime = @LogonTrigger.value('(/EVENT_INSTANCE/PostTime)[1]', 'datetime') 

	insert into DBA.Logon_Trigger
	(
		[LoginUser]
      ,[HostName]
      ,[ApplicationName]
      ,[ClientIP]
      ,[SessionID]
      ,[LoginTime]
	) values (
		@LoginName,
	    @HostName,
	    @ApplicationName,
	    @ClientIP,
	    @@SPID,
	    @LoginTime
	)

	end try
	begin catch
		return
	end catch

end
go

-- create a new query to test the trigger

select * from DBA.Logon_Trigger

select * from sys.dm_exec_connections

-- First, find what IP is being blocked
SELECT 
    client_net_address,
    session_id,
    login_name,
    connect_time
FROM sys.dm_exec_connections
WHERE login_name = 'KEYSUN\H.Mohammadi'
ORDER BY connect_time DESC
