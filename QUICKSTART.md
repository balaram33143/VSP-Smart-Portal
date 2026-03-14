# HOW TO RUN VSP SMART PORTAL

## FASTEST WAY (30 seconds)

```bash
# Navigate to project
cd C:\Users\varma\Downloads\vsp-smart-portal\vsp-smart-portal

# Start everything
docker-compose up -d

# Wait 30 seconds, then open browser
http://localhost:8000
```

✅ You'll see: **VSP Smart Portal Dashboard**

---

## OPTION 1: Docker (Recommended)

### Prerequisites
- Docker Desktop installed
- Port 3000, 8000, 3306 available

### Steps

```bash
# 1. Navigate to project folder
cd C:\Users\varma\Downloads\vsp-smart-portal\vsp-smart-portal

# 2. Start all services (MySQL + FastAPI)
docker-compose up -d

# 3. Wait 30 seconds for MySQL to initialize

# 4. Check status (should all be green)
docker-compose ps

# 5. Open browser
http://localhost:8000
```

### Stop
```bash
docker-compose down
```

---

## OPTION 2: Local Development (3 Terminals)

### Terminal 1 - Backend (FastAPI)
```bash
cd C:\Users\varma\Downloads\vsp-smart-portal\vsp-smart-portal\backend

# First time: create virtual environment
python -m venv venv
.\venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Start server (auto-reloads on file changes)
uvicorn main:app --reload --port 8000
```

### Terminal 2 - Frontend (HTTP Server)
```bash
cd C:\Users\varma\Downloads\vsp-smart-portal\vsp-smart-portal\frontend

# Start server on port 3000
python server.py
```

### Terminal 3 - Database (Docker)
```bash
cd C:\Users\varma\Downloads\vsp-smart-portal\vsp-smart-portal

# Start MySQL only
docker run --name mysql -d -p 3306:3306 \
  -e MYSQL_ROOT_PASSWORD=vsp2026 \
  -e MYSQL_DATABASE=vsp_portal \
  -v $(pwd)\database\init.sql:/docker-entrypoint-initdb.d/init.sql \
  mysql:8.0
```

### Open Browser
```
http://localhost:3000
```

---

## VERIFY IT'S WORKING

### Check All Services Running
```bash
docker-compose ps
```

Expected output:
```
NAME          IMAGE              STATUS
vsp_backend   vsp-smart-portal   Up 5 minutes
vsp_mysql     mysql:8.0          Up 7 minutes (healthy)
```

### Test API
```bash
curl http://localhost:8000/docs
```

Should open Swagger UI with all endpoints

### Test Database
```bash
docker-compose exec mysql mysql -uroot -pvsp2026 vsp_portal -e "SELECT COUNT(*) FROM locations;"
```

Expected: `150` (150 VSP locations loaded)

---

## WHAT YOU'LL SEE

Open http://localhost:3000 or http://localhost:8000

### Dashboard (Home Tab)
- VSP Smart Portal header
- Quick stats: Total locations, Lost items, Accident reports
- 4 navigation tabs

### Township Map Tab
- Interactive map showing 150+ real VSP/RINL locations
- Categories: Plants, Gates, Schools, Hospitals, Banks, Temples, Parks, Canteens
- Click on markers to see details

### Lost & Found Tab
- Form to report lost/found items
- Location dropdown (populated from database)
- Submit button saves to database
- List view of all reports

### Accident Report Tab
- Form to report incidents
- Location, type, severity selection
- Description and injured persons count
- Saves to database

---

## COMMON COMMANDS

```bash
# Start everything
docker-compose up -d

# Stop everything
docker-compose down

# View logs in real-time
docker-compose logs -f

# View backend logs only
docker-compose logs backend -f

# Restart a service
docker-compose restart backend

# Connect to MySQL database
docker-compose exec mysql mysql -uroot -pvsp2026 vsp_portal

# Run SQL query
docker-compose exec mysql mysql -uroot -pvsp2026 vsp_portal -e "SELECT * FROM locations LIMIT 5;"

# Backup database
docker-compose exec mysql mysqldump -uroot -pvsp2026 vsp_portal > backup.sql

# Restore backup
docker-compose exec mysql mysql -uroot -pvsp2026 vsp_portal < backup.sql
```

---

## TROUBLESHOOTING

### Port Already in Use
```bash
# Find what's using port 3000
netstat -ano | findstr :3000

# Kill the process
taskkill /PID <PID> /F
```

### Docker Won't Start
```bash
# Make sure Docker Desktop is running
# Or restart it: docker-compose down && docker-compose up -d
```

### MySQL Connection Error
```bash
# Restart MySQL
docker-compose restart mysql

# View MySQL logs
docker-compose logs mysql
```

### API Returns "Connection Refused"
```bash
# Make sure backend is running
# Terminal with fastapi should show: "Uvicorn running on http://0.0.0.0:8000"

# Test it:
curl http://localhost:8000/docs
```

### Frontend Shows Blank
```bash
# Hard refresh browser
Ctrl + Shift + R

# Check console for errors
F12 → Console tab
```

---

## DEVELOPMENT TIPS

### Edit Frontend (HTML/CSS/JS)
1. Edit file in `frontend/` folder
2. Refresh browser: `Ctrl+Shift+R`
3. Changes visible immediately

### Edit Backend (Python)
1. Edit file in `backend/main.py`
2. FastAPI auto-reloads (watch terminal)
3. Refresh API call or browser
4. Changes take effect

### Add New Database Field
1. Edit `database/init.sql`
2. Run: `docker-compose down -v`
3. Run: `docker-compose up -d`
4. Database schema reset with new fields

---

## NEXT STEPS

✅ **Get it running**
- Pick Option 1 or 2 above
- Run the commands
- Open browser to http://localhost:3000

✅ **Test the app**
- Try Lost & Found form
- Check Township Map
- File an Accident Report
- Verify data in database

✅ **Make changes**
- Edit frontend files
- Modify backend APIs
- Update database

✅ **Deploy**
- See DEPLOY.md for Railway/Render/AWS instructions

---

**Status**: ✅ Ready to run!
