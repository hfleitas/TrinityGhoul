if db_id('TrinityGhoul') is null
begin 
	create database TrinityGhoul;
end

use TrinityGhoul
go
drop table if exists SQLServerAuditInstance
go
create table SQLServerAuditInstance 
(
	 SQLServerAuditInstanceID	int	identity(1, 1)	not null
	,SQLServer					nvarchar(128)		not null
	,LG							nvarchar(128)		null
	,AuditDeployed				bit					not null	default (0)	
	constraint PK_SQLServerAuditInstance primary key clustered (SQLServerAuditInstanceID)
);

insert into dbo.SQLServerAuditInstance values 
 ('localhost',null,1)
,('Bori','Explore',1)
,('Tiger','Strike',1)
,('Hipnotic',null,0)
,('Savage',null,1)
,('Smoke','Crucible',0)
,('InHuman','Raid',1)
,('Pluribus','Raid',1)
,('Rogue','Raid',0)
,('Gifted','Crucible',1)
,('Wyld','Raid',1)
,('Scorpion',null,0)
,('Chris','Raid',1)
,('Common','Explore',1)
,('Crimson','Strike',1)
,('JonyBravo','Strike',1)
,('FinsUP','Crucible',1);	 

select isnull(LG, SQLServer) as Instance 
from SQLServerAuditInstance 
where AuditDeployed = 1 
group by isnull(LG, SQLServer)
order by Instance
go