--TRIGGERS
--1.trigger to check customer age
CREATE TRIGGER TRG_check_customer_age
ON Customers
INSTEAD OF INSERT
AS
BEGIN
	DECLARE @NewCustID CHAR(4);
	DECLARE @NewDOB DATE;
	DECLARE @Age INT; 
	SELECT @NewCustID = CustID 
	FROM inserted;
	SELECT @NewDOB = DOB 
	FROM inserted
	WHERE CustID = @NewCustID;
	-- Calculate age
	SET @Age = DATEDIFF(YEAR, @NewDOB, GETDATE());
	-- Adjust age if birthday has not occurred this year
	IF (MONTH(@NewDOB) > MONTH(GETDATE()) OR (MONTH(@NewDOB) = MONTH(GETDATE()) AND DAY(@NewDOB) > DAY(GETDATE())))
		BEGIN
			SET @Age = @Age - 1;
		END
	IF @Age < 18
		BEGIN
			PRINT 'Customer registration failed: The customer must be at least 18 years old';
		END
	ELSE
		BEGIN
			INSERT INTO Customers (CustID,Fname, Lname, DOB, Email, Address, PassportNum)
			SELECT CustID,Fname, Lname, DOB, Email, Address, PassportNum
			FROM inserted;
		END
END;
GO


--2.trigger to set book id to null in guide table
CREATE TRIGGER TRG_set_BookID_null
ON Booking
INSTEAD OF DELETE
AS
BEGIN
    UPDATE Guide
    SET BookID = NULL
    WHERE BookID IN (SELECT BookID
	                 FROM deleted);

    DELETE FROM Booking
    WHERE BookID IN (SELECT BookID 
	                 FROM deleted);

    PRINT 'BookID set to NULL in Guide before deletion';
END;

drop trigger TRG_set_BookID_null;
go

--3.trigger to delete a customer booking
CREATE TRIGGER TRG_delete_customer_booking
ON Customers
INSTEAD OF DELETE
AS
BEGIN
    DECLARE @bid CHAR(4);
	--using cursor if one customer has multiple bookings
    DECLARE booking_cursor CURSOR FOR 
    SELECT BookID FROM Booking
    WHERE CustID IN (SELECT CustID FROM deleted);

    OPEN booking_cursor;
    FETCH NEXT FROM booking_cursor INTO @bid;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        EXEC SP_cancel_booking @bid;
        FETCH NEXT FROM booking_cursor INTO @bid;
    END

    CLOSE booking_cursor;
    DEALLOCATE booking_cursor;

    DELETE FROM Customers
    WHERE CustID IN (SELECT CustID
	                 FROM deleted);
END;


DROP TRIGGER TRG_delete_customer_booking;

go

--4.trigger to notify customers about the change in flight status
CREATE TRIGGER TRG_notify_customer
ON Flight
AFTER UPDATE --used because there are changes occurring in the table
AS
BEGIN
DECLARE @Message VARCHAR(100);
-- Check for cancelled flights
IF EXISTS (SELECT 1 FROM inserted i 
JOIN deleted d ON i.FlightID = d.FlightID  --deleted is used to compare old and new status of flight,so that it can identify what changed
WHERE i.Status = 'Cancelled' AND d.Status <> 'Cancelled')
BEGIN
SET @Message = 'Your flight has been CANCELLED.';
SELECT c.CustID, c.Fname, c.Lname, i.FlightID, @Message AS Message
FROM inserted i
JOIN Travel_Packages p ON i.PackageID = p.PackageID
JOIN Booking b ON p.PackageID = b.PackageID
JOIN Customers c ON b.CustID = c.CustID
WHERE i.Status = 'Cancelled';
END;

-- Check for delayed flights
IF EXISTS (SELECT 1 FROM inserted i 
JOIN deleted d ON i.FlightID = d.FlightID 
WHERE i.Status = 'Delayed' AND d.Status <> 'Delayed')
BEGIN
SET @Message = 'Your flight has been DELAYED.';
SELECT c.CustID, c.Fname, c.Lname, i.FlightID, @Message AS Message
FROM inserted i
JOIN Travel_Packages p ON i.PackageID = p.PackageID
JOIN Booking b ON p.PackageID = b.PackageID
JOIN Customers c ON b.CustID = c.CustID
WHERE i.Status = 'Delayed';
END;

-- Check for rescheduled flights
IF EXISTS (SELECT 1 FROM inserted i 
JOIN deleted d ON i.FlightID = d.FlightID 
WHERE (d.Status = 'Cancelled' or d.status ='Delayed') AND i.Status = 'Scheduled')
BEGIN
SET @Message = 'Your flight has been RESCHEDULED.';
SELECT c.CustID, c.Fname, c.Lname, i.FlightID, @Message AS Message
FROM inserted i
JOIN Travel_Packages p ON i.PackageID = p.PackageID
JOIN Booking b ON p.PackageID = b.PackageID
JOIN Customers c ON b.CustID = c.CustID
WHERE i.Status = 'Scheduled';
END;
END;



