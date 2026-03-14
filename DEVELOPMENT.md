# VSP Smart Portal - Development Setup Guide

## 🎯 Project Architecture

```
VSP Smart Portal
├── Frontend (Static HTML/CSS/JS) → http://localhost:3000
├── Backend (FastAPI Python) → http://localhost:8000
├── Database (MySQL) → localhost:3306
└── Docker (Containerization)
```

---

## 🚀 Quick Start (5 minutes)

### Option 1: Docker (Recommended for Full Stack)
```bash
# Start all services
docker-compose up -d

# Check status
docker-compose ps

# View logs
docker-compose logs -f

# Stop all
docker-compose down
```

### Option 2: Local Development (Python + Live Server)

#### Terminal 1: Backend Server
```bash
cd backend

# First time: Create virtual environment
python -m venv venv
.\venv\Scripts\activate  # Windows
source venv/bin/activate  # Mac/Linux

# Install dependencies
pip install -r requirements.txt

# Start FastAPI with auto-reload
uvicorn main:app --reload --port 8000
```

#### Terminal 2: Frontend Server
```bash
cd frontend

# Start simple HTTP server
python server.py
# Access at: http://localhost:3000
```

#### Terminal 3: Database (Docker only)
```bash
docker run --name vsp_mysql -d \
  -p 3306:3306 \
  -e MYSQL_ROOT_PASSWORD=vsp2026 \
  -e MYSQL_DATABASE=vsp_portal \
  -v ./database/init.sql:/docker-entrypoint-initdb.d/init.sql \
  mysql:8.0
```

---

## 🔧 VS Code Setup

### 1. Install Extensions
- **Python** (ms-python.python)
- **Pylance** (ms-python.vscode-pylance)
- **Thunder Client** or **REST Client** (for API testing)
- **MySQL** (cweijan.vscode-mysql-client2)
- **Docker** (ms-vscode.docker)
- **Prettier** (esbenp.prettier-vscode)

### 2. VS Code Settings
Settings are automatically configured in `.vscode/settings.json`

### 3. Debug Configurations
Press **F5** and select:
- **Python: FastAPI Backend** - Starts backend with auto-reload
- **Browser: Frontend** - Opens frontend in Chrome
- **Full Stack Debug** - Runs both together

---

## 📡 API Endpoints Reference

### Base URLs
- **Development**: `http://localhost:8000`
- **Production**: `http://YOUR_IP:8000`

### Interactive API Docs
- **Swagger UI**: http://localhost:8000/docs
- **ReDoc**: http://localhost:8000/redoc

### Key Endpoints

#### Locations (Township Map)
```
GET  /api/locations           - List all 150+ VSP locations
POST /api/locations           - Add new location
GET  /api/locations/{id}      - Get location details
```

#### Lost & Found
```
POST /api/lost-found          - Report lost/found item
GET  /api/lost-found          - List all reports
GET  /api/lost-found/{id}     - Get report details
PUT  /api/lost-found/{id}     - Update report status
```

#### Accident Reports
```
POST /api/accidents           - File accident report
GET  /api/accidents           - List all reports
GET  /api/accidents/{id}      - Get report details
```

#### Machines
```
GET  /api/machines            - List all machines
POST /api/machines            - Add new machine
PUT  /api/machines/{id}       - Update machine status
```

---

## 🗄️ Database Connection

### Connect from VS Code
1. Press **Ctrl+Shift+P** → Search **MySQL: Add Connection**
2. **Host**: localhost
3. **Port**: 3306
4. **User**: root
5. **Password**: vsp2026
6. **Database**: vsp_portal

### Direct MySQL CLI
```bash
docker-compose exec mysql mysql -uroot -pvsp2026 vsp_portal

# Or if running locally
mysql -h localhost -u root -pvsp2026 vsp_portal
```

### Sample Queries
```sql
-- View all locations (150+ VSP places)
SELECT * FROM locations;

-- Count by category
SELECT category, COUNT(*) FROM locations GROUP BY category;

-- View lost & found reports
SELECT * FROM lost_found WHERE status='OPEN';

-- View accident reports
SELECT * FROM accident_reports ORDER BY created_at DESC;

-- View machines
SELECT * FROM machines WHERE status='RUNNING';
```

---

## 🧪 Testing Checklist

### ✅ Automated Tests
```bash
# Run all tests
cd backend
pytest

# Run specific test
pytest tests/test_locations.py -v

# With coverage
pytest --cov=.
```

### ✅ Manual Testing

#### 1. **Backend Health**
```bash
# Should return 200 OK
curl http://localhost:8000/docs
curl http://localhost:8000/api/health
```

#### 2. **Frontend Load**
- Open http://localhost:3000 in browser
- Should see VSP Smart Portal dashboard
- Check browser console for errors (F12)

#### 3. **Database Connection**
```bash
curl http://localhost:8000/api/locations
# Should return JSON array with 150+ locations
```

#### 4. **Forms (Full Workflow)**

**Lost & Found:**
1. Navigate to "Lost & Found" tab
2. Fill form: Item name, description, contact
3. Submit
4. Check database: `SELECT * FROM lost_found WHERE status='OPEN';`
5. Item should appear

**Accident Report:**
1. Navigate to "Accident Report" tab
2. Select location from dropdown (real VSP gates)
3. Select accident type and severity
4. Submit with details
5. Check database: `SELECT * FROM accident_reports ORDER BY created_at DESC;`

**Township Map:**
1. Click "Township Map" tab
2. Should load interactive map
3. Click on markers to see 150+ real VSP locations
4. Filter by category (GATE, PLANT, HOSPITAL, etc.)

#### 5. **API Testing in Thunder Client**

**Test Create Lost & Found:**
```
POST http://localhost:8000/api/lost-found
Content-Type: application/json

{
  "item_name": "Blue Wallet",
  "description": "Contains ID card and ATM card",
  "location_name": "Main Gate-1",
  "contact_name": "John Doe",
  "contact_phone": "9876543210",
  "item_type": "LOST"
}
```

**Test Create Accident Report:**
```
POST http://localhost:8000/api/accidents
Content-Type: application/json

{
  "reporter_name": "Supervisor Name",
  "department": "Blast Furnace",
  "location_name": "Main Gate-1",
  "accident_type": "MINOR_INJURY",
  "severity": "LOW",
  "description": "Minor cut on hand",
  "injured_persons": 1,
  "incident_date": "2026-03-14",
  "incident_time": "14:30:00"
}
```

---

## 🔄 Development Workflow

### Hot Reload (Automatic Restart)

**Backend (FastAPI):**
```bash
uvicorn main:app --reload
```
- Auto-restarts when you modify Python files
- Errors shown in terminal immediately

**Frontend (Browser):**
```bash
# Manual: Ctrl+Shift+R (Hard refresh)
# Or use live-reload extension
```

### Code Changes During Development

**Scenario 1: Fix bug in backend API**
1. Edit Python file in `backend/main.py`
2. FastAPI auto-reloads (watch terminal)
3. Refresh browser or API client (Thunder Client)
4. Test fix

**Scenario 2: Update frontend UI**
1. Edit HTML/CSS/JS in `frontend/`
2. Hard refresh browser (Ctrl+Shift+R)
3. Changes immediately visible

**Scenario 3: Database schema changes**
1. Modify `database/init.sql`
2. Restart containers: `docker-compose down -v && docker-compose up`
3. New schema loaded automatically

---

## 📊 Monitoring & Debugging

### View Logs in Real-time
```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f backend
docker-compose logs -f mysql

# From terminal
tail -f logs/app.log
```

### Debug Backend with VS Code
1. Set breakpoint in `backend/main.py`
2. Press **F5** → Select **Python: FastAPI Backend**
3. Debugger will pause at breakpoint
4. Step through code, inspect variables

### Monitor Database
```bash
# Check database size
SELECT
    ROUND(SUM(DATA_LENGTH) / 1024 / 1024, 2) AS 'Size (MB)'
FROM
    INFORMATION_SCHEMA.TABLES
WHERE
    TABLE_SCHEMA = 'vsp_portal';

# Check table row counts
SELECT TABLE_NAME, TABLE_ROWS
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'vsp_portal';
```

### Check Docker Resource Usage
```bash
docker stats
```

---

## 🚨 Troubleshooting

### Port Already in Use
```bash
# Find process using port 3000
netstat -ano | findstr :3000

# Kill process
taskkill /PID <PID> /F
```

### Database Connection Error
```bash
# Verify MySQL is running
docker-compose ps

# Restart database
docker-compose restart mysql

# Check connection
docker-compose exec mysql mysql -uroot -pvsp2026 -e "SELECT 1"
```

### Backend Won't Start
```bash
# Check Python version
python --version  # Should be 3.8+

# Check dependencies
pip list | grep -i fastapi

# Reinstall dependencies
pip install --upgrade -r requirements.txt
```

### Frontend Shows 404
```bash
# Verify file paths in index.html
# Check browser console for failed requests
# Ensure frontend server is running (should see "python server.py" output)
```

---

## 📱 Mobile Testing (Optional)

### Local Network Access
1. Find your PC IP: `ipconfig | findstr IPv4`
2. On phone (same WiFi): `http://YOUR_PC_IP:3000`
3. Test forms, permissions, responsive layout

---

## 🎓 Next Steps

1. **Frontend Enhancement**: Add TypeScript, React, or Vue for better UX
2. **Backend Features**: Add user authentication, file uploads, email notifications
3. **Database**: Add more tables (Users, Maintenance logs, Notifications)
4. **DevOps**: Set up CI/CD pipeline, automated testing
5. **Mobile App**: Create React Native or Flutter app
6. **Analytics**: Add dashboards for accident trends, machine utilization

---

## 📞 Quick Commands Reference

```bash
# Start everything
docker-compose up -d

# Check status
docker-compose ps

# View logs
docker-compose logs -f

# Stop everything
docker-compose down

# Stop and remove volumes (clean slate)
docker-compose down -v

# Rebuild images
docker-compose build

# Access database
docker-compose exec mysql mysql -uroot -pvsp2026 vsp_portal

# Restart specific service
docker-compose restart backend
docker-compose restart mysql
```

---

**Happy coding! 🚀 For questions, check the README.md or open an issue.**
