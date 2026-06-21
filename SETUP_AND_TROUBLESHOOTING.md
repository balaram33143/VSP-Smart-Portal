# VSP Smart Portal - Setup and Troubleshooting Guide

## 🚀 Quick Start

### Prerequisites
- Python 3.13+
- MySQL 8.0+ (or Docker)
- VS Code (recommended)

### Step 1: Install Dependencies
```powershell
cd backend
py -3.13 -m pip install -r requirements.txt
```

### Step 2: Setup MySQL Database

#### Option A: Using Docker (Recommended for Windows)
```powershell
# Create MySQL container
docker run --name vsp-mysql `
  -e MYSQL_ROOT_PASSWORD=vsp2026 `
  -e MYSQL_DATABASE=vsp_portal `
  -p 3306:3306 -d mysql:8.0

# Wait for MySQL to start (30 seconds)
Start-Sleep -Seconds 30

# Initialize database
docker exec vsp-mysql mysql -u root -pvsp2026 vsp_portal < database/init.sql
```

#### Option B: Using Local MySQL
```powershell
# If MySQL is installed locally
mysql -u root -p < database/init.sql
# Password: vsp2026
```

#### Option C: Using WSL (Windows Subsystem for Linux)
```bash
wsl
cd /mnt/c/Users/varma/Downloads/VSP-Smart-Portal-main/VSP-Smart-Portal-main
mysql -u root -p < database/init.sql
```

### Step 3: Start Backend
```powershell
cd backend
py -3.13 main.py
# Server will start on http://localhost:8000
```

### Step 4: Open Frontend
```
http://localhost:8000/
```

---

## ❌ Troubleshooting

### Issue 1: "Can't connect to MySQL server"
**Symptom:** 
```
2003: Can't connect to MySQL server on 'localhost:3306'
```

**Solution:**
1. Verify MySQL is running
   ```powershell
   # Check if MySQL is running
   Get-Service MySQL* | Format-Table Name, Status
   
   # Start MySQL if stopped
   Start-Service MySQL80  # or appropriate service name
   ```

2. Check if port 3306 is available
   ```powershell
   netstat -ano | findstr :3306
   ```

3. Verify .env file has correct credentials
   ```
   DB_HOST=localhost
   DB_PORT=3306
   DB_USER=root
   DB_PASSWORD=vsp2026
   ```

### Issue 2: "ModuleNotFoundError: No module named 'fastapi'"
**Solution:**
```powershell
cd backend
py -3.13 -m pip install fastapi==0.111.0 uvicorn[standard]==0.29.0
```

### Issue 3: "API returns 500 error"
**Solution:**
1. Check backend console for error messages
2. Run test script: `py test_api.py`
3. Verify MySQL is running and database is initialized

### Issue 4: "Frontend not loading"
**Solution:**
1. Verify backend is running on port 8000
2. Check browser console for CORS errors
3. Verify API_BASE_URL is correctly set in `frontend/js/config.js`

### Issue 5: "Port 8000 already in use"
**Solution:**
```powershell
# Find what's using port 8000
netstat -ano | findstr :8000

# Kill the process (replace PID with actual PID)
taskkill /PID <PID> /F

# Or use a different port
cd backend
py -3.13 main.py --port 8001
```

---

## 📊 Testing

### Run API Tests
```powershell
py test_api.py
```

### Test Individual Endpoints
```powershell
# Health check
curl http://localhost:8000/api/health

# Get locations
curl http://localhost:8000/api/locations

# Get machines
curl http://localhost:8000/api/machines

# Get dashboard stats
curl http://localhost:8000/api/dashboard
```

### Browser DevTools
1. Open http://localhost:8000/
2. Press F12 to open DevTools
3. Check Console tab for errors
4. Check Network tab for API responses

---

## 📝 Database

### Initialize Database
```powershell
mysql -u root -pvsp2026 vsp_portal < database/init.sql
```

### View Tables
```powershell
mysql -u root -pvsp2026 vsp_portal -e "SHOW TABLES;"
mysql -u root -pvsp2026 vsp_portal -e "SELECT COUNT(*) FROM locations;"
mysql -u root -pvsp2026 vsp_portal -e "SELECT COUNT(*) FROM machines;"
```

### Reset Database
```powershell
# Drop and recreate
mysql -u root -pvsp2026 -e "DROP DATABASE IF EXISTS vsp_portal;"
mysql -u root -pvsp2026 < database/init.sql
```

### Backup Database
```powershell
mysqldump -u root -pvsp2026 vsp_portal > backup.sql
```

### Restore Database
```powershell
mysql -u root -pvsp2026 vsp_portal < backup.sql
```

---

## 🐳 Docker Commands

### Start MySQL Container
```powershell
docker run --name vsp-mysql -e MYSQL_ROOT_PASSWORD=vsp2026 -e MYSQL_DATABASE=vsp_portal -p 3306:3306 -d mysql:8.0
```

### Stop Container
```powershell
docker stop vsp-mysql
```

### Start Existing Container
```powershell
docker start vsp-mysql
```

### View Logs
```powershell
docker logs vsp-mysql
```

### Remove Container
```powershell
docker rm vsp-mysql
```

### Access MySQL in Container
```powershell
docker exec -it vsp-mysql mysql -u root -pvsp2026
```

---

## 🔗 Useful Links

- **FastAPI Docs:** http://localhost:8000/docs
- **ReDoc:** http://localhost:8000/redoc
- **API Health:** http://localhost:8000/api/health
- **Leaflet.js Map:** http://localhost:8000/pages/map.html

---

## 📂 Project Structure

```
VSP-Smart-Portal/
├── backend/
│   ├── main.py              # FastAPI server
│   ├── requirements.txt      # Python dependencies
│   └── Dockerfile           # Docker config
├── frontend/
│   ├── index.html           # Dashboard
│   ├── pages/
│   │   ├── accident.html
│   │   ├── machines.html
│   │   ├── lostfound.html
│   │   └── map.html
│   ├── js/
│   │   ├── config.js        # API configuration
│   │   ├── api.js           # API client
│   │   └── app.js           # App logic
│   └── css/
│       └── style.css        # Industrial theme
├── database/
│   └── init.sql             # Schema + seed data
├── .env                     # Environment config
└── docker-compose.yml       # Docker Compose config
```

---

## 🛠️ Development Workflow

```powershell
# Terminal 1: Start MySQL (or Docker)
docker run --name vsp-mysql -e MYSQL_ROOT_PASSWORD=vsp2026 -e MYSQL_DATABASE=vsp_portal -p 3306:3306 mysql:8.0

# Terminal 2: Start Backend
cd backend
py -3.13 main.py

# Terminal 3: Open Frontend
Start-Process http://localhost:8000
```

---

## 📚 API Documentation

Visit http://localhost:8000/docs for interactive Swagger UI

### Main Endpoints

**Dashboard**
- GET `/api/dashboard` - Overall statistics

**Locations**
- GET `/api/locations` - List all locations
- GET `/api/locations/{id}` - Get location details
- GET `/api/locations/categories` - Get categories

**Machines**
- GET `/api/machines` - List machines
- GET `/api/machines/summary` - Machine status summary
- PATCH `/api/machines/{id}` - Update machine status

**Accidents**
- GET `/api/accidents` - List accident reports
- POST `/api/accidents` - Create accident report
- PATCH `/api/accidents/{id}/status` - Update status
- GET `/api/accidents/stats` - Accident statistics

**Lost & Found**
- GET `/api/lostfound` - List items
- POST `/api/lostfound` - Report item
- PATCH `/api/lostfound/{id}/status` - Update status

---

## ⚠️ Common Errors & Solutions

| Error | Cause | Solution |
|-------|-------|----------|
| 500 Internal Server Error | Database not connected | Start MySQL and verify connection |
| CORS Error | API URL mismatch | Check `frontend/js/config.js` |
| "Module not found" | Missing dependency | Run `pip install -r requirements.txt` |
| Port already in use | Another app using port 8000 | Use different port or kill process |
| "Cannot GET /" | Frontend not served | Verify backend is running and frontend path correct |

---

**Last Updated:** 2026-06-20
