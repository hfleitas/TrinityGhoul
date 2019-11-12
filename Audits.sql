USE [master]
GO

DROP SERVER AUDIT [DataAudit]
GO 
DROP SERVER AUDIT [JobAudit]
GO
DROP SERVER AUDIT [LoginAudit]
GO
DROP SERVER AUDIT [SchemaAudit]
GO

/****** Object:  Audit [DataAudit]    Script Date: 11/12/2019 12:03:41 PM ******/
CREATE SERVER AUDIT [DataAudit]
TO FILE 
(	FILEPATH = N'D:\Deployments\'
	,MAXSIZE = 16 MB
	,MAX_ROLLOVER_FILES = 128
	,RESERVE_DISK_SPACE = OFF
)
WITH
(	QUEUE_DELAY = 1000
	,ON_FAILURE = CONTINUE
	,AUDIT_GUID = 'a71b6bd3-d474-48e6-a224-bee7250e533b'
)
WHERE ([server_principal_name]<>N'FLEITASARTS\sqlsvc' AND [client_ip]<>N'local machine')
ALTER SERVER AUDIT [DataAudit] WITH (STATE = ON)
GO


/****** Object:  Audit [JobAudit]    Script Date: 11/12/2019 12:04:19 PM ******/
CREATE SERVER AUDIT [JobAudit]
TO FILE 
(	FILEPATH = N'D:\Deployments\'
	,MAXSIZE = 16 MB
	,MAX_ROLLOVER_FILES = 128
	,RESERVE_DISK_SPACE = OFF
)
WITH
(	QUEUE_DELAY = 1000
	,ON_FAILURE = CONTINUE
	,AUDIT_GUID = '64886c57-300e-433b-8411-ea8e04c6facb'
)
WHERE ([server_principal_name]<>N'FLEITASARTS\sqlsvc')
ALTER SERVER AUDIT [JobAudit] WITH (STATE = ON)
GO


/****** Object:  Audit [LoginAudit]    Script Date: 11/12/2019 12:05:25 PM ******/
CREATE SERVER AUDIT [LoginAudit]
TO FILE 
(	FILEPATH = N'D:\Deployments\'
	,MAXSIZE = 16 MB
	,MAX_ROLLOVER_FILES = 128
	,RESERVE_DISK_SPACE = OFF
)
WITH
(	QUEUE_DELAY = 1000
	,ON_FAILURE = CONTINUE
	,AUDIT_GUID = '347189ce-663b-4e78-aa35-6261a4c28050'
)
WHERE ([server_principal_name]<>N'FLEITASARTS\sqlsvc')
ALTER SERVER AUDIT [LoginAudit] WITH (STATE = ON)
GO


/****** Object:  Audit [SchemaAudit]    Script Date: 11/12/2019 12:06:32 PM ******/
CREATE SERVER AUDIT [SchemaAudit]
TO FILE 
(	FILEPATH = N'D:\Deployments\'
	,MAXSIZE = 16 MB
	,MAX_ROLLOVER_FILES = 128
	,RESERVE_DISK_SPACE = OFF
)
WITH
(	QUEUE_DELAY = 1000
	,ON_FAILURE = CONTINUE
	,AUDIT_GUID = '83feeced-5f95-45e1-9384-6d7e8b0f49c5'
)
WHERE ([server_principal_name]<>N'FLEITASARTS\sqlsvc' AND [server_principal_name]<>N'NT SERVICE\SQLTELEMETRY' AND [server_principal_name]<>N'repl' AND [Action_ID]<>(538990422))
ALTER SERVER AUDIT [SchemaAudit] WITH (STATE = ON)
GO

--Database Audit Specifications
USE [FleitasArts]
GO

DROP DATABASE AUDIT SPECIFICATION [DataSpec]
GO

CREATE DATABASE AUDIT SPECIFICATION [DataSpec]
FOR SERVER AUDIT [DataAudit]
ADD (DELETE ON DATABASE::[FleitasArts] BY [dbo]),
ADD (EXECUTE ON DATABASE::[FleitasArts] BY [dbo]),
ADD (INSERT ON DATABASE::[FleitasArts] BY [dbo]),
ADD (UPDATE ON DATABASE::[FleitasArts] BY [dbo])
WITH (STATE = ON)
GO


USE [msdb]
GO

DROP DATABASE AUDIT SPECIFICATION [JobSpec]
GO

CREATE DATABASE AUDIT SPECIFICATION [JobSpec]
FOR SERVER AUDIT [JobAudit]
ADD (DELETE ON OBJECT::[dbo].[sysjobs] BY [dbo]),
ADD (INSERT ON OBJECT::[dbo].[sysjobs] BY [dbo]),
ADD (UPDATE ON OBJECT::[dbo].[sysjobs] BY [dbo]),
ADD (DELETE ON OBJECT::[dbo].[sysjobsteps] BY [dbo]),
ADD (INSERT ON OBJECT::[dbo].[sysjobsteps] BY [dbo])
WITH (STATE = ON)
GO


