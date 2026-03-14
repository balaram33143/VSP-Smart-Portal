# VSP Smart Portal - Service Status & Quick Commands

## 🟢 Currently Running Services

### Frontend Server
- **URL**: http://localhost:3000
- **Status**: ✅ Running (Python HTTP Server)
- **Files Served**: HTML, CSS, JavaScript from `/frontend` directory
- **Stop**: `Ctrl+C` in frontend terminal
- **Restart**: `python frontend/server.py`

### Backend API
- **URL**: http://localhost:8000
- **API Docs**: http://localhost:8000/docs (Swagger UI)
- **Status**: ✅ Running (FastAPI)
- **Stop**: `docker-compose stop backend`
- **Restart**: `docker-compose restart backend`
- **Dev Mode**: `cd backend && uvicorn main:app --reload --port 8000`

### MySQL Database
- **Host**: localhost
- **Port**: 3306
- **User**: root
- **Password**: vsp2026
- **Database**: vsp_portal
- **Status**: ✅ Running (Docker)
- **Data**: 150+ VSP locations pre-loaded
- **Stop**: `docker-compose stop mysql`
- **Access**: `docker-compose exec mysql mysql -uroot -pvsp2026 vsp_portal`

---

## 🎯 Immediate Testing

### Test 1: Frontend Loads
```bash
# In browser
http://localhost:3000
```
✅ You should see VSP Smart Portal dashboard with 4 tabs:
- Dashboard
- Township Map
- Lost & Found
- Accident Report

### Test 2: API is Working
```bash
# In browser or Terminal
http://localhost:8000/docs
# Or
curl http://localhost:8000/api/locations
```
✅ Should return JSON array with 150+ VSP locations

### Test 3: Database Connected
```bash
# Terminal
docker-compose exec mysql mysql -uroot -pvsp2026 vsp_portal -e "SELECT COUNT(*) as total_locations FROM locations;"
```
✅ Should return: `total_locations = 150`

### Test 4: Forms Save to Database
1. Go to http://localhost:3000 → Lost & Found
2. Fill form: Item name, description, contact phone
3. Click Submit
4. Terminal: `docker-compose exec mysql mysql -uroot -pvsp2026 vsp_portal -e "SELECT * FROM lost_found;"`
✅ Your entry should appear in results

---

## 💾 Database Queries (Quick Reference)

```sql
-- All available locations in TSP
SELECT COUNT(*) FROM locations;

-- View specific location
SELECT * FROM locations WHERE category='GATE' LIMIT 5;

-- Lost & found reports
SELECT * FROM lost_found WHERE status='OPEN';

-- Accident reports
SELECT * FROM accident_reports ORDER BY created_at DESC LIMIT 10;

-- Machine status
SELECT machine_name, status FROM machines;
```

### Run queries from terminal:
```bash
docker-compose exec mysql mysql -uroot -pvsp2026 vsp_portal -e "SELECT * FROM locations LIMIT 5;"
```

---

## 🛠️ Development Shortcuts

### Terminal Windows Setup
**Option A: Automated (Windows only)**
```bash
# Double-click this file
dev.bat
```

**Option B: Manual Setup**

Terminal 1 - Frontend:
```bash
cd frontend
python server.py
# Runs on http://localhost:3000
```

Terminal 2 - Backend (optional, already in Docker):
```bash
cd backend
python -m venv venv
.\venv\Scripts\activate
pip install -r requirements.txt
uvicorn main:app --reload --port 8000
```

Terminal 3 - Database Monitor (optional):
```bash
docker-compose logs -f mysql
```

---

## 📂 File Editing Quick Guide

### Modify Frontend UI
```
frontend/
├── index.html          ← Main page structure
├── css/
│   └── style.css       ← All styling
└── js/
    ├── api.js          ← API calls to backend
    └── app.js          ← UI logic & interactions
```

**To make changes:**
1. Edit file (e.g., `css/style.css`)
2. Save (Ctrl+S)
3. Refresh browser: `Ctrl+Shift+R` (hard refresh)
4. Changes take effect immediately

### Modify Backend API
```
backend/
└── main.py            ← All API endpoints
```

**To make changes:**
1. Edit `main.py`
2. FastAPI auto-reloads (watch terminal for "Uvicorn reloaded")
3. Test with: `curl http://localhost:8000/docs`
4. Changes take effect immediately

### Modify Database
```
database/
└── init.sql           ← Schema & seed data
```

**To make changes:**
1. Edit `init.sql`
2. Restart Docker: `docker-compose down -v && docker-compose up -d`
3. Database reinitializes with new data

---

## 🔍 Using VS Code Debugger

### Debug Frontend (JavaScript)
1. Press `F5` or go to Run → Start Debugging
2. Select "Browser: Frontend"
3. Browser opens with debugger attached
4. Set breakpoints in `frontend/js/*.js`

### Debug Backend (Python)
1. Press `F5` or go to Run → Start Debugging
2. Select "Python: FastAPI Backend"
3. Terminal shows debugger ready
4. Set breakpoints in `backend/main.py`
5. Trigger API endpoint to hit breakpoint

### Debug Both (Full Stack)
1. Press `F5`
2. Select "Full Stack Debug"
3. Starts both frontend & backend debuggers

---

## 🚀 Common Development Tasks

### Task: Add New Database Field
1. Edit `database/init.sql` (add COLUMN to table)
2. `docker-compose down -v`
3. `docker-compose up -d`
4. Update `backend/main.py` to handle new field
5. Update `frontend/js/app.js` to show new field in form

### Task: Create New API Endpoint
1. Edit `backend/main.py`
2. Add new `@app.get()` or `@app.post()` function
3. Auto-reload happens
4. Test in http://localhost:8000/docs (Swagger)
5. Update frontend to call new endpoint

### Task: Modify Form Validation
1. Edit `backend/main.py` (Pydantic models)
2. Edit `frontend/js/app.js` (client-side validation)
3. Test form with edge cases

### Task: Add Styling
1. Edit `frontend/css/style.css`
2. Refresh browser: `Ctrl+Shift+R`
3. See changes immediately

---

## 🐛 Troubleshooting

### "Address already in use" - Port 3000/8000 Occupied
```bash
# Find what's using the port
netstat -ano | findstr :3000

# Kill the process (Windows)
taskkill /PID <PID> /F

# Or choose different port in server.py
```

### "Cannot connect to Docker" - MySQL Unreachable
```bash
# Check if container is running
docker-compose ps

# Restart database
docker-compose restart mysql

# View logs
docker-compose logs mysql
```

### "ModuleNotFoundError" - Missing Python packages
```bash
# Reinstall backend dependencies
cd backend
pip install -r requirements.txt
```

### Frontend Shows Blank/404
```bash
# Hard refresh browser
Ctrl+Shift+R

# Check console for errors
F12 in browser → Console tab

# Verify server is running
curl http://localhost:3000
```

---

## 📋 Full Setup Checklist

- [x] Docker running (3 containers: mysql, backend)
- [x] Frontend server running (port 3000)
- [x] Backend API running (port 8000)
- [x] Database populated (150+ VSP locations)
- [x] VS Code configured with debug launch configs
- [x] Test basic connectivity (all green)

**Next: Start developing! Pick any file and make changes.**

---

## 📞 Getting Help

### Check Logs
```bash
# All services
docker-compose logs

# Specific service
docker-compose logs backend
docker-compose logs mysql

# Live tail
docker-compose logs -f
```

### Test API
```bash
# List all locations
curl http://localhost:8000/api/locations | python -m json.tool

# Create lost & found report
curl -X POST http://localhost:8000/api/lost-found \
  -H "Content-Type: application/json" \
  -d '{"item_name":"Phone","description":"Black iPhone","location_name":"Main Gate","contact_name":"John","contact_phone":"9876543210","item_type":"LOST"}'
```

### Check Database
```bash
# List all tables
docker-compose exec mysql mysql -uroot -pvsp2026 vsp_portal -e "SHOW TABLES;"

# Check table structure
docker-compose exec mysql mysql -uroot -pvsp2026 vsp_portal -e "DESC locations;"
```

---

**Last Updated**: 2026-03-14  
**Status**: ✅ All systems operational
