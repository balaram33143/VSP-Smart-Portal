/**
 * VSP Smart Portal - API Client
 * All backend calls go through this module.
 */

const API = (() => {
  const BASE = window.location.hostname === 'localhost' || window.location.hostname === '127.0.0.1'
    ? 'http://localhost:8000'
    : '';  // same origin in production

  async function request(method, path, body = null) {
    const opts = {
      method,
      headers: { 'Content-Type': 'application/json' },
    };
    if (body) opts.body = JSON.stringify(body);
    const res = await fetch(BASE + path, opts);
    if (!res.ok) {
      const err = await res.json().catch(() => ({ detail: res.statusText }));
      throw new Error(err.detail || 'Request failed');
    }
    return res.json();
  }

  return {
    get:   (path) => request('GET', path),
    post:  (path, body) => request('POST', path, body),
    patch: (path, body) => request('PATCH', path, body),
    del:   (path) => request('DELETE', path),

    // ── DASHBOARD
    getDashboard: () => request('GET', '/api/dashboard'),

    // ── LOCATIONS
    getLocations:   (cat) => request('GET', `/api/locations${cat ? `?category=${cat}` : ''}`),
    getCategories:  () => request('GET', '/api/locations/categories'),

    // ── LOST & FOUND
    getLostFound: (params = {}) => {
      const q = new URLSearchParams(params).toString();
      return request('GET', `/api/lostfound${q ? '?' + q : ''}`);
    },
    createLostFound: (data) => request('POST', '/api/lostfound', data),
    updateLFStatus:  (id, status) => request('PATCH', `/api/lostfound/${id}/status?status=${status}`),
    deleteLF:        (id) => request('DELETE', `/api/lostfound/${id}`),

    // ── ACCIDENTS
    getAccidents:    (params = {}) => {
      const q = new URLSearchParams(params).toString();
      return request('GET', `/api/accidents${q ? '?' + q : ''}`);
    },
    getAccidentStats: () => request('GET', '/api/accidents/stats'),
    createAccident:   (data) => request('POST', '/api/accidents', data),
    updateAccStatus:  (id, status) => request('PATCH', `/api/accidents/${id}/status?status=${status}`),

    // ── MACHINES
    getMachines:     (params = {}) => {
      const q = new URLSearchParams(params).toString();
      return request('GET', `/api/machines${q ? '?' + q : ''}`);
    },
    getMachineSummary: () => request('GET', '/api/machines/summary'),
    updateMachine:     (id, data) => request('PATCH', `/api/machines/${id}`, data),

    // ── HEALTH
    checkHealth: () => request('GET', '/api/health'),
  };
})();
