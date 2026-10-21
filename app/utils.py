import hashlib
from tabulate import tabulate

def display_results(results):
    """Display the results in a nicely formatted table"""
    if not results:
        print("\nNo results found.\n")
        return
        
    for data, columns in results:
        if data:
            print("\n" + tabulate(data, headers=columns, tablefmt="grid") + "\n")
        else:
            print("\nNo data found.\n")

def hash_password(password):
    """Create a SHA-256 hash of a password"""
    return hashlib.sha256(password.encode()).hexdigest()