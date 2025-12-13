-- DML: Data Manipulation Language
-- CREATE, ALTER, DROP, etc


-- master veritabanýnda çalýþtýrýlmalý
use master
restore database Northwind
FROM DISK = '/var/opt/mssql/data/Northwind.bak'
WITH REPLACE