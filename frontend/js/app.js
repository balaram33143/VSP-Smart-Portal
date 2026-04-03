/**
 * VSP Smart Portal - App Utilities + Dashboard Logic
 */

// ── CLOCK ────────────────────────────────────────────────────
function startClock() {
  const clockEl   = document.getElementById('clock');
  const dateEl    = document.getElementById('dateline');
  const days      = ['Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday'];
  const months    = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];

  function tick() {
    const now = new Date();
    const hh  = String(now.getHours()).padStart(2, '0');
    const mm  = String(now.getMinutes()).padStart(2, '0');
    const ss  = String(now.getSeconds()).padStart(2, '0');
    if (clockEl) clockEl.textContent = `${hh}:${mm}:${ss}`;
    if (dateEl)  dateEl.textContent  = `${days[now.getDay()]}, ${now.getDate()} ${months[now.getMonth()]} ${now.getFullYear()}`;
  }

  tick();
  setInterval(tick, 1000);
}

startClock();

// ── TOAST ────────────────────────────────────────────────────
function showToast(msg, type = 'success') {
  let t = document.querySelector('.toast');
  if (!t) {
    t = document.createElement('div');
    t.className = 'toast';
    document.body.appendChild(t);
  }
  t.textContent = msg;
  t.className = `toast ${type} show`;
  clearTimeout(t._timer);
  t._timer = setTimeout(() => t.classList.remove('show'), 3500);
}

// ── SIDEBAR TOGGLE ───────────────────────────────────────────
function toggleSidebar() {
  document.getElementById('sidebar').classList.toggle('open');
}

// Click outside to close on mobile
document.addEventListener('click', (e) => {
  const sb = document.getElementById('sidebar');
  if (sb && sb.classList.contains('open') && !sb.contains(e.target)) {
    sb.classList.remove('open');
  }
});

// ── ACTIVE NAV ───────────────────────────────────────────────
document.querySelectorAll('.nav-item').forEach(a => {
  if (a.href === window.location.href) {
    a.classList.add('active');
  } else {
    a.classList.remove('active');
  }
});

// ── HELPERS ──────────────────────────────────────────────────
function formatDate(str) {
  if (!str) return '—';
  return new Date(str).toLocaleDateString('en-IN', { day: '2-digit', month: 'short', year: 'numeric' });
}

function statusPill(status) {
  return `<span class="status-pill pill-${status}">${status.replace(/_/g, ' ')}</span>`;
}

function badge(val, extraClass = '') {
  return `<span class="badge badge-${val} ${extraClass}">${val.replace(/_/g, ' ')}</span>`;
}

// ── DASHBOARD ────────────────────────────────────────────────
async function initDashboard() {
  // Load stats
  try {
    const d = await API.getDashboard();
    document.getElementById('stat-locations').textContent = d.locations;
    document.getElementById('stat-running').textContent   = d.machines_running;
    document.getElementById('stat-issues').textContent    = d.machines_issues;
    document.getElementById('stat-lf').textContent        = d.lostfound_open;
    document.getElementById('stat-acc').textContent       = d.accidents_open;
  } catch {
    showToast('⚠ Cannot reach API server. Is the backend running?', 'error');
    const el = document.getElementById('api-status');
    if (el) el.innerHTML = '<span class="dot dot-red"></span> API Offline';
  }

  // Machine strip
  try {
    const res = await API.getMachines();
    const strip = document.getElementById('machine-strip');
    if (!res.data.length) {
      strip.innerHTML = '<div class="empty-state"><p>No machines found</p></div>';
      return;
    }
    strip.innerHTML = res.data.map(m => `
      <div class="machine-chip">
        <div>
          <div class="machine-name">${m.machine_name}</div>
          <div class="machine-dept">${m.department || ''}</div>
        </div>
        ${statusPill(m.status)}
      </div>
    `).join('');
  } catch { /* silent */ }

  // Recent accidents
  try {
    const res = await API.getAccidents();
    const el  = document.getElementById('recent-accidents');
    const rows = res.data.slice(0, 5);
    if (!rows.length) {
      el.innerHTML = '<div class="loading-msg">No accident reports found.</div>';
      return;
    }
    el.innerHTML = `
      <div class="table-wrap">
        <table>
          <thead>
            <tr>
              <th>#</th>
              <th>Reporter</th>
              <th>Location</th>
              <th>Type</th>
              <th>Severity</th>
              <th>Date</th>
              <th>Status</th>
            </tr>
          </thead>
          <tbody>
            ${rows.map(r => `
              <tr>
                <td>${r.id}</td>
                <td>${r.reporter_name}</td>
                <td>${r.location_name}</td>
                <td>${r.accident_type.replace(/_/g, ' ')}</td>
                <td>${badge(r.severity)}</td>
                <td>${formatDate(r.incident_date)}</td>
                <td>${badge(r.status)}</td>
              </tr>
            `).join('')}
          </tbody>
        </table>
      </div>
    `;
  } catch { /* silent */ }
}
