/* Creating the Role Table */

CREATE TABLE Roles (
    roleID INT PRIMARY KEY,
    roleName VARCHAR(50) UNIQUE NOT NULL
);

/* Creating the Users Table */

CREATE TABLE Users (
    userID INT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    roleID INT,
    FOREIGN KEY (roleID) REFERENCES Roles(roleID)
);

/* Inserting the Values into the Roles Table */ 

INSERT INTO Roles VALUES (1, 'Physician'), (2, 'Receptionist'), (3, 'Admin');

/* Inserting the Values into the Users Table */

INSERT INTO Users VALUES 
(1, 'drsmith', 'hashedpassword123', 1),
(2, 'reception1', 'hashedpassword456', 2);

/* Creating the Stored Procedures for API Access */
/* Stored Procedure 1 */

DELIMITER $$

CREATE PROCEDURE GetPatientByID(IN pID INT)
BEGIN
    SELECT * FROM Patient_details WHERE patientID = pID;
END $$

DELIMITER ;

/* Stored Procedure 2 */

DELIMITER $$

CREATE PROCEDURE AddPrescription(
    IN p_prescriptionID INT,
    IN p_medicationName VARCHAR(100),
    IN p_dosage VARCHAR(50),
    IN p_startDate DATE,
    IN p_endDate DATE,
    IN p_visitID INT
)
BEGIN
    INSERT INTO Prescription_and_outcome
    VALUES (p_prescriptionID, p_medicationName, p_dosage, p_startDate, p_endDate, p_visitID);
END $$

DELIMITER ;

/* Creating the Audit Table */

CREATE TABLE Audit_Log (
    logID INT AUTO_INCREMENT PRIMARY KEY,
    userID INT,
    actionType VARCHAR(10), -- SELECT, INSERT, UPDATE, DELETE
    tableName VARCHAR(50),
    recordID INT,
    accessTime DATETIME DEFAULT CURRENT_TIMESTAMP,
    oldValue TEXT,
    newValue TEXT,
    FOREIGN KEY (userID) REFERENCES Users(userID)
);

/* Trigger example for Log Patient Table */

DELIMITER $$

CREATE TRIGGER log_patient_update
AFTER UPDATE ON Patient_details
FOR EACH ROW
BEGIN
    INSERT INTO Audit_Log (userID, actionType, tableName, recordID, oldValue, newValue)
    VALUES (NULL, 'UPDATE', 'Patient_details', OLD.patientID,
            CONCAT_WS(',', OLD.firstName, OLD.lastName, OLD.age),
            CONCAT_WS(',', NEW.firstName, NEW.lastName, NEW.age));
END $$

DELIMITER ;


/* Creating Views */

/* Creating View for Patient Diagnosis */

CREATE VIEW Patient_Diagnosis_View AS
SELECT p.patientID, CONCAT(p.firstName, ' ', p.lastName) AS fullName,
       d.diagnosisName, v.visitDate
FROM Patient_details p
JOIN Visit_details v ON p.patientID = v.patientID
JOIN VisitDiagnosis_details vd ON v.visitID = vd.visitID
JOIN Diagnosis_details d ON vd.diagnosisID = d.diagnosisID;

/* Creating View for Patient History */

CREATE VIEW Patient_Visit_History AS
SELECT p.patientID, CONCAT(p.firstName, ' ', p.lastName) AS fullName,
       v.visitID, v.visitDate, v.notes,
       d.firstName AS doctorFirstName, d.lastName AS doctorLastName
FROM Patient_details p
JOIN Visit_details v ON p.patientID = v.patientID
JOIN Doctor_details d ON v.doctorID = d.doctorID;

/* Creating View for Patient Overview */

CREATE VIEW Prescription_Summary AS
SELECT p.patientID, CONCAT(p.firstName, ' ', p.lastName) AS fullName,
       pr.prescriptionID, pr.medicationName, pr.dosage, pr.startDate, pr.endDate
FROM Patient_details p
JOIN Visit_details v ON p.patientID = v.patientID
JOIN Prescription_and_outcome pr ON v.visitID = pr.visitID;

/* Creating View for Diagnosis Frequency View */

CREATE VIEW Diagnosis_Frequency AS
SELECT d.diagnosisName, COUNT(vd.visitID) AS totalOccurrences
FROM Diagnosis_details d
JOIN VisitDiagnosis_details vd ON d.diagnosisID = vd.diagnosisID
GROUP BY d.diagnosisName
ORDER BY totalOccurrences DESC;

/* Creating View Doctor Workload Summary */

CREATE VIEW Doctor_Workload AS
SELECT d.doctorID, CONCAT(d.firstName, ' ', d.lastName) AS doctorName,
       COUNT(DISTINCT v.visitID) AS totalVisits,
       COUNT(DISTINCT a.appointmentID) AS totalAppointments
FROM Doctor_details d
LEFT JOIN Visit_details v ON d.doctorID = v.doctorID
LEFT JOIN Appointment_details a ON d.doctorID = a.doctorID
GROUP BY d.doctorID;

/* Creating View for Upcoming Appointments */

CREATE VIEW Upcoming_Appointments AS
SELECT a.appointmentID, a.appointmentDate, a.reason,
       p.firstName AS patientFirstName, p.lastName AS patientLastName,
       d.firstName AS doctorFirstName, d.lastName AS doctorLastName
FROM Appointment_details a
JOIN Patient_details p ON a.patientID = p.patientID
JOIN Doctor_details d ON a.doctorID = d.doctorID
WHERE a.appointmentDate >= CURRENT_DATE()
ORDER BY a.appointmentDate;


/* Creating Indexes */

CREATE INDEX idx_appointment_date ON Appointment_details(appointmentDate);

CREATE INDEX idx_visit_date ON Visit_details(visitDate);

CREATE INDEX idx_diagnosis_name ON Diagnosis_details(diagnosisName);

CREATE INDEX idx_prescription_visitID ON Prescription_and_outcome(visitID);

CREATE INDEX idx_doctor_visit ON Visit_details(doctorID, visitDate);


