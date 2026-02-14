import os
from datetime import datetime

# ---------------- DATABASE CONFIG ----------------
DB_HOST = "localhost"
DB_USER = "root"
DB_PASS = "root"
DB_NAME = "college_db"

print("DATABASE BACKUP AND RESTORE SYSTEM STARTED")

while True:
    print("\n===== DATABASE BACKUP & RESTORE =====")
    print("1. Backup Database")
    print("2. Restore Database")
    print("3. Exit")

    choice = input("Enter choice: ")

    # ---------------- BACKUP DATABASE ----------------
    if choice == "1":
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        backup_file = f"{DB_NAME}_backup_{timestamp}.sql"

        command = f"mysqldump -h {DB_HOST} -u {DB_USER} -p{DB_PASS} {DB_NAME} > {backup_file}"
        result = os.system(command)

        if result == 0:
            print("Backup created successfully:", backup_file)
        else:
            print("Backup failed! Check MySQL installation or PATH.")

    # ---------------- RESTORE DATABASE ----------------
    elif choice == "2":
        file_name = input("Enter backup file name (example: college_db_backup_20260215_101500.sql): ")

        command = f"mysql -h {DB_HOST} -u {DB_USER} -p{DB_PASS} {DB_NAME} < {file_name}"
        result = os.system(command)

        if result == 0:
            print("Database restored successfully!")
        else:
            print("Restore failed! Check file name or MySQL setup.")

    # ---------------- EXIT ----------------
    elif choice == "3":
        print("Exiting program...")
        break

    # ---------------- INVALID INPUT ----------------
    else:
        print("Invalid choice! Please try again.")
