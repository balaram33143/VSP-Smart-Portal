#!/usr/bin/env python3
"""
Simple HTTP Server for VSP Smart Portal Frontend
Serves static files at http://localhost:3000
"""
import http.server
import socketserver
import os
from pathlib import Path

PORT = 3000
SCRIPT_DIR = Path(__file__).parent.absolute()
os.chdir(SCRIPT_DIR)

class MyHTTPRequestHandler(http.server.SimpleHTTPRequestHandler):
    def end_headers(self):
        self.send_header('Cache-Control', 'no-store, no-cache, must-revalidate')
        return super().end_headers()

    def do_GET(self):
        if self.path == '/':
            self.path = '/index.html'
        return http.server.SimpleHTTPRequestHandler.do_GET(self)

if __name__ == '__main__':
    with socketserver.TCPServer(("", PORT), MyHTTPRequestHandler) as httpd:
        print(f"✅ Frontend server running at http://localhost:{PORT}")
        print(f"📁 Serving from: {SCRIPT_DIR}")
        print("Press Ctrl+C to stop\n")
        print("Live reload on file changes:")
        print("- Edit HTML/CSS/JS files in VS Code")
        print("- Refresh browser (Ctrl+Shift+R for hard refresh)")
        try:
            httpd.serve_forever()
        except KeyboardInterrupt:
            print("\n\n👋 Server stopped")
