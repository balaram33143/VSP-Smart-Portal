/**
 * VSP Smart Portal - Environment Configuration
 * This file is injected during deployment with the correct API URL
 */

(function() {
  // Determine API base URL based on environment
  let apiBaseUrl = '{{API_BASE_URL}}'; // Replaced by GitHub Actions during CI/CD
  
  // For local development (file:// or localhost)
  if (apiBaseUrl === '{{API_BASE_URL}}' || !apiBaseUrl) {
    // Placeholder not replaced - local development
    apiBaseUrl = 'http://localhost:8000';
  } else if (apiBaseUrl.includes('localhost') || apiBaseUrl.includes('127.0.0.1')) {
    // Already set correctly
  } else if (apiBaseUrl === '') {
    // Empty - use same origin (GitHub Pages)
    apiBaseUrl = window.location.origin;
  }
  
  window.API_BASE_URL = apiBaseUrl;
  
  // API Configuration
  window.API_CONFIG = {
    timeout: 30000, // 30 seconds
    retries: 3,
  };

  console.log('✅ API Config loaded:', {
    apiBase: window.API_BASE_URL,
    hostname: window.location.hostname,
    environment: (apiBaseUrl.includes('localhost') || apiBaseUrl.includes('127.0.0.1')) ? 'LOCAL' : 'PRODUCTION',
  });
})();
