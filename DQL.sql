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