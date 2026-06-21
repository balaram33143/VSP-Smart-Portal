#!/usr/bin/env python3
"""
API Test Script to identify any errors without database
"""
import requests
import json
import sys

BASE_URL = "http://localhost:8000"
ENDPOINTS = [
    ("/api/health", "GET", None),
    ("/api/dashboard", "GET", None),
    ("/api/locations", "GET", None),
    ("/api/machines", "GET", None),
    ("/api/accidents", "GET", None),
    ("/api/lostfound", "GET", None),
]

def test_endpoint(method, path, data=None):
    """Test an API endpoint"""
    url = BASE_URL + path
    try:
        if method == "GET":
            resp = requests.get(url, timeout=5)
        elif method == "POST":
            resp = requests.post(url, json=data, timeout=5)
        else:
            return None
        
        print(f"\n{'='*70}")
        print(f"🔗 [{method}] {path}")
        print(f"Status: {resp.status_code}")
        try:
            print(f"Response: {json.dumps(resp.json(), indent=2)[:300]}")
        except:
            print(f"Response: {resp.text[:300]}")
        return resp.status_code
    except Exception as e:
        print(f"\n{'='*70}")
        print(f"❌ [{method}] {path}")
        print(f"ERROR: {str(e)}")
        return None

if __name__ == "__main__":
    print("🧪 VSP Smart Portal - API Test Suite")
    print(f"Testing: {BASE_URL}")
    
    for path, method, data in ENDPOINTS:
        test_endpoint(method, path, data)
    
    print(f"\n{'='*70}\n✅ Testing complete")
