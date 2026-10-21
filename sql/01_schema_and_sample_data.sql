/* Creating the Database called "neurology_clinic_emr_system" */

CREATE database neurology_clinic_emr_system;

/* Making neurology_clinic_emr_system has the Default database */

USE neurology_clinic_emr_system;

/* Creating the Patient_details Table */

CREATE TABLE Patient_details (
    patientID INT PRIMARY KEY,
    firstName VARCHAR(50) NOT NULL,
    lastName VARCHAR(50) NOT NULL,
    age INT NOT NULL,
    address VARCHAR(100),
    phone VARCHAR(20) NOT NULL,
    insurance VARCHAR(50) NOT NULL,
    sex VARCHAR(50) NOT NULL,
    nationality VARCHAR(50) NOT NULL,
    weight VARCHAR(50),
    height VARCHAR(50)
    
);

/* Creating the Doctor_details Table */

CREATE TABLE Doctor_details (
    doctorID INT PRIMARY KEY,
    firstName VARCHAR(50) NOT NULL,
    lastName VARCHAR(50) NOT NULL,
    department VARCHAR(50) NOT NULL,
    specialty VARCHAR(50) NOT NULL,
    experience VARCHAR(50) NOT NULL,
    no_of_surgeries_performed INT,
    phone VARCHAR(20) NOT NULL
);

/* Creating the Appointment_details Table */

CREATE TABLE Appointment_details (
    appointmentID INT PRIMARY KEY,
    appointmentDate DATETIME NOT NULL,
    reason VARCHAR(200),
    patientID INT NOT NULL,
    doctorID INT NOT NULL,
    CONSTRAINT fk_appt_patient
        FOREIGN KEY (patientID)
        REFERENCES Patient_details(patientID),
    CONSTRAINT fk_appt_doctor
        FOREIGN KEY (doctorID)
        REFERENCES Doctor_details(doctorID)
);

/* Creating the Diagnosis_details Table */

CREATE TABLE Diagnosis_details (
    diagnosisID INT PRIMARY KEY,
    diagnosisName VARCHAR(100) NOT NULL,
    cause VARCHAR(100),
    duration_of_the_problem VARCHAR(100)

);

/* Creating the Visit_details Table */

CREATE TABLE Visit_details (
    visitID INT PRIMARY KEY,
    visitDate DATETIME NOT NULL,
    notes TEXT,
    patientID INT NOT NULL,
    doctorID INT NOT NULL,
    CONSTRAINT fk_visit_patient
        FOREIGN KEY (patientID)
        REFERENCES Patient_details(patientID),
    CONSTRAINT fk_visit_doctor
        FOREIGN KEY (doctorID)
        REFERENCES Doctor_details(doctorID)
);

/* Creating the VisitDiagnosis_details Table */

CREATE TABLE VisitDiagnosis_details (
    visitID INT NOT NULL,
    diagnosisID INT NOT NULL,
    CONSTRAINT pk_visit_diagnosis PRIMARY KEY (visitID, diagnosisID),
    CONSTRAINT fk_vd_visit
        FOREIGN KEY (visitID)
        REFERENCES Visit_details(visitID),
    CONSTRAINT fk_vd_diagnosis
        FOREIGN KEY (diagnosisID)
        REFERENCES Diagnosis_details(diagnosisID)
);

/* Creating the Prescription_and_outcome Table */

CREATE TABLE Prescription_and_outcome (
    prescriptionID INT PRIMARY KEY,
    medicationName VARCHAR(100) NOT NULL,
    dosage VARCHAR(50),
    startDate DATE,
    endDate DATE,
    visitID INT NOT NULL,
    CONSTRAINT fk_prescription_visit
        FOREIGN KEY (visitID)
        REFERENCES Visit_details(visitID)
);

/* Inserting the Sample Values into Patient_details Table */

INSERT INTO Patient_details 
    (patientID, firstName, lastName, age, address, phone, insurance, sex, nationality, weight, height)
VALUES
    (1, 'John', 'Doe', 30, '123 Main Street', '555-123-4567', 'GoodHealth Insurance', 'Male', 'American', '72 kg', '180 cm'),
    (2, 'Jane', 'Smith', 25, '456 Park Avenue', '555-987-6543', 'CarePlus Insurance', 'Female', 'British', '65 kg', '170 cm'),
    (3, 'Michael', 'Johnson', 40, '789 Elm Street', '555-555-1212', 'HealthFirst Insurance', 'Male', 'Canadian', '80 kg', '175 cm');

/* Inserting the Sample Values into Doctor_details Table */

INSERT INTO Doctor_details
    (doctorID, firstName, lastName, department, specialty, experience, no_of_surgeries_performed, phone)
VALUES
    (101, 'Alice', 'Brown', 'Cardiology', 'Cardiac Surgeon', '10 years', 150, '555-111-2222'),
    (102, 'Bob', 'Green', 'Neurology', 'Neurosurgeon', '8 years', 100, '555-333-4444'),
    (103, 'Charlie', 'Black', 'Orthopedics', 'Orthopedic Surgeon', '5 years', 50, '555-555-6666');

/* Inserting the Sample Values into Appointment_details Table */

INSERT INTO Appointment_details
    (appointmentID, appointmentDate, reason, patientID, doctorID)
VALUES
    (1001, '2025-03-22 10:00:00', 'Routine Check-up', 1, 101),
    (1002, '2025-03-23 14:30:00', 'Follow-up Visit', 2, 102),
    (1003, '2025-03-24 09:15:00', 'Consultation for Knee Pain', 3, 103);
    
/* Inserting the Sample Values into Diagnosis_details Table */    

INSERT INTO Diagnosis_details
    (diagnosisID, diagnosisName, cause, duration_of_the_problem)
VALUES
    (201, 'Hypertension', 'High blood pressure', '6 months'),
    (202, 'Migraine', 'Chronic headaches', '2 years'),
    (203, 'Fracture', 'Accident', '3 weeks');
    
/* Inserting the Sample Values into Visit_details Table */    

INSERT INTO Visit_details
    (visitID, visitDate, notes, patientID, doctorID)
VALUES
    (3001, '2025-03-22 10:15:00', 'Patient complains of chest pain, recommended ECG', 1, 101),
    (3002, '2025-03-23 14:45:00', 'Patient reports severe headaches', 2, 102),
    (3003, '2025-03-24 09:30:00', 'Patient complains of knee pain from sports injury', 3, 103);
    
/* Inserting the Sample Values into VisitDiagnosis_details Table */

INSERT INTO VisitDiagnosis_details
    (visitID, diagnosisID)
VALUES
    (3001, 201),
    (3002, 202),
    (3003, 203);
    
/* Inserting the Sample Values into Prescription_and_outcome Table */    

INSERT INTO Prescription_and_outcome
    (prescriptionID, medicationName, dosage, startDate, endDate, visitID)
VALUES
    (4001, 'Aspirin', '100 mg daily', '2025-03-22', '2025-04-22', 3001),
    (4002, 'Sumatriptan', '50 mg as needed', '2025-03-23', '2025-04-23', 3002),
    (4003, 'Ibuprofen', '200 mg thrice daily', '2025-03-24', '2025-03-31', 3003);

/* Viewing the Tables in the Database */
SELECT * FROM Patient_details;
SELECT * FROM Doctor_details;
SELECT * FROM Appointment_details;
SELECT * FROM Diagnosis_details;
SELECT * FROM Visit_details;
SELECT * FROM VisitDiagnosis_details;
SELECT * FROM Prescription_and_outcome;

/* ------------Supporting Functionalities------------- */

/* Viewing the database */

SHOW Databases;

/* Editing the Existing Records */

UPDATE Patient_details
SET 
    insurance = 'NewHealth Insurance',
    address   = '789 New Address Avenue'
WHERE patientID = 1;


UPDATE Doctor_details
SET 
    phone = '555-999-8888'
WHERE doctorID = 101;

/* Searching the Patient Records */

/* Search by Name */

SELECT 
    patientID,
    firstName,
    lastName,
    phone,
    insurance
FROM Patient_details
WHERE lastName LIKE '%Doe%';

/* Search by ID */

SELECT 
    patientID,
    firstName,
    lastName,
    phone,
    insurance
FROM Patient_details
WHERE patientID = 1;

/* Search by Visit date */

SELECT 
    p.patientID,
    p.firstName,
    p.lastName,
    v.visitDate,
    v.notes
FROM Patient_details p
JOIN Visit_details v ON p.patientID = v.patientID
WHERE CAST(v.visitDate AS DATE) = '2025-03-22';

/* Finding the Patients who has "Hypertension" */

SELECT 
    p.patientID,
    CONCAT(p.firstName, ' ', p.lastName) AS PatientName,
    d.diagnosisName
FROM Patient_details p
JOIN Visit_details v ON p.patientID = v.patientID
JOIN VisitDiagnosis_details vd ON v.visitID = vd.visitID
JOIN Diagnosis_details d ON vd.diagnosisID = d.diagnosisID
WHERE d.diagnosisName = 'Hypertension';

/* Finding the Patients who has visited between the 2025-03-01 and 2025-03-31 */

SELECT 
    p.patientID,
    p.firstName,
    p.lastName,
    v.visitID,
    v.visitDate
FROM Patient_details p
JOIN Visit_details v ON p.patientID = v.patientID
WHERE v.visitDate BETWEEN '2025-03-01' AND '2025-03-31'
ORDER BY v.visitDate;

/* Finding the Patients who has visited certain doctor */

SELECT 
    p.patientID,
    p.firstName,
    p.lastName,
    v.visitDate,
    CONCAT(d.firstName, ' ', d.lastName) AS DoctorName
FROM Patient_details p
JOIN Visit_details v ON p.patientID = v.patientID
JOIN Doctor_details d ON v.doctorID = d.doctorID
WHERE d.doctorID = 101
ORDER BY v.visitDate DESC;

/* Finding the Patients who has visited certain doctor, on specific date and with specific diagnosis */

SELECT 
    p.patientID,
    CONCAT(p.firstName, ' ', p.lastName) AS PatientName,
    v.visitDate,
    d.diagnosisName,
    CONCAT(doc.firstName, ' ', doc.lastName) AS DoctorName
FROM Patient_details p
JOIN Visit_details v ON p.patientID = v.patientID
JOIN Doctor_details doc ON v.doctorID = doc.doctorID
JOIN VisitDiagnosis_details vd ON v.visitID = vd.visitID
JOIN Diagnosis_details d ON vd.diagnosisID = d.diagnosisID
WHERE doc.doctorID = 102
  AND CAST(v.visitDate AS DATE) = '2025-03-23'
  AND d.diagnosisName = 'Migraine';

/* Finding the Patients who has visited the Clinic Twice within the shortest Interval */

/*-- Step 1: Calculate day gaps between consecutive visits for each patient.*/
WITH CTE_VisitGaps AS (
    SELECT 
        v.patientID,
        v.visitID,
        v.visitDate,
        LEAD(v.visitDate) OVER (PARTITION BY v.patientID ORDER BY v.visitDate) AS nextVisitDate,
        DATEDIFF(day, v.visitDate, 
                  LEAD(v.visitDate) OVER (PARTITION BY v.patientID ORDER BY v.visitDate)
                 ) AS dayGap
    FROM Visit_details v
)

/*-- Step 2: Find the global minimum gap across all patients.*/
, CTE_MinGap AS (
    SELECT MIN(dayGap) AS MinGap
    FROM CTE_VisitGaps
    WHERE dayGap IS NOT NULL
)

/*-- Step 3: Join back to get patients & diagnoses for visits with that shortest gap.*/
SELECT 
    p.patientID,
    CONCAT(p.firstName, ' ', p.lastName) AS PatientName,
    d.diagnosisName,
    G.dayGap AS ShortestDayGap,
    G.visitDate AS FirstVisitDate,
    G.nextVisitDate AS SecondVisitDate
FROM CTE_VisitGaps G
JOIN CTE_MinGap MG ON G.dayGap = MG.MinGap
JOIN Patient_details p ON G.patientID = p.patientID
JOIN VisitDiagnosis_details vd ON G.visitID = vd.visitID
JOIN Diagnosis_details d ON vd.diagnosisID = d.diagnosisID
WHERE G.dayGap IS NOT NULL
ORDER BY p.patientID;







