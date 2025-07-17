CREATE DATABASE EpicExplorers;

CREATE TABLE Customers(
CustID CHAR(4) CHECK(CustID LIKE 'C%'),
Fname VARCHAR(50) NOT NULL,
Lname VARCHAR(50) NOT NULL,
DOB DATE NOT NULL,
Email VARCHAR(100) CHECK(Email LIKE '%@%.%'),
Address VARCHAR(100) NOT NULL,
PassportNum VARCHAR(20) NOT NULL,
PRIMARY KEY (CustID)
);

CREATE TABLE Destination (
DestID CHAR(4) CHECK(DestID LIKE 'D%'),
DestName VARCHAR(50) NOT NULL,
Country VARCHAR(30) NOT NULL,
Description VARCHAR(50),
PRIMARY KEY (DestID)
);

CREATE TABLE Travel_Packages (
PackageID CHAR(4) CHECK(PackageID LIKE 'P%'),
PackageName VARCHAR(30) NOT NULL,
PackagePrice DECIMAL(10,2) NOT NULL,
StartDate DATE NOT NULL,
EndDate DATE NOT NULL,
PDuration INT NOT NULL,
DestID CHAR(4) CHECK(DestID LIKE 'D%'),
PRIMARY KEY (PackageID),
FOREIGN KEY (DestID) REFERENCES Destination 
);

CREATE TABLE Hotel (
HotelID CHAR(4) CHECK(HotelID LIKE 'H%'),
HName VARCHAR(30) NOT NULL,
HPrice DECIMAL(10,2) NOT NULL,
Location VARCHAR(50),
DestID CHAR(4) CHECK(DestID LIKE 'D%'),
PRIMARY KEY (HotelID),
FOREIGN KEY (DestID) REFERENCES Destination
);

CREATE TABLE Booking(
BookID CHAR(4) CHECK(BookID LIKE 'B%'),
BDate DATE NOT NULL,
TotalPrice DECIMAL(10,2),
CustID CHAR(4) CHECK(CustID LIKE 'C%'),
PackageID CHAR(4) CHECK(PackageID LIKE 'P%'),
PRIMARY KEY (BookID),
FOREIGN KEY (CustID) REFERENCES Customers,
FOREIGN KEY (PackageID) REFERENCES Travel_Packages
); 

CREATE TABLE Guide (
GuideID CHAR(4) CHECK(GuideID LIKE 'G%'),
GuideName VARCHAR(50) NOT NULL,
CostPerDay DECIMAL(10,2) NOT NULL,
PhoneNumber VARCHAR(15) NOT NULL,
BookID CHAR(4) CHECK(BookID LIKE 'B%'),
PRIMARY KEY (GuideID),
FOREIGN KEY (BookID) REFERENCES Booking
);

CREATE TABLE Flight (
FlightID CHAR(4) CHECK(FlightID LIKE 'F%'),
Airline VARCHAR(30) NOT NULL,
ArrivalTime TIME NOT NULL,
FPrice DECIMAL(10,2) NOT NULL,
DepartureTime TIME NOT NULL,
FDuration VARCHAR(10) CHECK(FDuration LIKE '%h %m') NOT NULL,
PackageID CHAR(4) CHECK(PackageID LIKE 'P%'),
Status VARCHAR(30) CHECK(Status IN('Scheduled','Delayed','Cancelled')),
PRIMARY KEY (FlightID),
FOREIGN KEY (PackageID) REFERENCES Travel_Packages
);

-- Insert into Customers (10 records)
INSERT INTO Customers (CustID, Fname, Lname, DOB, Email, Address, PassportNum) VALUES
('C001', 'John', 'Doe', '1999-05-15', 'johndoe@example.com', '123 Maple St, NY', 'AB123456'),
('C002', 'Jane', 'Smith', '1988-08-22', 'janesmith@example.com', '456 Oak St, LA', 'CD789012'),
('C003', 'Alice', 'Johnson', '2000-03-10', 'alicej@example.com', '789 Pine St, TX', 'EF345678'),
('C004', 'Robert', 'Brown', '1980-11-30', 'robbrown@example.com', '321 Birch St, FL', 'GH901234'),
('C005', 'Emma', 'Davis', '2001-07-18', 'emmad@example.com', '654 Cedar St, IL', 'IJ567890'),
('C006', 'Michael', 'Wilson', '1985-09-25', 'mikewilson@example.com', '987 Spruce St, OH', 'KL345678'),
('C007', 'Sophia', 'Martinez', '1997-02-14', 'sophiam@example.com', '852 Elm St, WA', 'MN901234'),
('C008', 'Daniel', 'Taylor', '2004-06-08', 'dantaylor@example.com', '963 Walnut St, TX', 'OP567890'),
('C009', 'Olivia', 'Anderson', '1991-04-03', 'oliviaa@example.com', '741 Ash St, GA', 'QR345678'),
('C010', 'Ethan', 'Thomas', '1989-12-20', 'ethant@example.com', '159 Fir St, CA', 'ST901234');

-- Insert into Destination (10 records)
INSERT INTO Destination (DestID, DestName, Country, Description) VALUES
('D001', 'Eiffel Tower', 'France', 'Iconic landmark in Paris'),
('D002', 'Great Wall', 'China', 'Ancient wall with scenic views'),
('D003', 'Machu Picchu', 'Peru', 'Historic Incan city'),
('D004', 'Statue of Liberty', 'USA', 'Famous landmark in New York'),
('D005', 'Colosseum', 'Italy', 'Ancient Roman amphitheater'),
('D006', 'Sydney Opera House', 'Australia', 'Famous performing arts venue'),
('D007', 'Taj Mahal', 'India', 'Marble mausoleum in Agra'),
('D008', 'Santorini', 'Greece', 'Beautiful whitewashed island'),
('D009', 'Mount Fuji', 'Japan', 'Sacred mountain and pilgrimage site'),
('D010', 'Niagara Falls', 'Canada', 'Massive waterfalls on the border');


-- Insert into Travel_Packages (10 records)
INSERT INTO Travel_Packages (PackageID, PackageName, PackagePrice, StartDate, EndDate, PDuration, DestID) VALUES
('P001', 'Paris Adventure', 1500.00, '2025-06-01', '2025-06-07', 7, 'D001'),
('P002', 'China Wonders', 2000.00, '2025-07-10', '2025-07-16', 6, 'D002'),
('P003', 'Incan Escape', 1800.00, '2025-05-20', '2025-05-30', 10, 'D003'),
('P004', 'NYC Explorer', 1700.00, '2025-08-05', '2025-08-13', 8, 'D004'),
('P005', 'Roman Holiday', 2200.00, '2025-09-01', '2025-09-12', 12, 'D005'),
('P006', 'Sydney Highlights', 1600.00, '2025-06-10', '2025-06-24', 14, 'D006'),
('P007', 'India Royal Tour', 2100.00, '2025-07-01', '2025-07-05', 5, 'D007'),
('P008', 'Greek Islands', 2300.00, '2025-10-01', '2025-10-07', 6, 'D008'),
('P009', 'Japan Journey', 2500.00, '2025-11-01', '2025-11-09', 9, 'D009'),
('P010', 'Canadian Adventure', 1900.00, '2025-12-01', '2025-12-07', 6, 'D010');

-- Insert into Hotel (10 records)
INSERT INTO Hotel (HotelID, HName, HPrice, Location, DestID) VALUES
('H001', 'Paris Grand', 200.00, 'Near Eiffel Tower', 'D001'),
('H002', 'Beijing Royal', 180.00, 'Near Great Wall', 'D002'),
('H003', 'Cusco Retreat', 150.00, 'Near Machu Picchu', 'D003'),
('H004', 'Liberty Inn', 175.00, 'Near Statue of Liberty', 'D004'),
('H005', 'Colosseum Suites', 190.00, 'Near Colosseum', 'D005'),
('H006', 'Sydney Harbour', 210.00, 'Near Opera House', 'D006'),
('H007', 'Agra Palace', 160.00, 'Near Taj Mahal', 'D007'),
('H008', 'Santorini Blue', 230.00, 'Island View', 'D008'),
('H009', 'Fuji Heights', 250.00, 'Near Mount Fuji', 'D009'),
('H010', 'Falls Lodge', 200.00, 'Near Niagara Falls', 'D010');

-- Insert into Booking (10 records)
INSERT INTO Booking (BookID, BDate, TotalPrice, CustID, PackageID) VALUES
('B001', '2025-04-01', 4100.00, 'C001', 'P001'),
('B002', '2025-04-05', 4500.00, 'C002', 'P002'),
('B003', '2025-04-10', 5000.00, 'C003', 'P003'),
('B004', '2025-04-15', 4490.00, 'C004', 'P004'),
('B005', '2025-04-20', 6790.00, 'C005', 'P005'),
('B006', '2025-04-25', 6800.00, 'C006', 'P006'),
('B007', '2025-04-30', 4320.00, 'C007', 'P007'),
('B008', '2025-05-05', 5230.00, 'C008', 'P008'),
('B009', '2025-05-10', 6865.00, 'C009', 'P009'),
('B010', '2025-05-15', 4380.00, 'C010', 'P010');

-- Insert into Guide (15 records)
INSERT INTO Guide (GuideID, GuideName, CostPerDay, PhoneNumber, BookID) VALUES
('G001', 'Pierre Dupont', 100.00, '123-456-7890', 'B001'),
('G002', 'Li Wei', 120.00, '234-567-8901', 'B002'),
('G003', 'Carlos Mendez', 110.00, '345-678-9012', 'B003'),
('G004', 'Emma Wilson', 105.00, '456-789-0123', 'B004'),
('G005', 'Luca Romano', 130.00, '567-890-1234', 'B005'),
('G006', 'Sydney Carter', 115.00, '678-901-2345', 'B006'),
('G007', 'Raj Patel', 140.00, '789-012-3456', 'B007'),
('G008', 'Dimitrios Kostas', 125.00, '890-123-4567', 'B008'),
('G009', 'Haruto Tanaka', 135.00, '901-234-5678', 'B009'),
('G010', 'Ethan Williams', 110.00, '012-345-6789', 'B010'),
('G011', 'Rishab Raghoo',120.00,'110-543-9876',NULL),
('G012', 'Keke Soso',125.00,'321-543-1856',NULL),
('G013', 'Khushi Bee',115.00,'654-597-5269',NULL),
('G014', 'Kentish Thum',130.00,'167-956-1256',NULL),
('G015', 'Ayush Auckel',120.00,'678-345-8012',NULL);

-- Insert into Flight (10 records)
INSERT INTO Flight (FlightID, Airline, ArrivalTime, FPrice, DepartureTime, FDuration, PackageID, Status) VALUES
('F001', 'Air France', '10:30:00', 500.00, '05:00:00', '5h 30m', 'P001', 'Scheduled'),
('F002', 'China Airlines', '14:15:00', 700.00, '08:00:00', '6h 15m', 'P002', 'Scheduled'),
('F003', 'LATAM Airlines', '12:45:00', 600.00, '08:00:00', '4h 45m', 'P003', 'Scheduled'),
('F004', 'Delta Airlines', '15:20:00', 550.00, '10:00:00', '5h 20m', 'P004', 'Scheduled'),
('F005', 'Alitalia', '09:30:00', 750.00, '05:00:00', '4h 30m', 'P005', 'Scheduled'),
('F006', 'Qantas', '18:10:00', 650.00, '12:00:00', '6h 10m', 'P006', 'Scheduled'),
('F007', 'Air India', '20:45:00', 720.00, '15:00:00', '5h 45m', 'P007', 'Scheduled'),
('F008', 'Aegean Airlines', '13:00:00', 800.00, '06:00:00', '7h 00m', 'P008', 'Scheduled'),
('F009', 'Japan Airlines', '17:30:00', 900.00, '11:00:00', '6h 30m', 'P009', 'Scheduled'),
('F010', 'Air Canada', '22:00:00', 620.00, '16:00:00', '6h 00m', 'P010', 'Scheduled');

select * from Guide
select * from Travel_Packages
select * from Customers
select * from Flight
select * from Hotel
select * from Destination
select * from Booking


