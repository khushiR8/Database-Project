--STORED PROCEDURES
--1.this sp is used to add a new customer with a generated customer id
CREATE PROCEDURE SP_add_customer
	@Fname VARCHAR(50), 
	@Lname VARCHAR(50),
	@DOB DATE,
	@Email VARCHAR(100),
	@Address VARCHAR(100),
	@PassportNum VARCHAR(20)
AS
BEGIN
	DECLARE @NewCustID CHAR(4);

	SELECT @NewCustID = 'C' + RIGHT('000' + CAST(CAST(SUBSTRING(ISNULL(MAX(CustID), 'B000'), 2, 3) AS INT) + 1 AS VARCHAR), 3)
	FROM Customers;

	INSERT INTO Customers (CustID, Fname, Lname, DOB, Email, Address, PassportNum) VALUES
	(@NewCustID,@fname,@Lname,@DOB,@Email,@Address,@PassportNum)
END;

--Above 18
EXEC SP_add_customer 'Maspain', 'Chocolate', '2000-09-12', 'mas.pain@example.com', 'Caro banane', 'P7654321' ;
--Under 18
EXEC SP_add_customer 'Theo', 'James', '2010-09-15', 'Theo.james@example.com', 'Caro canne', 'P6384572';

go

--2.sp to view customer details
CREATE PROCEDURE SP_view_customer
AS
BEGIN
	SELECT *
	FROM Customers;
END;

EXEC SP_view_customer;
go


--3.This sp is implemented to view available guides
CREATE PROCEDURE SP_view_available_guides
AS
BEGIN
SELECT g.GuideID, g.GuideName, g.CostPerDay, g.PhoneNumber, g.BookID
FROM Guide g
LEFT JOIN Booking b ON g.BookID = b.BookID
WHERE b.BookID IS NULL; 
END;

EXEC SP_view_available_guides;
go

--4.sp to view travel packages
CREATE PROCEDURE SP_view_travel_package
AS
BEGIN
	SELECT *
	FROM Travel_Packages;
END;

EXEC SP_view_travel_package;

Drop procedure SP_view_travel_package
GO


--5.SP_price_without_guide 
--booking does not exists yet, that's why it does not have an assigned guide
--this procedure is used in SP_customer_budget
CREATE PROCEDURE SP_price_without_guide
	@PacID AS CHAR(4),
	@NOguide AS DECIMAL(10,2) OUTPUT, --sum not including guide
	@NumberDays AS INT OUTPUT
AS
BEGIN 
	DECLARE @HotelP AS DECIMAL(10,2), @TP AS DECIMAL(10,2), @FlightP AS DECIMAL(10,2)

	SET @TP = (SELECT PackagePrice
					FROM Travel_Packages 
					WHERE PackageID = @PacID);
	SET @FlightP = (SELECT FPrice
					FROM Flight 
					WHERE PackageID = @PacID);
	SET @NumberDays = (SELECT PDuration
					FROM Travel_packages
					WHERE PackageID = @PacID)
	SET @HotelP = @NumberDays * (SELECT HPrice 
								FROM Hotel h
								LEFT JOIN Travel_Packages t
								ON h.DestID = t.DestID 
								WHERE t.PackageID = @PacID);
	SET @NOguide = @TP + @FlightP +  @HotelP
END;

DROP PROCEDURE SP_price_without_guide
DECLARE @MINUSguide AS DECIMAL(10,2), @tourDays AS INT;
EXEC  SP_price_without_guide 'P001',@MINUSguide OUTPUT, @tourDays OUTPUT
PRINT 'Cost of tour not including guide: ' + CAST(@MINUSguide AS VARCHAR(10))
PRINT 'Number of days for the tour: ' + CAST(@tourDays AS VARCHAR(10));
GO


--6.sp calculate customer budget
CREATE PROCEDURE SP_customer_budget
	@budget AS DECIMAL(10,2) --one parameter
AS 
BEGIN 
	DECLARE @P_ID AS CHAR(4), @G_ID AS CHAR(4) 
	DECLARE @MINUSguide AS DECIMAL(10,2), @tourDays AS INT;
	DECLARE @price AS DECIMAL(10,2), @guideCost AS DECIMAL(10,2)

	-- temporary table 
    CREATE TABLE #BudgetResults (
        PackageID CHAR(4),
        PackageName VARCHAR(30),
        PackagePrice DECIMAL(10,2),
		StartDate DATE, 
		EndDate DATE,
        HotelName VARCHAR(30),
        HotelPrice DECIMAL(10,2),
        Airline VARCHAR(30),
        FlightPrice DECIMAL(10,2),
		GuideID CHAR(4),
        GuideName VARCHAR(50),
        CostPerDay DECIMAL(10,2),
        TotalPrice DECIMAL(10,2)
    );

	DECLARE id_cursor CURSOR FOR 
	SELECT PackageID 
	FROM Travel_packages 

	OPEN id_cursor
	FETCH NEXT FROM id_cursor INTO @P_ID --retrieving all package IDs
	WHILE @@FETCH_STATUS = 0 
		BEGIN
			--retrieve price not including guide cost
			EXEC  SP_price_without_guide @P_ID, @MINUSguide OUTPUT, @tourDays OUTPUT 

			--ensuring we get a guide
			SET @G_ID = (SELECT TOP 1 GuideID FROM Guide WHERE BookID IS NULL);
			SET @guideCost = @tourDays * (SELECT CostPerDay  --calculating guide cost
											FROM Guide
											WHERE GuideID = @G_ID);
			SET @price = @MINUSguide + @guideCost --calculating total cost 
			IF @price <= @budget 
				BEGIN 
					INSERT INTO #BudgetResults 
					SELECT t.PackageID,t.PackageName, t.PackagePrice ,t.StartDate, t.EndDate, h.Hname ,h.HPrice ,f.Airline ,f.FPrice ,g.GuideID,g.GuideName ,g.CostPerDay,@price AS Total_Price
					FROM Travel_Packages t
					JOIN Hotel h ON h.DestID = t.DestID 
					JOIN Flight f ON f.PackageID = t.PackageID 
					JOIN Booking b ON t.PackageID  = b.PackageID 
					LEFT JOIN Guide g ON g.GuideID = @G_ID -- Join with selected guide
					WHERE t.PackageID = @P_ID;
				END
			FETCH NEXT FROM id_cursor INTO @P_ID
		END
	CLOSE id_cursor 
	DEALLOCATE id_cursor
	
	IF NOT EXISTS (SELECT 1 FROM #BudgetResults)
		BEGIN 
			PRINT 'No travel package available for this budget.Please try again later.'
		END
	ELSE 
		BEGIN
			SELECT * FROM #BudgetResults; -- Return all results
		END
    -- deletes temporary table
    DROP TABLE #BudgetResults;
END;

DROP PROCEDURE SP_customer_budget;
EXEC SP_customer_budget 7000;
EXEC SP_customer_budget 4500;
EXEC SP_customer_budget 1000;

--7.sp to calculate total price for booking
--booking already exists, this procedure is used for invoice generation in SP_create_booking
CREATE PROCEDURE SP_total_price_booking
	@PID AS CHAR(4),
	@GID AS CHAR(4)
AS
BEGIN 
	DECLARE @priceH AS DECIMAL(10,2), @TravelP AS DECIMAL(10,2), @priceF AS DECIMAL(10,2), @priceG AS DECIMAL(10,2)
	DECLARE @TotalP AS DECIMAL(10,2),@NumDays AS INT
	SET @TravelP = (SELECT PackagePrice
					FROM Travel_Packages 
					WHERE PackageID = @PID);
	SET @priceF = (SELECT FPrice
					FROM Flight 
					WHERE PackageID = @PID);
	SET @NumDays = (SELECT PDuration
					FROM Travel_packages
					WHERE PackageID = @PID)
	SET @priceG = @NumDays * (SELECT CostPerDay
						      FROM Guide
					          WHERE GuideID = @GID);
	SET @priceH = @NumDays* (SELECT HPrice 
							FROM Hotel h
							LEFT JOIN Travel_Packages t
							ON h.DestID = t.DestID 
							WHERE t.PackageID = @PID);
	SET @TotalP = @TravelP + @priceF + @priceG + @priceH
	RETURN @TotalP;
END;

DROP PROCEDURE SP_total_price_booking

DECLARE @price AS DECIMAL(10,2);
EXEC @price = SP_total_price_booking 'P001','G001';
PRINT 'Total Price: ' + CAST(@price AS VARCHAR(10))
GO

--8.sp create booking
CREATE PROCEDURE SP_create_booking
@cid CHAR(4),
@pid CHAR(4)
AS
BEGIN
    DECLARE @NewBookID CHAR(4);
    DECLARE @cday DATE;
    DECLARE @price AS DECIMAL(10,2);
    DECLARE @result CHAR(4);
    DECLARE @gid CHAR(4);

    SET @cday = GETDATE();

    -- Check if the customer exists
    IF NOT EXISTS (SELECT 1 FROM Customers WHERE CustID = @cid)
    BEGIN
        PRINT 'Error: Customer ID ' + @cid + ' does not exist.';
        RETURN;
    END

    -- Check if the travel package exists
    IF NOT EXISTS (SELECT 1 FROM Travel_Packages WHERE PackageID = @pid)
    BEGIN
        PRINT 'Error: Travel Package ID ' + @pid + ' does not exist.';
        RETURN;
    END

    -- Generate new Booking ID
    SELECT @NewBookID = 'B' + RIGHT('000' + CAST(CAST(SUBSTRING(ISNULL(MAX(BookID), 'B000'), 2, 3) AS INT) + 1 AS VARCHAR), 3)
    FROM Booking;

    -- Insert new booking
    INSERT INTO Booking (BookID, BDate, TotalPrice, CustID, PackageID)
    VALUES (@NewBookID, @cday, @price, @cid, @pid);

    -- Assign guide to booking
    EXEC SP_assign_guide_to_booking @NewBookID, @gid OUTPUT;

    -- Calculate total price
    EXEC @price = SP_total_price_booking @pid, @gid;

    -- Update total price in Booking
    UPDATE Booking
    SET TotalPrice = @price
    WHERE BookID = @NewBookID;
END;

drop procedure SP_create_booking;

--Valid data
EXEC SP_create_booking 'C011','P003';
--Invalid customerID
EXEC SP_create_booking 'C020','P003';


go

--9 displays all bookings
CREATE PROCEDURE SP_view_booking
AS
BEGIN
	SELECT *
	FROM Booking;
END;

EXEC SP_view_booking;
go

--10.This sp assign guide when a booking is created
CREATE PROCEDURE SP_assign_guide_to_booking
@BID CHAR(4),
@gid char(4) OUTPUT
AS
BEGIN
    DECLARE @guide_id CHAR(4);

    SET @guide_id = (
        SELECT TOP 1 GuideID
        FROM Guide
        WHERE BookID IS NULL);

	set @gid=@guide_id

    IF @guide_id IS NULL
    BEGIN
        PRINT 'No guide available';
        RETURN;
    END
    ELSE
    BEGIN
        update Guide
		set BookID=@BID
		where GuideID=@guide_id
    END
END;

Declare @result as char(4)

exec SP_assign_guide_to_booking 'B010',@result;
print (@result)

drop procedure SP_assign_guide_to_booking;
go

SELECT *
FROM Guide

--11.sp to update flight status
CREATE PROCEDURE SP_update_flight_status
@NewFlightID CHAR(4),
@NewStatus VARCHAR(30)
AS
BEGIN

BEGIN TRY
-- Check if flight exists
IF NOT EXISTS (SELECT 1 
FROM Flight 
WHERE FlightID = @NewFlightID)
BEGIN
PRINT 'Error: Flight does not exist.';
RETURN;
END
-- Update flight status
UPDATE Flight
SET Status = @NewStatus
WHERE FlightID = @NewFlightID;

PRINT('Flight '+ @NewFlightID+ ' is '+ @NewStatus);
END TRY
BEGIN CATCH
PRINT 'An error occurred while updating the flight status.';
PRINT ERROR_MESSAGE();
END CATCH
END;

EXEC SP_update_flight_status 'F005', 'Cancelled';
EXEC SP_update_flight_status 'F005', 'Delayed';
EXEC SP_update_flight_status 'F005', 'Scheduled';
EXEC SP_update_flight_status 'F015', 'Scheduled';


select *
from Flight
GO

--12.sp cancel booking
CREATE PROCEDURE SP_cancel_booking
    @bookid CHAR(4)
AS
BEGIN
    BEGIN TRY
        -- Check if the booking exists
        IF NOT EXISTS (SELECT 1 FROM Booking WHERE BookID = @bookid)
        BEGIN
            PRINT 'Error: Booking ID ' + @bookid + ' not found.';
            RETURN; -- Exit procedure
        END
        
        -- Delete the booking
        DELETE FROM Booking
        WHERE BookID = @bookid;

        PRINT 'Success: Booking ID ' + @bookid + ' has been successfully deleted.';
    END TRY
    BEGIN CATCH
        PRINT 'Error: Unable to delete booking.';
        PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS VARCHAR);
        PRINT 'Error Message: ' + ERROR_MESSAGE();
    END CATCH;
END;


drop procedure SP_cancel_booking
--Valid BookingId
Exec SP_cancel_booking 'B011' ;
--InValid BokkingId
Exec SP_cancel_booking 'B030' ;

select *
from Booking

select *
from Guide
GO

--13.sp to delete customer
CREATE PROCEDURE SP_delete_customer
@cid CHAR(4)
AS
BEGIN
    BEGIN TRY
        -- Check if the customer exists
        IF NOT EXISTS (SELECT 1 FROM Customers WHERE CustID = @cid)
        BEGIN
            PRINT 'Error: Customer ID ' + @cid + ' not found.';
            RETURN; -- Exit the procedure if the customer does not exist
        END

        -- Delete the customer
        DELETE FROM Customers
        WHERE CustID = @cid;

        PRINT 'Success: Customer ID ' + @cid + ' has been successfully deleted.';
    END TRY
    BEGIN CATCH
        PRINT 'Error: Unable to delete customer.';
        PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS VARCHAR);
        PRINT 'Error Message: ' + ERROR_MESSAGE();
    END CATCH;
END;

EXEC SP_view_customer;

EXEC SP_delete_customer 'C011';

DROP PROCEDURE SP_delete_customer;
Go
