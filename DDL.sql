-- DDL : Data Definition Language
-- INSERT, UPDATE, DELETE

select * from Categories
insert into Categories (CategoryName)
values ('Züccaciye')

update Categories set CategoryName = 'Glassware'
where CategoryID = 9

delete from Categories
where CategoryID = 11

insert into Products (ProductName, UnitPrice, UnitsInStock, Discontinued)
values ('Teapot', 92.46, 24, 0)

delete from Products where ProductID in (79,80,81,82)
delete from Products where ProductID = 83

update Products set QuantityPerUnit = '1 piece in box', CategoryID = 9
where ProductID = 78

update Products set SupplierID = 30
where ProductID = 78

insert into Suppliers (CompanyName, ContactName, Phone, City, Country)
values ('Korkmaz', 'Rüstem Yýldýrým', '+90 312 312 0000', 'Ankara', 'Türkiye')

--- tedarikçi ekleyin
insert into Suppliers (CompanyName, ContactName, Phone, City, Country)
values ('Tefal', 'Nuran Gökçe', '+902122120000', 'Ýstanbul', 'Türkiye'),
	   ('Vestel', 'Mehmet Kaya', '+902842120000', 'Manisa', 'Türkiye'),
	   ('Özkayalar', 'Murteza Akkaya', '+903222120000', 'Mersin', 'Türkiye'),
	   ('Yeþil Göle', 'Volkan Pareci', '+903122120000', 'Ankara', 'Türkiye'),
	   ('Favorim', 'Yasemin Bakar', '+903122120000', 'Ankara', 'Türkiye')
--- kategori ekleyin
insert into Categories (CategoryName, Description)
values ('Electronics', 'Device that use electricity'),
	   ('Fruits', 'Fresh imported and local fruits'),
	   ('Vegetables', 'Fresh imported and local eatable stuffs')
--- kendi 3 ürününüzü ekleyin

insert into Products 
(ProductName, SupplierID, CategoryID, UnitPrice, UnitsInStock, QuantityPerUnit)
values
('Iron', 31, 12, 184.99, 8, '1 piece in box'),
('Vacuum Cleaner', 32, 12, 91, 8, '1 piece in box'),
('Pan Set', 31, 9, 207.45, 8, '108 piece in box'),
('Spoon', 30, 9, 9.98, 8, '12 piece in box'),
('Fork', 35, 9, 9.88, 8, '12 piece in box'),
('Pomegranate', 33, 13, 24.75, 8, '12 kg per package'),
('Orange', 33, 13, 18.30, 8, '24 kg per package'),
('Apple', 33, 13, 15.98, 8, '36 kg per package'),
('Eggplant', 34, 14, 8.12, 8, '12 kg each box'),
('Zuccini', 34, 14, 8.30, 8, '6 kg each box'),
('Coriander', 34, 14, 6.75, 8, '24 piece per package')

--- müþteri ekleyin
insert into Customers 
(CustomerID, CompanyName, ContactName, City, Country, Phone)
values
('CANPE', 'Perk Coorporation', 'Can Perk', 'Ankara', 'Türkiye', '+90 501 5000000'),
('VEKAK', 'Vektörel Akademi', 'Þemsettin Cankurtaran', 'Kayseri', 'Türkiye', '+90 502 2000000'),
('BIBAA', 'Bilgeler Okulu', 'Bilge Durdu', 'Sivas', 'Türkiye', '+90 503 3000000')
--- çalýþan ekleyin
insert into Employees (FirstName, LastName, HomePhone, City, Country, BirthDate, HireDate)
values ('Bastian', 'Fülkrük', '+49 123-4566-98', 'Berlin', 'Germany', '1973-10-25', '2006-02-19')
--- eklediðiniz müþteriye günün tarihinde bir sipariþ oluþturun
-- Çalýþan => Bastian: 10
-- Müþteri => CANPE
insert into Orders 
(CustomerID, EmployeeID, OrderDate, RequiredDate, Freight)
values
--('CANPE', 10, GETDATE(), DATEADD(DAY, 3, GETDATE()), 2.12)
('CANPE', 10, '2026-03-01', '2026-03-05', 2.12)

insert into Orders 
(CustomerID, EmployeeID, OrderDate, RequiredDate, Freight)
values
('VEKAK', 10, '2026-03-02', '2026-03-05', 2.12)
select @@identity


select top 1 * from Orders order by 1 desc
--- eklenen sipariþe eklediðiniz ürünleri dahil edin ve satýþý tamamlayýn

-- Kolon isimleri yazýlmadan insert yapýlacaksa tablonun kendi kolon düeni baz alýnýr.
insert into [Order Details]
values (11078, 95, 24.75, 2, 0),
	   (11078, 93, 9.98, 1, 0),
	   (11078, 94, 9.88, 1, 0),
	   (11078, 90, 184.99, 1, 0),
	   (11078, 4, 22, 4, 0)

update Products set UnitsInStock = UnitsInStock - 2, UnitsOnOrder = UnitsOnOrder + 2 
where ProductID = 95

select p.ProductName, od.UnitPrice * od.Quantity as Total
from Products p
inner join [Order Details] od on p.ProductID = od.ProductID
where od.OrderID = 11078

select sum(od.UnitPrice * od.Quantity) as Total
from Products p
inner join [Order Details] od on p.ProductID = od.ProductID
where od.OrderID = 11078

select FullName, Phone, [Type]
into Persons from
(
	select ContactName as FullName, Phone, 'C' as Type from Customers
	union
	select FirstName + ' ' + LastName, HomePhone, 'E' from Employees
	union
	select ContactName, Phone, 'S' from Suppliers
) as p

select * from Persons where Type = 'C'

begin transaction
	update Products set UnitPrice = UnitPrice * 1.08 where CategoryID = 1

	select ProductName, UnitPrice from Products 
	where CategoryID = 1
	order by UnitPrice
--rollback transaction
commit transaction

-- Database Standarts
-- ACID : Atomicity, Consistency, Isolation, Durability

-- Isolation Levels
-- READ UNCOMMITTED - READ COMMITTED - SERIALIZABLE - SNAPSHOT - REPEATABLE READ

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

begin tran
update Categories set CategoryName = 'Glassware'
select * from Categories


rollback tran