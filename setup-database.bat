@echo off
REM VSP Smart Portal - Database Setup Script for Windows
REM This script initializes the MySQL database with sample data

echo.
echo ========================================================================
echo VSP Smart Portal - Database Initialization Script
echo ========================================================================
echo.

REM Check if MySQL is installed
where mysql >nul 2>nul
if %errorlevel% neq 0 (
    echo ERROR: MySQL is not installed or not in PATH
    echo.
    echo Please install MySQL Community Server from:
    echo https://dev.mysql.com/downloads/mysql/
    echo.
    echo Or use Docker:
    echo docker run --name vsp-mysql ^
    echo   -e MYSQL_ROOT_PASSWORD=vsp2026 ^
    echo   -e MYSQL_DATABASE=vsp_portal ^
    echo   -p 3306:3306 -d mysql:8.0
    echo.
    pause
    exit /b 1
)

echo MySQL found. Attempting to initialize database...
echo.

REM Run the initialization script
echo Running: mysql -u root -p < database/init.sql
mysql -u root -p < database\init.sql

if %errorlevel% equ 0 (
    echo.
    echo ========================================================================
    echo SUCCESS! Database initialized successfully!
    echo ========================================================================
    echo.
    echo Tables created:
    echo   - locations (150+ records)
    echo   - machines (20 records)
    echo   - lost_found (5 records)
    echo   - accident_reports (3 records)
    echo.
    echo Next step: Start the backend server
    echo   cd backend
    echo   py -3.13 main.py
    echo.
) else (
    echo.
    echo ========================================================================
    echo ERROR: Database initialization failed!
    echo ========================================================================
    echo.
    echo Make sure:
    echo   1. MySQL server is running
    echo   2. Root password is correct
    echo   3. You have proper permissions
    echo.
)

pause
