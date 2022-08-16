use master
drop database MSSQLTip
go

create database MSSQLTip
go

alter database MSSQLTip add filegroup FG1
alter database MSSQLTip add filegroup FG2
go

use MSSQLTip
go

select groupName as FileGroupName from sysfilegroups
go

create table tbl1 (
	ID int identity(1, 1)
);
go

create table tbl2 (
	ID int identity(1, 1),
	fname varchar(20)
) on FG1;
go

sp_help tbl1
go

sp_help tbl2
go

/*testing*/
insert into tbl2 (fname) values ('Atif')
go

alter database MSSQLTip modify filegroup fg1 default
go

/*file uusgeh*/
alter database MSSQLTip
add file (name = MSSQLTip_1, filename = 'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\MSSQLTip_1.mdf')
to filegroup fg1
go

alter database MSSQLTip
add file (name = MSSQLTip_2, filename = 'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\MSSQLTip_2.mdf')
to filegroup fg2
go

use MSSQLTip
go

sp_helpfile
go

/*default file groupiig tohiruulah*/
alter database MSSQLTip modify filegroup FG1 default
go

create table table3 (
	ID tinyint
);
go

sp_help table3
go

insert into table3 values(10);
go

/*check default filegroup*/
use MSSQLTip
go

select groupname as DefaultFileGroup from sysfilegroups
where convert(bit, (status & 0x10)) = 1
go