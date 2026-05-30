DROP DATABASE IF EXISTS ClinicSystem;
CREATE DATABASE ClinicSystem;
USE ClinicSystem;



CREATE TABLE Department (
    DepartmentID INT PRIMARY KEY,
    DepartmentName VARCHAR(100) NOT NULL
);

CREATE TABLE Clinic (
    ClinicID INT PRIMARY KEY,
    ClinicName VARCHAR(100) NOT NULL,
    Address VARCHAR(200),
    DepartmentID INT,
    FOREIGN KEY (DepartmentID) REFERENCES Department(DepartmentID)
);

CREATE TABLE Doctor (
    DoctorID INT PRIMARY KEY,
    DoctorName VARCHAR(100) NOT NULL,
    Phone VARCHAR(20),
    Address VARCHAR(200),
    DepartmentID INT,
    FOREIGN KEY (DepartmentID) REFERENCES Department(DepartmentID)
);

CREATE TABLE Patient (
    PatientID INT PRIMARY KEY,
    PatientName VARCHAR(100) NOT NULL,
    Phone VARCHAR(20),
    Address VARCHAR(200),
    BirthDate DATE,
    Job VARCHAR(100)
);

CREATE TABLE Appointment (
    AppointmentID INT PRIMARY KEY,
    AppointmentDate DATE,
    PatientID INT,
    DoctorID INT,
    StartTime TIME,
    EndTime TIME,
    Cost DECIMAL(10,2),
    Status VARCHAR(30),
    Diagnosis VARCHAR(200),

    FOREIGN KEY (PatientID) REFERENCES Patient(PatientID),
    FOREIGN KEY (DoctorID) REFERENCES Doctor(DoctorID)
);

DELIMITER $$

CREATE TRIGGER PreventOverlappingAppointments
BEFORE INSERT ON Appointment
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT 1
        FROM Appointment
        WHERE DoctorID = NEW.DoctorID
        AND AppointmentDate = NEW.AppointmentDate
        AND NEW.StartTime < EndTime
        AND NEW.EndTime > StartTime
    )
    THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Doctor already has an appointment at this time';
    END IF;
END$$

DELIMITER ;

INSERT INTO Department VALUES
(1,'Cardiology'),
(2,'Neurology'),
(3,'Orthopedics'),
(4,'Dermatology'),
(5,'Pediatrics'),
(6,'Oncology'),
(7,'ENT'),
(8,'Ophthalmology'),
(9,'Gastroenterology'),
(10,'Urology');



INSERT INTO Clinic VALUES
(1,'Heart Clinic','Mansoura',1),
(2,'Brain Clinic','Cairo',2),
(3,'Bone Clinic','Alexandria',3),
(4,'Skin Clinic','Tanta',4),
(5,'Kids Clinic','Zagazig',5),
(6,'Cancer Clinic','Mansoura',6),
(7,'ENT Clinic','Cairo',7),
(8,'Eye Clinic','Alexandria',8),
(9,'Digestive Clinic','Tanta',9),
(10,'Urology Clinic','Zagazig',10);



INSERT INTO Doctor VALUES
(101,'Ahmed Ali','01011111111','Mansoura',1),
(102,'Sara Mohamed','01022222222','Cairo',2),
(103,'Omar Hassan','01033333333','Alexandria',3),
(104,'Mona Youssef','01044444444','Tanta',4),
(105,'Khaled Mostafa','01055555555','Zagazig',5),
(106,'Hany Adel','01066666666','Mansoura',6),
(107,'Noha Ali','01077777777','Cairo',7),
(108,'Tamer Hassan','01088888888','Alexandria',8),
(109,'Reham Omar','01099999998','Tanta',9),
(110,'Karim Mostafa','01099999997','Zagazig',10);



INSERT INTO Patient VALUES
(1,'Mariam Ahmed','01010101010','Mansoura','2004-01-01','Student'),
(2,'Ali Mahmoud','01020202020','Cairo','2003-02-02','Engineer'),
(3,'Nour Tarek','01030303030','Alexandria','2002-03-03','Teacher'),
(4,'Youssef Ali','01040404040','Tanta','2001-04-04','Designer'),
(5,'Mona Ibrahim','01050505050','Zagazig','2000-05-05','Accountant'),
(6,'Hassan Adel','01060606060','Mansoura','1999-06-06','Student'),
(7,'Salma Tarek','01070707070','Cairo','1998-07-07','Teacher'),
(8,'Khaled Samy','01080808080','Alexandria','1997-08-08','Engineer'),
(9,'Aya Maher','01090909090','Tanta','1996-09-09','Designer'),
(10,'Nada Fathy','01101010101','Zagazig','1995-10-10','Accountant');



INSERT INTO Appointment VALUES
(1,'2025-01-15',1,101,'10:00:00','10:30:00',200,'Completed','Fatty Liver'),
(2,'2025-01-16',2,102,'11:00:00','11:30:00',250,'Completed','Migraine'),
(3,'2025-01-17',3,103,'12:00:00','12:30:00',180,'Scheduled','Back Pain'),
(4,'2025-01-18',4,104,'13:00:00','13:30:00',150,'Postponed','Skin Allergy'),
(5,'2025-01-19',5,105,'14:00:00','14:30:00',300,'Completed','Flu'),
(6,'2025-01-20',6,106,'09:00:00','09:30:00',220,'Completed','Cancer'),
(7,'2025-01-21',7,107,'10:00:00','10:30:00',180,'Scheduled','Sinusitis'),
(8,'2025-01-22',8,108,'11:00:00','11:30:00',250,'Completed','Eye Infection'),
(9,'2025-01-23',9,109,'12:00:00','12:30:00',300,'Scheduled','Gastritis'),
(10,'2025-01-24',10,110,'13:00:00','13:30:00',275,'Completed','Kidney Stones');


CREATE VIEW DoctorSchedule AS
SELECT
    d.DoctorName,
    a.AppointmentDate,
    a.StartTime,
    a.EndTime,
    a.Status
FROM Doctor d
JOIN Appointment a
ON d.DoctorID = a.DoctorID;


CREATE INDEX idx_patient ON Appointment(PatientID);
CREATE INDEX idx_doctor ON Appointment(DoctorID);
CREATE INDEX idx_date ON Appointment(AppointmentDate);



SELECT p.PatientName
FROM Patient p
JOIN Appointment a
ON p.PatientID = a.PatientID
WHERE a.Diagnosis = 'Fatty Liver'
AND a.AppointmentDate >= DATE_SUB(CURDATE(), INTERVAL 1 YEAR);


SELECT c.Address
FROM Clinic c
JOIN Department d
ON c.DepartmentID=d.DepartmentID
WHERE d.DepartmentName='Cardiology';


SELECT
p.PatientName,
SUM(a.Cost) AS TotalPaid
FROM Patient p
JOIN Appointment a
ON p.PatientID=a.PatientID
GROUP BY p.PatientID,p.PatientName;


SELECT
d.DoctorName,
COUNT(a.AppointmentID) AS AppointmentCount
FROM Doctor d
LEFT JOIN Appointment a
ON d.DoctorID=a.DoctorID
GROUP BY d.DoctorID,d.DoctorName;


SELECT COUNT(*) AS Departments FROM Department;
SELECT COUNT(*) AS Clinics FROM Clinic;
SELECT COUNT(*) AS Doctors FROM Doctor;
SELECT COUNT(*) AS Patients FROM Patient;
CREATE VIEW PatientAppointments AS
SELECT
p.PatientName,
d.DoctorName,
a.AppointmentDate,
a.Status
FROM Patient p
JOIN Appointment a
ON p.PatientID = a.PatientID
JOIN Doctor d
ON a.DoctorID = d.DoctorID;
SELECT SUM(Cost) AS TotalPaid
FROM Appointment
WHERE PatientID = 1
AND AppointmentDate >= DATE_SUB(CURDATE(), INTERVAL 3 YEAR);
SELECT COUNT(*) AS Appointments FROM Appointment;
CREATE VIEW DepartmentDoctors AS
SELECT
d.DepartmentName,
dr.DoctorName
FROM Department d
JOIN Doctor dr
ON d.DepartmentID = dr.DepartmentID;
SELECT
d.DepartmentName,
COUNT(a.AppointmentID) AS TotalAppointments,
SUM(a.Cost) AS TotalRevenue
FROM Department d
JOIN Doctor dr
ON d.DepartmentID = dr.DepartmentID
JOIN Appointment a
ON dr.DoctorID = a.DoctorID
GROUP BY d.DepartmentName;
SELECT
p.PatientName,
d.DoctorName,
a.AppointmentDate
FROM Appointment a
JOIN Patient p
ON a.PatientID = p.PatientID
JOIN Doctor d
ON a.DoctorID = d.DoctorID
WHERE a.AppointmentDate >= CURDATE();