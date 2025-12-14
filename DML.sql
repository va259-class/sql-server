-- DML: Data Manipulation Language
-- CREATE, ALTER, DROP, etc


-- master veritabanýnda çalýþtýrýlmalý
use master
restore database Northwind
FROM DISK = '/var/opt/mssql/data/Northwind.bak'
WITH REPLACE

--- Personelin izinlerinin tutulacaðý bir tablo

--KISA HALÝ
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
-- Primary Key : Tablodaki satýrlarý birbirinden ayýrmamýzý saðlayan esas kolon özelliði veren kýsýtlamadýr
-- Not Null    : 'Hücre insert ve update edilirken NULL deðer kabul edemez' kýsýtlamasýný uygular
-- Foreign Key : Hücrenin deðerinin esasýnda baþka bir tabloda iþaret edilen bir hücreyi referans alýnmasýný saðlayan kýsýtlamadýr.
-- Default     : Hücrenin insert anýnda boþ geçilmesi halinde alacaðý deðerin belirleyen kýsýtlamadýr.
-- Check       : Hücrenin deðerinin baþka deðerlere ve koþullara baðlý kalarak ayarlanmasý kýsýtýdýr.

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

delete from ProductPriceHistory -- tüm kayýtlarý siler
truncate table ProductPriceHistory -- tüm kayýtlarý indexleri ve identity seed dahil yok eder

update Products set UnitPrice = 20.50 where ProductID = 1

insert into ProductPriceHistory 
values (1, 20.50, getdate())

-- Alerts
-- ÖDEV

---- VIEW
--- Varolan farklý kaynaklardaki veya özelleþtirilmiþ sorgulardaki veriler
--- tablo gibi okumamýz saðlar
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
--- INDEX
--- FUNCTION
--- STORED PROCEDURE