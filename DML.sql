-- DML: Data Manipulation Language
-- CREATE, ALTER, DROP, etc


-- master veritabanında çalıştırılmalı
use master
restore database Northwind
FROM DISK = '/var/opt/mssql/data/backups/Northwind.bak'
WITH REPLACE

--- Personelin izinlerinin tutulacağı bir tablo

--KISA HALİ
--create table EmployeeVacations
--(
--	VacationID int not null primary key identity(1,1),
--	EmployeeID int not null,
--	StartDate datetime not null,
--	EndDate datetime not null,
--	DaysInUse smallint,
--	Note varchar(64),
--	Approved bit default(0),
--	ApprovedBy int not null
--)

create table EmployeeVacations
(
	VacationID int not null identity(1,1),
	EmployeeID int not null,
	StartDate datetime not null,
	EndDate datetime not null,
	DaysInUse as DateDiff(day, StartDate, EndDate),
	Note varchar(64),
	Approved bit default(0),
	ApprovedBy int,
	constraint PK_EmployeeVacations primary key(VacationID),
	constraint FK_EmployeeVacations_EmployeeID foreign key (EmployeeID) references Employees(EmployeeID),
	constraint FK_EmployeeVacations_ApproverID foreign key (ApprovedBy) references Employees(EmployeeID),
	constraint CK_Date_Compare check (EndDate > StartDate)
)

-- CONSTRAINTS
-- Primary Key : Tablodaki satırları birbirinden ayırmamızı sağlayan esas kolon özelliği veren kısıtlamadır
-- Not Null    : 'Hücre insert ve update edilirken NULL değer kabul edemez' kısıtlamasını uygular
-- Foreign Key : Hücrenin değerinin esasında başka bir tabloda işaret edilen bir hücreyi referans alınmasını sağlayan kısıtlamadır.
-- Default     : Hücrenin insert anında boş geçilmesi halinde alacağı değerin belirleyen kısıtlamadır.
-- Check       : Hücrenin değerinin başka değerlere ve koşullara bağlı kalarak ayarlanması kısıtıdır.

insert into EmployeeVacations
(EmployeeID, StartDate, EndDate, Note)
values
(10, '2006-07-05', '2006-07-10', 'Summer vacation')

select * from EmployeeVacations

alter table EmployeeVacations
add City varchar(16) null

alter table EmployeeVacations
drop column City

--drop table EmployeeVacations

-- ProductPriceHistory
create table ProductPriceHistory
(
	HistoryID int not null identity(1,1),
	ProductID int not null,
	Price money not null,
	UpdatedDate datetime not null,
	constraint PK_ProductPriceHistory primary key (HistoryID),
	constraint FK_ProductPriceHistory_ProductID foreign key (ProductID) references Products(ProductID),
	constraint CK_Price check (Price > 0) 
)

insert into ProductPriceHistory (ProductID, Price, UpdatedDate)
select ProductID, UnitPrice, dateadd(month, -6, getdate()) from Products where Discontinued = 0

delete from ProductPriceHistory -- tüm kayıtları siler
truncate table ProductPriceHistory -- tüm kayıtları indexleri ve identity seed dahil yok eder

update Products set UnitPrice = 20.50 where ProductID = 1

insert into ProductPriceHistory 
values (1, 20.50, getdate())

-- Alerts
-- ÖDEV

---- VIEW
--- Varolan farklı kaynaklardaki veya özelleştirilmiş sorgulardaki veriler
--- tablo gibi okumamız sağlar
GO
CREATE VIEW PeopleInSystem
AS
(
	select ContactName as FullName, Phone, 'C' as Type from Customers
	union
	select FirstName + ' ' + LastName, HomePhone, 'E' from Employees
	union
	select ContactName, Phone, 'S' from Suppliers
)

select * from Persons -- TABLE
select * from PeopleInSystem -- VIEW

select * from PeopleInSystem WHERE [Type] = 'E'

go
create view CustomersForLetter
as
(
	select ContactName as FullName, PostalCode from Customers
	where PostalCode is not null
)
go
select * from CustomersForLetter where FullName like 'a%'
go
alter view CustomersForLetter
as
(
	select ContactName as FullName, PostalCode, Country from Customers
	where PostalCode is not null 
)

go
select * from CustomersForLetter where FullName like 'a%'

drop view CustomersForLetter
go
create view SpanishCustomersForLetter
as
(
	select ContactName as FullName, PostalCode from Customers
	where PostalCode is not null and Country = 'Spain'
)
go
select * from SpanishCustomersForLetter

--- TRIGGER
alter table Categories
add ModifiedAt datetime --default (getdate())

alter table Categories
add constraint df_ModifiedAt default (getdate()) for ModifiedAt

insert into Categories (CategoryName, Description)
values ('Home Stuff', 'Things that are used for house errands')

update Categories set Description = 'Kitchen and bathroom tools'
where CategoryID = 9

select * from Categories

--  TRIGGER 

-- insert, update, delete sorgularının çalıştığı anda
-- bu sorguların çalışmasına müdahale edilme işidir.

-- Bilinmesi gereken: Tabloya müdahale esnasında inserted ve deleted
-- adında iki adet trigger özelinde geçici tablonun olması
go
create trigger tr_SetModifiedAt on Categories
after update as 
begin
	update Categories set ModifiedAt = getdate() 
	from inserted
	where Categories.CategoryID = inserted.CategoryID
end 

go
create trigger tr_CancelDelete on Categories
instead of delete
as
begin 
	print 'Categoriy deletion is prevented!'
end

delete from Categories where CategoryID = 15

go
alter trigger tr_CancelDelete on Categories
instead of delete
as
begin 
	print 'Category deletion is prevented!'
end

-- ÖRNEK:
-- Order Details içinde bir satış kalemi oluşturulunca
-- Product stoğu da etkilensin
go
create trigger tr_UpdateStocks on [Order Details]
after insert
as 
begin
	update Products 
	set UnitsInStock = UnitsInStock - inserted.Quantity,
		UnitsOnOrder = UnitsOnOrder + inserted.Quantity
	from inserted
	where Products.ProductID = inserted.ProductID
end

insert into Orders 
(CustomerID, EmployeeID, OrderDate, RequiredDate, Freight)
values
('VEKAK', 11, '2026-04-01', '2026-04-03', 2.12)

select top 1 OrderID from Orders order by OrderID desc

insert into [Order Details]
values (11080, 93, 9.98, 3, 0)

insert into [Order Details]
values (11080, 94, 9.88, 2, 0)
--- INDEX

ALTER TABLE Employees
ADD EMail varchar(32) null

-- tüm email alanları atandı
ALTER TABLE Employees
ALTER COLUMN EMail varchar(32) not null

select * from Employees

insert into Employees 
(FirstName, LastName, EMail, HomePhone, City, Country, BirthDate, HireDate)
values 
('Can', 'Perk', 'can@northwind.com', '+90 555-55-55', 'Ankara', 'Türkiye', '1976-02-20', '2006-04-29')

delete from Employees where EmployeeID >= 13

go
create unique index idx_Employee_Mail
on Employees(EMail)

--Artık aynı mail adresine sahip iki kayıt olamaz!!!!!
go 
create index idx_FirstName on Employees(FirstName)

-- Burada kritik olan
select * from Employees where FirstName = 'Can'
--- FUNCTION
go
create function simdi()
returns datetime
as
begin
	return getdate()
end
go
select dbo.simdi()

go
create function youngestEmployee()
returns table
as 
return 
(
	select top 1 FirstName + ' ' + LastName as FullName, BirthDate
	from Employees order by BirthDate desc
)

select * from dbo.youngestEmployee()

go
create function getOrderDetailFromId(@id int)
returns table
as
return
(
	select p.ProductName, od.UnitPrice, od.Quantity
	from [Order Details] od
	inner join Products p on p.ProductID = od.ProductID
	where od.OrderID = @id
)

select * from getOrderDetailFromId(11080)

-- C# Equivalent
-- public DateTime simdi()
-- {
--	   return DateTime.Now;
-- }

-- var a = simdi();
--- STORED PROCEDURE
go
create procedure sp_EmployeeOrderPerformanceByYear
	@empId int,
	@year int
as
begin
	select o.OrderDate, sum(od.UnitPrice * od.Quantity) as Total
	from Orders o
	inner join [Order Details] od on o.OrderID = od.OrderID
	where o.EmployeeID = @empId and datepart(year, o.OrderDate) = @year
	group by o.OrderDate
	order by o.OrderDate
end

exec sp_EmployeeOrderPerformanceByYear 1, 1997

go
alter procedure sp_EmployeeOrderPerformanceByYear
	@empId int,
	@year int
as
begin
	declare @fullName varchar(32)
	set @fullName = (select FirstName + ' ' + LastName
					 from Employees
					 where EmployeeID = @empId)
			
	print @fullName + ' için siparişler listelendi'

	select o.OrderDate, sum(od.UnitPrice * od.Quantity) as Total
	from Orders o
	inner join [Order Details] od on o.OrderID = od.OrderID
	where o.EmployeeID = @empId and datepart(year, o.OrderDate) = @year
	group by o.OrderDate
	order by o.OrderDate
end
exec sp_EmployeeOrderPerformanceByYear 1, 1997

drop trigger tr_UpdateStocks

go
create procedure sp_createSafeOrder
	@orderId int,
	@productId int,
	@unitPrice money,
	@quantity smallint
as 
begin 
	begin transaction
		insert into [Order Details]
		values(@orderId, @productId, @unitPrice, @quantity, 0)

		update Products 
		set UnitsInStock = UnitsInStock - @quantity,
			UnitsOnOrder = UnitsOnOrder + @quantity
		where ProductID = @productId

		declare @stock int
		set @stock = (select UnitsInStock 
					  from Products 
					  where ProductID = @productId)

		if (@stock < 0) 
		begin 
			rollback transaction;
			throw 54000, 'Stok Yetersiz', 1;
		end
				

	commit transaction
end

go
exec sp_createSafeOrder 11080, 92, 207.45, 1

select * from [Order Details] where OrderID = 11080

--ÇALIŞMAZ!!
exec sp_createSafeOrder 11080, 96, 18.30, 10
-- ÇALIŞIR ❤
exec sp_createSafeOrder 11080, 96, 18.30, 8

-- ÖDEV : zaten var olan sipariş eklenmek istenirse update etsin
-- ÖDEV: ürün fiyatı vermeye gerek yok zaten güncel fiyattan satılıyor

begin transaction
	insert into Employees 
	(FirstName, LastName, EMail, HomePhone, City, Country, BirthDate, HireDate)
	values 
	('Can', 'Perk', 'can2@northwind.com', '+90 555-55-55', 'Ankara', 'Türkiye', '1976-02-20', '2006-04-29')

	select * from Employees
rollback transaction

select * from Employees