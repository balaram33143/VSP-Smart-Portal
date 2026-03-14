# 🏭 VSP Smart Portal — RINL Vizag Steel

Full-stack internal portal for RINL Vizag Steel Plant & Ukkunagaram Township.
**Stack:** Plain HTML/CSS/JS frontend · Python FastAPI backend · MySQL database

---

## ✅ Features

| Feature | Details |
|---|---|
| 🗺 Township Map | Interactive Leaflet map · 100+ real VSP/RINL locations · Category filters |
| ⚙ Plant Status | All major machines · Live status · Update from browser |
| 🔍 Lost & Found | Submit / search / resolve lost & found items |
| 🚨 Accident Report | Report incidents · Severity tracking · Status workflow |
| 📊 Dashboard | Live stats from all modules |

---

## 🚀 OPTION A — Run without Docker (VS Code, Recommended for Dev)

### Prerequisites
- Python 3.10+ installed
- MySQL 8.0 installed and running
- VS Code

### Step 1 — Setup Database
```bash
mysql -u root -p < database/init.sql
```
When prompted, enter your MySQL root password.

### Step 2 — Setup Backend
```bash
cd backend
pip install -r requirements.txt
```

Copy env file:
```bash
cp ../.env.example .env
# Edit .env with your MySQL password if different
```

Run the server:
```bash
uvicorn main:app --reload --port 8000
```

You should see:
```
INFO:     Uvicorn running on http://0.0.0.0:8000
INFO:     Application startup complete.
```

### Step 3 — Open Frontend
Open `frontend/index.html` directly in your browser — OR install the
**Live Server** extension in VS Code and right-click `index.html` → Open with Live Server.

> **Note:** The frontend calls `http://localhost:8000` automatically.
> Make sure the FastAPI server is running before opening the portal.

---

## 🐳 OPTION B — Docker (One Command)

### Prerequisites
- Docker Desktop installed

### Run:
```bash
docker-compose up -d
```

Wait ~30 seconds for MySQL to initialize, then open:
```
http://localhost:8000
```

To stop:
```bash
docker-compose down
```

---

## 📁 Project Structure

```
vsp-smart-portal/
├── frontend/
│   ├── index.html          ← Dashboard (home page)
│   ├── css/
│   │   └── style.css       ← All styles (industrial dark theme)
│   ├── js/
│   │   ├── api.js          ← All API calls (centralized)
│   │   └── app.js          ← Shared utilities + dashboard logic
│   └── pages/
│       ├── map.html        ← Township Map (Leaflet)
│       ├── machines.html   ← Plant & Machine Status
│       ├── lostfound.html  ← Lost & Found
│       └── accident.html   ← Accident Reporting
├── backend/
│   ├── main.py             ← FastAPI app (all routes)
│   ├── requirements.txt
│   └── Dockerfile
├── database/
│   └── init.sql            ← 100+ locations + seed data
├── docker-compose.yml
├── .env.example
└── README.md
```

---

## 🌐 API Reference

| Method | Endpoint | Description |
|---|---|---|
| GET | `/api/health` | Health check |
| GET | `/api/dashboard` | All dashboard stats |
| GET | `/api/locations` | All locations (optional `?category=PLANT`) |
| GET | `/api/locations/categories` | Category counts |
| GET | `/api/lostfound` | Lost & Found list |
| POST | `/api/lostfound` | Submit new item |
| PATCH | `/api/lostfound/{id}/status?status=RESOLVED` | Update status |
| DELETE | `/api/lostfound/{id}` | Delete record |
| GET | `/api/accidents` | All accident reports |
| POST | `/api/accidents` | Submit accident report |
| GET | `/api/accidents/stats` | Accident statistics |
| PATCH | `/api/accidents/{id}/status?status=RESOLVED` | Update status |
| GET | `/api/machines` | All machines |
| GET | `/api/machines/summary` | Status summary count |
| PATCH | `/api/machines/{id}` | Update machine status |

**Swagger UI** (auto-generated): http://localhost:8000/docs

---

## 🗺 Location Categories

| Category | Count | Color |
|---|---|---|
| PLANT | 28+ | 🔴 Red |
| GATE | 6 | 🟡 Amber |
| SCHOOL | 7 | 🔵 Blue |
| HOSPITAL | 5 | 🟢 Green |
| BANK | 5 | 🟣 Purple |
| TEMPLE | 7 | 🩷 Pink |
| PARK | 4 | 💚 Green |
| CANTEEN | 6 | 🟠 Orange |
| OFFICE | 15+ | ⚫ Gray |
| SPORTS | 3 | 🔵 Cyan |

---

## 🔧 Troubleshooting

**"Cannot reach API server" toast on dashboard:**
→ FastAPI not running. Run `uvicorn main:app --reload --port 8000` in `backend/`

**MySQL connection error:**
→ Check `.env` DB_PASSWORD matches your MySQL root password
→ Make sure MySQL service is running: `sudo systemctl start mysql` (Linux)

**CORS error in browser console:**
→ Open the frontend via `http://localhost` (Live Server), not as a file:// URL

**Map not loading:**
→ Check internet connection (Leaflet loads tiles from OpenStreetMap CDN)

---

## 📞 Emergency Contacts (Pre-loaded)
- Plant Fire Station: **0891-2518999**
- VSP Main Hospital: **0891-2518911**
- Security Control Room: **0891-2518700**
