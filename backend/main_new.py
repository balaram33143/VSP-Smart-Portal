"""
VSP Smart Portal - FastAPI Backend with SQLite
Run: python main_new.py
"""

from fastapi import FastAPI, HTTPException, Query
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from fastapi.responses import FileResponse
import sqlite3
import os
from datetime import datetime, date
from typing import Optional, List
from pydantic import BaseModel
import json
from init_db import init_db

app = FastAPI(
    title="VSP Smart Portal API",
    description="RINL Vizag Steel Plant Smart Portal Backend",
    version="1.0.0"
)

# ─── INITIALIZE DATABASE ─────────────────────────────────────
init_db()

# ─── CORS ────────────────────────────────────────────────────
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

# ─── DB CONFIG ───────────────────────────────────────────────
DB_PATH = os.path.join(os.path.dirname(__file__), "..", "vsp_portal.db")

def get_db():
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    return conn

def row_to_dict(row):
    return dict(row) if row else None

def rows_to_list(rows):
    result = []
    for row in rows:
        d = dict(row)
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
    item_type: str
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
        db.execute("SELECT 1").fetchone()
        db.close()
        return {"status": "ok", "db": "connected", "timestamp": datetime.now().isoformat()}
    except Exception as e:
        return {"status": "error", "db": str(e)}

# ─── LOCATIONS ───────────────────────────────────────────────
@app.get("/api/locations")
def get_locations(category: Optional[str] = None):
    try:
        db = get_db()
        if category:
            rows = db.execute("SELECT * FROM locations WHERE category = ? ORDER BY name", (category.upper(),)).fetchall()
        else:
            rows = db.execute("SELECT * FROM locations ORDER BY category, name").fetchall()
        result = rows_to_list(rows)
        db.close()
        return {"total": len(result), "data": result}
    except Exception as e:
        raise HTTPException(500, f"Database error: {str(e)}")

@app.get("/api/locations/categories")
def get_categories():
    try:
        db = get_db()
        rows = db.execute("SELECT category, COUNT(*) as count FROM locations GROUP BY category ORDER BY category").fetchall()
        db.close()
        return [{"category": r[0], "count": r[1]} for r in rows]
    except Exception as e:
        raise HTTPException(500, f"Database error: {str(e)}")

@app.get("/api/locations/{loc_id}")
def get_location(loc_id: int):
    try:
        db = get_db()
        row = db.execute("SELECT * FROM locations WHERE id = ?", (loc_id,)).fetchone()
        db.close()
        if not row:
            raise HTTPException(404, "Location not found")
        return row_to_dict(row)
    except Exception as e:
        raise HTTPException(500, f"Database error: {str(e)}")

# ─── LOST & FOUND ────────────────────────────────────────────
@app.get("/api/lostfound")
def get_lostfound(status: Optional[str] = None, item_type: Optional[str] = None):
    try:
        db = get_db()
        q = "SELECT * FROM lost_found WHERE 1=1"
        params = []
        if status:
            q += " AND status = ?"
            params.append(status.upper())
        if item_type:
            q += " AND item_type = ?"
            params.append(item_type.upper())
        q += " ORDER BY date_reported DESC"
        rows = db.execute(q, params).fetchall()
        result = rows_to_list(rows)
        db.close()
        return {"total": len(result), "data": result}
    except Exception as e:
        raise HTTPException(500, f"Database error: {str(e)}")

@app.post("/api/lostfound")
def create_lostfound(item: LostFoundCreate):
    try:
        db = get_db()
        db.execute(
            """INSERT INTO lost_found 
               (item_name, description, location_name, contact_name, contact_phone, item_type, date_reported) 
               VALUES (?, ?, ?, ?, ?, ?, ?)""",
            (item.item_name, item.description, item.location_name, item.contact_name, 
             item.contact_phone, item.item_type.upper(), item.date_reported)
        )
        db.commit()
        db.close()
        return {"status": "created", "message": "Lost/Found item reported successfully"}
    except Exception as e:
        raise HTTPException(500, f"Database error: {str(e)}")

@app.patch("/api/lostfound/{item_id}/status")
def update_lostfound_status(item_id: int, status: str):
    try:
        db = get_db()
        db.execute("UPDATE lost_found SET status = ? WHERE id = ?", (status.upper(), item_id))
        db.commit()
        db.close()
        return {"status": "updated", "message": f"Item {item_id} status updated"}
    except Exception as e:
        raise HTTPException(500, f"Database error: {str(e)}")

@app.delete("/api/lostfound/{item_id}")
def delete_lostfound(item_id: int):
    try:
        db = get_db()
        db.execute("DELETE FROM lost_found WHERE id = ?", (item_id,))
        db.commit()
        db.close()
        return {"status": "deleted", "message": f"Item {item_id} deleted"}
    except Exception as e:
        raise HTTPException(500, f"Database error: {str(e)}")

# ─── ACCIDENTS ───────────────────────────────────────────────
@app.get("/api/accidents")
def get_accidents(status: Optional[str] = None):
    try:
        db = get_db()
        if status:
            rows = db.execute("SELECT * FROM accident_reports WHERE status = ? ORDER BY incident_date DESC", (status.upper(),)).fetchall()
        else:
            rows = db.execute("SELECT * FROM accident_reports ORDER BY incident_date DESC").fetchall()
        result = rows_to_list(rows)
        db.close()
        return {"total": len(result), "data": result}
    except Exception as e:
        raise HTTPException(500, f"Database error: {str(e)}")

@app.post("/api/accidents")
def create_accident(report: AccidentReportCreate):
    try:
        db = get_db()
        db.execute(
            """INSERT INTO accident_reports 
               (reporter_name, reporter_id, department, location_name, accident_type, severity, 
                description, injured_persons, first_aid_given, reported_to_supervisor, 
                incident_date, incident_time) 
               VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)""",
            (report.reporter_name, report.reporter_id, report.department, report.location_name,
             report.accident_type.upper(), report.severity.upper(), report.description,
             report.injured_persons, int(report.first_aid_given), int(report.reported_to_supervisor),
             report.incident_date, report.incident_time)
        )
        db.commit()
        db.close()
        return {"status": "created", "message": "Accident report submitted successfully"}
    except Exception as e:
        raise HTTPException(500, f"Database error: {str(e)}")

@app.patch("/api/accidents/{report_id}/status")
def update_accident_status(report_id: int, status: str):
    try:
        db = get_db()
        db.execute("UPDATE accident_reports SET status = ? WHERE id = ?", (status.upper(), report_id))
        db.commit()
        db.close()
        return {"status": "updated", "message": f"Report {report_id} status updated"}
    except Exception as e:
        raise HTTPException(500, f"Database error: {str(e)}")

@app.get("/api/accidents/stats")
def accident_stats():
    try:
        db = get_db()
        total = db.execute("SELECT COUNT(*) FROM accident_reports").fetchone()[0]
        critical = db.execute("SELECT COUNT(*) FROM accident_reports WHERE severity IN ('HIGH','CRITICAL')").fetchone()[0]
        open_count = db.execute("SELECT COUNT(*) FROM accident_reports WHERE status = 'REPORTED'").fetchone()[0]
        injured = db.execute("SELECT SUM(injured_persons) FROM accident_reports").fetchone()[0] or 0
        db.close()
        return {
            "total_reports": total,
            "critical_severity": critical,
            "open_reports": open_count,
            "total_injured": injured
        }
    except Exception as e:
        raise HTTPException(500, f"Database error: {str(e)}")

# ─── MACHINES ────────────────────────────────────────────────
@app.get("/api/machines")
def get_machines(status: Optional[str] = None):
    try:
        db = get_db()
        if status:
            rows = db.execute("SELECT * FROM machines WHERE status = ? ORDER BY machine_name", (status.upper(),)).fetchall()
        else:
            rows = db.execute("SELECT * FROM machines ORDER BY machine_name").fetchall()
        result = rows_to_list(rows)
        db.close()
        return {"total": len(result), "data": result}
    except Exception as e:
        raise HTTPException(500, f"Database error: {str(e)}")

@app.get("/api/machines/summary")
def machines_summary():
    try:
        db = get_db()
        running = db.execute("SELECT COUNT(*) FROM machines WHERE status = 'RUNNING'").fetchone()[0]
        issues = db.execute("SELECT COUNT(*) FROM machines WHERE status IN ('BREAKDOWN','MAINTENANCE')").fetchone()[0]
        total = db.execute("SELECT COUNT(*) FROM machines").fetchone()[0]
        db.close()
        return {
            "running": running,
            "issues": issues,
            "total": total,
            "idle": total - running - issues
        }
    except Exception as e:
        raise HTTPException(500, f"Database error: {str(e)}")

@app.patch("/api/machines/{machine_id}")
def update_machine(machine_id: int, update: MachineStatusUpdate):
    try:
        db = get_db()
        db.execute(
            "UPDATE machines SET status = ?, notes = ?, operator_name = ? WHERE id = ?",
            (update.status.upper(), update.notes, update.operator_name, machine_id)
        )
        db.commit()
        db.close()
        return {"status": "updated", "message": f"Machine {machine_id} updated"}
    except Exception as e:
        raise HTTPException(500, f"Database error: {str(e)}")

# ─── DASHBOARD ───────────────────────────────────────────────
@app.get("/api/dashboard")
def get_dashboard():
    try:
        db = get_db()
        locs = db.execute("SELECT COUNT(*) FROM locations").fetchone()[0]
        lf_open = db.execute("SELECT COUNT(*) FROM lost_found WHERE status = 'OPEN'").fetchone()[0]
        acc_open = db.execute("SELECT COUNT(*) FROM accident_reports WHERE status = 'REPORTED'").fetchone()[0]
        running = db.execute("SELECT COUNT(*) FROM machines WHERE status = 'RUNNING'").fetchone()[0]
        issues = db.execute("SELECT COUNT(*) FROM machines WHERE status IN ('BREAKDOWN','MAINTENANCE')").fetchone()[0]
        total_machines = db.execute("SELECT COUNT(*) FROM machines").fetchone()[0]
        db.close()
        return {
            "locations": locs,
            "lostfound_open": lf_open,
            "accidents_open": acc_open,
            "machines_running": running,
            "machines_issues": issues,
            "machines_total": total_machines
        }
    except Exception as e:
        raise HTTPException(500, f"Database error: {str(e)}")

# ─── SERVE FRONTEND ──────────────────────────────────────────
frontend_path = os.path.join(os.path.dirname(__file__), "..", "frontend")
if os.path.exists(frontend_path):
    app.mount("/css", StaticFiles(directory=os.path.join(frontend_path, "css")), name="css")
    app.mount("/js", StaticFiles(directory=os.path.join(frontend_path, "js")), name="js")
    app.mount("/pages", StaticFiles(directory=os.path.join(frontend_path, "pages")), name="pages")

    @app.get("/")
    def serve_index():
        return FileResponse(os.path.join(frontend_path, "index.html"))

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main_new:app", host="0.0.0.0", port=8000, reload=True)
