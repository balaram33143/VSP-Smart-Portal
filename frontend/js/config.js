/**
 * VSP Smart Portal - Environment Configuration
 * This file is injected during deployment with the correct API URL
 */

(function() {
  // Set API base URL based on deployment environment
  // This gets replaced during CI/CD deployment
  window.API_BASE_URL = '{{API_BASE_URL}}'; // Replaced by GitHub Actions
  
  // API Configuration
  window.API_CONFIG = {
    timeout: 30000, // 30 seconds
    retries: 3,
  };

  console.log('🔧 API Config loaded:', {
    apiBase: window.API_BASE_URL,
    hostname: window.location.hostname,
  });
})();
