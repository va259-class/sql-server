-- ÖRNEKLER
-- ÖRNEK 1
-- Bir ürün silinmeye çalýþýlýr ise o ürün sildirilmesin 
-- ve tablodaki IsDeleted kolonu true yapýlsýn (SOFT)

alter table Products
add IsDeleted bit not null default(0)

go
create trigger tr_IsDeleted on Products
instead of delete
as 
begin
	update p set IsDeleted = 1
	from Products p
	join deleted d on d.ProductID = p.ProductID
end

go
delete from Products where ProductID = 1
delete from Products where CategoryID = 1

-- ÖRNEK 2
-- Bir view aracýlýðý ile müþterilerin ay bazlý sipariþlerini getirin
go
create view CustomerOrders
as
select 
	format(o.OrderDate, 'MM/yyyy') as [Month], 
	c.CompanyName, 
	sum(od.UnitPrice * od.Quantity) as Total
from Orders o
inner join Customers c on o.CustomerID = c.CustomerID
inner join [Order Details] od on o.OrderID = od.OrderID
group by format(o.OrderDate, 'MM/yyyy'), c.CompanyName

--KULLANIM

select * from CustomerOrders 
where CompanyName = 'Frankenversand'
order by 1

-- ÖRNEK 3
-- Oluþturulan view'i silin
drop view CustomerOrders
-- ÖRNEK 4
-- Müþteri koduna göre sipariþleri bir stored procedure 
-- aracýlýðý ile getirelim
go
create procedure sp_CustomerOrders 
	@customerId nchar(5)
as begin
	select o.OrderDate from Orders o
	where o.CustomerID = @customerId
end

exec sp_CustomerOrders 'QUICKS'
-- ÖRNEK 5
-- Oluþturulan bu Stored Procedure'ü deðiþtirelim ve 
-- yýl filtresi ekleyelim
go
alter procedure sp_CustomerOrders 
	@customerId nchar(5),
	@year int = null
as begin
	select o.OrderDate from Orders o
	where o.CustomerID = @customerId and
		  (@year is null or year(o.OrderDate) = @year)
end

exec sp_CustomerOrders 'QUICKS', 1997

-- ÖRNEK 6
-- OrderTracks adýnda bir tablo oluþturalým
-- Order eklendiðinde, güncellendiðinde ve silindiðinde
-- bu tracks tablosuna ne olduðuna dair hareketler yazýlsýn
create table OrderTracks
(
	ID int identity(1,1),
	OrderID int not null,
	[Action] varchar(128) not null,
	constraint PK_OrderTracks primary key (ID),
	constraint FK_OrderID foreign key (OrderID) references Orders(OrderID) -- sonradan silinecek
)

alter table OrderTracks
add ActionDate datetime default(getdate())

select * from OrderTracks

go
alter trigger tr_OrderTrack on Orders
after insert, update, delete
as begin
	-- INSERT
	insert into OrderTracks
	select i.OrderID, 'Yeni sipariþ', getdate()
	from inserted i
	left join deleted d on i.OrderID = d.OrderID
	where d.OrderID is null

	-- DELETE
	insert into OrderTracks
	select d.OrderID, 'Sipariþ silindi', getdate()
	from deleted d
	left join inserted i on d.OrderID = i.OrderID
	where i.OrderID is null

	-- UPDATE
	insert into OrderTracks
	select d.OrderID, 
	CONCAT('Sipariþ tarihi: ', d.OrderDate, ' => ', i.OrderDate, '; Teslimat Tarihi: ', d.RequiredDate, ' => ', i.RequiredDate), 
	getdate()
	from inserted i
	inner join deleted d on i.OrderID = d.OrderID
end

--- Bir Order 
alter table OrderTracks
drop FK_OrderID

-- DENEME
insert into Orders 
(CustomerID, EmployeeID, OrderDate, RequiredDate, Freight)
values
('BIBAA', 11, '2026-04-28', '2026-04-30', 3.14)

select * from OrderTracks where OrderID = 11083 order by ActionDate asc

update Orders set OrderDate = '2026-12-22', RequiredDate = '2026-12-26' where OrderID = 11084

select * from OrderTracks
truncate table OrderTracks

-- ÖRNEK 7
-- Supplier Notes adýnda bir tabloda personel bazlý notlar alýnacak bir tablo ekleyin
-- Tabloya 5 adet kayýt ekleyin

create table [Supplier Notes]
(
	ID int primary key identity(1,1),
	SupplierID int not null,
	EmployeeID int not null,
	Comment varchar(128),

	constraint FK_SupplierID foreign key (SupplierID) references Suppliers(SupplierID),
	constraint FK_EmployeeID foreign key (EmployeeID) references Employees(EmployeeID)
)

insert into [Supplier Notes]
values (1,9, 'Çok pazarlýk yapýyor. Müdüre dikkat edilmeli')

insert into [Supplier Notes]
values (3,7, 'Firma temsilcisine ulaþýlamýyor')

select e.FirstName + ' ' + e.LastName as FullName, s.CompanyName, sn.CommentDate, sn.Comment 
from [Supplier Notes] sn
inner join Suppliers s on sn.SupplierID = s.SupplierID
inner join Employees e on sn.EmployeeID = e.EmployeeID


-- ÖRNEK 8
-- Eklenen Supplier Notes tablosuna boþ geçilemeyen bir NoteDate alaný ekleyin
alter table [Supplier Notes]
add CommentDate datetime not null default(getdate())


insert into [Supplier Notes] (SupplierID, EmployeeID, Comment)
values (21,10, 'Bu yýl iyi satýþ yapabiliriz.')
--alter table [Supplier Notes]
--drop column CommentDate

-- ÖRNEK 9
-- Oluþturulan Supplier Notes tablosunu silin
drop table [Supplier Notes]

-- ARAÞTIRMALI ÖRNEK :
-- Her yýlýn en çok satýþ yapan personelini bulmak