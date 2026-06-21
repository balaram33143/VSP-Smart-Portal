# VSP Smart Portal - Quick Reference Card

## 🚀 QUICK START (5 Minutes)

### Option 1: One-Command Setup (PowerShell)
```powershell
powershell -ExecutionPolicy Bypass -File setup.ps1
```

### Option 2: Manual Docker Setup
```powershell
# Terminal 1: Start MySQL in Docker
docker run --name vsp-mysql ^
  -e MYSQL_ROOT_PASSWORD=vsp2026 ^
  -e MYSQL_DATABASE=vsp_portal ^
  -p 3306:3306 -d mysql:8.0

# Wait 30 seconds...
Start-Sleep -Seconds 30

# Terminal 1: Initialize Database
docker exec vsp-mysql mysql -u root -pvsp2026 vsp_portal < database/init.sql

# Terminal 2: Start Backend
cd backend
py -3.13 main.py

# Terminal 3: Open in Browser
Start-Process http://localhost:8000
```

---

## 📚 USEFUL COMMANDS

### Database Commands
```powershell
# View tables
mysql -u root -pvsp2026 vsp_portal -e "SHOW TABLES;"

# Check locations count
mysql -u root -pvsp2026 vsp_portal -e "SELECT COUNT(*) FROM locations;"

# Backup database
mysqldump -u root -pvsp2026 vsp_portal > backup.sql

# Restore database
mysql -u root -pvsp2026 vsp_portal < backup.sql
```

### Docker Commands
```powershell
# List containers
docker ps -a

# View MySQL logs
docker logs vsp-mysql

# Stop container
docker stop vsp-mysql

# Start container
docker start vsp-mysql

# Remove container
docker rm vsp-mysql
```

### Backend Commands
```powershell
# Start backend (development)
cd backend
py -3.13 main.py

# Start backend (custom port)
py -3.13 main.py --port 8001

# Test API
py test_api.py

# View API docs
http://localhost:8000/docs
```

### Python Commands
```powershell
# Install dependencies
py -3.13 -m pip install -r requirements.txt

# List installed packages
py -3.13 -m pip list

# Upgrade pip
py -3.13 -m pip install --upgrade pip
```

---

## 🐛 TROUBLESHOOTING

### Problem: "Can't connect to MySQL"
**Solution:**
```powershell
# Check if MySQL is running
Get-Service MySQL* | Format-Table Name, Status

# Or check if Docker container is running
docker ps | findstr vsp-mysql

# Start MySQL if stopped
Start-Service MySQL80
# Or restart Docker container
docker start vsp-mysql
```

### Problem: "Port 8000 already in use"
**Solution:**
```powershell
# Find what's using port 8000
netstat -ano | findstr :8000

# Kill the process (replace PID)
taskkill /PID <PID> /F

# Or use different port
cd backend
py -3.13 main.py --port 8001
```

### Problem: "Module not found"
**Solution:**
```powershell
cd backend
py -3.13 -m pip install fastapi uvicorn[standard] mysql-connector-python python-dotenv pydantic
```

### Problem: "API returns 500 errors"
**Check:**
1. MySQL is running: `docker ps | findstr mysql` or `Get-Service MySQL*`
2. Database initialized: `mysql -u root -pvsp2026 vsp_portal -e "SHOW TABLES;"`
3. Backend logs: Look at terminal output

---

## 📊 API ENDPOINTS

| Method | Endpoint | Purpose |
|--------|----------|---------|
| GET | `/api/health` | Health check + DB status |
| GET | `/api/dashboard` | Statistics & summary |
| GET | `/api/locations` | List all locations |
| GET | `/api/locations/categories` | Location categories |
| GET | `/api/machines` | List machines |
| GET | `/api/machines/summary` | Machine status counts |
| PATCH | `/api/machines/{id}` | Update machine status |
| GET | `/api/accidents` | List accidents |
| POST | `/api/accidents` | Create accident report |
| PATCH | `/api/accidents/{id}/status` | Update accident status |
| GET | `/api/lostfound` | List lost & found items |
| POST | `/api/lostfound` | Report lost/found item |
| PATCH | `/api/lostfound/{id}/status` | Update item status |

---

## 🔗 USEFUL LINKS

- **Dashboard:** http://localhost:8000/
- **API Docs:** http://localhost:8000/docs
- **ReDoc:** http://localhost:8000/redoc
- **Map:** http://localhost:8000/pages/map.html
- **Machines:** http://localhost:8000/pages/machines.html
- **Accidents:** http://localhost:8000/pages/accident.html
- **Lost & Found:** http://localhost:8000/pages/lostfound.html

---

## 📝 CONFIGURATION

### Database Credentials
```
Host: localhost
Port: 3306
User: root
Password: vsp2026
Database: vsp_portal
```

### Backend Configuration
```
Host: 0.0.0.0
Port: 8000
API Base: http://localhost:8000
Hot Reload: Enabled
CORS: Allow All Origins
```

### Frontend Configuration
```
API URL: http://localhost:8000 (auto-detected in development)
Production: Set API_BASE_URL in js/config.js
```

---

## 📦 REQUIREMENTS

### Minimum
- Python 3.13+
- MySQL 8.0+ OR Docker

### Optional
- VS Code (recommended editor)
- Git (for version control)
- Postman (for API testing)

### System
- Windows 10+
- 2GB RAM minimum
- 500MB disk space

---

## ✅ VERIFICATION CHECKLIST

After setup, verify:

- [ ] MySQL container running: `docker ps | findstr mysql`
- [ ] Database initialized: `mysql -u root -pvsp2026 vsp_portal -e "SELECT COUNT(*) FROM locations;"`
- [ ] Backend running: `http://localhost:8000/docs` loads
- [ ] API health: `curl http://localhost:8000/api/health` shows "db": "connected"
- [ ] Dashboard loads: `http://localhost:8000/` displays data
- [ ] Map loads: `http://localhost:8000/pages/map.html` shows locations
- [ ] Forms work: Can submit accident/lost & found reports

---

## 🆘 GET HELP

### Files to Check
- **Setup issues:** Read `SETUP_AND_TROUBLESHOOTING.md`
- **API issues:** Check `backend/main.py` and backend console
- **Frontend issues:** Check browser DevTools Console (F12)
- **Database issues:** Check `database/init.sql`

### Error Locations
- Backend logs: Terminal where you ran `py -3.13 main.py`
- Frontend logs: Browser Developer Tools → Console (F12)
- MySQL logs: `docker logs vsp-mysql`

---

## 🎯 DEPLOYMENT CHECKLIST

- [ ] Code reviewed and tested
- [ ] Database setup complete
- [ ] Backend running without errors
- [ ] Frontend loads successfully
- [ ] All API endpoints working
- [ ] Forms submitting data
- [ ] Map displaying locations
- [ ] Performance acceptable
- [ ] Security configured
- [ ] Backups working

---

**Last Updated:** 2026-06-20  
**Version:** 1.0  
**Status:** Production Ready (Database Required)
