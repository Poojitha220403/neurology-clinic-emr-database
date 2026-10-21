"""Integration tests against a MySQL database built from sql/01 and sql/02.

They run in CI against a MySQL 8 service container and are skipped when
EMR_DB_HOST is not set.
"""
import os
import re
from pathlib import Path

import pytest

mysql = pytest.importorskip("mysql.connector")

pytestmark = pytest.mark.skipif(
    not os.getenv("EMR_DB_HOST"), reason="set EMR_DB_HOST to run database tests"
)

SQL_01 = Path(__file__).resolve().parent.parent / "sql" / "01_schema_and_sample_data.sql"
CORE_TABLES = {
    "Patient_details", "Doctor_details", "Appointment_details", "Diagnosis_details",
    "Visit_details", "VisitDiagnosis_details", "Prescription_and_outcome",
}
VIEWS = {
    "Patient_Diagnosis_View", "Patient_Visit_History", "Prescription_Summary",
    "Diagnosis_Frequency", "Doctor_Workload", "Upcoming_Appointments",
}


@pytest.fixture
def conn():
    c = mysql.connect(
        host=os.environ["EMR_DB_HOST"],
        port=int(os.getenv("EMR_DB_PORT", "3306")),
        user=os.getenv("EMR_DB_USER", "root"),
        password=os.getenv("EMR_DB_PASSWORD", ""),
        database="neurology_clinic_emr_system",
        autocommit=False,
    )
    yield c
    c.rollback()  # every test leaves the sample data untouched
    c.close()


def names(cur, sql, *params):
    cur.execute(sql, params)
    return {row[0] for row in cur.fetchall()}


def test_all_tables_exist(conn):
    cur = conn.cursor()
    tables = names(cur, "SELECT table_name FROM information_schema.tables "
                        "WHERE table_schema = DATABASE() AND table_type = 'BASE TABLE'")
    assert CORE_TABLES | {"Roles", "Users", "Audit_Log"} <= tables


def test_views_procedures_and_indexes_exist(conn):
    cur = conn.cursor()
    assert VIEWS <= names(cur, "SELECT table_name FROM information_schema.views "
                               "WHERE table_schema = DATABASE()")
    assert {"GetPatientByID", "AddPrescription"} <= names(
        cur, "SELECT routine_name FROM information_schema.routines "
             "WHERE routine_schema = DATABASE() AND routine_type = 'PROCEDURE'")
    assert {"idx_appointment_date", "idx_visit_date", "idx_doctor_visit"} <= names(
        cur, "SELECT index_name FROM information_schema.statistics WHERE table_schema = DATABASE()")


def test_sample_data_and_updates_applied(conn):
    cur = conn.cursor()
    for table in CORE_TABLES:
        cur.execute(f"SELECT COUNT(*) FROM {table}")
        assert cur.fetchone()[0] == 3, table
    cur.execute("SELECT insurance FROM Patient_details WHERE patientID = 1")
    assert cur.fetchone()[0] == "NewHealth Insurance"


def test_get_patient_by_id_procedure(conn):
    cur = conn.cursor()
    cur.callproc("GetPatientByID", [2])
    rows = [r for result in cur.stored_results() for r in result.fetchall()]
    assert len(rows) == 1 and rows[0][1:3] == ("Jane", "Smith")


def test_add_prescription_procedure(conn):
    cur = conn.cursor()
    cur.callproc("AddPrescription", [4999, "Topiramate", "25 mg daily", "2025-04-01", "2025-05-01", 3002])
    cur.execute("SELECT medicationName, visitID FROM Prescription_and_outcome WHERE prescriptionID = 4999")
    assert cur.fetchone() == ("Topiramate", 3002)


def test_prescription_requires_existing_visit(conn):
    cur = conn.cursor()
    with pytest.raises(mysql.Error):
        cur.callproc("AddPrescription", [4998, "X", "1 mg", "2025-04-01", "2025-04-02", 999999])


def test_patient_update_is_audited(conn):
    cur = conn.cursor()
    cur.execute("SELECT COUNT(*) FROM Audit_Log")
    before = cur.fetchone()[0]
    cur.execute("UPDATE Patient_details SET age = 31 WHERE patientID = 1")
    cur.execute("SELECT actionType, tableName, recordID, newValue FROM Audit_Log ORDER BY logID DESC LIMIT 1")
    action, table, record, new_value = cur.fetchone()
    assert (action, table, record) == ("UPDATE", "Patient_details", 1)
    assert new_value.endswith(",31")
    cur.execute("SELECT COUNT(*) FROM Audit_Log")
    assert cur.fetchone()[0] == before + 1


def test_diagnosis_frequency_view(conn):
    cur = conn.cursor()
    cur.execute("SELECT diagnosisName, totalOccurrences FROM Diagnosis_Frequency")
    assert dict(cur.fetchall()) == {"Hypertension": 1, "Migraine": 1, "Fracture": 1}


def test_shortest_visit_interval_query(conn):
    """The final query in sql/01 finds patients with the shortest gap between visits."""
    query = SQL_01.read_text()
    query = query[query.index("WITH CTE_VisitGaps"):].strip().rstrip(";")
    query = re.sub(r"/\*.*?\*/", "", query, flags=re.S)
    cur = conn.cursor()
    cur.execute("INSERT INTO Visit_details VALUES (3004, '2025-03-25 10:15:00', 'Follow-up', 1, 101)")
    cur.execute("INSERT INTO VisitDiagnosis_details VALUES (3004, 201)")
    cur.execute(query)
    rows = cur.fetchall()
    assert rows, "expected the patient with two visits"
    patient_id, _name, diagnosis, gap = rows[0][:4]
    assert (patient_id, diagnosis, gap) == (1, "Hypertension", 3)
