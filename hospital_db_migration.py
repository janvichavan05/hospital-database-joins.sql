import mysql.connector
import psycopg2
from datetime import datetime

start_time = datetime.now()

# ---------------- MYSQL CONNECTION ----------------
mysql_conn = mysql.connector.connect(
    host="localhost",
    user="root",
    password="root",
    database="hospital_mysql"
)
mysql_cursor = mysql_conn.cursor()

# ---------------- POSTGRES CONNECTION ----------------
pg_conn = psycopg2.connect(
    host="localhost",
    user="postgres",
    password="postgres",
    database="hospital_postgres"
)
pg_cursor = pg_conn.cursor()

# ---------------- CREATE TABLES ----------------
create_tables_query = """
DROP TABLE IF EXISTS appointments;
DROP TABLE IF EXISTS doctors;
DROP TABLE IF EXISTS patients;

CREATE TABLE patients (
    patient_id INT PRIMARY KEY,
    name VARCHAR(100),
    age INT,
    gender VARCHAR(10),
    phone VARCHAR(15)
);

CREATE TABLE doctors (
    doctor_id INT PRIMARY KEY,
    name VARCHAR(100),
    specialization VARCHAR(100)
);

CREATE TABLE appointments (
    appointment_id INT PRIMARY KEY,
    patient_id INT REFERENCES patients(patient_id),
    doctor_id INT REFERENCES doctors(doctor_id),
    date DATE
);
"""
pg_cursor.execute(create_tables_query)
pg_conn.commit()
print("PostgreSQL tables created.")

# ---------------- MIGRATION FUNCTION ----------------
def migrate_table(table_name):
    mysql_cursor.execute(f"SELECT * FROM {table_name}")
    rows = mysql_cursor.fetchall()

    inserted = 0
    for row in rows:
        cols = ','.join(['%s'] * len(row))
        query = f"INSERT INTO {table_name} VALUES ({cols})"
        try:
            pg_cursor.execute(query, row)
            inserted += 1
        except Exception as e:
            print(f"Insert error in {table_name}: {e}")

    pg_conn.commit()
    return inserted

# ---------------- MIGRATE DATA ----------------
tables = ["patients", "doctors", "appointments"]
counts = {}

for t in tables:
    print(f"Migrating {t}...")
    counts[t] = migrate_table(t)

# ---------------- INTEGRITY CHECK ----------------
def get_pg_count(table):
    pg_cursor.execute(f"SELECT COUNT(*) FROM {table}")
    return pg_cursor.fetchone()[0]

integrity_pass = True
for t in tables:
    if get_pg_count(t) != counts[t]:
        integrity_pass = False

# FK Check
pg_cursor.execute("""
SELECT COUNT(*) FROM appointments
WHERE patient_id NOT IN (SELECT patient_id FROM patients)
""")
invalid_fk = pg_cursor.fetchone()[0]

if invalid_fk > 0:
    integrity_pass = False

# ---------------- SUMMARY ----------------
end_time = datetime.now()

print("\n------ MIGRATION REPORT ------")
print("Patients:", counts["patients"])
print("Doctors:", counts["doctors"])
print("Appointments:", counts["appointments"])
print("Foreign Key Issues:", invalid_fk)
print("Integrity:", "PASSED" if integrity_pass else "FAILED")
print("Time:", end_time - start_time)
print("------------------------------")

# ---------------- CLOSE ----------------
mysql_cursor.close()
pg_cursor.close()
mysql_conn.close()
pg_conn.close()
