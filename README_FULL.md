# 🏭 VSP Township & Steel Plant Smart Portal

**Full-stack production-ready application for RINL Vizag Steel Plant Township Management**

[![Docker](https://img.shields.io/badge/Docker-Ready-2496ED?logo=docker)](https://www.docker.com/)
[![Python](https://img.shields.io/badge/FastAPI-0.111-009688?logo=python)](https://fastapi.tiangolo.com/)
[![MySQL](https://img.shields.io/badge/MySQL-8.0-4479A1?logo=mysql)](https://www.mysql.com/)
[![License](https://img.shields.io/badge/License-MIT-green)](#license)

---

## 🚀 **Quick Start (90 Seconds)**

```bash
# Clone repository
git clone https://github.com/balaram33143/VSP-Smart-Portal.git
cd VSP-Smart-Portal

# Copy environment
cp .env.example .env

# Start everything with Docker
docker-compose up -d --build

# Wait 30 seconds, then open browser
```

**Access Points:**
- 🌐 **Frontend Dashboard**: [http://localhost:3000](http://localhost:3000)
- 🌐 **Alternative Frontend**: [http://localhost:8000](http://localhost:8000)
- ⚙️ **API Documentation**: [http://localhost:8000/docs](http://localhost:8000/docs)
- 🐬 **Database**: `mysql://root:vsp2026@localhost:3306/vsp_portal`

---

## 🎯 **Features**

### 📍 **Township Map**
- Interactive Leaflet map with **102+ real VSP/RINL locations**
- Real coordinates for all gates, plants, schools, hospitals, banks, temples
- Category filtering (Plant, Gate, School, Hospital, Bank, Temple, etc.)
- Click markers for detailed location information

### 🔍 **Lost & Found System**
- Submit lost/found items with location and contact info
- Search and filter reports by status
- Database-backed persistent storage
- Status tracking (Open, Resolved, Closed)

### 🚨 **Accident Reporting**
- Report workplace incidents with severity levels
- Location selection from 102+ real VSP locations
- Incident type categorization
- Status workflow management
- Real-time data storage

### ⚙️ **Machine Status Dashboard**
- Monitor plant machinery status
- Real-time operational metrics
- Equipment breakdown tracking
- Status updates from field operations

### 📊 **Dashboard Analytics**
- Live statistics (Locations, Machines, Incidents)
- Quick action buttons for common tasks
- Recent activities feed
- Machine status overview

---

## 📦 **Tech Stack**

| Layer | Technology | Features |
|-------|-----------|----------|
| **Frontend** | HTML5, CSS3, JavaScript ES6 | Responsive, Dark Theme, Real-time Updates |
| **Backend** | FastAPI (Python 3.11) | Async APIs, Automatic Docs, CORS Ready |
| **Database** | MySQL 8.0 | 102+ Pre-loaded Locations, Full ACID Support |
| **DevOps** | Docker + Docker Compose | Single-command deployment, Multi-container |
| **API** | RESTful + Swagger UI | 15+ endpoints, Interactive documentation |

---

## 🏭 **Real VSP Data (102+ Locations)**

### **Plant Production Units (28+)**
- Blast Furnace Complex (BF-1,2,3)
- Steel Melt Shop-I & II (SMS)
- Hot Strip Mill (HSM)
- Wire Rod Mill (WRM)
- Coke Oven Batteries (COB)
- Continuous Casting Shop
- And 22+ more production units

### **Administrative & Support**
- **Gates**: Main Gate-1, Gate-2, Gate-3, Gate-4, Admin Gate, Contractor Gate
- **Schools**: DAV Public School, Kendriya Vidyalaya, ZPHS, ITI, VSP Junior College
- **Hospitals**: VSP Main Hospital (300-bed), Occupational Health Centre, 3 Dispensaries
- **Banks**: SBI, Canara Bank, RINL Cooperative Bank, 2 ATMs
- **Temples**: ISKCON, Sri Venkateswara, Hanuman, Sai Baba, Durga Temple, Mosque, Church
- **Recreation**: Gandhi Park, Children's Park, Sports Complex, Football Ground, Swimming Pool
- **Services**: Canteens, Post Office, Security Office, Fire Station

---

## 📡 **API Endpoints**

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/health` | Health check |
| GET | `/api/dashboard` | Dashboard statistics |
| **Locations** |
| GET | `/api/locations` | All 102+ locations |
| GET | `/api/locations/{id}` | Location details |
| **Lost & Found** |
| GET | `/api/lostfound` | All reports |
| POST | `/api/lostfound` | Create report |
| PATCH | `/api/lostfound/{id}/status` | Update status |
| DELETE | `/api/lostfound/{id}` | Delete report |
| **Accidents** |
| GET | `/api/accidents` | All reports |
| POST | `/api/accidents` | File accident report |
| PATCH | `/api/accidents/{id}/status` | Update status |
| **Machines** |
| GET | `/api/machines` | All machines |
| GET | `/api/machines/summary` | Status summary |
| PATCH | `/api/machines/{id}` | Update machine |

**Interactive API Docs**: [http://localhost:8000/docs](http://localhost:8000/docs)

---

## 🗂️ **Project Structure**

```
VSP-Smart-Portal/
├── frontend/                    # HTML/CSS/JavaScript UI
│   ├── index.html              # Main dashboard
│   ├── css/style.css           # Dark theme styling
│   ├── js/
│   │   ├── api.js              # API client
│   │   └── app.js              # UI logic
│   ├── pages/
│   │   ├── map.html            # Township map
│   │   ├── lostfound.html      # Lost & found
│   │   ├── accident.html       # Accident reporting
│   │   └── machines.html       # Machine status
│   └── server.py               # Frontend HTTP server
│
├── backend/                     # FastAPI backend
│   ├── main.py                 # All API endpoints
│   ├── requirements.txt         # Python dependencies
│   └── Dockerfile              # Backend container
│
├── database/
│   └── init.sql                # 102+ locations seed data
│
├── docker-compose.yml          # Multi-container setup
├── .env.example                # Environment variables
├── README.md                   # This file
├── QUICKSTART.md               # Quick reference
├── DEVELOPMENT.md              # Dev guide
├── DEPLOY.md                   # Production deployment
└── SERVICES.md                 # Service reference
```

---

## 🚀 **Installation Methods**

### **Option 1: Docker (Recommended)**

```bash
docker-compose up -d
```

All services start in 30 seconds. Zero configuration needed.

### **Option 2: Local Development**

```bash
# Terminal 1 - Backend
cd backend
python -m venv venv
./venv/Scripts/activate  # or source venv/bin/activate
pip install -r requirements.txt
uvicorn main:app --reload --port 8000

# Terminal 2 - Frontend
cd frontend
python server.py

# Terminal 3 - Database
docker run --name mysql -d -p 3306:3306 \
  -e MYSQL_ROOT_PASSWORD=vsp2026 \
  -e MYSQL_DATABASE=vsp_portal \
  -v $(pwd)/database/init.sql:/docker-entrypoint-initdb.d/init.sql \
  mysql:8.0
```

---

## 📊 **Database Schema**

### **locations** (102 rows)
- Real VSP/RINL coordinates
- Categories: PLANT, GATE, SCHOOL, HOSPITAL, BANK, TEMPLE, PARK, CANTEEN, OFFICE, SPORTS
- Descriptions and icons

### **lost_found**
- Item tracking
- Status workflow: OPEN → RESOLVED → CLOSED
- Contact information

### **accident_reports**
- Incident documentation
- Severity levels: LOW, MEDIUM, HIGH, CRITICAL
- Status tracking: REPORTED → UNDER_INVESTIGATION → RESOLVED → CLOSED

### **machines**
- Equipment inventory
- Status: RUNNING, IDLE, MAINTENANCE, BREAKDOWN, OFFLINE
- Maintenance schedules

---

## 🧪 **Testing**

### **Test Frontend**
```
http://localhost:3000
```
- Dashboard loads with stats
- Navigation tabs work
- CSS styling applied
- JavaScript interactive

### **Test API**
```bash
curl http://localhost:8000/api/locations | python -m json.tool
```

### **Test Database**
```bash
docker-compose exec mysql mysql -uroot -pvsp2026 vsp_portal -e "SELECT COUNT(*) FROM locations;"
# Returns: 102
```

---

## 📚 **Documentation**

- **[QUICKSTART.md](QUICKSTART.md)** - 5-minute setup guide
- **[DEVELOPMENT.md](DEVELOPMENT.md)** - Local development guide
- **[DEPLOY.md](DEPLOY.md)** - Production deployment (Railway/Render/AWS)
- **[SERVICES.md](SERVICES.md)** - Service reference & commands

---

## 🔧 **Common Commands**

```bash
# Start services
docker-compose up -d

# Check status
docker-compose ps

# View logs
docker-compose logs -f

# Restart services
docker-compose restart

# Stop everything
docker-compose down

# Database access
docker-compose exec mysql mysql -uroot -pvsp2026 vsp_portal

# Backup database
docker-compose exec mysql mysqldump -uroot -pvsp2026 vsp_portal > backup.sql

# Restore backup
docker-compose exec mysql mysql -uroot -pvsp2026 vsp_portal < backup.sql
```

---

## 🌍 **Production Deployment**

### **Railway.app (Recommended)**
- ✅ Docker-native
- ✅ Free tier available
- ✅ Auto-scaling
- 📖 See [DEPLOY.md](DEPLOY.md)

### **Render.com**
- 💰 $15/month base
- ✅ Easy setup
- ✅ GitHub integration

### **AWS**
- 💪 Full control
- 💵 $50+ monthly
- 📖 See [DEPLOY.md](DEPLOY.md)

---

## 🔒 **Security**

- ✅ CORS configured
- ✅ Environment variables for sensitive data
- ✅ Input validation (Pydantic)
- ✅ SQL injection protection
- ✅ HTTPS ready for deployment

---

## 🤝 **Contributing**

Contributions welcome! Please:
1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open Pull Request

---

## 📞 **Support**

**Issues or Questions?**
- Check [DEVELOPMENT.md](DEVELOPMENT.md) for troubleshooting
- Review [DEPLOY.md](DEPLOY.md) for deployment help
- Create GitHub issue with error details

---

## 📄 **License**

This project is licensed under the MIT License - see LICENSE file for details.

---

## 🎉 **Status**

✅ **Full-stack production app ready**
- ✅ 102+ real VSP locations
- ✅ Docker deployment working
- ✅ API fully functional
- ✅ Database populated
- ✅ Forms connected
- ✅ Mobile responsive

---

## 📍 **About VSP (RINL)**

**RINL Vizag Steel Plant** (Vizag Steel) is a major steel production facility in Visakhapatnam, India. This portal provides smart township management for employees and operations staff.

**Website**: [www.vizagsteel.com](https://www.vizagsteel.com)

---

**Made with ❤️ for RINL Vizag Steel Plant**

Last Updated: March 14, 2026
