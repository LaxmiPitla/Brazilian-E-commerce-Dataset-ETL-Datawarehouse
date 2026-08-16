/*
==============================================================
Create Database and Schemas
==============================================================
Script Usage: 
		This script creates Database named 'EcommerceDatawarehouse' ,if it already exists then it is
		Dropped  and recreated database 'EcommerceDatawarehouse'. Additionally, the script sets up three schemas
		within database 'bronze','silver','gold'

*/
--Create database ecommercedatawarehouse
USE master;
GO

IF EXISTS(SELECT 1 FROM sys.databases where name = 'BrazilecomDWH')
BEGIN 
	ALTER DATABASE BrazilecomDWH SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE BrazilecomDWH;
END;
GO
----creating database
CREATE DATABASE BrazilecomDWH;
GO

use BrazilecomDWH;
GO

---- create schemas

CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO

CREATE SCHEMA gold;
GO
