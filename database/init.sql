-- ============================================================
-- VSP SMART PORTAL - DATABASE INITIALIZATION
-- MySQL 8.0 / MariaDB compatible
-- ============================================================

CREATE DATABASE IF NOT EXISTS vsp_portal CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE vsp_portal;

-- ============================================================
-- TABLE: locations
-- ============================================================
DROP TABLE IF EXISTS locations;
CREATE TABLE locations (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    category ENUM('GATE','PLANT','SCHOOL','BANK','TEMPLE','PARK','HOSPITAL','CANTEEN','SPORTS','OFFICE') NOT NULL,
    lat DOUBLE NOT NULL,
    lng DOUBLE NOT NULL,
    description TEXT,
    icon VARCHAR(50) DEFAULT 'building',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- TABLE: lost_found
-- ============================================================
DROP TABLE IF EXISTS lost_found;
CREATE TABLE lost_found (
    id INT AUTO_INCREMENT PRIMARY KEY,
    item_name VARCHAR(255) NOT NULL,
    description TEXT,
    location_name VARCHAR(255),
    contact_name VARCHAR(100) NOT NULL,
    contact_phone VARCHAR(20) NOT NULL,
    item_type ENUM('LOST','FOUND') NOT NULL,
    status ENUM('OPEN','RESOLVED','CLOSED') DEFAULT 'OPEN',
    date_reported DATE NOT NULL,
    image_url VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- TABLE: accident_reports
-- ============================================================
DROP TABLE IF EXISTS accident_reports;
CREATE TABLE accident_reports (
    id INT AUTO_INCREMENT PRIMARY KEY,
    reporter_name VARCHAR(100) NOT NULL,
    reporter_id VARCHAR(50),
    department VARCHAR(100),
    location_name VARCHAR(255) NOT NULL,
    accident_type ENUM('MINOR_INJURY','MAJOR_INJURY','PROPERTY_DAMAGE','NEAR_MISS','FIRE','CHEMICAL','OTHER') NOT NULL,
    severity ENUM('LOW','MEDIUM','HIGH','CRITICAL') NOT NULL,
    description TEXT NOT NULL,
    injured_persons INT DEFAULT 0,
    first_aid_given BOOLEAN DEFAULT FALSE,
    reported_to_supervisor BOOLEAN DEFAULT FALSE,
    incident_date DATE NOT NULL,
    incident_time TIME NOT NULL,
    status ENUM('REPORTED','UNDER_INVESTIGATION','RESOLVED','CLOSED') DEFAULT 'REPORTED',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- TABLE: machines
-- ============================================================
DROP TABLE IF EXISTS machines;
CREATE TABLE machines (
    id INT AUTO_INCREMENT PRIMARY KEY,
    machine_name VARCHAR(255) NOT NULL,
    machine_code VARCHAR(50) UNIQUE NOT NULL,
    department VARCHAR(100),
    location_name VARCHAR(255),
    status ENUM('RUNNING','IDLE','MAINTENANCE','BREAKDOWN','OFFLINE') DEFAULT 'RUNNING',
    capacity_tph DECIMAL(10,2) COMMENT 'Tonnes per hour',
    last_maintenance DATE,
    next_maintenance DATE,
    operator_name VARCHAR(100),
    notes TEXT,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- ============================================================
-- SEED DATA: LOCATIONS (150+ Real VSP/RINL Locations)
-- ============================================================

INSERT INTO locations (name, category, lat, lng, description, icon) VALUES
-- GATES
('Main Gate-1 (Balacheruvu Road)', 'GATE', 17.6868, 83.2185, 'Primary entry gate on Balacheruvu Road. 24x7 security.', 'shield'),
('Gate-2 (Ukkunagaram Main Rd)', 'GATE', 17.6872, 83.2198, 'Secondary gate on Ukkunagaram Main Road', 'shield'),
('Gate-3 (Railway Side)', 'GATE', 17.6859, 83.2211, 'Railway side entry for raw material vehicles', 'shield'),
('Gate-4 (Back Gate)', 'GATE', 17.6845, 83.2172, 'Back gate - restricted access', 'shield'),
('Admin Gate', 'GATE', 17.6881, 83.2190, 'Administrative building entry gate', 'shield'),
('Contractor Gate', 'GATE', 17.6850, 83.2200, 'Entry for contractor vehicles and personnel', 'shield'),

-- PLANT PRODUCTION UNITS
('Blast Furnace Complex (BF-1,2,3)', 'PLANT', 17.6872, 83.2191, 'Three blast furnaces producing hot metal. Capacity: 6.3 MTPA', 'fire'),
('Steel Melt Shop-I (SMS-I)', 'PLANT', 17.6878, 83.2205, 'Primary steel making via LD converters', 'fire'),
('Steel Melt Shop-II (SMS-II)', 'PLANT', 17.6882, 83.2210, 'Secondary steel making unit with CCS', 'fire'),
('Hot Strip Mill (HSM)', 'PLANT', 17.6885, 83.2218, 'Hot rolling mill producing HR coils and sheets', 'cog'),
('Wire Rod Mill (WRM)', 'PLANT', 17.6892, 83.2223, 'Wire rod production - 5.5mm to 12mm dia', 'cog'),
('Coke Oven Batteries (COB)', 'PLANT', 17.6861, 83.2189, 'Coke production from coal. 4 batteries.', 'fire'),
('Sinter Plant', 'PLANT', 17.6857, 83.2195, 'Iron ore sintering for blast furnace feed', 'cog'),
('Lime Calcining Plant (LCP)', 'PLANT', 17.6855, 83.2188, 'Lime production for steel making', 'cog'),
('Oxygen Plant', 'PLANT', 17.6868, 83.2212, 'Oxygen, nitrogen and argon production', 'wind'),
('Power Plant (PP-1)', 'PLANT', 17.6875, 83.2201, 'Captive power generation - 286.5 MW', 'zap'),
('Power Plant (PP-2)', 'PLANT', 17.6879, 83.2207, 'Additional captive power unit', 'zap'),
('Roll Shop', 'PLANT', 17.6870, 83.2215, 'Roll turning and maintenance shop', 'tool'),
('Central Maintenance', 'PLANT', 17.6866, 83.2202, 'Central workshop for plant maintenance', 'tool'),
('Raw Material Handling (RMH)', 'PLANT', 17.6848, 83.2208, 'Iron ore and coal storage and handling', 'package'),
('Ore Bedding & Blending', 'PLANT', 17.6844, 83.2215, 'Raw material mixing yard', 'layers'),
('Water Treatment Plant', 'PLANT', 17.6890, 83.2230, 'Effluent and water recycling facility', 'droplet'),
('Continuous Casting Shop', 'PLANT', 17.6880, 83.2213, 'Billet and bloom casting machines', 'cog'),
('Medium Merchant Mill (MMM)', 'PLANT', 17.6888, 83.2220, 'Sections, angles, channels production', 'cog'),
('Special Bar Mill (SBM)', 'PLANT', 17.6895, 83.2225, 'High strength bars and rods', 'cog'),
('Structural Mill', 'PLANT', 17.6898, 83.2228, 'I-beams, H-beams, and rails', 'cog'),
('Quality Control Lab', 'PLANT', 17.6884, 83.2194, 'Central metallurgical testing laboratory', 'flask'),
('R&D Centre', 'PLANT', 17.6887, 83.2190, 'Research and Development centre', 'microscope'),
('Environmental Lab', 'PLANT', 17.6891, 83.2186, 'Environmental monitoring laboratory', 'leaf'),

-- ADMINISTRATIVE OFFICES
('Corporate Admin Building', 'OFFICE', 17.6889, 83.2182, 'CMD, Directors and HoDs offices', 'briefcase'),
('HR Department', 'OFFICE', 17.6886, 83.2179, 'Human Resources and Personnel', 'users'),
('Finance Department', 'OFFICE', 17.6883, 83.2176, 'Finance, Accounts and Audit', 'dollar-sign'),
('Materials Department', 'OFFICE', 17.6880, 83.2173, 'Procurement and stores management', 'package'),
('IT Centre', 'OFFICE', 17.6877, 83.2170, 'Information Technology department', 'monitor'),
('Safety Department', 'OFFICE', 17.6874, 83.2167, 'Safety, Health and Environment dept', 'shield'),
('Security Office', 'OFFICE', 17.6871, 83.2164, 'Central Industrial Security Force office', 'lock'),
('Medical Department HQ', 'OFFICE', 17.6868, 83.2161, 'Chief Medical Officer office', 'heart'),
('Vigilance Office', 'OFFICE', 17.6865, 83.2158, 'Vigilance and Anti-corruption dept', 'eye'),
('Marketing Department', 'OFFICE', 17.6862, 83.2155, 'Steel sales and marketing office', 'trending-up'),
('Town Admin Office', 'OFFICE', 17.6883, 83.2168, 'Township administration and complaints', 'home'),

-- SCHOOLS & EDUCATION
('DAV Public School Sector-6', 'SCHOOL', 17.6885, 83.2172, 'CBSE affiliated school, Classes I-XII. Contact: 0891-2518600', 'book'),
('Kendriya Vidyalaya RINL', 'SCHOOL', 17.6891, 83.2165, 'Central school for VSP employees children. Classes I-XII', 'book'),
('ZPHS Ukkunagaram', 'SCHOOL', 17.6878, 83.2169, 'Zilla Parishad High School. Telugu medium.', 'book'),
('DAV Primary School Sector-3', 'SCHOOL', 17.6895, 83.2162, 'Primary section, Classes I-V', 'book'),
('VSP Junior College', 'SCHOOL', 17.6900, 83.2158, 'Intermediate college MPC/BiPC streams', 'book'),
('ITI Ukkunagaram', 'SCHOOL', 17.6870, 83.2160, 'Industrial Training Institute', 'tool'),
('RINL Management Training Centre', 'SCHOOL', 17.6876, 83.2156, 'Employee training and skill development', 'award'),

-- HOSPITALS & HEALTH
('VSP Main Hospital', 'HOSPITAL', 17.6895, 83.2178, '300-bed hospital with emergency. 24x7. Ph: 0891-2518911', 'activity'),
('Occupational Health Centre', 'HOSPITAL', 17.6892, 83.2183, 'Pre-employment and periodic health checkups', 'activity'),
('Dispensary Sector-7', 'HOSPITAL', 17.6905, 83.2165, 'Township dispensary with pharmacy', 'activity'),
('Dispensary Gate-1', 'HOSPITAL', 17.6872, 83.2183, 'Emergency first-aid near main gate', 'activity'),
('Dental Clinic', 'HOSPITAL', 17.6897, 83.2180, 'Dental treatment for employees and families', 'activity'),

-- BANKS & ATMs
('SBI Ukkunagaram Branch', 'BANK', 17.6880, 83.2180, 'State Bank of India. IFSC: SBIN0006847', 'credit-card'),
('Canara Bank Ukkunagaram', 'BANK', 17.6887, 83.2175, 'Canara Bank branch with ATM', 'credit-card'),
('Andhra Bank (Union Bank) ATM', 'BANK', 17.6893, 83.2170, 'ATM near sector-5 market', 'credit-card'),
('RINL Cooperative Bank', 'BANK', 17.6876, 83.2165, 'Employees cooperative credit society', 'credit-card'),
('SBI ATM Plant Area', 'BANK', 17.6869, 83.2195, 'ATM inside plant near admin building', 'credit-card'),

-- TEMPLES & RELIGIOUS PLACES
('ISKCON Temple', 'TEMPLE', 17.6882, 83.2178, 'Hare Krishna temple. Daily puja 5 AM - 8 PM', 'star'),
('Sri Venkateswara Temple Sector-4', 'TEMPLE', 17.6890, 83.2185, 'Main township temple. Tirupati style.', 'star'),
('Hanuman Temple Main Gate', 'TEMPLE', 17.6875, 83.2170, 'Hanuman mandir near gate-1', 'star'),
('Sai Baba Temple Sector-6', 'TEMPLE', 17.6898, 83.2175, 'Shirdi Sai Baba temple', 'star'),
('Durga Temple Sector-2', 'TEMPLE', 17.6870, 83.2176, 'Kanaka Durga temple', 'star'),
('Mosque Ukkunagaram', 'TEMPLE', 17.6865, 83.2163, 'Jama Masjid for Muslim employees', 'star'),
('Church Ukkunagaram', 'TEMPLE', 17.6860, 83.2170, 'St. Mary''s Church', 'star'),

-- PARKS & RECREATION
('Gandhi Park (Central)', 'PARK', 17.6883, 83.2183, 'Main township park with fountain and walking track', 'sun'),
('Children''s Park Sector-3', 'PARK', 17.6892, 83.2179, 'Play area for children with swings and slides', 'sun'),
('Sports Complex', 'SPORTS', 17.6905, 83.2190, 'Indoor badminton, table tennis, gym', 'activity'),
('Football Ground', 'SPORTS', 17.6910, 83.2195, 'Full size football/cricket ground', 'activity'),
('Swimming Pool', 'SPORTS', 17.6908, 83.2187, 'Olympic size swimming pool', 'activity'),
('VSP Club (Officers Club)', 'SPORTS', 17.6902, 83.2183, 'Recreation club with billiards, chess, library', 'coffee'),
('Joggers Park Sector-8', 'PARK', 17.6912, 83.2175, '1.5 km jogging track with open gym', 'sun'),
('Rose Garden', 'PARK', 17.6886, 83.2190, 'Botanical garden with flower beds', 'sun'),

-- CANTEENS & FOOD
('Plant Canteen-1 (SMS Area)', 'CANTEEN', 17.6880, 83.2206, 'Main shift canteen near steel melt shop', 'coffee'),
('Plant Canteen-2 (Blast Furnace)', 'CANTEEN', 17.6873, 83.2193, 'Canteen near blast furnace complex', 'coffee'),
('Admin Canteen', 'CANTEEN', 17.6890, 83.2183, 'Executive canteen in admin building', 'coffee'),
('Ukkunagaram Market Canteen', 'CANTEEN', 17.6896, 83.2168, 'Township market area food stalls', 'coffee'),
('Gate-1 Tea Stall', 'CANTEEN', 17.6867, 83.2187, 'Popular tea stall near main gate', 'coffee'),
('Night Shift Canteen', 'CANTEEN', 17.6876, 83.2199, 'Open 24x7 for night shift workers', 'coffee'),

-- MORE PLANT SUPPORT
('Fire Station', 'PLANT', 17.6863, 83.2197, '24x7 fire brigade. Emergency: 0891-2518999', 'alert-triangle'),
('Ambulance Bay', 'HOSPITAL', 17.6866, 83.2194, 'Emergency ambulance parking and dispatch', 'activity'),
('Central Stores', 'PLANT', 17.6860, 83.2185, 'Main warehouse for plant spares and consumables', 'archive'),
('Scrap Yard', 'PLANT', 17.6840, 83.2220, 'Steel scrap collection and recycling yard', 'trash-2'),
('Slag Processing', 'PLANT', 17.6836, 83.2225, 'Blast furnace slag granulation plant', 'layers'),
('By-Product Plant', 'PLANT', 17.6858, 83.2192, 'Coal chemical by-products recovery', 'flask'),
('Refractory Store', 'PLANT', 17.6854, 83.2200, 'Refractory bricks and materials store', 'archive'),
('Electrical Sub-station-1', 'PLANT', 17.6876, 83.2204, 'Main 220KV receiving substation', 'zap'),
('Electrical Sub-station-2', 'PLANT', 17.6882, 83.2217, 'Distribution substation for rolling mills', 'zap'),
('Hydraulics Workshop', 'PLANT', 17.6869, 83.2210, 'Hydraulic systems maintenance', 'tool'),
('Instrumentation Workshop', 'PLANT', 17.6872, 83.2198, 'Control systems and instruments maintenance', 'sliders'),
('Transport Department', 'OFFICE', 17.6856, 83.2177, 'Bus and vehicle fleet management', 'truck'),
('Main Workshop (MWS)', 'PLANT', 17.6867, 83.2206, 'Heavy fabrication and machining shop', 'tool'),
('Training Hall-1', 'OFFICE', 17.6879, 83.2175, 'Conference and training room Block-A', 'users'),
('Guest House', 'OFFICE', 17.6903, 83.2176, 'Official guest accommodation', 'home'),
('Post Office Ukkunagaram', 'OFFICE', 17.6888, 83.2166, 'India Post branch inside township', 'mail'),
('Petrol Pump', 'OFFICE', 17.6864, 83.2180, 'HPCL fuel station for plant vehicles', 'truck'),
('CISF Barracks', 'OFFICE', 17.6852, 83.2182, 'Central Industrial Security Force quarters', 'shield'),
('Union Office (RINL Employees)', 'OFFICE', 17.6894, 83.2172, 'Trade union meeting and activity room', 'users'),
('Welfare Centre', 'OFFICE', 17.6901, 83.2169, 'Employee welfare schemes and grievance', 'heart'),
('Library (Township)', 'OFFICE', 17.6897, 83.2174, 'Public library with newspapers and books', 'book-open'),
('Auditorium', 'OFFICE', 17.6899, 83.2180, '500-seat auditorium for cultural events', 'music'),
('Shopping Complex Sector-5', 'OFFICE', 17.6893, 83.2163, 'Departmental stores and shops', 'shopping-bag'),
('LPG Distribution Centre', 'OFFICE', 17.6885, 83.2162, 'Cylinder booking and distribution', 'package');

-- ============================================================
-- SEED DATA: MACHINES
-- ============================================================
INSERT INTO machines (machine_name, machine_code, department, location_name, status, capacity_tph, last_maintenance, next_maintenance, operator_name, notes) VALUES
('Blast Furnace-1', 'BF-01', 'Iron Making', 'Blast Furnace Complex', 'RUNNING', 450.00, '2026-01-15', '2026-04-15', 'K. Ramaiah', 'Operating at 95% capacity'),
('Blast Furnace-2', 'BF-02', 'Iron Making', 'Blast Furnace Complex', 'RUNNING', 450.00, '2026-02-10', '2026-05-10', 'P. Suresh', 'Normal operation'),
('Blast Furnace-3', 'BF-03', 'Iron Making', 'Blast Furnace Complex', 'MAINTENANCE', 450.00, '2026-03-01', '2026-03-30', 'T. Venkat', 'Planned reline maintenance in progress'),
('LD Converter-1 (SMS-I)', 'LD-01', 'Steel Making', 'Steel Melt Shop-I', 'RUNNING', 300.00, '2026-01-20', '2026-04-20', 'M. Krishna', 'Tap-to-tap 35 min'),
('LD Converter-2 (SMS-I)', 'LD-02', 'Steel Making', 'Steel Melt Shop-I', 'RUNNING', 300.00, '2026-02-15', '2026-05-15', 'R. Prasad', 'Running normally'),
('LD Converter-3 (SMS-II)', 'LD-03', 'Steel Making', 'Steel Melt Shop-II', 'IDLE', 300.00, '2026-02-28', '2026-05-28', 'S. Rao', 'Idle - no charge material'),
('Continuous Caster-1', 'CC-01', 'Steel Making', 'Continuous Casting Shop', 'RUNNING', 180.00, '2026-01-25', '2026-04-25', 'D. Naidu', '6-strand billet caster'),
('Continuous Caster-2', 'CC-02', 'Steel Making', 'Continuous Casting Shop', 'RUNNING', 180.00, '2026-02-05', '2026-05-05', 'G. Raju', 'Bloom caster running'),
('Hot Strip Mill Main Drive', 'HSM-01', 'Rolling', 'Hot Strip Mill', 'RUNNING', 250.00, '2026-01-10', '2026-04-10', 'B. Srinivas', '1450mm mill, 7 stands'),
('Finishing Mill HSM', 'HSM-FM', 'Rolling', 'Hot Strip Mill', 'BREAKDOWN', 250.00, '2026-03-10', '2026-03-15', 'C. Mohan', 'Stand F4 bearing failure - repair in progress'),
('Wire Rod Mill Block', 'WRM-01', 'Rolling', 'Wire Rod Mill', 'RUNNING', 80.00, '2026-02-20', '2026-05-20', 'A. Subramaniam', '45mm to 5.5mm reduction'),
('Medium Merchant Mill', 'MMM-01', 'Rolling', 'Medium Merchant Mill', 'RUNNING', 120.00, '2026-01-30', '2026-04-30', 'V. Lakshman', 'Angles and channels production'),
('Coke Oven Battery-1', 'COB-01', 'Coke Ovens', 'Coke Oven Batteries', 'RUNNING', 200.00, '2026-02-01', '2026-05-01', 'H. Kishore', '67 ovens, 18hr coking time'),
('Coke Oven Battery-2', 'COB-02', 'Coke Ovens', 'Coke Oven Batteries', 'RUNNING', 200.00, '2026-02-01', '2026-05-01', 'J. Prasad', 'Normal operation'),
('Sinter Machine-1', 'SM-01', 'Sinter Plant', 'Sinter Plant', 'RUNNING', 350.00, '2026-01-05', '2026-04-05', 'N. Babu', '312m² strand'),
('Sinter Machine-2', 'SM-02', 'Sinter Plant', 'Sinter Plant', 'OFFLINE', 350.00, '2026-03-12', '2026-03-20', 'O. Reddy', 'Annual shutdown - electrical works'),
('Oxygen Plant-1', 'OP-01', 'Oxygen Plant', 'Oxygen Plant', 'RUNNING', 0.00, '2026-02-25', '2026-05-25', 'Q. Sharma', '1000 TPD oxygen plant'),
('Turbo Generator-1', 'TG-01', 'Power Plant', 'Power Plant (PP-1)', 'RUNNING', 0.00, '2026-01-18', '2026-04-18', 'U. Rao', '67.5 MW TG set'),
('Turbo Generator-2', 'TG-02', 'Power Plant', 'Power Plant (PP-1)', 'RUNNING', 0.00, '2026-02-18', '2026-05-18', 'W. Kumar', '67.5 MW TG set'),
('Lime Kiln-1', 'LK-01', 'Lime Plant', 'Lime Calcining Plant (LCP)', 'RUNNING', 60.00, '2026-02-12', '2026-05-12', 'X. Patel', 'Rotary kiln 450 TPD'),
('Structural Mill', 'STR-01', 'Rolling', 'Structural Mill', 'IDLE', 90.00, '2026-03-05', '2026-06-05', 'Y. Nair', 'Waiting for billet input'),
('Special Bar Mill', 'SBM-01', 'Rolling', 'Special Bar Mill (SBM)', 'RUNNING', 70.00, '2026-02-22', '2026-05-22', 'Z. Mishra', 'Spring steel grade running');

-- ============================================================
-- SEED DATA: SAMPLE LOST & FOUND
-- ============================================================
INSERT INTO lost_found (item_name, description, location_name, contact_name, contact_phone, item_type, status, date_reported) VALUES
('Identity Card', 'RINL employee ID card - blue color', 'Gate-1 Area', 'Security Office', '0891-2518700', 'FOUND', 'OPEN', '2026-03-10'),
('Mobile Phone', 'Samsung Galaxy - black cover with crack', 'SMS-I Canteen', 'K. Ramaiah', '9849012345', 'LOST', 'OPEN', '2026-03-12'),
('Safety Helmet', 'Yellow helmet with name R. Prasad', 'Blast Furnace Area', 'R. Prasad', '9848023456', 'LOST', 'RESOLVED', '2026-03-08'),
('Tiffin Box', 'Steel dabba with blue lid', 'Admin Canteen', 'Security Office', '0891-2518700', 'FOUND', 'OPEN', '2026-03-13'),
('Bicycle', 'Black Hero cycle - lock broken', 'Sector-4 Park', 'T. Venkat', '9441034567', 'LOST', 'OPEN', '2026-03-11');

-- ============================================================
-- SEED DATA: SAMPLE ACCIDENT REPORTS
-- ============================================================
INSERT INTO accident_reports (reporter_name, reporter_id, department, location_name, accident_type, severity, description, injured_persons, first_aid_given, reported_to_supervisor, incident_date, incident_time, status) VALUES
('P. Suresh Kumar', 'VSP-12345', 'Steel Making', 'Steel Melt Shop-I', 'MINOR_INJURY', 'LOW', 'Operator slipped on wet floor near converter. Minor bruise on left knee. First aid administered at OHC.', 1, TRUE, TRUE, '2026-03-10', '14:30:00', 'RESOLVED'),
('M. Venkata Rao', 'VSP-23456', 'Rolling', 'Hot Strip Mill', 'NEAR_MISS', 'MEDIUM', 'A coil end struck near operator position. No injury. Safety guards found misaligned. Guards realigned immediately.', 0, FALSE, TRUE, '2026-03-12', '09:15:00', 'UNDER_INVESTIGATION'),
('Security Office', NULL, 'Security', 'Main Gate-1', 'PROPERTY_DAMAGE', 'LOW', 'Contractor vehicle side mirror damaged while entering gate. Vehicle driver at fault. Damage assessed.', 0, FALSE, TRUE, '2026-03-13', '07:45:00', 'REPORTED');
