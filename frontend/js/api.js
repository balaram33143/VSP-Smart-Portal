/**
 * VSP Smart Portal - API Client
 * All backend calls go through this module.
 */

const API = (() => {
  // Determine API base URL based on environment
  let BASE;
  
  // First check if config.js already set it
  if (window.API_BASE_URL && window.API_BASE_URL !== '{{API_BASE_URL}}') {
    BASE = window.API_BASE_URL;
  } 
  // Check hostname for localhost
  else if (window.location.hostname === 'localhost' || window.location.hostname === '127.0.0.1' || window.location.hostname === '') {
    // Local development (file:// or localhost server)
    BASE = 'http://localhost:8000';
  }
  // GitHub Pages or other production URL
  else {
    BASE = window.location.origin;
  }
  
  console.log('🔌 API Connection - BASE URL:', BASE);

  async function request(method, path, body = null) {
    const url = BASE + path;
    const opts = {
      method,
      headers: { 'Content-Type': 'application/json' },
    };
    if (body) opts.body = JSON.stringify(body);
    
    try {
      const res = await fetch(url, opts);
      if (!res.ok) {
        const err = await res.json().catch(() => ({ detail: res.statusText }));
        console.error(`❌ API Error [${method} ${path}]:`, err);
        throw new Error(err.detail || `Request failed: ${res.status}`);
      }
      const data = await res.json();
      console.log(`✅ API Success [${method} ${path}]:`, data);
      return data;
    } catch (error) {
      console.error(`❌ API Request Failed [${method} ${url}]:`, error.message);
      throw error;
    }
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
