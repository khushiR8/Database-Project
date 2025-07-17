--DCL Security measures
--Admin – Full control (Can manage all tables)
--Travel Agent – Can handle bookings, customers,hotel,flight,guide, travel packages
--Customer Support – Can view bookings and assist customers with travel details but cannot modify anything
--Guest – Can only view available packages
--guide - can only view the table guide to check assigned booking	


--create users and logins
CREATE LOGIN TravelAdmin
WITH PASSWORD ='Admin123';

CREATE USER TravelAdmin 
FOR LOGIN TravelAdmin;

CREATE LOGIN TravelAgent
WITH PASSWORD ='Agent123';

CREATE USER TravelAgent 
FOR LOGIN TravelAgent;

CREATE LOGIN CustomerSupport
WITH PASSWORD ='Support123';

CREATE USER CustomerSupport 
FOR LOGIN CustomerSupport;

CREATE LOGIN Guest
WITH PASSWORD ='Guest123';

CREATE USER Guest 
FOR LOGIN Guest;

CREATE LOGIN guide
WITH PASSWORD ='guide123';

CREATE USER guide 
FOR LOGIN guide;

--Granting access
--TRAVEL ADMIN
-- the travel admin as full control on the entire database
GRANT SELECT, INSERT, UPDATE, DELETE ON Customers TO TravelAdmin;
GRANT SELECT, INSERT, UPDATE, DELETE ON Destination TO TravelAdmin;
GRANT SELECT, INSERT, UPDATE, DELETE ON Travel_Packages TO TravelAdmin;
GRANT SELECT, INSERT, UPDATE, DELETE ON Hotel TO TravelAdmin;
GRANT SELECT, INSERT, UPDATE, DELETE ON Booking TO TravelAdmin;
GRANT SELECT, INSERT, UPDATE, DELETE ON Guide TO TravelAdmin;
GRANT SELECT, INSERT, UPDATE, DELETE ON Flight TO TravelAdmin;
--Granting access on stored procedures
GRANT EXECUTE ON SP_add_customer TO TravelAdmin;
GRANT EXECUTE ON SP_view_available_guides TO TravelAdmin;
GRANT EXECUTE ON SP_assign_guide_to_booking TO TravelAdmin;
GRANT EXECUTE ON SP_create_booking TO TravelAdmin;
GRANT EXECUTE ON SP_cancel_booking TO TravelAdmin;
GRANT EXECUTE ON SP_total_price_booking TO TravelAdmin;
GRANT EXECUTE ON SP_customer_budget TO TravelAdmin;
GRANT EXECUTE ON SP_view_travel_package TO TravelAdmin;
GRANT EXECUTE ON SP_view_customer TO TravelAdmin;
GRANT EXECUTE ON SP_delete_customer TO TravelAdmin;
GRANT EXECUTE ON SP_price_without_guide TO TravelAdmin;
GRANT EXECUTE ON SP_update_flight_status TO TravelAdmin;
GRANT EXECUTE ON SP_view_booking TO TravelAdmin;

EXEC SP_add_customer 'Maspain', 'Chocolate', '2000-09-12', 'mas.pain@example.com', 'Caro banane', 'P7654321' ;
EXEC SP_view_available_guides
EXEC SP_assign_guide_to_booking
EXEC SP_create_booking 'C002','P002';
EXEC SP_cancel_booking 'B011'
EXEC SP_total_price_booking
EXEC SP_customer_budget
EXEC SP_view_travel_package
EXEC SP_view_customer
EXEC SP_delete_customer 'C011'
EXEC SP_price_without_guide
EXEC SP_update_flight_status
EXEC SP_view_booking

--Granting access on triggers
GRANT TRIGGER ON TRG_check_customer_age TO TravelAdmin;
GRANT TRIGGER ON TRG_set_BookID_null_in_Guide TO TravelAdmin;
GRANT TRIGGER ON TRG_delete_customer_booking TO TravelAdmin;
GRANT TRIGGER ON TRG_check_customer_age TO TravelAdmin;

--TRAVEL AGENT
--the travel agent should have access only to handle Bookings, Customers, and Travel Packages
GRANT SELECT, INSERT, UPDATE ON Booking TO TravelAgent; --allow agents to view all bookings/create new bookings/update
GRANT SELECT, UPDATE ON Travel_Packages TO TravelAgent; --view and update packages if needed (e.g price)
GRANT SELECT,INSERT,UPDATE ON Customers TO TravelAgent; --view and update customer info
GRANT SELECT,UPDATE ON Hotel TO TravelAgent;  
GRANT SELECT,UPDATE ON Guide TO TravelAgent;
GRANT SELECT,UPDATE ON Flight TO TravelAgent;
GRANT SELECT,UPDATE ON Destination TO TravelAgent;

--Granting access to stored procedures 
GRANT EXECUTE ON SP_create_booking TO TravelAgent;
GRANT EXECUTE ON SP_view_booking TO TravelAgent;
GRANT EXECUTE ON SP_view_available_guides TO TravelAgent;
GRANT EXECUTE ON SP_add_customer TO TravelAgent;
GRANT EXECUTE ON SP_view_travel_package TO TravelAgent;


--customer support has access to view only bookings and customers but cannot modify them
GRANT SELECT ON Booking TO CustomerSupport;
GRANT SELECT ON Customers TO CustomerSupport;

--Granting access to stored procedures 
GRANT EXECUTE ON SP_view_booking TO CustomerSupport;
GRANT EXECUTE ON SP_view_customer TO CustomerSupport;

--guest can only view travel_packages,hotel,flight
GRANT SELECT ON Travel_Packages TO Guest;
GRANT SELECT ON Hotel TO Guest;  
GRANT SELECT ON Flight TO Guest;

--Granting access to stored procedures 
GRANT EXECUTE ON SP_view_travel_package TO Guest;

--guide can only view guide table
GRANT SELECT ON Guide TO guide
GRANT SELECT ON Booking TO guide
GRANT SELECT ON Travel_Packages TO guide

--Granting access to stored procedures 
GRANT EXECUTE ON SP_view_booking TO guide;
GRANT EXECUTE ON SP_view_travel_package TO guide;

--Testing for TravelAdmin
select * from Customers;

select * from Booking;

INSERT into Customers(CustID, Fname, Lname, DOB, Email, Address, PassportNum) 
VALUES ('C012', 'Jack', 'Williams', '1995-12-15', 'jackw@example.com', '321 Oak St, MI', 'JK234567');

INSERT INTO Booking (BookID, BDate, TotalPrice, CustID, PackageID) 
VALUES ('B012', '2025-06-10', 1800.00, 'C012', 'P006');

UPDATE Customers 
SET Address = '999 Birch St, MI' 
WHERE CustID = 'C012';

UPDATE Booking 
SET TotalPrice = 2000 
WHERE BookID = 'B012';

DELETE FROM Customers 
WHERE CustID = 'C012';
DELETE FROM Booking 
WHERE BookID = 'B012';


--Testing for TravelAgent
select * from Customers;
select * from Booking;
select * from Travel_Packages
select * from Hotel
select * from Guide
select * from Flight

INSERT into Customers(CustID, Fname, Lname, DOB, Email, Address, PassportNum) 
VALUES ('C012', 'Jack', 'Williams', '1995-12-15', 'jackw@example.com', '321 Oak St, MI', 'JK234567');

INSERT INTO Booking (BookID, BDate, TotalPrice, CustID, PackageID) 
VALUES ('B012', '2025-06-10', 1800.00, 'C012', 'P006');

UPDATE Booking 
SET TotalPrice = 2400 
WHERE BookID = 'B012';

UPDATE Customers 
SET Email = 'newemail@example.com' 
WHERE CustID = 'C012';

--No access to delete any data
DELETE FROM Customers 
WHERE CustID = 'C012';
DELETE FROM Booking 
WHERE BookID = 'B012';


--Testing for customer support
select * from Customers;
select * from Booking;

--no access to view these tables
select * from Travel_Packages
select * from Hotel
select * from Guide
select * from Flight

--No access to insert,update,delete
INSERT into Customers(CustID, Fname, Lname, DOB, Email, Address, PassportNum) 
VALUES ('C012', 'Jack', 'Williams', '1995-12-15', 'jackw@example.com', '321 Oak St, MI', 'JK234567');

UPDATE Customers 
SET Email = 'newemail@example.com' 
WHERE CustID = 'C012';

DELETE FROM Customers 
WHERE CustID = 'C012';

DELETE FROM Booking
WHERE BookID='B011'


--Testing for guide
select * from Guide
select * from Booking;
select * from Travel_Packages

--no access
select * from Customers;
select * from Hotel
select * from Flight

--No access to insert,update,delete
INSERT into Customers(CustID, Fname, Lname, DOB, Email, Address, PassportNum) 
VALUES ('C012', 'Jack', 'Williams', '1995-12-15', 'jackw@example.com', '321 Oak St, MI', 'JK234567');

UPDATE Customers 
SET Email = 'newemail@example.com' 
WHERE CustID = 'C012';

DELETE FROM Customers 
WHERE CustID = 'C012';

--Testing for Guest
select * from Travel_Packages
select * from Hotel
select * from Flight

--no access 
select * from Customers;
select * from Guide
select * from Booking;











