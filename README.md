# Airline Reservation & Flight Scheduling System

## Overview

The **Airline Reservation & Flight Scheduling System** is a database-driven application developed using **Microsoft SQL Server** as part of a Database Management Systems (DBMS) project. The system is designed to manage and automate key airline operations, including passenger reservations, flight scheduling, crew assignments, luggage tracking, payment processing, and operational reporting.

This project demonstrates the practical implementation of relational database concepts, data integrity mechanisms, business rules, and SQL Server programming techniques in a real-world airline management scenario.

---

## Features

### Passenger Management

* Store passenger profiles and travel information
* Membership tiers (Regular, Silver, Gold, Platinum)
* Loyalty points tracking

### Flight Management

* Flight scheduling and route management
* Aircraft assignment
* Flight status monitoring
* Delay tracking and analysis

### Booking System

* Flight reservations and seat allocation
* Unique seat validation per flight
* Booking lifecycle management
* Automated booking reference generation

### Crew Management

* Pilot and cabin crew records
* Flight crew assignments
* Conflict detection for overlapping pilot schedules

### Payment Processing

* Multiple payment methods support
* Transaction recording and tracking
* Payment status management

### Luggage Tracking

* Luggage registration and tracking
* Status monitoring
* Location management

### Reporting & Analytics

* Most Booked Routes Report
* Revenue Per Flight Analysis
* Passenger Booking History
* Customer Segmentation
* Delayed Flight Analysis
* Staff Duty Schedules
* Luggage Tracking Reports

---

## Database Technologies Used

* Microsoft SQL Server
* T-SQL
* Stored Procedures
* Views
* Triggers
* Sequences
* Foreign Keys
* CHECK Constraints
* UNIQUE Constraints
* Data Validation Rules

---

## Database Structure

The system consists of multiple interconnected entities, including:

* Airports
* Aircraft
* Passengers
* Pilots
* Cabin Crew
* Flights
* Flight Schedules
* Flight Crew Assignments
* Ticket Bookings
* Payments
* Luggage Records
* Flight Delay Logs

These entities are linked through relational database principles to ensure data consistency and integrity.

---

## Key Business Rules Implemented

* A pilot cannot be assigned to overlapping flights.
* Each seat can only be booked once per flight.
* Departure and arrival airports must be different.
* Flight arrival time must be later than departure time.
* Payment records must always be linked to a valid booking.
* Maintenance schedules must follow logical date sequences.

---

## Stored Procedures

The project includes reusable stored procedures for:

* Flight Booking
* Booking Cancellation
* Passenger Check-In
* Crew Assignment
* Flight Delay Recording

These procedures include error handling and validation logic to maintain data accuracy.

---

## Trigger Implementation

### Prevent Pilot Double Booking

A database trigger prevents pilots from being assigned to flights scheduled within a three-hour conflict window, ensuring operational feasibility and data integrity.

---

## Reporting Views

The system includes several SQL views for business intelligence and operational monitoring:

* `vw_MostBookedRoutes`
* `vw_DelayedFlightAnalysis`
* `vw_PassengerBookingHistory`
* `vw_CustomerSegmentation`
* `vw_RevenuePerFlight`
* `vw_StaffDutySchedules`
* `vw_LuggageTrackingReport`

---

## Learning Outcomes

Through this project, we gained practical experience in:

* Database Design and Normalization
* SQL Server Development
* Business Rule Enforcement
* Data Integrity Management
* Query Optimization
* Database Reporting and Analytics
* Real-World System Modeling

---

## Future Enhancements

* Refund Management Module
* Passenger Notification System
* Audit Logging Mechanism
* Advanced Dashboard Integration
* Real-Time Flight Tracking
* Online Check-In Functionality

---

## Contributors

**Shiza Ali**
BS Data Science

**Yusra Ahmad**
BS Cyber Security

---

## Academic Project

Developed as part of the **Database Management Systems (DBMS)** course at **The University of Faisalabad**.

---

⭐ If you found this project useful, consider giving the repository a star.
