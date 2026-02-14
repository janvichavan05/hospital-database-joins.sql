-- =========================
-- CREATE TABLES
-- =========================
CREATE TABLE Doctors (
    doctor_id INT PRIMARY KEY,
    doctor_name VARCHAR(50),
    specialization VARCHAR(50),
    manager_id INT
);

CREATE TABLE Patients (
    patient_id INT PRIMARY KEY,
    patient_name VARCHAR(50),
    age INT,
    doctor_id INT
);

CREATE TABLE Appointments (
    appointment_id INT PRIMARY KEY,
    patient_id INT,
    doctor_id INT,
    date DATE
);

-- =========================
-- INSERT DATA
-- =========================
INSERT INTO Doctors VALUES
(1, 'Dr. Mehta', 'Cardiologist', NULL),
(2, 'Dr. Sharma', 'Neurologist', 1),
(3, 'Dr. Patel', 'Orthopedic', 1),
(4, 'Dr. Khan', 'Dermatologist', NULL);

INSERT INTO Patients VALUES
(101, 'Amit', 30, 1),
(102, 'Neha', 25, 2),
(103, 'Ravi', 40, NULL),
(104, 'Pooja', 35, 3);

INSERT INTO Appointments VALUES
(1001, 101, 1, '2026-02-01'),
(1002, 102, 2, '2026-02-03'),
(1003, 104, 3, '2026-02-05');

-- =========================
-- INNER JOIN
-- =========================
SELECT p.patient_name, d.doctor_name
FROM Patients p
INNER JOIN Doctors d
ON p.doctor_id = d.doctor_id;

-- =========================
-- LEFT JOIN
-- =========================
SELECT p.patient_name, d.doctor_name
FROM Patients p
LEFT JOIN Doctors d
ON p.doctor_id = d.doctor_id;

-- =========================
-- RIGHT JOIN
-- =========================
SELECT p.patient_name, d.doctor_name
FROM Patients p
RIGHT JOIN Doctors d
ON p.doctor_id = d.doctor_id;

-- =========================
-- FULL JOIN (MySQL Compatible)
-- =========================
SELECT p.patient_name, d.doctor_name
FROM Patients p
LEFT JOIN Doctors d
ON p.doctor_id = d.doctor_id

UNION

SELECT p.patient_name, d.doctor_name
FROM Patients p
RIGHT JOIN Doctors d
ON p.doctor_id = d.doctor_id;

-- =========================
-- SELF JOIN (Doctor Manager)
-- =========================
SELECT 
    d1.doctor_name AS Doctor,
    d2.doctor_name AS Manager
FROM Doctors d1
LEFT JOIN Doctors d2
ON d1.manager_id = d2.doctor_id;
