use master
go
drop table if exists employees;
go 
create table employees(
    id int identity(1,1) primary key clustered,
    name varchar(128),
    salary int
 )
 insert into employees values
 ('hiram', 34000),
 ('patricia', 100000),
 ('jake', 52000);

select * from employees

go 
drop user if exists hiram
go
create user hiram without login
go 
drop proc if exists UpdateSalary;
go
create proc UpdateSalary 
with execute as 'hiram'
as 
    update employees set salary = 999999 where name = user_name();
revert;
go
UpdateSalary;
go 
select * from employees

GO
/*cleanup*/
drop proc if exists UpdateSalary;
drop user if exists hiram
drop table if exists employees;
