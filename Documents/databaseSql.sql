
CREATE DATABASE SumoTech;
GO
USE SumoTech;


create table Item 
(
	itemid int NOT NULL Primary Key identity(1,1),
	brand varchar(50) NOT NULL,
	name_ varchar(50) NOT NULL,
	price Float NOT NULL,
	production_year int,
	item_description varchar(2500) NOT NULL,
	item_type varchar(50),
	check (item_type IN ('Television', 'Basic Electronic', 'HouseHold Applience', 'Computer Part')),
);

/* Store Entitys*/
create table Store
(
	storeid int NOT NULL Primary Key identity(1,1),
	country varchar(50),
	city varchar(50),
	address_ varchar(150)  NOT NULL ,
	phone varchar(20) UNIQUE NOT NULL,
);

create table StoreRevenue(
	storeid int NOT NULL Foreign Key References Store(storeid),
	monthly_revenue float,
	month_start Date
);

create table Employee
(
	employeeid int NOT NULL Primary Key identity(1,1),
	Storeid int NOT NULL Foreign Key References Store(storeid),
	first_name varchar(50) NOT NULL,
	last_name varchar(50) NOT NULL,
	phone varchar(20) UNIQUE NOT NULL,
	salary int NOT NULL default 2000,
	hire_date Date default GETDATE(),
	Managerid int Foreign Key References Employee(employeeid),
);

create table StoreItem
(
	storeid int NOT NULL Foreign Key References Store(storeid) ON DELETE CASCADE,
	itemid int NOT NULL Foreign Key References Item(itemid) ON DELETE CASCADE,
	quantity int,
	Primary Key(storeid, itemid)
);
/*Store Entity End*/


create table Supplier
(	
	supplierid int NOT NULL PRIMARY KEY identity(1,1),
	name_ varchar(50) NOT NULL,
	country varchar(50) NOT NULL,
	city varchar(50) NOT NULL,
	address_ varchar(150) NOT NULL,
	phone varchar(20) UNIQUE NOT NULL,
);

/*Customer Entities*/
create table Customer
(
	customerid int NOT NULL Primary Key identity(1,1),
	first_name varchar(50) NOT NULL,
	last_name varchar(50) NOT NULL,
	phone varchar(20) UNIQUE NOT NULL,
	Email varchar(50) NOT NULL
);
create table CustomerAddress(
	addressid int NOT NULL  Primary Key Identity(1,1),
	customerid int NOT NULL Foreign Key References Customer(customerid),
	country varchar(50) NOT NULL,
	city varchar(50) NOT NULL,
	address_ varchar(150) NOT NULL,
);
create table OrderLine
(
	orderlineid int NOT NULL Primary Key identity(1,1),
	customerid int NOT NULL Foreign Key References Customer(customerid),
	order_price float default 0,
	destination_address varchar(150),
	order_date Date default getDate()
);

create table OrderedItem
(
	orderlineid int NOT NULL Foreign Key References OrderLine(orderlineid),
	itemid int NOT NULL Foreign Key References Item(itemid) ON DELETE CASCADE,
	storeid int NOT NULL Foreign Key References Store(storeid),
	quantity int NOT NULL,
	Primary Key(orderlineid, itemid)
);
/*Customer Entities End*/

create table Factory
(
	factoryid int NOT NULL PRIMARY KEY identity(1,1),
	country varchar(50),
	city varchar(50),
	address_ varchar(150) NOT NULL,
	productionCapacity int NOT NULL,
);

/*Items*/
create table HouseholdApplience
(
	itemid int NOT NULL Foreign KEY REFERENCES Item(itemid) ON DELETE CASCADE,
	factoryid int NOT NULL FOREIGN KEY REFERENCES Factory(factoryid),
	applienceType varchar(30) NOT NULL,
	check( applienceType IN ('Fridge' , 'Owen', 'Washer', 'Dish Washer')),
	applienceProductivity varchar(4) NOT NULL,
	check(applienceProductivity IN ('A++', 'A+', 'A' , 'B', 'C', 'D')),
	PRIMARY KEY(itemid)
);

create table SuppliedItem
(
	itemid int NOT NULL FOREIGN KEY REFERENCES Item(itemid) ON DELETE CASCADE,
	supplierid int NOT NULL FOREIGN KEY REFERENCES Supplier(supplierid),
	Primary Key (itemid)
);

create table Television
(
	televisionid int NOT NULL FOREIGN KEY REFERENCES SuppliedItem(itemid) ON DELETE CASCADE,
	screenSize float NOT NULL , 
	screenResolution char(9) NOT NULL,
	isSmart char(1) NOT NULL,
	check (isSmart IN ('n','y')),
	PRIMARY KEY(televisionid)
);

create table BasicElectronic
(
	electronicid int NOT NULL FOREIGN KEY REFERENCES SuppliedItem(itemid) ON DELETE CASCADE,
	electronicType varchar(20) NOT NULL,
	check (electronicType IN ('Coffe Machine','HairDryer','Kettle')),
	PRIMARY KEY(electronicid)
);

create table ComputerPart
(
	computerPartid int NOT NULL FOREIGN KEY REFERENCES SuppliedItem(itemid) ON DELETE CASCADE,
	partType varchar(10) NOT NULL,
	check (partType IN ('CPU','GPU', 'RAM', 'Harddisk')),
	PRIMARY KEY(computerPartid)
);

create table GPU
(
	gpuid int NOT NULL FOREIGN KEY REFERENCES ComputerPart(computerPartid) ON DELETE CASCADE,
	chipset varchar(20) NOT NULL,
	memory int NOT NULL,
	check (chipset IN ('AMD','Intel')),
	check (memory IN (1,2,4,6,8)),
	PRIMARY KEY(gpuid)
);

create table CPU
(
	cpuid int NOT NULL FOREIGN KEY REFERENCES ComputerPart(computerPartid) ON DELETE CASCADE,
	cpuModel varchar(20) NOT NULL,
	cpuCoreCount char(2) NOT NULL,
	check (cpuCoreCount IN (2,4,8)),
	PRIMARY KEY(cpuid)
);

create table RAM
(
	ramid int NOT NULL FOREIGN KEY REFERENCES ComputerPart(computerPartid) ON DELETE CASCADE,
	memory int NOT NULL,
	check (memory IN (4, 8, 16, 32, 64)),
	speed int NOT NULL,
	PRIMARY KEY(ramid)
);

create table Harddisk
(
	hddid int NOT NULL FOREIGN KEY REFERENCES ComputerPart(computerPartid) ON DELETE CASCADE,
	memory int NOT NULL,
	check (memory IN (256, 512, 1024, 2048)),
	PRIMARY KEY(hddid)
);

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TRIGGER OrderLinePrice -- increase orderline price
ON OrderedItem
AFTER INSERT
AS
BEGIN
	declare @orderlineid int;
	declare @orderprice float;
	set @orderlineid = (select orderlineid FROM inserted);
	set @orderprice = (select price FROM Item WHERE itemid = (select itemid FROM inserted)) 
						* (select quantity FROM inserted);
	UPDATE OrderLine
	SET order_price = (select order_price From OrderLine Where orderlineid = @orderlineid) + @orderprice
	WHERE orderlineid = @orderlineid;
END

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TRIGGER ManagerDeletion
ON Employee
INSTEAD OF DELETE
AS
BEGIN
	declare @deletedemployeeid int;
	set @deletedemployeeid = (select employeeid From deleted);
	UPDATE Employee
		SET Managerid = NULL
		WHERE Managerid = @deletedemployeeid;

	DELETE FROM Employee where employeeid = @deletedemployeeid;
	
END

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TRIGGER OrderingItemNew -- decrease store item quantity
ON OrderedItem
INSTEAD OF INSERT
AS
BEGIN
	declare @ordereditemquantityn int; declare @storeidn int; declare @itemquantityn int; declare @itemidn int; declare @orderlineidn int;
	set @orderlineidn = (SELECT orderlineid From inserted);
	set @storeidn = (SELECT storeid FROM inserted);
	set @itemidn = (SELECT itemid FROM inserted);
	set @ordereditemquantityn = (SELECT quantity FROM inserted);

	if(@orderlineidn = (SELECT orderlineid FROM OrderedItem WHERE orderlineid = @orderlineidn AND itemid = @itemidn AND storeid = @storeidn))
	BEGIN
		print 'there are already same product'
		set @itemquantityn = (Select quantity FROM OrderedItem WHERE orderlineid = @orderlineidn AND itemid = @itemidn AND storeid = @storeidn);
	
		UPDATE OrderedItem
		SET quantity = (@itemquantityn + @ordereditemquantityn) WHERE (storeid = @storeidn AND itemid = @itemidn AND orderlineid = @orderlineidn);
	END
	ELSE
	BEGIN
		print 'there is no same product'
		INSERT INTO OrderedItem (orderlineid, itemid, storeid,quantity) VALUES (@orderlineidn,@itemidn,@storeidn, @ordereditemquantityn);
	END
END

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TRIGGER OrderingItem -- decrease store item quantity
ON OrderedItem
AFTER INSERT
AS
BEGIN
	declare @orderquantityx int;
	declare @storeitemquantityx int;
	declare @storeidx int;
	declare @itemidx int;
	set @itemidx = (select itemid FROM inserted);
	set @storeidx = (select storeid FROM inserted);
	set @storeitemquantityx = (select quantity FROM StoreItem WHERE storeid = @storeidx AND itemid = @itemidx);
	set @orderquantityx = (select quantity FROM inserted);
	UPDATE StoreItem
	SET quantity = (@storeitemquantityx - @orderquantityx) WHERE storeid = @storeidx AND itemid = @itemidx;
END


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TRIGGER InsertStoreItem -- decrease store item quantity
ON StoreItem
INSTEAD OF INSERT
AS
BEGIN
	declare @storeitemquantity int; declare @storeid int; declare @itemquantity int; declare @itemid int;
	
	set @storeid = (SELECT storeid FROM inserted);
	set @itemid = (SELECT itemid FROM inserted);
	set @itemquantity = (SELECT quantity FROM inserted);

	if(@itemid = (SELECT itemid FROM StoreItem WHERE itemid = @itemid AND storeid = @storeid) AND (@storeid = (SELECT storeid FROM StoreItem WHERE itemid = @itemid AND storeid = @storeid)))
	BEGIN
		print 'there are already same product'
		set @storeitemquantity = (SELECT quantity FROM StoreItem WHERE (storeid = @storeid AND itemid = @itemid));
	
		UPDATE StoreItem
		SET quantity = (@storeitemquantity + @itemquantity) WHERE (storeid = @storeid AND itemid = @itemid);
	END
	ELSE
	BEGIN
		print 'there is no same product'
		INSERT INTO StoreItem (storeid, itemid,quantity) VALUES (@storeid,@itemid, @itemquantity);
	END
END


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*Stored Procedures*/

CREATE PROCEDURE StoreEmployees --To Get Employees of a Store
	@storeid int
AS
SELECT * FROM Employee AS e
WHERE e.Storeid = @storeid

GO

CREATE PROCEDURE StoreItems --To Get Items of a store
	@storeid int
AS
SELECT * FROM Item WHERE itemid IN(
	SELECT itemid 
	FROM StoreItem 
	WHERE storeid = @storeid
)

GO

CREATE PROCEDURE CustomerOrders --To Get Orders of a Customer
	@customerid int
AS
SELECT * FROM OrderLine AS o
WHERE o.customerid = @customerid

GO

CREATE PROCEDURE CustomerItems --To Get Items of a Customer
	@customerid int
AS
SELECT * FROM OrderedItem WHERE orderlineid IN(
	SELECT orderlineid
	FROM OrderLine AS o
	WHERE o.customerid = @customerid
)

GO

CREATE PROCEDURE SuppliedItems	--to get Items of a Supplier
	@supplierid int
AS
SELECT * FROM Item WHERE itemid IN(
	SELECT itemid
	FROM SuppliedItem AS s
	WHERE s.supplierid = @supplierid
)

GO

CREATE PROCEDURE FactoryItems	--to get Items of a Factory
	@factoryid int
AS
SELECT * FROM Item WHERE itemid IN(
	SELECT itemid
	FROM HouseholdAppliences AS h
	WHERE h.factoryid = @factoryid
)

GO

CREATE PROCEDURE RAMItems	--to get RAMs
AS
BEGIN
SELECT * FROM Item WHERE itemid IN(
	Select itemid
	FROM RAM
)
END

GO

CREATE PROCEDURE CPUItems	--to get CPU items
AS
BEGIN
SELECT * FROM Item WHERE itemid IN(
	Select itemid
	FROM CPU
)
END

GO

CREATE PROCEDURE GPUItems	--to get GPU items
AS
BEGIN
SELECT * FROM Item WHERE itemid IN(
	Select itemid
	FROM GPU
)
END

GO

CREATE PROCEDURE HouseHoldItems	--to get House Hold Appliences Items
AS
BEGIN
SELECT * FROM Item WHERE itemid IN(
	Select itemid
	FROM HouseholdAppliences
)
END

GO

CREATE PROCEDURE HarddiskItems	--to get Hard Disk Items
AS
BEGIN
SELECT * FROM Item WHERE itemid IN(
	Select itemid
	FROM Harddisk
)
END

GO

CREATE PROCEDURE DeleteLastAdded
AS
BEGIN
declare @itemid  int;
set @itemid = @@IDENTITY;
print @itemid;
DELETE FROM Item WHERE itemid = @itemid;
END

GO

CREATE PROCEDURE InsertTelevision	--insert a new television item
	@brand varchar(50),
	@name varchar(50),
	@price float,
	@item_description varchar(2500),
	@production_year int,
	@supplierid int,
	@screensize float,
	@screenResolution varchar(9),
	@isSmart char(1)
AS
BEGIN
declare @itemid int;
if(@supplierid = (SELECT supplierid FROM Supplier WHERE supplierid = @supplierid))
BEGIN
	insert into Item ( brand, name_, price,production_year,item_description, item_type)
	values (@brand, @name, @price, @production_year, @item_description, 'Television');
	set @itemid = @@IDENTITY;
	insert into SuppliedItem (itemid,supplierid)
	values (@itemid, @supplierid);
	set @itemid = (Select MAX(itemid) FROM SuppliedItem);
	insert into Television (televisionid, screenSize, screenResolution,isSmart)
	values (@itemid, @screensize,@screenResolution,@isSmart);
END
END

GO

CREATE PROCEDURE InsertBasicElectronic	--insert a new basic electronic
	@brand varchar(50),
	@name varchar(50),
	@price float,
	@item_description varchar(2500),
	@production_year int,
	@supplierid int,
	@electronicType varchar(20)
AS
BEGIN
declare @itemid int;
if(@supplierid = (SELECT supplierid FROM Supplier WHERE supplierid = @supplierid))
BEGIN
	insert into Item (brand, name_, price, production_year,item_description,item_type)
	values (@brand, @name, @price, @production_year, @item_description, 'Basic Electronic');
	set @itemid = @@IDENTITY;
	insert into SuppliedItem (itemid,supplierid)
	values (@itemid, @supplierid);
	set @itemid = (Select MAX(itemid) FROM SuppliedItem);
	insert into BasicElectronic (electronicid,electronicType)
	values (@itemid, @electronicType);
END
END

GO

CREATE PROCEDURE InsertHouseHold	--insert a new house hold applience
	@brand varchar(50),
	@name varchar(50),
	@price float,
	@item_description varchar(2500),
	@production_year int,
	@factoryid int,
	@applienceType varchar(30),
	@applienceProductivity varchar(4)
AS
BEGIN
declare @itemid int;
if(@factoryid = (SELECT factoryid FROM Factory WHERE factoryid = @factoryid))
BEGIN
	insert into Item (brand, name_, price, production_year,item_description,item_type)
	values (@brand, @name ,@price, @production_year, @item_description, 'HouseHold Applience');
	set @itemid = @@IDENTITY;
	insert into HouseholdApplience (itemid, factoryid, applienceType,applienceProductivity)
	values (@itemid, @factoryid, @applienceType, @applienceProductivity);
END
END
GO

CREATE PROCEDURE InsertRAM	--insert a new ram
	@brand varchar(50),
	@name varchar(50),
	@price float,
	@item_description varchar(2500),
	@production_year int,
	@supplierid int,
	@memory int,
	@speed int
AS
BEGIN
declare @itemid int;
if(@supplierid = (SELECT supplierid FROM Supplier WHERE supplierid = @supplierid))
BEGIN
	insert into Item (brand, name_, price, production_year,item_description,item_type)
	values (@brand, @name, @price, @production_year, @item_description, 'Computer Part');
	set @itemid = @@IDENTITY;
	insert into SuppliedItem (itemid,supplierid)
	values (@itemid, @supplierid);
	insert into ComputerPart (computerPartid,partType)
	values (@itemid, 'RAM');
	insert into RAM (ramid, memory, speed)
	values (@itemid, @memory, @speed);
END
END
GO

CREATE PROCEDURE InsertCPU	--insert a new cpu
	@brand varchar(50),
	@name varchar(50),
	@price float,
	@item_description varchar(2500),
	@production_year int,
	@supplierid int,
	@cpuModel varchar,
	@cpuCoreCount char(2)
AS
BEGIN
declare @itemid int;
if(@supplierid = (SELECT supplierid FROM Supplier WHERE supplierid = @supplierid))
BEGIN
	insert into Item (brand, name_, price, production_year,item_description,item_type)
	values (@brand, @name, @price, @production_year, @item_description, 'Computer Part');
	set @itemid = @@IDENTITY;
	insert into SuppliedItem (itemid,supplierid)
	values (@itemid, @supplierid);
	insert into ComputerPart (computerPartid,partType)
	values (@itemid, 'CPU');
	insert into CPU(cpuid, cpuModel,cpuCoreCount)
	values (@itemid, @cpuModel, @cpuCoreCount);
END
END
GO

CREATE PROCEDURE InsertGPU		--insert a new gpu
	@brand varchar(50),
	@name varchar(50),
	@price float,	
	@item_description varchar(2500),
	@production_year int,
	@supplierid int,
	@chipset varchar(20),
	@memory int
AS
BEGIN
declare @itemid int;
if(@supplierid = (SELECT supplierid FROM Supplier WHERE supplierid = @supplierid))
BEGIN
	insert into Item (brand, name_, price, production_year,item_description,item_type)
	values (@brand, @name, @price, @production_year, @item_description, 'Computer Part');
	set @itemid = @@IDENTITY;
	insert into SuppliedItem (itemid,supplierid)
	values (@itemid, @supplierid);
	insert into ComputerPart (computerPartid,partType)
	values (@itemid, 'GPU');
	insert into GPU (gpuid, chipset,memory)
	values (@itemid, @chipset, @memory);
END
END
GO

CREATE PROCEDURE InsertHarddisk		--insert a new Harddisk
	@brand varchar(50),
	@name varchar(50),
	@price float,
	@item_description varchar(2500),
	@production_year int,
	@supplierid int,
	@memory int
AS
BEGIN
declare @itemid int;
if(@supplierid = (SELECT supplierid FROM Supplier WHERE supplierid = @supplierid))
BEGIN
	insert into Item (brand, name_, price, production_year,item_description,item_type)
	values (@brand, @name, @price, @production_year, @item_description, 'Computer Part');
	set @itemid = @@IDENTITY;
	insert into SuppliedItem (itemid,supplierid)
	values (@itemid, @supplierid);
	insert into ComputerPart (computerPartid,partType)
	values (@itemid, 'Harddisk');
	insert into Harddisk(hddid ,memory)
	values (@itemid, @memory);
END
END

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

USE SumoTech;
GO
/*Customers*/
insert into Customer (first_name, last_name, Phone, Email)
values ('Suleyman Barıs', 'ESER', '05457226673', 'suleymanbariseser@gmail.com');
insert into Customer (first_name, last_name, Phone, Email)
values ('Jaylon', 'Warren', '+90-545-5521-1730', 'tby.mdk.18@xzcsrv75.life');
insert into Customer (first_name, last_name, Phone, Email)
values ('Eva', 'Mckee', '+90-505-5597-7790', 'hhamza.xben.31u@guowaishipin.xyz');
insert into Customer (first_name, last_name, Phone, Email)
values ('Kristin' ,'Newton', '+90-555-5534-7624', 'saomer3@redrabbit1.tk');
insert into Customer (first_name, last_name, Phone, Email)
values ('Connor', 'Briggs', '+90-545-5525-0766', 'dmelad.more.9u@greenhomelove.com');
insert into Customer (first_name, last_name, Phone, Email)
values ('Nathaly', 'Hardy', '+90-505-5520-9359', 'oanish.kumarp225c@brrwd.com');
insert into Customer (first_name, last_name, Phone, Email)
values ('Cael', 'Daugherty', '+90-505-5560-5028', 'nhasan_1445c@нфабрика.рф');
insert into Customer (first_name, last_name, Phone, Email)
values ('Aidyn', 'Williams', '+90-505-5592-1026', 'jrawan.ali@predilectionaz.com');
insert into Customer (first_name, last_name, Phone, Email)
values ('Colton', 'Dillon', '+90-555-5596-1306', 'cfore@whizdom.biz');
insert into Customer (first_name, last_name, Phone, Email)
values ('Sidney', 'Bright', '+90-555-5590-6589', 'isa.gui10@bosceme.xyz');

GO
/*Customer Address*/
insert into CustomerAddress (customerid,country,city,address_)
values (1,'Turkey', 'Istanbul', 'Kadıkoy - Istanbul');
insert into CustomerAddress (customerid,country,city,address_)
values (2,'Turkey', 'Istanbul', 'Besiktas - Istanbul');
insert into CustomerAddress (customerid,country,city,address_)
values (3,'Turkey', 'Istanbul', 'Ortakoy - Istanbul');
insert into CustomerAddress (customerid,country,city,address_)
values (4,'Turkey', 'Istanbul', 'Maltepe - Istanbul');
insert into CustomerAddress (customerid,country,city,address_)
values (5,'Turkey', 'Istanbul', 'Fatih - Istanbul');
insert into CustomerAddress (customerid,country,city,address_)
values (6,'Turkey', 'Istanbul', 'Sefakoy - Istanbul');
insert into CustomerAddress (customerid,country,city,address_)
values (7,'Turkey', 'Istanbul', 'Pendik - Istanbul');
insert into CustomerAddress (customerid,country,city,address_)
values (8,'Turkey', 'Istanbul', 'Kartal - Istanbul');
insert into CustomerAddress (customerid,country,city,address_)
values (9,'Turkey', 'Istanbul', 'Cankaya - Ankara');
insert into CustomerAddress (customerid,country,city,address_)
values (10,'Turkey', 'Istanbul', 'Didim - Aydın');

GO

/*Supplier*/
insert into Supplier (name_, country, city, address_, phone)
values ('MOBİCOM', 'Turkey', 'Istanbul', 'Istanbul - Turkey', '4168798415');
insert into Supplier (name_, country, city, address_, phone)
values ('Tİ MESH', 'Turkey', 'Istanbul', 'Istanbul - Turkey', '879874982912');
insert into Supplier (name_, country, city, address_, phone)
values ('HEPSİ TEKNO', 'Turkey', 'Istanbul', 'Istanbul - Turkey', '4716546198');
GO
/*Factory*/
insert into Factory (country, city, address_, productionCapacity)
values ('Turkey', 'Istanbul', 'Istanbul - Turkey', 1200);
insert into Factory (country, city, address_, productionCapacity)
values ('Turkey', 'Izmir', 'Izmir - Turkey', 800);
GO
/*Store*/
insert into Store (country, city, address_, phone)
values ('Turkey', 'Istanbul', 'Istanbul - Turkey', '41847817897289');
insert into Store (country, city, address_, phone)
values ('Turkey', 'Istanbul', 'Istanbul - Turkey', '746871798797');
insert into Store (country, city, address_, phone)
values ('Turkey', 'Istanbul', 'Istanbul - Turkey', '7411917289717');
GO
/*Employee*/
insert into Employee (Storeid, first_name, last_name, phone, salary, hire_date, Managerid)
values (1,'Eden', 'Welch', '+90-505-5552-5994',2000, GETDATE(), null);
insert into Employee (Storeid, first_name, last_name, phone, salary, hire_date, Managerid)
values (1,'Rodney', 'Pittman', '+90-505-5528-4894',2000, GETDATE(), 1);
insert into Employee (Storeid, first_name, last_name, phone, salary, hire_date, Managerid)
values (1,'Wendy', 'Jennings', '+90-505-5549-4811',2000, GETDATE(), 1);
insert into Employee (Storeid, first_name, last_name, phone, salary, hire_date, Managerid)
values (2,'Case','Robbins', '+90-535-5520-0797',2000, GETDATE(), null);
insert into Employee (Storeid, first_name, last_name, phone, salary, hire_date, Managerid)
values (2,'Denisse', 'Cordova', '+90-505-5531-8187',2000, GETDATE(), 4);
insert into Employee (Storeid, first_name, last_name, phone, salary, hire_date, Managerid)
values (2,'Mina', 'Bass', '+90-505-5530-1183',2000, GETDATE(), 4);
insert into Employee (Storeid, first_name, last_name, phone, salary, hire_date, Managerid)
values (3,'Baron', 'Bonilla', '+90-505-5586-5075',2000, GETDATE(), null);
insert into Employee (Storeid, first_name, last_name, phone, salary, hire_date, Managerid)
values (3,'Molly', 'Mayer', '+90-555-5510-5657',2000, GETDATE(), 7);
insert into Employee (Storeid, first_name, last_name, phone, salary, hire_date, Managerid)
values (3,'Braxton', 'Bartlett', '+90-535-5593-6041',2000, GETDATE(), 7);
GO
/*Insert Television*/
exec InsertTelevision 'LG','55UM7100 55" 139 Ekran Uydu Alıcılı 4K Ultra HD Smart LED TV 55UM7100PLB',3877,'Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta.',2018,1,80,'1920*1080','y';
exec InsertTelevision 'Samsung','40N5300 40" 102 Ekran Uydu Alıcılı Full HD Smart LED TV', 2199,'Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta.', 2018,2,60,'1920*1080','y';
exec InsertTelevision 'Samsung','49RU7100 49" Uydu Alıcılı 4K Ultra HD Smart LED TV',3569,'Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta.  Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta.   Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta.   Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. ', 2018,3,70,'1920*1080','y';
exec InsertTelevision 'Sunny','Sheen SH49DLK08 49" Full HD LED TV',1525,'Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta.  Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta.   Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta.   Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta.   Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta.', 2018,3,120,'1920*1080','y';
/*Insert Basic Electronic*/
exec InsertBasicElectronic 'Philips','Philips FC9751/07 PowerPro Max Torbasız Elektrikli Süpürge 0-FC975107',1179,'Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta.  Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta.   Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta.   Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta.   Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. ',2017,1,'Coffe Machine';
exec InsertBasicElectronic 'Philips','GC4909/60 3000W Azur Buharlı Ütü 500-016-506-GC4909/60',580.50,'Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta.  Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta.   Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta.   Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta.  Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta.   Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. ',2017,1,'HairDryer';
exec InsertBasicElectronic 'VESTEL','Enerjik Kms6000 Katı Meyve Sıkacağı KMS6000',234,'Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta.  Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta.   Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta.   Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta.   Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta.   Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. ',2017,1,'Kettle';
exec InsertBasicElectronic 'FANTOM','Fantom P 1200 Pratic Kırmızı Kuru Süpürge 2015ST000864',133.90,'Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta.  Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta.   Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta.   Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta.   Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. ',2017,2,'Coffe Machine';
exec InsertBasicElectronic 'Fakir','Fakir Ranger 890 W Toz Torbasız 4AAAA Elektrikli Süpürge 2018ST00000172',522.90,'Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta.  Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta.   Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta.   Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. ',2017,2,'HairDryer';
exec InsertBasicElectronic 'Fakir','Hercules Vücut Analiz Baskülü Hercules HERCULES',98 ,'Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta.  Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta.   Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta.   Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta.   Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. ',2017,3,'Kettle';
exec InsertBasicElectronic 'Arzum','AR1032 Shaken Take Kişisel Blender - Siyah',221.65,'Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta.  Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta.   Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta.   Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta.   Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta.',2017,3,'Coffe Machine';
/*Insert RAM*/
exec InsertRAM 'Crucial','For Mac 8gb 2666mhz Ddr4 Ct8g4s266m RAMN48192CRU0025',309.53,'Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta.  Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta.   Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta.   Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta.   Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta.   Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. ',2016,1,8,2666;
exec InsertRAM 'Kingston','HyperX Fury 8GB DDR4 3200MHz CL16 HX432C16FB3/8',289,'Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta.  Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta.   Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta.   Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta.   Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta.   Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta.   Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. ',2017,2,16,3200;
exec InsertRAM 'Everest','Rm-44 4 Gb 1600Mhz Ddr3 Cl11 16 Çipli Ram OEM RAM DDR3 E 4-1600',98.24,'Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta.  Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta.   Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta.   Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta.   Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta.   Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. ',2018,3,4,1600;
/*Insert CPU*/
exec InsertCPU 'Amd','Ryzen 5 1600 Soket AM4 3.2GHz-3.6GHz 16MB 6/12 65W 14nm İşlemci 38025',599,'Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta.  Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta.  Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta.  Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta.  Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. ',2016,1,'AMD','8';
exec InsertCPU 'Intel','9900KF i9 3.60GHz LGA1151 16MB Gaming İşlemci BX80684I99900KF',3579,'Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta.  Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta.  Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta.  Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta.  Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. ',2016,2,'Intel','8';
exec InsertCPU 'Intel','Intel Pentium Gold G5400 3.7GHz 4Mb Cache 2 Çekirdek Soket 1151 İşlemci 977176',382.72,'Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta.  Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta.  Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta.  Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta.  Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta.  Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. ',2016,3,'Intel','4';
/*Insert GPU*/
exec InsertGPU 'MSI','GeForce RTX 2070 Super GAMING X TRIO 8GB 256 Bit Ekran Kartı 210192504',4600,'Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta.  Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta.  Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta.  Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta.  Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta.  Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta.  Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. ',2018,1,'Intel',8;
exec InsertGPU 'POWERCOLOR','POWERCOLOR RX580 AXRX 580 8GB D5-3DHDV2OC AMD X580 DDR5 256bit 16X EKRAN KARTI T03063',4600,'Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta.  Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta.  Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta.  Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta.  Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta.  Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta.  Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. ',2015,3,'AMD',2;
/*Insert Harddisk*/
exec InsertHarddisk 'Frisby','Frisby FHC-2525B 2.5” SATA USB 2.0 Alüminyum Harici HDD Kutusu USB HDD FRISBY FHC-2525B',57,'Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta.  Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta.  Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta.  Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta.  Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta.  Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. ',2017,1,1024;
exec InsertHarddisk 'Concord','C-855 2,5 Harici Hdd Kutusu Harddisk 3,0 Usb C-855 Hdd Kutusu',45.90,'Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta.  Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta.  Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta.  Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta.  Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta.  Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta.  Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. ',2016,1,2048;
exec InsertHarddisk 'Seagate','2TB SEAGATE 3.5" 5900RPM 64MB SATA3 ST2000VM003 HDD pc.hdd.pc.sata.0329',389,'Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta.  Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta.  Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta.  Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta.  Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta.  Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. ',2018,2,2048;
exec InsertHarddisk 'Samsung','M3 320 2.5 Inc Usb 3.0 Harici Taşınabilir Hdd STHX-W320UAB/G',143,'Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta.  Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta.  Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta.  Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta.  Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta.  Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. ', 2019,3,512;
exec InsertHarddisk 'Seagate','Pipeline 500 Gb Sata3 3,5'' Pc Bilgisayar Hdd Harddisk - Refurbished 1746486',159,'Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta.  Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta.  Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta.  Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta.  Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta.  Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta.  Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. ', 2015,3,512;
/*Insert House Hold Applience*/
exec InsertHouseHold 'Altus','AL 413 C A+ 3 Programlı Bulaşık Makinesi',1199,'Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta.  Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta.  Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta.  Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta.  Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta.  Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta.  Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta.  Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. ',2018,1,'Fridge','A+';
exec InsertHouseHold 'Bosch','Bosch GSN36VI30N A++ 255 lt 7 Çekmeceli No-Frost Derin Dondurucu',4549,'Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta.  Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta.  Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta.  Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta.  Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta.  Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta.  Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta.  Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. ',2018,2,'Owen','A++';
exec InsertHouseHold 'Simfer','Simfer 3420 Midi Fırın 34 Litre 5206',228.50,'Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta.  Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta.  Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta.  Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta.  Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta.  Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta.  Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta.  Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. ',2018,2,'Washer','C';
exec InsertHouseHold 'Eratool','Erato Siyah Dört Gözlü Set Üstü Ocak Lpg Tüp Uyumlu EO 105',450,'Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta.  Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta.  Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta.  Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta.  Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta.  Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta.  Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. ',2018,1,'Dish Washer','A';
exec InsertHouseHold 'VESTEL','SP 120 Soğuk Su Sebili SU SEBİLİ',338,'Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta.  Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta.  Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta.  Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta.  Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta.  Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta.  Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta.  Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Voluptatum, nemo aliquid delectus voluptatibus repellendus rem quae quas? Odit accusantium hic dolor laudantium, ea sunt, magnam at, possimus pariatur nihil dicta. ', 2018,2,'Owen','B';
GO
/*Insert Store Item*/
insert into StoreItem (storeid, itemid, quantity)
values (1,1,50);
insert into StoreItem (storeid, itemid, quantity)
values (1,2,50);
insert into StoreItem (storeid, itemid, quantity)
values (1,4,50);
insert into StoreItem (storeid, itemid, quantity)
values (1,7,50);
insert into StoreItem (storeid, itemid, quantity)
values (1,8,50);
insert into StoreItem (storeid, itemid, quantity)
values (1,18,50);
insert into StoreItem (storeid, itemid, quantity)
values (1,20,50);
insert into StoreItem (storeid, itemid, quantity)
values (1,21,50);
GO
insert into StoreItem (storeid, itemid, quantity)
values (2,2,50);
insert into StoreItem (storeid, itemid, quantity)
values (2,3,50);
insert into StoreItem (storeid, itemid, quantity)
values (2,5,50);
insert into StoreItem (storeid, itemid, quantity)
values (2,6,50);
insert into StoreItem (storeid, itemid, quantity)
values (2,7,50);
insert into StoreItem (storeid, itemid, quantity)
values (2,24,50);
GO
insert into StoreItem (storeid, itemid, quantity)
values (3,1,50);
insert into StoreItem (storeid, itemid, quantity)
values (3,4,50);
insert into StoreItem (storeid, itemid, quantity)
values (3,5,50);
insert into StoreItem (storeid, itemid, quantity)
values (3,7,50);
insert into StoreItem (storeid, itemid, quantity)
values (3,14,50);
insert into StoreItem (storeid, itemid, quantity)
values (3,13,50);
insert into StoreItem (storeid, itemid, quantity)
values (3,16,50);
insert into StoreItem (storeid, itemid, quantity)
values (3,26,50);
GO
/*Insert Order Lines */
insert into OrderLine (customerid,destination_address,order_date)
values (1, (select address_ From CustomerAddress WHERE customerid = 1), GETDATE());
insert into OrderLine (customerid,destination_address,order_date)
values (2, (select address_ From CustomerAddress WHERE customerid = 2), GETDATE());
insert into OrderLine (customerid,destination_address,order_date)
values (3,(select address_ From CustomerAddress WHERE customerid = 3), GETDATE());
insert into OrderLine (customerid,destination_address,order_date)
values (4, (select address_ From CustomerAddress WHERE customerid = 4), GETDATE());
insert into OrderLine (customerid,destination_address,order_date)
values (5,(select address_ From CustomerAddress WHERE customerid = 5), GETDATE());
insert into OrderLine (customerid,destination_address,order_date)
values (6,(select address_ From CustomerAddress WHERE customerid = 6), GETDATE());
insert into OrderLine (customerid,destination_address,order_date)
values (7,(select address_ From CustomerAddress WHERE customerid = 7), GETDATE());
insert into OrderLine (customerid,destination_address,order_date)
values (8,(select address_ From CustomerAddress WHERE customerid = 8), GETDATE());
insert into OrderLine (customerid,destination_address,order_date)
values (9, (select address_ From CustomerAddress WHERE customerid = 9), GETDATE());
insert into OrderLine (customerid,destination_address,order_date)
values (10,(select address_ From CustomerAddress WHERE customerid = 10), GETDATE());
GO
/*Insert Ordered Items*/
insert into OrderedItem (orderlineid,itemid,storeid,quantity)
values (1,1,1,3);
insert into OrderedItem (orderlineid,itemid,storeid,quantity)
values (1,4,3,2);
insert into OrderedItem (orderlineid,itemid,storeid,quantity)
values (1,7,3,2);
insert into OrderedItem (orderlineid,itemid,storeid,quantity)
values (1,26,3,5);
GO
insert into OrderedItem (orderlineid,itemid,storeid,quantity)
values (2,16,3,4);
insert into OrderedItem (orderlineid,itemid,storeid,quantity)
values (2,13,3,2);
insert into OrderedItem (orderlineid,itemid,storeid,quantity)
values (2,9,1,7);
GO
insert into OrderedItem (orderlineid,itemid,storeid,quantity)
values (3,26,3,1);
insert into OrderedItem (orderlineid,itemid,storeid,quantity)
values (3,8,1,2);
GO
insert into OrderedItem (orderlineid,itemid,storeid,quantity)
values (4,7,2,2);
insert into OrderedItem (orderlineid,itemid,storeid,quantity)
values (4,26,3,1);
GO
insert into OrderedItem (orderlineid,itemid,storeid,quantity)
values (5,6,2,2);
GO
insert into OrderedItem (orderlineid,itemid,storeid,quantity)
values (6,1,1,1);
insert into OrderedItem (orderlineid,itemid,storeid,quantity)
values (6,3,2,2);
insert into OrderedItem (orderlineid,itemid,storeid,quantity)
values (6,6,2,2);
GO
insert into OrderedItem (orderlineid,itemid,storeid,quantity)
values (7,26,3,1);
insert into OrderedItem (orderlineid,itemid,storeid,quantity)
values (7,14,3,3);
GO
insert into OrderedItem (orderlineid,itemid,storeid,quantity)
values (8,3,2,4);
insert into OrderedItem (orderlineid,itemid,storeid,quantity)
values (8,7,3,1);
GO
insert into OrderedItem (orderlineid,itemid,storeid,quantity)
values (9,14,3,6);
GO
insert into OrderedItem (orderlineid,itemid,storeid,quantity)
values (10,21,1,3);
insert into OrderedItem (orderlineid,itemid,storeid,quantity)
values (10,18,1,2);


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW most_expensive_order
AS

SELECT TOP 1
	ol.order_price,
	c.customerid as ıd,
	c.first_name as first_name,
	c.last_name as last_name,
	year(ol.order_date) as y,
	month(ol.order_date) as m,
	day(ol.order_date) as d
FROM 
	OrderLine AS ol
INNER JOIN Customer AS c
	on c.customerid = ol.customerid ORDER BY order_price DESC

GO
---------------
create view old_stuff
as
select TOP 1
	i.production_year,
	i.itemid,
	i.brand,
	i.name_,
	i.item_type,
	si.storeid
from
	Item as i
INNER JOIN StoreItem as si
	on si.itemid = i.itemid
where YEAR(GETDATE()) - i.production_year > 2 ORDER BY production_year

GO
