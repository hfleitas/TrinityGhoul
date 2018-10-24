use TrinityGhoul
go
create or alter proc uspAuditSQLServerAccess (
	@login sysname = '%',
	@database sysname = '%'
	)
as

set nocount on;

select		 suser_sname(p.sid) as Login_Name
			,p.type_desc as [Login_Type]
			,r.is_disabled
			,r.name as Permission_Name
			,r.type_desc as Permission_Type
			,p.create_date
			,p.modify_date
from		master.sys.server_principals r
left join	master.sys.server_role_members m on r.principal_id = m.role_principal_id
left join	master.sys.server_principals p on p.principal_id = m.member_principal_id
where		p.name like @login
and			p.type_desc in ('SQL_LOGIN','WINDOWS_LOGIN','WINDOWS_GROUP')

	union

select		 suser_sname(prin.sid) as Login_Name
			,prin.type_desc as [Login_Type]
			,prin.is_disabled
			,perm.permission_name COLLATE SQL_Latin1_General_CP1_CI_AS as Permission_Name
			,perm.class_desc as Permission_Type
			,prin.create_date
			,prin.modify_date
from		master.sys.server_permissions perm
left join	master.sys.server_principals prin on perm.grantee_principal_id = prin.principal_id
left join	master.sys.server_principals grantor on perm.grantor_principal_id = grantor.principal_id
where		prin.name like @login
and			prin.type_desc in ('SQL_LOGIN','WINDOWS_LOGIN','WINDOWS_GROUP')
order by	Login_Name, r.name;
go