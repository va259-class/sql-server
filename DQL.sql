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

--Veritabanýndaki tüm kiþileri listeleme
select ContactName as FullName, Phone, 'C' as Type from Customers
union
select FirstName + ' ' + LastName, HomePhone, 'E' from Employees
union
select ContactName, Phone, 'S' from Suppliers

--Adý C ile baþlayan ürünler
select ProductName, UnitPrice, UnitsInStock from Products
where ProductName like 'C%'

select * from Customers where CustomerID = 'BERGS'

select 
	o.OrderID, 
	format(o.OrderDate, 'yyyy-MM-dd') as OrderDate, 
	e.FirstName + ' ' + e.LastName as Employee 
from Orders o
inner join Employees e on e.EmployeeID = o.EmployeeID
where CustomerID = 'BERGS'

select 
	p.ProductName, 
	od.UnitPrice, 
	od.Quantity, 
	od.Discount,
	od.UnitPrice * od.Quantity as SubTotal
from [Order Details] od
inner join Products p on od.ProductID = p.ProductID
where od.OrderID = 10524
-- Aggregate Function
select 
	sum(od.UnitPrice * od.Quantity) as Total
from [Order Details] od
inner join Products p on od.ProductID = p.ProductID
where od.OrderID = 10524

-- en yüksek fiyat
select max(UnitPrice) from Products

-- en düþük fiyat
select min(UnitPrice) from Products

-- ortalama fiyat
select avg(UnitPrice) from Products

-- depodaki toplam stok bedeli
select sum(UnitPrice * UnitsInStock) as Total
from Products

-- Firmalarýn sipariþ adetleri
select CustomerID, count(CustomerID) as OrderCount from Orders
group by CustomerID
order by OrderCount desc

-- 10'dan fazla sipariþ veren firmalar
select CustomerID, count(CustomerID) as OrderCount from Orders
group by CustomerID
having count(CustomerID) > 10 -- aggregate function için where anlamýna gelir
order by OrderCount desc
-- Firma adýna göre gruplansýn
select c.CompanyName, count(0) as OrderCount 
from Orders o
inner join Customers c on o.CustomerID = c.CustomerID
group by c.CompanyName
having count(0) > 10
order by OrderCount desc

-- Hangi tedarikçi bize kaç ürün getiriyor
select s.CompanyName, count(0) as ProductCount from Suppliers s
inner join Products p on s.SupplierID = p.SupplierID
group by s.CompanyName
order by 2 desc

-- Tedarik edilip ürünleri en çok satýlan ve gelir elde edilen firmalar
select top 5 s.CompanyName, sum(od.UnitPrice * od.Quantity) as Total 
from Suppliers s
inner join Products p on s.SupplierID = p.SupplierID
inner join [Order Details] od on p.ProductID = od.ProductID
group by s.CompanyName
order by Total desc
-- 1997 Aðustos ayýnda elde edilen toplam gelir
select sum(od.UnitPrice * od.Quantity) as Total
from Orders o
inner join [Order Details] od on o.OrderID = od.OrderID
where DATEPART(YEAR, o.OrderDate) = 1997 and
	  DATEPART(MONTH, o.OrderDate) = 8 
-- Adet bazýnda en çok satýlan 5 ürün 
select top 5 p.ProductName, sum(od.Quantity) as Quantity 
from Products p
inner join [Order Details] od on p.ProductID = od.ProductID
group by p.ProductName
order by Quantity desc
-- Tutar bazýnda en çok satýlan ürün
select top 5 p.ProductName, sum(od.UnitPrice * od.Quantity) as Total 
from Products p
inner join [Order Details] od on p.ProductID = od.ProductID
group by p.ProductName
order by Total desc
-- Ýçecek ve Tatlý kategorisindeki ürünler
--Yöntem 1:
select ProductName from Products 
where CategoryID = 1 or CategoryID = 3
-- Yöntem 2:
select ProductName from Products 
where CategoryID in (1,3)
--Yöntem 3: SUB QUERY
select ProductName from Products 
where CategoryID in
(
	select CategoryID from Categories
	where CategoryName in ('Beverages', 'Confections')
)
-- 1997 yýlýnda ortalama sipariþ tutarý
select avg(od.UnitPrice * od.Quantity) as AverageSale from Orders o
inner join [Order Details] od on o.OrderID = od.OrderID
where datepart(year, o.OrderDate) = 1997
-- 1997 yýlýnda aylýk gelir daðýlýmý
select datepart(month, o.OrderDate) Month, avg(od.UnitPrice * od.Quantity) as AverageSale 
from Orders o
inner join [Order Details] od on o.OrderID = od.OrderID
where datepart(year, o.OrderDate) = 1997
group by datepart(month, o.OrderDate)
order by 1
-- 1997 2. çeyreðinde satýþ personellerinin performansý
select e.FirstName, e.LastName, sum(od.UnitPrice * od.Quantity) as  Total 
from Orders o
inner join Employees e on o.EmployeeID = e.EmployeeID
inner join [Order Details] od on o.OrderID = od.OrderID
where datepart(year, o.OrderDate) = 1997 and datepart(month, OrderDate) in(4,5,6)
group by e.FirstName, e.LastName
order by 2 desc
-- En az sipariþ verilen ay
select top 1
	datepart(year, o.OrderDate) as [Year], 
	datepart(month, o.OrderDate) as [Month], 
	sum(od.UnitPrice * od.Quantity) as Total 
from Orders o
inner join [Order Details] od on o.OrderID = od.OrderID
group by datepart(year, o.OrderDate), datepart(month, o.OrderDate)
order by Total asc
-- 1998 Nisan ayýnda verilen sipariþleri teslim durumu
select 
	o.OrderID, 
	case 
		when ShippedDate is null then 'Teslim Edilmedi'
		when ShippedDate is not null then 'Teslim Edildi' 
	end as [Status]
from Orders o
where datepart(year, o.OrderDate) = 1998 and 
	  datepart(month, o.OrderDate) = 4
order by 2 desc
-- Sipariþ durumuna göre ürün listesi
select 
	ProductName, 
	case 
		when UnitsOnOrder > 0 then 'Sevkiyat Bekliyor'
		else '-'
	end as [Status]
from Products
order by [Status] desc
-- WHAT YOU MEASURE IS WHAT YOU GET
-- Belirli bir ürünü alan müþterilerin listesi (Örnek 1 nolu ürün)

select CompanyName, Phone from Customers
where CustomerID in
(
	-- distinct ile tekrar eden satýrlar tekilleþtirildi
	-- UYARI: DISTINCT çok kolonlu tablolarda pek tercih edilmemeli
	select distinct o.CustomerID from Orders o
	inner join [Order Details] od on o.OrderID = od.OrderID
	where od.ProductID = 2
)
order by CompanyName

-- YÖNTEM 2
select CompanyName, Phone from Customers
where CustomerID in
(
	-- distinct ile tekrar eden satýrlar tekilleþtirildi
	-- UYARI: DISTINCT çok kolonlu tablolarda pek tercih edilmemeli
	select distinct o.CustomerID from Orders o
	inner join [Order Details] od on o.OrderID = od.OrderID
	where od.ProductID = (
		select top 1 ProductID from Products
		where ProductName = 'Chang'
	)
)
order by CompanyName

-- 1997 yýlýnda indirimlerden kaynaklý kaybedilen ay bazlý gelir
select 
	datepart(month, o.OrderDate) as [Month],
	round(sum(od.UnitPrice * od.Quantity * od.Discount), 2) as Discount
from Orders o
inner join [Order Details] od on o.OrderID = od.OrderID
where datepart(year, o.OrderDate) = 1997 and od.Discount > 0
group by datepart(month, o.OrderDate)
order by [Month]

-- personelin ülkelerine göre satýþ performans
select e.Country, sum(od.UnitPrice * od.Quantity) as Total 
from [Order Details] od
inner join Orders o on od.OrderID = o.OrderID
inner join Employees e on o.EmployeeID = e.EmployeeID
group by e.Country