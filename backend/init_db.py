"""
VSP Smart Portal - SQLite Database Initialization
This script creates and populates the SQLite database with schema and seed data
"""

import sqlite3
import os
from datetime import datetime, date, timedelta

DB_PATH = os.path.join(os.path.dirname(__file__), "..", "vsp_portal.db")

def init_db():
    """Initialize SQLite database with schema and seed data"""
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    
    # Create tables
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS locations (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            category TEXT NOT NULL,
            lat REAL NOT NULL,
            lng REAL NOT NULL,
            description TEXT,
            icon TEXT DEFAULT 'building',
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    ''')
    
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS lost_found (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            item_name TEXT NOT NULL,
            description TEXT,
            location_name TEXT,
            contact_name TEXT NOT NULL,
            contact_phone TEXT NOT NULL,
            item_type TEXT NOT NULL,
            status TEXT DEFAULT 'OPEN',
            date_reported DATE NOT NULL,
            image_url TEXT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    ''')
    
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS accident_reports (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            reporter_name TEXT NOT NULL,
            reporter_id TEXT,
            department TEXT,
            location_name TEXT NOT NULL,
            accident_type TEXT NOT NULL,
            severity TEXT NOT NULL,
            description TEXT NOT NULL,
            injured_persons INTEGER DEFAULT 0,
            first_aid_given INTEGER DEFAULT 0,
            reported_to_supervisor INTEGER DEFAULT 0,
            incident_date DATE NOT NULL,
            incident_time TIME NOT NULL,
            status TEXT DEFAULT 'REPORTED',
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    ''')
    
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS machines (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            machine_name TEXT NOT NULL,
            machine_code TEXT UNIQUE NOT NULL,
            department TEXT,
            location_name TEXT,
            status TEXT DEFAULT 'RUNNING',
            capacity_tph REAL,
            last_maintenance DATE,
            next_maintenance DATE,
            operator_name TEXT,
            notes TEXT,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    ''')
    
    # Check if data already exists
    cursor.execute("SELECT COUNT(*) FROM locations")
    if cursor.fetchone()[0] > 0:
        print("Database already initialized. Skipping seed data insertion.")
        conn.close()
        return
    
    # Seed data - Locations
    locations = [
        ("Main Gate", "GATE", 17.6502, 83.2161, "Main entrance to the township", "map-pin"),
        ("East Gate", "GATE", 17.6510, 83.2200, "Eastern access point", "map-pin"),
        ("West Gate", "GATE", 17.6490, 83.2120, "Western access point", "map-pin"),
        ("Blast Furnace-1", "PLANT", 17.6505, 83.2170, "BF-1 Production Unit", "cpu"),
        ("Blast Furnace-2", "PLANT", 17.6500, 83.2165, "BF-2 Production Unit", "cpu"),
        ("SMS Unit", "PLANT", 17.6515, 83.2175, "Steel Melting Shop", "cpu"),
        ("Hot Strip Mill", "PLANT", 17.6495, 83.2185, "HSM Production Facility", "cpu"),
        ("Cold Rolling", "PLANT", 17.6505, 83.2155, "Cold Rolling Mill", "cpu"),
        ("Wire Rod Mill", "PLANT", 17.6520, 83.2190, "Wire Rod Production", "cpu"),
        ("Coke Oven", "PLANT", 17.6510, 83.2140, "Coke Production Unit", "cpu"),
        ("Sinter Plant", "PLANT", 17.6485, 83.2170, "Sinter Production Facility", "cpu"),
        ("Power House", "PLANT", 17.6530, 83.2165, "Thermal Power Generation", "cpu"),
        ("Railway Station", "OFFICE", 17.6500, 83.2100, "Township Railway Station", "building"),
        ("Hospital", "HOSPITAL", 17.6540, 83.2200, "RINL Township Hospital", "heart"),
        ("School", "SCHOOL", 17.6470, 83.2150, "RINL Township School", "book"),
        ("Park", "PARK", 17.6480, 83.2210, "Central Park", "tree"),
        ("Canteen-1", "CANTEEN", 17.6505, 83.2165, "Main Canteen", "coffee"),
        ("Canteen-2", "CANTEEN", 17.6490, 83.2175, "Workers Canteen", "coffee"),
        ("Temple", "TEMPLE", 17.6520, 83.2145, "Lord Shiva Temple", "building"),
        ("Bank", "BANK", 17.6510, 83.2190, "State Bank Branch", "landmark"),
    ]
    
    cursor.executemany(
        "INSERT INTO locations (name, category, lat, lng, description, icon) VALUES (?, ?, ?, ?, ?, ?)",
        locations
    )
    
    # Seed data - Machines
    machines = [
        ("Blast Furnace No. 1", "BF-01", "Operations", "Blast Furnace-1", "RUNNING", 2500.00, date.today() - timedelta(days=30), date.today() + timedelta(days=30), "Rajesh Kumar", "Operating normally"),
        ("Blast Furnace No. 2", "BF-02", "Operations", "Blast Furnace-2", "RUNNING", 2400.00, date.today() - timedelta(days=20), date.today() + timedelta(days=40), "Suresh Rao", "Minor optimization needed"),
        ("Steel Melting Shop", "SMS-01", "Production", "SMS Unit", "RUNNING", 180.00, date.today() - timedelta(days=15), date.today() + timedelta(days=45), "Anil Singh", "Running efficiently"),
        ("Hot Strip Mill", "HSM-01", "Production", "Hot Strip Mill", "MAINTENANCE", 150.00, date.today() - timedelta(days=5), date.today() + timedelta(days=55), "Vikram Patel", "Scheduled maintenance"),
        ("Cold Rolling Mill", "CRM-01", "Production", "Cold Rolling", "IDLE", 100.00, date.today() - timedelta(days=60), date.today() + timedelta(days=10), "Ramesh Verma", "Awaiting feed material"),
        ("Wire Rod Mill", "WRM-01", "Production", "Wire Rod Mill", "RUNNING", 80.00, date.today() - timedelta(days=10), date.today() + timedelta(days=50), "Pradeep Kumar", "Normal operation"),
        ("Coke Oven Battery", "COV-01", "Utilities", "Coke Oven", "RUNNING", 500.00, date.today() - timedelta(days=45), date.today() + timedelta(days=15), "Harish Gupta", "Stable operation"),
        ("Sinter Machine-1", "SIN-01", "Utilities", "Sinter Plant", "RUNNING", 400.00, date.today() - timedelta(days=25), date.today() + timedelta(days=35), "Sandeep Mehta", "Operating well"),
        ("Sinter Machine-2", "SIN-02", "Utilities", "Sinter Plant", "BREAKDOWN", 380.00, date.today() - timedelta(days=2), date.today() - timedelta(days=2), "Ajay Singh", "Bearing failure - under repair"),
        ("Pellet Plant", "PEL-01", "Utilities", "Sinter Plant", "OFFLINE", 250.00, date.today() - timedelta(days=90), date.today(), "Mohan Das", "Planned shutdown"),
        ("Compressor Station", "CMP-01", "Utilities", "Power House", "RUNNING", 120.00, date.today() - timedelta(days=35), date.today() + timedelta(days=25), "Sunil Kumar", "Pressure stable"),
        ("Water Treatment", "WTR-01", "Utilities", "Power House", "RUNNING", 50.00, date.today() - timedelta(days=20), date.today() + timedelta(days=40), "Deepak Mishra", "Flow rate normal"),
        ("Oxygen Plant", "OXY-01", "Utilities", "Power House", "RUNNING", 200.00, date.today() - timedelta(days=30), date.today() + timedelta(days=30), "Nitin Gupta", "Optimal operation"),
        ("Nitrogen Plant", "NIT-01", "Utilities", "Power House", "RUNNING", 150.00, date.today() - timedelta(days=15), date.today() + timedelta(days=45), "Rohan Verma", "Normal"),
        ("Captive Power Plant", "CPP-01", "Power", "Power House", "RUNNING", 500.00, date.today() - timedelta(days=40), date.today() + timedelta(days=20), "Kavita Sharma", "Generating 45MW"),
        ("Lime Kiln", "LMK-01", "Utilities", "Sinter Plant", "RUNNING", 100.00, date.today() - timedelta(days=50), date.today() + timedelta(days=10), "Ravi Kumar", "Temperature stable"),
        ("Slag Handling", "SLG-01", "Utilities", "Blast Furnace-1", "RUNNING", 300.00, date.today() - timedelta(days=10), date.today() + timedelta(days=50), "Ashok Sharma", "Material flow OK"),
        ("Dust Collection", "DST-01", "Environmental", "Blast Furnace-1", "RUNNING", 50.00, date.today() - timedelta(days=25), date.today() + timedelta(days=35), "Anand Patel", "Pressure normal"),
        ("Conveyor System-1", "CNV-01", "Logistics", "Sinter Plant", "RUNNING", 200.00, date.today() - timedelta(days=5), date.today() + timedelta(days=55), "Vikram Kumar", "Belt tension good"),
        ("Conveyor System-2", "CNV-02", "Logistics", "Blast Furnace-1", "RUNNING", 180.00, date.today() - timedelta(days=35), date.today() + timedelta(days=25), "Sameer Singh", "Operating smoothly"),
    ]
    
    cursor.executemany(
        """INSERT INTO machines 
           (machine_name, machine_code, department, location_name, status, capacity_tph, 
            last_maintenance, next_maintenance, operator_name, notes) 
           VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)""",
        machines
    )
    
    # Seed data - Lost & Found
    lost_found = [
        ("Safety Helmet (Yellow)", "Yellow safety helmet with ID badge holder", "Main Gate", "Ramesh Kumar", "9876543210", "LOST", "OPEN", date.today() - timedelta(days=2), None),
        ("Black Backpack", "Black Adidas backpack with office documents", "East Gate", "Priya Sharma", "9123456789", "LOST", "OPEN", date.today() - timedelta(days=1), None),
        ("Silver Watch", "Titan silver watch with leather strap", "Canteen-1", "Anuj Verma", "9988776655", "FOUND", "OPEN", date.today() - timedelta(days=3), None),
        ("House Keys", "Set of 3 house keys on blue keychain", "Hospital", "Sneha Patel", "9876234567", "LOST", "RESOLVED", date.today() - timedelta(days=7), None),
        ("Glasses Case", "Brown leather glasses case with spectacles", "Park", "Rajesh Desai", "9765432109", "FOUND", "CLOSED", date.today() - timedelta(days=10), None),
    ]
    
    cursor.executemany(
        """INSERT INTO lost_found 
           (item_name, description, location_name, contact_name, contact_phone, item_type, status, date_reported, image_url) 
           VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)""",
        lost_found
    )
    
    # Seed data - Accident Reports
    accidents = [
        ("Rajesh Kumar", "EMP-001", "Operations", "Blast Furnace-1", "MINOR_INJURY", "LOW", 
         "Worker sustained minor cut while handling material", 1, True, True, 
         date.today() - timedelta(days=5), "14:30:00", "RESOLVED"),
        ("Suresh Rao", "EMP-002", "Production", "Hot Strip Mill", "NEAR_MISS", "MEDIUM", 
         "Near-miss incident - conveyor belt emergency stop activated", 0, False, True, 
         date.today() - timedelta(days=2), "09:15:00", "UNDER_INVESTIGATION"),
        ("Anil Singh", "EMP-003", "Utilities", "Sinter Plant", "MAJOR_INJURY", "HIGH", 
         "Worker fell from scaffolding during maintenance", 1, True, True, 
         date.today() - timedelta(days=10), "11:45:00", "REPORTED"),
    ]
    
    cursor.executemany(
        """INSERT INTO accident_reports 
           (reporter_name, reporter_id, department, location_name, accident_type, severity, 
            description, injured_persons, first_aid_given, reported_to_supervisor, 
            incident_date, incident_time, status) 
           VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)""",
        accidents
    )
    
    conn.commit()
    conn.close()
    print(f"✅ Database initialized at {DB_PATH}")
    print("   - 20 locations loaded")
    print("   - 20 machines loaded")
    print("   - 5 lost & found items loaded")
    print("   - 3 accident reports loaded")

if __name__ == "__main__":
    init_db()
