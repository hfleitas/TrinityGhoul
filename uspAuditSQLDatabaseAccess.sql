use TrinityGhoul
go
create or alter proc uspAuditSQLDatabaseAccess (
	@login sysname = '%',
	@database sysname = '%'
	)
as

set nocount on;

if @database <> '%' 
begin
	declare	@DBRolePermissions table (
		 DatabaseName		nvarchar(128)
		,Principal_Name		sysname
		,Login_Name			sysname null
		,is_disabled		bit default(0)
		,DB_RoleMember		varchar(300)
		,Permission_Type	sysname
		,Create_Date		datetime
		,Modify_Date		datetime
		)

	insert into @DBRolePermissions
	exec sp_MSforeachdb '
		select		 distinct ''?'' as DatabaseName
				,users.Name as UserName
				,suser_sname(users.sid) as Login_Name
				,case 
					when u.hasdbaccess = 0
						and u.issqluser = 1
						then 1
					else 0
					end as is_disabled
				,roles.Name as Role_Member_Name
				,roles.type_desc
				,users.create_date
				,users.modify_date
	from		[?].sys.database_role_members r
	left join	[?].sys.database_principals users on r.member_principal_id = users.principal_id
	left join	[?].sys.database_principals roles on r.role_principal_id = roles.principal_id
	inner join	[?].sys.sysusers u on users.name = u.name
	';

	insert into @DBRolePermissions
	exec sp_msforeachdb '
	select		distinct ''?'' as DatabaseName
				,users.Name as UserName
				,suser_sname(users.sid) as Login_Name
				,case 
					when u.hasdbaccess = 0
						and u.issqluser = 1
						then 1
					else 0
					end as is_disabled
				,r.Permission_Name as DB_RoleMember
				,r.class_desc
				,users.create_date
				,users.modify_date
	from		[?].sys.database_permissions r
	left join	[?].sys.database_principals users on r.Grantee_principal_id = users.principal_id
	inner join	[?].sys.sysusers u on users.name = u.name
	where		r.class_desc = ''DATABASE''
	';

	select		distinct 
				 DatabaseName
				,Principal_Name
				,Login_Name
				,is_disabled
				,DB_RoleMember as Permission_Name
				,Permission_Type
				,Create_Date
				,Modify_Date
	from		@DBRolePermissions
	where		(ISNULL(Login_Name, '') like @login or ISNULL(Principal_Name, '') like @login)
	and			DatabaseName like @database
	and			Principal_Name not in ('MS_DataCollectorInternalUser', 'Public')
	and			Principal_Name not like 'MSReplPAL_%'
	order by	DatabaseName, Principal_Name, DB_RoleMember;
end
else begin
	select	'' as DatabaseName
			,'' as Principal_Name
			,'' as Login_Name
			,'' as is_disabled
			,'' as Permission_Name
			,'' as Permission_Type
			,'' as Create_Date
			,'' as Modify_Date
end
go