-- SQL : Structred Query Language
-- DQL : Data Query Language
-- SELECT
select 'Can' as FirstName, 'Perk' as LastName

select 3 + 23

select 'can ' + cast(36 as varchar)

select 'Can' as FirstName, 'Perk' as LastName, 37 as Age
union
select 'Osman', 'Ülger', 22
union
select 'Kübra', 'Cömert', 24

-- * => Tüm kolonlar
select * from Persons -- Tüm kiþiler

--where => kolon üzerinden satýr filtreleme
select * from Persons where CityId = 3 -- Kiþilerde CityId 3 olanlar
select Name from Persons

select * from Departments
select * from Cities

--Trabzon'un nüfusu
select Population from Cities 
where Id = 3

select Population from Cities 
where Name = 'Trabzon'

-- Bilgi iþlemde çalýþan kiþilerin adý ve doðum tarihi
select Name, BirthDate from Persons
where DepartmentId = 1

-- Kiþilerin nereli olduðunu gösteren tablo
select p.Name, c.Name from Persons as p
inner join Cities as c on p.CityId = c.Id

USE Northwind

select * from Employees

-- Pahalýdan ucuza ürün listesi
select ProductName, UnitPrice from Products
order by UnitPrice desc

-- Çalýþanlarýn ülkesi ve telefonu
select FirstName + ' ' + LastName as FullName, 
	   Country, 
	   HomePhone
from Employees

-- Ürünlerin kategorileri
select p.ProductName, c.CategoryName from Products as p
inner join Categories as c on p.CategoryID = c.CategoryID

-- Fiyatý 50 TL altýnda olan ürünlerin fiyatlarý 
-- ve %7 artýþ yapýlacak yeni fiyatlarý
select 
	ProductName, 
	UnitPrice as CurrentPrice, 
	CAST(ROUND(UnitPrice * 1.07, 2) as decimal(5, 2)) as NewPrice 
from Products
where UnitPrice < 50

-- UnitPrice money tipinde olduðu için round onu daha hassas deðerde gösteriyor.
-- Bu sayýyý decimal yaparsak hassasiyeti kendimiz verebiliriz

-- Almanya'daki tedarikçilerin getirdiði ürünler
select p.ProductName, s.CompanyName from Suppliers as s
inner join Products as p on s.SupplierID = p.SupplierID
where s.Country = 'Germany'
-- Ekmek türü tahýl ürünleri
select p.ProductName from Products p
inner join Categories c on p.CategoryID = c.CategoryID
where c.CategoryName = 'Grains/Cereals'
order by p.ProductName
-- Stokta kritik seviye (10 birim) altýna düþen ürünler
select ProductName, UnitsInStock from Products
where UnitsInStock <= 10
order by UnitsInStock desc
-- Depoda olan ürünlerin toplam bedeli + sipariþ edilen ürünlerden sonra ilgili ürünlerin stok durumu
select 
	ProductName, 
	UnitPrice * UnitsInStock as [Total In Stock],
	UnitPrice * UnitsOnOrder as [Total in Progress]
from Products
where UnitsOnOrder > 0
order by [Total In Stock] desc

-- Ürünlerin kategorileri ve saðlayýcýlarý
select top 10 p.ProductName, c.CategoryName, s.CompanyName
from Products p
inner join Categories c on c.CategoryID = p.CategoryID
inner join Suppliers s on s.SupplierID = p.SupplierID
order by p.ProductName asc

select p.ProductName, c.CategoryName, s.CompanyName
from Products p
inner join Categories c on c.CategoryID = p.CategoryID
inner join Suppliers s on s.SupplierID = p.SupplierID
order by p.ProductName asc
offset 70 rows
fetch next 10 rows only

-- Chai ürünün þu ana kadar satýþlarý
select o.OrderDate, od.Quantity, od.UnitPrice from Products p
inner join [Order Details] od on od.ProductID = p.ProductID
inner join Orders o on o.OrderID = od.OrderID
where p.ProductName = 'Chai'
order by o.OrderDate

select ProductName from Products order by ProductName