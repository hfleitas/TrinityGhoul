use TrinityGhoul
go
create or alter proc uspAuditSQLDatabaseObjectAccess (
	@login sysname = '%',
	@database sysname = '%'
	)
as

set nocount on;

if @database <> '%' and @login <> '%' and len(trim(@login))>0 
begin
	declare @ObjectPermissions table (
		 DatabaseName	nvarchar(128)
		,Principal_Name	sysname
		,Login_Name		sysname null
		,ObjectType		sysname
		,ObjectName		nvarchar(500)
		,PermissionName	varchar(300)
		,state_desc		varchar(300)
		,Grantor		varchar(300)
		);
	declare @CurrentDB sysname, @SQLCmd nvarchar(max);

	declare DBCursor cursor fast_forward
	for
	select	[name]
	from	master.sys.databases
	where	state = 0
	and		[name] like @database;

	open DBCursor

	fetch next
	from DBCursor
	into @CurrentDB;

	while (@@fetch_status = 0)
	begin
		set @SQLCmd = 'use [' + @CurrentDB + ']
		select		''' + @CurrentDB + ''' as DatabaseName
					,grantee.name as Principal_Name
					,suser_sname(grantee.sid) as Login_Name
					,p.class_desc as ObjectType
					,case p.class_desc
						when ''SCHEMA'' then CONVERT(sysname, (select objects.name from sys.schemas objects where objects.schema_id = p.major_id)) COLLATE Latin1_General_CI_AS
						when ''DATABASE'' then CONVERT(sysname, p.class_desc) COLLATE Latin1_General_CI_AS
						when ''OBJECT_OR_COLUMN'' then CONVERT(sysname, ISNULL((select o.name + ''.'' + objects.name from sys.columns objects where objects.[object_id] = p.major_id and objects.column_id = p.minor_id), o.name)) COLLATE Latin1_General_CI_AS
						when ''DATABASE_PRINCIPAL'' then CONVERT(sysname, (select objects.name from sys.database_principals objects where objects.principal_id = p.major_id)) COLLATE Latin1_General_CI_AS
						when ''ASSEMBLY'' then CONVERT(sysname, (select objects.name from sys.assemblies objects where objects.assembly_id = p.major_id)) COLLATE Latin1_General_CI_AS
						when ''TYPE'' then CONVERT(sysname, (select objects.name from sys.types objects where objects.user_type_id = p.major_id)) COLLATE Latin1_General_CI_AS
						when ''XML_SCHEMA_COLLECTION'' then CONVERT(sysname, (select objects.name from sys.xml_schema_collections objects where objects.xml_collection_id = p.major_id)) COLLATE Latin1_General_CI_AS
						when ''MESSAGE_TYPE'' then CONVERT(sysname, (select objects.name from sys.service_message_types objects where objects.message_type_id = p.major_id)) COLLATE Latin1_General_CI_AS
						when ''SERVICE_CONTRACT'' then CONVERT(sysname, (select objects.name from sys.service_contracts objects where objects.service_contract_id = p.major_id)) COLLATE Latin1_General_CI_AS
						when ''REMOTE_SERVICE_BINDING'' then CONVERT(sysname, (select distinct objects.name from sys.remote_service_bindings objects where objects.remote_service_binding_id = p.major_id)) COLLATE Latin1_General_CI_AS
						when ''ROUTE'' then CONVERT(sysname, (select objects.name from sys.routes objects where objects.route_id = p.major_id)) COLLATE Latin1_General_CI_AS
						when ''FULLTEXT_CATALOG'' then CONVERT(sysname, (select objects.name from sys.fulltext_catalogs objects where objects.fulltext_catalog_id = p.major_id)) COLLATE Latin1_General_CI_AS
						when ''SYMMETRIC_KEY'' then CONVERT(sysname, (select distinct objects.name from sys.symmetric_keys objects where objects.symmetric_key_id = p.major_id)) COLLATE Latin1_General_CI_AS
						when ''CERTIFICATE'' then CONVERT(sysname, (select distinct objects.name from sys.certificates objects where objects.certificate_id = p.major_id)) COLLATE Latin1_General_CI_AS
						when ''ASYMMETRIC_KEY'' then CONVERT(sysname, (select objects.name from sys.asymmetric_keys objects where objects.asymmetric_key_id = p.major_id)) COLLATE Latin1_General_CI_AS
						else CONVERT(sysname, ''n\a'') COLLATE Latin1_General_CI_AS
						end as ObjectName
					,Permission_name
					,state_desc
					,grantor.name as Grantor
		from		[' + @CurrentDB + '].sys.database_permissions p
		left join	[' + @CurrentDB + '].sys.database_principals grantee on p.grantee_principal_id = grantee.principal_id
		left join	[' + @CurrentDB + '].sys.all_objects o on p.major_id = o.[object_id]
		left join	[' + @CurrentDB + '].sys.database_principals grantor on p.grantor_principal_id = grantor.principal_id
		where		p.class_desc not in (''DATABASE'')';

		insert into @ObjectPermissions
		exec sp_executesql @SQLCmd;

		fetch next
		from DBCursor
		into @CurrentDB;
	end

	close DBCursor;
	deallocate DBCursor;

	select		distinct 
				DatabaseName
				,Principal_Name
				,Login_Name
				,ObjectName
				,ObjectType
				,PermissionName
				,state_desc as StateDescription
				,Grantor
	from		@ObjectPermissions
	where		(ISNULL(Login_Name, '') like @login or ISNULL(Principal_Name, '') like @login)
	order by	DatabaseName, Principal_Name, ObjectName, PermissionName;
end
else begin
	select	'' as DatabaseName
			,'' as Principal_Name
			,'' as Login_Name
			,'' as ObjectName
			,'' as ObjectType
			,'' as PermissionName
			,'' as StateDescription
			,'' as Grantor 
end
go