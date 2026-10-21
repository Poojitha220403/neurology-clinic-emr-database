from mysql.connector import MySQLConnection, Error
from config import DB_CONFIG

def get_connection():
    """Create and return a database connection"""
    try:
        return MySQLConnection(**DB_CONFIG)
    except Error as e:
        print(f"Error connecting to database: {e}")
        return None

def call_stored_procedure(procedure_name, args=None):
    """Call a stored procedure and return the results"""
    if args is None:
        args = []
        
    connection = get_connection()
    if not connection:
        return []
        
    cursor = connection.cursor()
    try:
        cursor.callproc(procedure_name, args)
        
        result_sets = []
        for result in cursor.stored_results():
            columns = [col[0] for col in result.description]
            data = result.fetchall()
            result_sets.append((data, columns))
            
        connection.commit()
        return result_sets
    except Error as e:
        print(f"Error calling stored procedure {procedure_name}: {e}")
        return []
    finally:
        cursor.close()
        connection.close()