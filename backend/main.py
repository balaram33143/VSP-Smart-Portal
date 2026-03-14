"""
VSP Smart Portal - FastAPI Backend
Run: uvicorn main:app --reload --port 8000
"""

from fastapi import FastAPI, HTTPException, Query
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from fastapi.responses import FileResponse
import mysql.connector
import os
from datetime import datetime, date
from typing import Optional, List
from pydantic import BaseModel
import json

app = FastAPI(
    title="VSP Smart Portal API",
    description="RINL Vizag Steel Plant Smart Portal Backend",
    version="1.0.0"
)

# ─── CORS ────────────────────────────────────────────────────
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

# ─── DB CONFIG ───────────────────────────────────────────────
DB_CONFIG = {
    "host":     os.getenv("DB_HOST", "localhost"),
    "port":     int(os.getenv("DB_PORT", 3306)),
    "user":     os.getenv("DB_USER", "root"),
    "password": os.getenv("DB_PASSWORD", "vsp2026"),
    "database": os.getenv("DB_NAME", "vsp_portal"),
}

def get_db():
    return mysql.connector.connect(**DB_CONFIG)

def row_to_dict(cursor, row):
    columns = [col[0] for col in cursor.description]
    return dict(zip(columns, row))

def rows_to_list(cursor, rows):
    columns = [col[0] for col in cursor.description]
    result = []
    for row in rows:
        d = dict(zip(columns, row))
        for k, v in d.items():
            if isinstance(v, (date, datetime)):
                d[k] = str(v)
        result.append(d)
    return result

# ─── PYDANTIC MODELS ─────────────────────────────────────────
class LostFoundCreate(BaseModel):
    item_name: str
    description: Optional[str] = None
    location_name: Optional[str] = None
    contact_name: str
    contact_phone: str
    item_type: str   # LOST | FOUND
    date_reported: str

class AccidentReportCreate(BaseModel):
    reporter_name: str
    reporter_id: Optional[str] = None
    department: Optional[str] = None
    location_name: str
    accident_type: str
    severity: str
    description: str
    injured_persons: int = 0
    first_aid_given: bool = False
    reported_to_supervisor: bool = False
    incident_date: str
    incident_time: str

class MachineStatusUpdate(BaseModel):
    status: str
    notes: Optional[str] = None
    operator_name: Optional[str] = None

# ─── HEALTH ──────────────────────────────────────────────────
@app.get("/api/health")
def health():
    try:
        db = get_db()
        db.close()
        return {"status": "ok", "db": "connected", "timestamp": datetime.now().isoformat()}
    except Exception as e:
        return {"status": "error", "db": str(e)}

# ─── LOCATIONS ───────────────────────────────────────────────
@app.get("/api/locations")
def get_locations(category: Optional[str] = None):
    db = get_db()
    cur = db.cursor()
    if category:
        cur.execute("SELECT * FROM locations WHERE category = %s ORDER BY name", (category.upper(),))
    else:
        cur.execute("SELECT * FROM locations ORDER BY category, name")
    rows = rows_to_list(cur, cur.fetchall())
    db.close()
    return {"total": len(rows), "data": rows}

@app.get("/api/locations/categories")
def get_categories():
    db = get_db()
    cur = db.cursor()
    cur.execute("SELECT category, COUNT(*) as count FROM locations GROUP BY category ORDER BY category")
    rows = cur.fetchall()
    db.close()
    return [{"category": r[0], "count": r[1]} for r in rows]

@app.get("/api/locations/{loc_id}")
def get_location(loc_id: int):
    db = get_db()
    cur = db.cursor()
    cur.execute("SELECT * FROM locations WHERE id = %s", (loc_id,))
    row = cur.fetchone()
    db.close()
    if not row:
        raise HTTPException(404, "Location not found")
    return row_to_dict(cur, row)

# ─── LOST & FOUND ────────────────────────────────────────────
@app.get("/api/lostfound")
def get_lostfound(
    status: Optional[str] = None,
    item_type: Optional[str] = None,
    search: Optional[str] = None
):
    db = get_db()
    cur = db.cursor()
    q = "SELECT * FROM lost_found WHERE 1=1"
    params = []
    if status:
        q += " AND status = %s"
        params.append(status.upper())
    if item_type:
        q += " AND item_type = %s"
        params.append(item_type.upper())
    if search:
        q += " AND (item_name LIKE %s OR description LIKE %s OR location_name LIKE %s)"
        like = f"%{search}%"
        params += [like, like, like]
    q += " ORDER BY created_at DESC"
    cur.execute(q, params)
    rows = rows_to_list(cur, cur.fetchall())
    db.close()
    return {"total": len(rows), "data": rows}

@app.post("/api/lostfound", status_code=201)
def create_lostfound(item: LostFoundCreate):
    db = get_db()
    cur = db.cursor()
    cur.execute("""
        INSERT INTO lost_found (item_name, description, location_name, contact_name,
            contact_phone, item_type, date_reported)
        VALUES (%s, %s, %s, %s, %s, %s, %s)
    """, (item.item_name, item.description, item.location_name, item.contact_name,
          item.contact_phone, item.item_type.upper(), item.date_reported))
    db.commit()
    new_id = cur.lastrowid
    db.close()
    return {"id": new_id, "message": "Report submitted successfully"}

@app.patch("/api/lostfound/{item_id}/status")
def update_lostfound_status(item_id: int, status: str = Query(...)):
    db = get_db()
    cur = db.cursor()
    cur.execute("UPDATE lost_found SET status = %s WHERE id = %s", (status.upper(), item_id))
    db.commit()
    db.close()
    return {"message": "Status updated"}

@app.delete("/api/lostfound/{item_id}")
def delete_lostfound(item_id: int):
    db = get_db()
    cur = db.cursor()
    cur.execute("DELETE FROM lost_found WHERE id = %s", (item_id,))
    db.commit()
    db.close()
    return {"message": "Record deleted"}

# ─── ACCIDENT REPORTS ────────────────────────────────────────
@app.get("/api/accidents")
def get_accidents(status: Optional[str] = None, severity: Optional[str] = None):
    db = get_db()
    cur = db.cursor()
    q = "SELECT * FROM accident_reports WHERE 1=1"
    params = []
    if status:
        q += " AND status = %s"
        params.append(status.upper())
    if severity:
        q += " AND severity = %s"
        params.append(severity.upper())
    q += " ORDER BY created_at DESC"
    cur.execute(q, params)
    rows = rows_to_list(cur, cur.fetchall())
    db.close()
    return {"total": len(rows), "data": rows}

@app.post("/api/accidents", status_code=201)
def create_accident(report: AccidentReportCreate):
    db = get_db()
    cur = db.cursor()
    cur.execute("""
        INSERT INTO accident_reports
            (reporter_name, reporter_id, department, location_name, accident_type,
             severity, description, injured_persons, first_aid_given,
             reported_to_supervisor, incident_date, incident_time)
        VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)
    """, (report.reporter_name, report.reporter_id, report.department,
          report.location_name, report.accident_type.upper(), report.severity.upper(),
          report.description, report.injured_persons, report.first_aid_given,
          report.reported_to_supervisor, report.incident_date, report.incident_time))
    db.commit()
    new_id = cur.lastrowid
    db.close()
    return {"id": new_id, "message": "Accident report submitted successfully"}

@app.patch("/api/accidents/{report_id}/status")
def update_accident_status(report_id: int, status: str = Query(...)):
    db = get_db()
    cur = db.cursor()
    cur.execute("UPDATE accident_reports SET status = %s WHERE id = %s", (status.upper(), report_id))
    db.commit()
    db.close()
    return {"message": "Status updated"}

@app.get("/api/accidents/stats")
def accident_stats():
    db = get_db()
    cur = db.cursor()
    cur.execute("SELECT COUNT(*) FROM accident_reports")
    total = cur.fetchone()[0]
    cur.execute("SELECT COUNT(*) FROM accident_reports WHERE severity IN ('HIGH','CRITICAL')")
    critical = cur.fetchone()[0]
    cur.execute("SELECT COUNT(*) FROM accident_reports WHERE status = 'REPORTED'")
    open_count = cur.fetchone()[0]
    cur.execute("SELECT SUM(injured_persons) FROM accident_reports")
    injured = cur.fetchone()[0] or 0
    db.close()
    return {"total": total, "critical": critical, "open": open_count, "injured": injured}

# ─── MACHINES ────────────────────────────────────────────────
@app.get("/api/machines")
def get_machines(status: Optional[str] = None, department: Optional[str] = None):
    db = get_db()
    cur = db.cursor()
    q = "SELECT * FROM machines WHERE 1=1"
    params = []
    if status:
        q += " AND status = %s"
        params.append(status.upper())
    if department:
        q += " AND department LIKE %s"
        params.append(f"%{department}%")
    q += " ORDER BY department, machine_name"
    cur.execute(q, params)
    rows = rows_to_list(cur, cur.fetchall())
    db.close()
    return {"total": len(rows), "data": rows}

@app.get("/api/machines/summary")
def machine_summary():
    db = get_db()
    cur = db.cursor()
    cur.execute("SELECT status, COUNT(*) as count FROM machines GROUP BY status")
    rows = cur.fetchall()
    db.close()
    return {r[0]: r[1] for r in rows}

@app.patch("/api/machines/{machine_id}")
def update_machine(machine_id: int, update: MachineStatusUpdate):
    db = get_db()
    cur = db.cursor()
    q = "UPDATE machines SET status = %s"
    params = [update.status.upper()]
    if update.notes:
        q += ", notes = %s"
        params.append(update.notes)
    if update.operator_name:
        q += ", operator_name = %s"
        params.append(update.operator_name)
    q += " WHERE id = %s"
    params.append(machine_id)
    cur.execute(q, params)
    db.commit()
    db.close()
    return {"message": "Machine updated"}

# ─── DASHBOARD STATS ─────────────────────────────────────────
@app.get("/api/dashboard")
def dashboard():
    db = get_db()
    cur = db.cursor()
    cur.execute("SELECT COUNT(*) FROM locations")
    locs = cur.fetchone()[0]
    cur.execute("SELECT COUNT(*) FROM lost_found WHERE status = 'OPEN'")
    lf_open = cur.fetchone()[0]
    cur.execute("SELECT COUNT(*) FROM accident_reports WHERE status = 'REPORTED'")
    acc_open = cur.fetchone()[0]
    cur.execute("SELECT COUNT(*) FROM machines WHERE status = 'RUNNING'")
    running = cur.fetchone()[0]
    cur.execute("SELECT COUNT(*) FROM machines WHERE status IN ('BREAKDOWN','MAINTENANCE')")
    issues = cur.fetchone()[0]
    cur.execute("SELECT COUNT(*) FROM machines")
    total_machines = cur.fetchone()[0]
    db.close()
    return {
        "locations": locs,
        "lostfound_open": lf_open,
        "accidents_open": acc_open,
        "machines_running": running,
        "machines_issues": issues,
        "machines_total": total_machines
    }

# ─── SERVE FRONTEND ──────────────────────────────────────────
frontend_path = os.path.join(os.path.dirname(__file__), "..", "frontend")
if os.path.exists(frontend_path):
    app.mount("/static", StaticFiles(directory=os.path.join(frontend_path, "css")), name="css")
    app.mount("/js", StaticFiles(directory=os.path.join(frontend_path, "js")), name="js")
    app.mount("/pages", StaticFiles(directory=os.path.join(frontend_path, "pages")), name="pages")

    @app.get("/")
    def serve_index():
        return FileResponse(os.path.join(frontend_path, "index.html"))

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
