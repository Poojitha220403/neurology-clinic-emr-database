import getpass
from db_connector import call_stored_procedure
from utils import display_results, hash_password

# Global variables
current_user = None
current_role = None

def main_menu():
    """Display the main menu options"""
    print("\n ------ Neurology Clinic EMR System -----")
    print("1. Physician Login")
    print("2. Receptionist Login")
    print("3. Admin Login")
    print("4. Exit")
    return input("\nSelect an option: ")

def physician_menu():
    """Display Physician menu options"""
    print("\n==== Physician Portal ====")
    print("1. Add Prescription")
    print("2. View Patients")
    print("3. Log Out")
    return input("\nSelect an option: ")

def receptionist_menu():
    """Display Receptionist menu options"""
    print("\n==== Receptionist Portal ====")
    print("1. View Patients")
    print("2. Log Out")
    return input("\nSelect an option: ")

def admin_menu():
    """Display Admin menu options"""
    print("\n==== Admin Portal ====")
    print("1. Add Prescription")
    print("2. View Patients")
    print("9. Log Out")
    return input("\nSelect an option: ")

def login(role):
    """Handle user login"""
    global current_user, current_role
    
    username = input("Username: ")
    password = getpass.getpass("Password: ")
    password_hash = hash_password(password)
    
    # Connect directly to database instead of using stored procedure
    from db_connector import get_connection
    from mysql.connector import Error
    
    connection = get_connection()
    if not connection:
        print("\nDatabase connection error. Please try again later.")
        return False
        
    cursor = connection.cursor()
    try:
        # Query the Users table directly (matching your database structure)
        query = """
        SELECT user_id, username, email, provider_id 
        FROM Users 
        WHERE username = %s AND password_hash = %s AND active = TRUE
        """
        cursor.execute(query, (username, password_hash))
        user_data = cursor.fetchone()
        
        if user_data:
            user_id = user_data[0]  # First column is user_id
            
            # Set the current user context
            cursor.execute("SET @current_user_id = %s", (user_id,))
            connection.commit()
            
            current_user = user_id
            current_role = role
            
            print("\nLogin successful!")
            return True
        else:
            print("\nInvalid username or password. Please try again.")
            return False
            
    except Error as e:
        print(f"\nLogin error: {e}")
        return False
    finally:
        cursor.close()
        connection.close()

def prescribe_medication():
    """Prescribe medication for a visit"""
    try:
        prescription_id = int(input("Enter Prescription ID: "))
        medication_name = input("Enter Medication Name: ")
        dosage = input("Enter Dosage (e.g., 500 mg twice daily): ")
        start_date = input("Enter Start Date (YYYY-MM-DD): ")
        end_date = input("Enter End Date (YYYY-MM-DD): ")
        visit_id = int(input("Enter Visit ID: "))

        params = [prescription_id, medication_name, dosage, start_date, end_date, visit_id, current_user]
        results = call_stored_procedure("AddPrescription", params)
        print("✅ Prescription recorded successfully.")
        display_results(results)

    except ValueError:
        print("Invalid input. Please enter proper values.")
    except Exception as e:
        print(f" Error prescribing medication: {e}")

def view_patient_details():
    """View detailed patient information"""
    patient_id = input("\nEnter patient ID: ")
    try:
        patient_id = int(patient_id)
        results = call_stored_procedure("GetPatientByID", [patient_id])
        display_results(results)
    except ValueError:
        print("Invalid patient ID. Please enter a number.")

def main():
    """Main application function"""
    global current_user, current_role
    
    print("Welcome to the Neurology Clinic EMR System")
    
    try:
        while True:
            if not current_user:
                choice = main_menu()
                
                if choice == "1":
                    login("physician")
                elif choice == "2":
                    login("receptionist")
                elif choice == "3":
                    login("admin")
                elif choice == "4":
                    print("\nExiting system. Thank you for using the EMR system.")
                    break
                else:
                    print("\nInvalid option. Please try again.")
            
            elif current_role == "physician":
                choice = physician_menu()
                
                if choice == "1":
                    prescribe_medication()
                elif choice == "2":
                    view_patient_details()
                elif choice == "3":
                    current_user = None
                    current_role = None
                    print("\nLogged out successfully.")
                else:
                    print("\nOption not implemented yet or invalid selection.")
            
            elif current_role == "receptionist":
                choice = receptionist_menu()
                
                if choice == "1":
                    view_patient_details()
                elif choice == "2":
                    current_user = None
                    current_role = None
                    print("\nLogged out successfully.")
                else:
                    print("\nOption not implemented yet or invalid selection.")
            
            elif current_role == "admin":
                choice = admin_menu()
                
                if choice == "1":
                    prescribe_medication()
                elif choice == "2":
                    view_patient_details()
                elif choice == "3":
                    current_user = None
                    current_role = None
                    print("\nLogged out successfully.")
                else:
                    print("\nOption not implemented yet or invalid selection.")
            
    
    except KeyboardInterrupt:
        print("\n\nProgram interrupted. Exiting...")
    finally:
        print("\nThank you for using the University Health Clinic EMR System.")

if __name__ == "__main__":
    main()
