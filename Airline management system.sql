
-- AIRLINE RESERVATION AND FLIGHT SCHEDULING SYSTEM

-- DATABASE CREATION
IF EXISTS (SELECT * FROM sys.databases WHERE name = 'AirlineReservationDB')
BEGIN
    ALTER DATABASE AirlineReservationDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE AirlineReservationDB;
END
GO
CREATE DATABASE AirlineReservationDB;
GO
USE AirlineReservationDB;
GO

-- AIRPORTS TABLE
CREATE TABLE Airport (
    AirportID INT PRIMARY KEY IDENTITY(1,1),
    AirportCode CHAR(3) UNIQUE NOT NULL,
    AirportName NVARCHAR(100) NOT NULL,
    City NVARCHAR(50) NOT NULL,
    Country NVARCHAR(50) NOT NULL,
    TimeZone NVARCHAR(50) NOT NULL,
    OperatingStatus NVARCHAR(20) DEFAULT 'Active'
        CHECK (OperatingStatus IN ('Active','Closed','Maintenance'))
);
GO

-- AIRCRAFT TABLE
CREATE TABLE Aircraft (
    AircraftID INT PRIMARY KEY IDENTITY(1,1),
    AircraftRegistration NVARCHAR(20) UNIQUE NOT NULL,
    AircraftType NVARCHAR(50) NOT NULL,
    ManufacturerName NVARCHAR(50) NOT NULL,
    TotalSeatsEconomy INT NOT NULL,
    TotalSeatsBusiness INT NOT NULL,
    MaintenanceStatus NVARCHAR(20) DEFAULT 'Operational'
        CHECK (MaintenanceStatus IN ('Operational','Maintenance','Out of Service')),
    LastMaintenanceDate DATE,
    NextScheduledMaintenance DATE,
    CONSTRAINT chk_maintenance_dates
    CHECK (
        NextScheduledMaintenance IS NULL
        OR LastMaintenanceDate IS NULL
        OR NextScheduledMaintenance > LastMaintenanceDate
    )
);
GO

-- PASSENGERS TABLE
CREATE TABLE Passengers (
    PassengerID INT PRIMARY KEY IDENTITY(1,1),
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    PassportNumber NVARCHAR(20) UNIQUE NOT NULL,
    DateOfBirth DATE NOT NULL,
    Gender CHAR(1)
        CHECK (Gender IN ('M','F','O')),
    EmailAddress NVARCHAR(100) UNIQUE NOT NULL
        CHECK (EmailAddress LIKE '%@%.%'),
    PhoneNumber NVARCHAR(20),
    Nationality NVARCHAR(50),
    MembershipStatus NVARCHAR(20) DEFAULT 'Regular'
        CHECK (MembershipStatus IN ('Regular','Silver','Gold','Platinum')),
    MembershipPoints INT DEFAULT 0
);
GO

-- PILOTS TABLE
    Create table Pilot (
    PilotID INT PRIMARY KEY IDENTITY(1,1),
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    EmployeeID NVARCHAR(20) UNIQUE NOT NULL,
    LicenseNumber NVARCHAR(30) UNIQUE NOT NULL,
    LicenseExpiryDate DATE NOT NULL,
    PilotRating NVARCHAR(50),
    TotalFlightHours INT DEFAULT 0,
    EmploymentStatus NVARCHAR(20) DEFAULT 'Active'
        CHECK (EmploymentStatus IN ('Active','On Leave','Inactive'))
);
GO

-- CABIN CREW TABLE
CREATE TABLE CabinCrew (
    CrewID INT PRIMARY KEY IDENTITY(1,1),
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    EmployeeID NVARCHAR(20) UNIQUE NOT NULL,
    Position NVARCHAR(50),
    LanguagesSpoken NVARCHAR(100),
    SafetyCertificationExpiry DATE,
    EmploymentStatus NVARCHAR(20) DEFAULT 'Active'
        CHECK (EmploymentStatus IN ('Active','On Leave','Inactive'))
);
GO

-- FLIGHTS TABLE
CREATE TABLE Flight (
    FlightID INT PRIMARY KEY IDENTITY(1,1),
    FlightNumber NVARCHAR(10) UNIQUE NOT NULL,
    DepartureAirportID INT NOT NULL,
    ArrivalAirportID INT NOT NULL,
    AircraftID INT NOT NULL,
    FlightDistance INT,
    FlightDuration INT,
    FlightStatus NVARCHAR(20) DEFAULT 'Scheduled'
        CHECK (FlightStatus IN ('Scheduled','Delayed','Cancelled','Departed','Landed')),
    ScheduledDepartureTime DATETIME NOT NULL,
    ScheduledArrivalTime DATETIME NOT NULL,
    ActualDepartureTime DATETIME,
    ActualArrivalTime DATETIME,
    DelayReason NVARCHAR(200),

    FOREIGN KEY (DepartureAirportID) REFERENCES Airport(AirportID),
    FOREIGN KEY (ArrivalAirportID) REFERENCES Airport(AirportID),
    FOREIGN KEY (AircraftID) REFERENCES Aircraft(AircraftID),

    CONSTRAINT chk_different_airports
    CHECK (DepartureAirportID <> ArrivalAirportID),

    CONSTRAINT chk_arrival_after_departure
    CHECK (ScheduledArrivalTime > ScheduledDepartureTime)
);
GO

-- FLIGHT SCHEDULES TABLE
CREATE TABLE FlightSchedules (
    ScheduleID INT PRIMARY KEY IDENTITY(1,1),
    FlightNumber NVARCHAR(10) NOT NULL,
    DepartureAirportID INT NOT NULL,
    ArrivalAirportID INT NOT NULL,
    ScheduledDepartureTime TIME NOT NULL,
    ScheduledArrivalTime TIME NOT NULL,
    DaysOfWeek NVARCHAR(50) NOT NULL,
    EconomyBaseFare DECIMAL(10,2) NOT NULL,
    BusinessBaseFare DECIMAL(10,2) NOT NULL,

    FOREIGN KEY (DepartureAirportID) REFERENCES Airport(AirportID),
    FOREIGN KEY (ArrivalAirportID) REFERENCES Airport(AirportID)
);
GO

-- FLIGHT CREW ASSIGNMENT TABLE
CREATE TABLE FlightCrewAssignments (
    AssignmentID INT PRIMARY KEY IDENTITY(1,1),
    FlightID INT NOT NULL,
    PilotID INT NULL,
    CrewID INT NULL,
    Role NVARCHAR(50),
    AssignmentStatus NVARCHAR(20) DEFAULT 'Assigned'
        CHECK (AssignmentStatus IN ('Assigned','Cancelled')),

    FOREIGN KEY (FlightID) REFERENCES Flight(FlightID),
    FOREIGN KEY (PilotID) REFERENCES Pilot(PilotID),
    FOREIGN KEY (CrewID) REFERENCES CabinCrew(CrewID),

    CONSTRAINT chk_staff_assignment
    CHECK (
        (PilotID IS NOT NULL AND CrewID IS NULL)
        OR
        (PilotID IS NULL AND CrewID IS NOT NULL)
    )
);
GO

-- TICKET BOOKINGS TABLE
CREATE TABLE TicketBookings (
    BookingID INT PRIMARY KEY IDENTITY(1,1),
    BookingReference NVARCHAR(20) UNIQUE NOT NULL,
    PassengerID INT NOT NULL,
    FlightID INT NOT NULL,
    SeatNumber NVARCHAR(5) NOT NULL
        CHECK (SeatNumber LIKE '[A-Z][0-9]%'),
    SeatClass NVARCHAR(20)
        CHECK (SeatClass IN ('Economy','Business')),
    BookingStatus NVARCHAR(20) DEFAULT 'Confirmed'
        CHECK (BookingStatus IN ('Confirmed','Checked In','Cancelled','Boarded')),
    BookingDate DATETIME DEFAULT GETDATE(),
    TicketPrice DECIMAL(10,2) NOT NULL,
    DiscountApplied DECIMAL(10,2) DEFAULT 0,
    FinalPrice DECIMAL(10,2) NOT NULL,
    SpecialRequests NVARCHAR(200),

    FOREIGN KEY (PassengerID) REFERENCES Passengers(PassengerID),
    FOREIGN KEY (FlightID) REFERENCES Flight(FlightID),

    CONSTRAINT uq_flight_seat UNIQUE (FlightID, SeatNumber)
);
GO

-- LUGGAGE RECORDS TABLE
CREATE TABLE LuggageRecords (
    LuggageID INT PRIMARY KEY IDENTITY(1,1),
    BookingID INT NOT NULL,
    LuggageTag NVARCHAR(20) UNIQUE NOT NULL,
    Weight DECIMAL(10,2),
    LuggageType NVARCHAR(50)
        CHECK (LuggageType IN ('Checked Baggage','Carry-On')),
    Status NVARCHAR(20)
        CHECK (Status IN ('Pending','Loaded','Delivered','Lost')),
    CurrentLocation NVARCHAR(100),

    FOREIGN KEY (BookingID) REFERENCES TicketBookings(BookingID)
);
GO

-- PAYMENTS TABLE
CREATE TABLE Payments (
    PaymentID INT PRIMARY KEY IDENTITY(1,1),
    BookingID INT NOT NULL,
    PaymentAmount DECIMAL(10,2) NOT NULL,
    PaymentDate DATETIME DEFAULT GETDATE(),
    PaymentMethod NVARCHAR(50)
        CHECK (PaymentMethod IN ('Credit Card','Debit Card','Cash','Bank Transfer','Mobile Payment','Refund')),
    PaymentStatus NVARCHAR(20)
        CHECK (PaymentStatus IN ('Completed','Pending','Refunded','Failed')),
    TransactionID NVARCHAR(50) UNIQUE,

    FOREIGN KEY (BookingID) REFERENCES TicketBookings(BookingID)
);
GO

-- FLIGHT DELAY LOG TABLE
CREATE TABLE FlightDelayLog (
    DelayLogID INT PRIMARY KEY IDENTITY(1,1),
    FlightID INT NOT NULL,
    DelayMinutes INT NOT NULL,
    DelayReason NVARCHAR(200),
    ReportedTime DATETIME DEFAULT GETDATE(),

    FOREIGN KEY (FlightID) REFERENCES Flight(FlightID)
);
GO

-- SEQUENCE
CREATE SEQUENCE seq_booking_ref
START WITH 1
INCREMENT BY 1;
GO

-- INSERT AIRPORTS
INSERT INTO Airport VALUES
('LAX','Los Angeles International','Los Angeles','USA','PST','Active'),
('JFK','John F Kennedy International','New York','USA','EST','Active'),
('LHR','Heathrow Airport','London','UK','GMT','Active'),
('DXB','Dubai International','Dubai','UAE','GST','Active'),
('CDG','Charles de Gaulle','Paris','France','CET','Active'),
('NRT','Narita International','Tokyo','Japan','JST','Active'),
('FRA','Frankfurt Airport','Frankfurt','Germany','CET','Active'),
('SIN','Singapore Changi','Singapore','Singapore','SGT','Active'),
('IST','Istanbul Airport','Istanbul','Turkey','TRT','Active'),
('YYZ','Toronto Pearson','Toronto','Canada','EST','Active');
GO

-- INSERT AIRCRAFT
INSERT INTO Aircraft VALUES
('REG101','Boeing 737','Boeing',180,20,'Operational','2025-01-10','2025-07-10'),
('REG102','Airbus A320','Airbus',170,18,'Operational','2025-02-10','2025-08-10'),
('REG103','Boeing 777','Boeing',300,50,'Operational','2025-01-15','2025-07-15'),
('REG104','Airbus A380','Airbus',450,80,'Operational','2025-03-01','2025-09-01'),
('REG105','Boeing 787','Boeing',250,40,'Operational','2025-02-20','2025-08-20'),
('REG106','Airbus A350','Airbus',280,45,'Operational','2025-01-30','2025-07-30'),
('REG107','Boeing 747','Boeing',350,60,'Operational','2025-02-12','2025-08-12'),
('REG108','Embraer E190','Embraer',90,10,'Operational','2025-03-15','2025-09-15'),
('REG109','ATR 72','ATR',70,5,'Operational','2025-01-25','2025-07-25'),
('REG110','Airbus A321','Airbus',200,25,'Operational','2025-02-18','2025-08-18');
GO

-- INSERT PASSENGERS
INSERT INTO Passengers VALUES
('John','Smith','P1001','1990-05-12','M','john@gmail.com','111111111','USA','Gold',500),
('Maria','Garcia','P1002','1992-03-10','F','maria@gmail.com','222222222','Spain','Silver',300),
('Ahmed','Ali','P1003','1988-07-14','M','ahmed@gmail.com','333333333','Pakistan','Regular',100),
('Lisa','Chen','P1004','1995-08-20','F','lisa@gmail.com','444444444','China','Platinum',1000),
('James','Brown','P1005','1985-11-11','M','james@gmail.com','555555555','UK','Gold',600),
('Emma','Wilson','P1006','1993-06-22','F','emma@gmail.com','666666666','Canada','Silver',350),
('Michael','Lee','P1007','1989-02-15','M','michael@gmail.com','777777777','USA','Regular',120),
('Sophia','Martin','P1008','1996-01-18','F','sophia@gmail.com','888888888','France','Gold',700),
('David','Miller','P1009','1984-04-30','M','david@gmail.com','999999999','Germany','Regular',90),
('Yuki','Tanaka','P1010','1991-12-25','F','yuki@gmail.com','123456789','Japan','Silver',250);
GO

-- INSERT PILOTS
INSERT INTO Pilot VALUES
('Robert','Davis','PL001','LIC001','2027-12-31','Captain',12000,'Active'),
('Sarah','Miller','PL002','LIC002','2028-01-20','Captain',10000,'Active'),
('David','Taylor','PL003','LIC003','2027-11-15','First Officer',8000,'Active'),
('Jessica','Anderson','PL004','LIC004','2029-03-10','Captain',15000,'Active'),
('Christopher','Martin','PL005','LIC005','2027-06-30','First Officer',7000,'Active'),
('Daniel','White','PL006','LIC006','2028-05-20','Captain',11000,'Active'),
('Kevin','Scott','PL007','LIC007','2027-09-18','First Officer',6500,'Active'),
('Andrew','Walker','PL008','LIC008','2029-01-01','Captain',16000,'Active'),
('Brian','Young','PL009','LIC009','2028-08-12','First Officer',6000,'Active'),
('Thomas','Hall','PL010','LIC010','2027-10-10','Captain',13000,'Active');
GO

-- INSERT CABIN CREW
INSERT INTO CabinCrew VALUES
('Amanda','Thomas','CC001','Flight Attendant','English,Spanish','2027-06-15','Active'),
('Kevin','White','CC002','Flight Attendant','English,German','2027-01-10','Active'),
('Rachel','Green','CC003','Purser','English,French','2028-05-20','Active'),
('Daniel','Park','CC004','Flight Attendant','English,Korean','2027-11-30','Active'),
('Isabella','Romano','CC005','Flight Attendant','Italian,English','2028-08-15','Active'),
('Thomas','Wright','CC006','Purser','English,Dutch','2027-03-25','Active'),
('Sophia','Clark','CC007','Flight Attendant','English,Arabic','2028-07-19','Active'),
('Mia','Lewis','CC008','Flight Attendant','English,Japanese','2027-09-12','Active'),
('Olivia','Walker','CC009','Purser','English,Turkish','2028-02-28','Active'),
('Lucas','Allen','CC010','Flight Attendant','English,Chinese','2027-12-01','Active');
GO

-- INSERT FLIGHT SCHEDULES
INSERT INTO FlightSchedules VALUES
('AA101',1,2,'08:00','16:00','Monday,Wednesday',300,700),
('BA202',3,4,'09:00','17:00','Tuesday,Thursday',450,900),
('CA303',5,6,'10:00','18:00','Friday',350,800),
('DA404',7,8,'06:00','12:00','Daily',280,650),
('EA505',9,10,'13:00','20:00','Saturday',500,1000),
('FA606',2,1,'15:00','23:00','Sunday',320,720),
('GA707',4,3,'11:00','19:00','Daily',420,850),
('HA808',6,5,'05:00','13:00','Monday',390,790),
('IA909',8,7,'07:00','15:00','Tuesday',360,760),
('JA010',10,9,'14:00','22:00','Friday',410,820);
GO

-- INSERT FLIGHTS
INSERT INTO Flight VALUES
('AA101',1,2,1,2500,480,'Scheduled','2026-06-01 08:00','2026-06-01 16:00',NULL,NULL,NULL),
('BA202',3,4,2,3500,500,'Scheduled','2026-06-02 09:00','2026-06-02 17:00',NULL,NULL,NULL),
('CA303',5,6,3,4500,600,'Scheduled','2026-06-03 10:00','2026-06-03 18:00',NULL,NULL,NULL),
('DA404',7,8,4,2800,420,'Scheduled','2026-06-04 06:00','2026-06-04 12:00',NULL,NULL,NULL),
('EA505',9,10,5,5000,540,'Scheduled','2026-06-05 13:00','2026-06-05 20:00',NULL,NULL,NULL),
('FA606',2,1,6,2600,480,'Scheduled','2026-06-06 15:00','2026-06-06 23:00',NULL,NULL,NULL),
('GA707',4,3,7,3900,500,'Scheduled','2026-06-07 11:00','2026-06-07 19:00',NULL,NULL,NULL),
('HA808',6,5,8,3100,470,'Scheduled','2026-06-08 05:00','2026-06-08 13:00',NULL,NULL,NULL),
('IA909',8,7,9,2000,450,'Scheduled','2026-06-09 07:00','2026-06-09 15:00',NULL,NULL,NULL),
('JA010',10,9,10,4200,530,'Scheduled','2026-06-10 14:00','2026-06-10 22:00',NULL,NULL,NULL);
GO

-- INSERT CREW ASSIGNMENTS
INSERT INTO FlightCrewAssignments VALUES
(1,1,NULL,'Captain','Assigned'),
(2,2,NULL,'Captain','Assigned'),
(3,3,NULL,'First Officer','Assigned'),
(4,4,NULL,'Captain','Assigned'),
(5,5,NULL,'First Officer','Assigned'),
(6,NULL,1,'Flight Attendant','Assigned'),
(7,NULL,2,'Flight Attendant','Assigned'),
(8,NULL,3,'Purser','Assigned'),
(9,NULL,4,'Flight Attendant','Assigned'),
(10,NULL,5,'Flight Attendant','Assigned');
GO

-- INSERT BOOKINGS
INSERT INTO TicketBookings VALUES
('BK1001',1,1,'A1','Economy','Confirmed',GETDATE(),300,0,300,'Vegetarian Meal'),
('BK1002',2,2,'A2','Business','Checked In',GETDATE(),700,50,650,'Window Seat'),
('BK1003',3,3,'A3','Economy','Confirmed',GETDATE(),320,20,300,NULL),
('BK1004',4,4,'A4','Business','Boarded',GETDATE(),850,50,800,NULL),
('BK1005',5,5,'A5','Economy','Confirmed',GETDATE(),400,0,400,'Extra Legroom'),
('BK1006',6,6,'A6','Economy','Checked In',GETDATE(),350,10,340,NULL),
('BK1007',7,7,'A7','Business','Confirmed',GETDATE(),900,100,800,NULL),
('BK1008',8,8,'A8','Economy','Confirmed',GETDATE(),310,10,300,NULL),
('BK1009',9,9,'A9','Economy','Boarded',GETDATE(),360,20,340,NULL),
('BK1010',10,10,'B1','Business','Confirmed',GETDATE(),950,100,850,NULL);
GO

-- INSERT LUGGAGE RECORDS
INSERT INTO LuggageRecords VALUES
(1,'LUG1001',20,'Checked Baggage','Pending','LAX Terminal'),
(2,'LUG1002',15,'Carry-On','Loaded','JFK Gate A'),
(3,'LUG1003',18,'Checked Baggage','Pending','CDG Counter'),
(4,'LUG1004',25,'Checked Baggage','Loaded','DXB Cargo'),
(5,'LUG1005',12,'Carry-On','Delivered','NRT Arrival'),
(6,'LUG1006',16,'Checked Baggage','Pending','FRA Counter'),
(7,'LUG1007',19,'Checked Baggage','Loaded','SIN Cargo'),
(8,'LUG1008',14,'Carry-On','Delivered','IST Arrival'),
(9,'LUG1009',22,'Checked Baggage','Pending','YYZ Counter'),
(10,'LUG1010',17,'Carry-On','Loaded','LHR Gate');
GO

-- INSERT PAYMENTS
INSERT INTO Payments VALUES
(1,300,GETDATE(),'Credit Card','Completed','TXN1001'),
(2,650,GETDATE(),'Debit Card','Completed','TXN1002'),
(3,300,GETDATE(),'Cash','Completed','TXN1003'),
(4,800,GETDATE(),'Bank Transfer','Completed','TXN1004'),
(5,400,GETDATE(),'Mobile Payment','Completed','TXN1005'),
(6,340,GETDATE(),'Credit Card','Completed','TXN1006'),
(7,800,GETDATE(),'Debit Card','Completed','TXN1007'),
(8,300,GETDATE(),'Cash','Completed','TXN1008'),
(9,340,GETDATE(),'Credit Card','Completed','TXN1009'),
(10,850,GETDATE(),'Bank Transfer','Completed','TXN1010');
GO

-- INSERT DELAY LOGS
INSERT INTO FlightDelayLog VALUES
(1,30,'Bad Weather',GETDATE()),
(2,15,'Technical Issue',GETDATE()),
(3,45,'Air Traffic',GETDATE()),
(4,20,'Late Crew',GETDATE()),
(5,10,'Fuel Delay',GETDATE()),
(6,25,'Security Check',GETDATE()),
(7,40,'Heavy Rain',GETDATE()),
(8,18,'Boarding Delay',GETDATE()),
(9,35,'Maintenance',GETDATE()),
(10,12,'Operational Delay',GETDATE());
GO


-- STORED PROCEDURE: BOOK FLIGHT
CREATE PROCEDURE sp_BookFlight
    @PassengerID INT,
    @FlightID INT,
    @SeatNumber NVARCHAR(5),
    @SeatClass NVARCHAR(20),
    @TicketPrice DECIMAL(10,2),
    @SpecialRequests NVARCHAR(200) = NULL
AS
BEGIN
    BEGIN TRY
        IF EXISTS (
            SELECT 1
            FROM TicketBookings
            WHERE FlightID = @FlightID
            AND SeatNumber = @SeatNumber
            AND BookingStatus != 'Cancelled'
        )
        BEGIN
            RAISERROR('Seat already booked',16,1);
            RETURN;
        END

        INSERT INTO TicketBookings
        (
            BookingReference,
            PassengerID,
            FlightID,
            SeatNumber,
            SeatClass,
            TicketPrice,
            FinalPrice,
            SpecialRequests
        )
        VALUES
        (
            'BK' + CAST(NEXT VALUE FOR seq_booking_ref AS NVARCHAR(10)),
            @PassengerID,
            @FlightID,
            @SeatNumber,
            @SeatClass,
            @TicketPrice,
            @TicketPrice,
            @SpecialRequests
        );

        PRINT 'Flight booked successfully';

    END TRY

    BEGIN CATCH
        PRINT ERROR_MESSAGE();
    END CATCH
END
GO

-- STORED PROCEDURE: CANCEL BOOKING
CREATE PROCEDURE sp_CancelBooking
    @BookingID INT
AS
BEGIN
    BEGIN TRY

        UPDATE TicketBookings
        SET BookingStatus = 'Cancelled'
        WHERE BookingID = @BookingID;

        PRINT 'Booking cancelled successfully';

    END TRY

    BEGIN CATCH
        PRINT ERROR_MESSAGE();
    END CATCH
END
GO

-- STORED PROCEDURE: ASSIGN CREW
CREATE PROCEDURE sp_AssignCrewToFlight
    @FlightID INT,
    @PilotID INT = NULL,
    @CrewID INT = NULL,
    @Role NVARCHAR(50)
AS
BEGIN
    BEGIN TRY
        DECLARE @FlightDateTime DATETIME;

        SELECT @FlightDateTime = ScheduledDepartureTime
        FROM Flight
        WHERE FlightID = @FlightID;

        IF @PilotID IS NOT NULL
        BEGIN
            IF EXISTS (
                SELECT 1
                FROM FlightCrewAssignments fca
                INNER JOIN Flights f
                ON fca.FlightID = f.FlightID
                WHERE fca.PilotID = @PilotID
                AND ABS(DATEDIFF(MINUTE, f.ScheduledDepartureTime, @FlightDateTime)) < 180
            )
            BEGIN
                RAISERROR('Pilot already assigned nearby time',16,1);
                RETURN;
            END
        END

        INSERT INTO FlightCrewAssignments
        (FlightID, PilotID, CrewID, Role)
        VALUES
        (@FlightID, @PilotID, @CrewID, @Role);

        PRINT 'Crew assigned successfully';

    END TRY

    BEGIN CATCH
        PRINT ERROR_MESSAGE();
    END CATCH
END
GO

-- STORED PROCEDURE: CHECK IN PASSENGER
CREATE PROCEDURE sp_CheckInPassenger
    @BookingID INT
AS
BEGIN
    BEGIN TRY
        UPDATE TicketBookings
        SET BookingStatus = 'Checked In'
        WHERE BookingID = @BookingID;
        PRINT 'Passenger checked in';
    END TRY
    BEGIN CATCH
        PRINT ERROR_MESSAGE();
    END CATCH
END
GO

-- STORED PROCEDURE: RECORD FLIGHT DELAY
CREATE PROCEDURE sp_RecordFlightDelay
    @FlightID INT,
    @DelayMinutes INT,
    @DelayReason NVARCHAR(200)
AS
BEGIN
    BEGIN TRY
        UPDATE Flight
        SET FlightStatus = 'Delayed',
            DelayReason = @DelayReason
        WHERE FlightID = @FlightID;

        INSERT INTO FlightDelayLog
        (FlightID, DelayMinutes, DelayReason)
        VALUES
        (@FlightID, @DelayMinutes, @DelayReason);

        PRINT 'Delay recorded';
    END TRY
    BEGIN CATCH
        PRINT ERROR_MESSAGE();
    END CATCH
END
GO

-- VIEW: MOST BOOKED ROUTES
CREATE VIEW vw_MostBookedRoutes AS
SELECT
    a1.AirportCode AS DepartureAirport,
    a2.AirportCode AS ArrivalAirport,
    COUNT(tb.BookingID) AS TotalBookings
FROM Flight f
INNER JOIN Airport a1
ON f.DepartureAirportID = a1.AirportID
INNER JOIN Airport a2
ON f.ArrivalAirportID = a2.AirportID
LEFT JOIN TicketBookings tb
ON f.FlightID = tb.FlightID
GROUP BY a1.AirportCode, a2.AirportCode;
GO

-- VIEW: DELAYED FLIGHT ANALYSIS
CREATE VIEW vw_DelayedFlightAnalysis AS
SELECT
    f.FlightNumber,
    f.FlightStatus,
    f.DelayReason,
    d.DelayMinutes,
    d.ReportedTime
FROM Flight f
INNER JOIN FlightDelayLog d
ON f.FlightID = d.FlightID;
GO

-- VIEW: PASSENGER BOOKING HISTORY
CREATE VIEW vw_PassengerBookingHistory AS
SELECT
    p.PassengerID,
    p.FirstName + ' ' + p.LastName AS PassengerName,
    COUNT(tb.BookingID) AS TotalBookings,
    SUM(tb.FinalPrice) AS TotalSpent
FROM Passengers p
LEFT JOIN TicketBookings tb
ON p.PassengerID = tb.PassengerID
GROUP BY p.PassengerID, p.FirstName, p.LastName;
GO

-- VIEW: STAFF DUTY SCHEDULES
CREATE VIEW vw_StaffDutySchedules AS
SELECT
    f.FlightNumber,
    p.FirstName + ' ' + p.LastName AS PilotName,
    cc.FirstName + ' ' + cc.LastName AS CrewName,
    fca.Role,
    f.ScheduledDepartureTime
FROM FlightCrewAssignments fca
INNER JOIN Flight f
ON fca.FlightID = f.FlightID
LEFT JOIN Pilot p
ON fca.PilotID = p.PilotID
LEFT JOIN CabinCrew cc
ON fca.CrewID = cc.CrewID;
GO

-- VIEW: Customer Segmentation
CREATE VIEW vw_CustomerSegmentation AS
SELECT 
    p.PassengerID,

    p.FirstName + ' ' + p.LastName AS PassengerName,

    p.MembershipStatus,

    COUNT(tb.BookingID) AS TotalBookings,

    ISNULL(SUM(tb.FinalPrice),0) AS LifetimeValue,

    MAX(tb.BookingDate) AS LastBookingDate,

    CASE
        WHEN ISNULL(SUM(tb.FinalPrice),0) >= 5000 THEN 'VIP'

        WHEN ISNULL(SUM(tb.FinalPrice),0) >= 2000 THEN 'Regular'

        ELSE 'Normal'
    END AS CustomerSegment

FROM Passengers p

LEFT JOIN TicketBookings tb
    ON p.PassengerID = tb.PassengerID

GROUP BY
    p.PassengerID,
    p.FirstName,
    p.LastName,
    p.MembershipStatus;
GO

-- VIEW: REVENUE PER FLIGHT
CREATE VIEW vw_RevenuePerFlight AS
SELECT
    f.FlightNumber,
    COUNT(tb.BookingID) AS TotalPassengers,
    SUM(tb.FinalPrice) AS TotalRevenue
FROM Flight f
LEFT JOIN TicketBookings tb
ON f.FlightID = tb.FlightID
GROUP BY f.FlightNumber;
GO

-- VIEW: LUGGAGE TRACKING REPORT
CREATE VIEW vw_LuggageTrackingReport AS
SELECT
    lr.LuggageTag,
    p.FirstName + ' ' + p.LastName AS PassengerName,
    f.FlightNumber,
    lr.Weight,
    lr.Status,
    lr.CurrentLocation
FROM LuggageRecords lr
INNER JOIN TicketBookings tb
ON lr.BookingID = tb.BookingID
INNER JOIN Passengers p
ON tb.PassengerID = p.PassengerID
INNER JOIN Flight f
ON tb.FlightID = f.FlightID;
GO

-- TRIGGER TO PREVENT DOUBLE BOOKING OF PILOT
CREATE TRIGGER tr_PreventPilotDoubleBooking
ON FlightCrewAssignments
AFTER INSERT
AS
BEGIN

    IF EXISTS (
        SELECT 1
        FROM inserted i
        INNER JOIN FlightCrewAssignments fca
        ON i.PilotID = fca.PilotID
        AND i.AssignmentID != fca.AssignmentID
        INNER JOIN Flight f1
        ON i.FlightID = f1.FlightID
        INNER JOIN Flight f2
        ON fca.FlightID = f2.FlightID
        WHERE ABS(DATEDIFF(MINUTE,
            f1.ScheduledDepartureTime,
            f2.ScheduledDepartureTime)) < 180
    )
    BEGIN
        RAISERROR('Pilot already assigned nearby flight timing',16,1);
        ROLLBACK TRANSACTION;
    END
END
GO
PRINT '=========================================';
PRINT 'AIRLINE DATABASE PROJECT CREATED SUCCESSFULLY';
PRINT '=========================================';

--Show Table Data

SELECT * FROM Passengers;
SELECT * FROM Flight;
SELECT * FROM TicketBookings;
SELECT * FROM Payments;

--Show Advanced Reports

--A. Most Booked Routes
SELECT * FROM vw_MostBookedRoutes;
--B. Delayed Flight Analysis
SELECT * FROM vw_DelayedFlightAnalysis;
--C. Passenger Booking History
SELECT * FROM vw_PassengerBookingHistory;
--D. Staff Duty Schedules
SELECT * FROM vw_StaffDutySchedules;
--E. Revenue Per Flight
SELECT * FROM vw_RevenuePerFlight;
--F. Luggage Tracking Report
SELECT * FROM vw_LuggageTrackingReport;

SELECT name
FROM sys.views;

SELECT * FROM sys.procedures;

-- 5 MOST HIGEST GENERATED REVENUES PER FLIGHT
SELECT TOP 5 *
FROM vw_RevenuePerFlight
ORDER BY TotalRevenue DESC;

-- VIP CUSTOMERS
SELECT *
FROM vw_CustomerSegmentation
WHERE CustomerSegment = 'VIP';

PRINT '===== PASSENGER DETAILS =====';

SELECT PassengerID,
       FirstName + ' ' + LastName AS PassengerName,
       MembershipStatus
FROM Passengers;