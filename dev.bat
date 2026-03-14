@echo off
REM VSP Smart Portal - Development Quick Start
REM Windows Command Prompt Script

cls
echo.
echo ======================================
echo  VSP SMART PORTAL - Development Setup
echo ======================================
echo.

:menu
echo.
echo Select option:
echo.
echo 1. Start Frontend Server (http://localhost:3000)
echo 2. Start Backend Server (http://localhost:8000)
echo 3. Start Everything (Docker)
echo 4. Stop Everything (Docker)
echo 5. View Docker Logs
echo 6. Reset Database
echo 7. Open Database Client
echo 8. Exit
echo.

set /p choice="Enter choice (1-8): "

if "%choice%"=="1" goto frontend
if "%choice%"=="2" goto backend
if "%choice%"=="3" goto docker_up
if "%choice%"=="4" goto docker_down
if "%choice%"=="5" goto docker_logs
if "%choice%"=="6" goto reset_db
if "%choice%"=="7" goto mysql_client
if "%choice%"=="8" goto end

echo Invalid choice. Please try again.
goto menu

:frontend
echo.
echo Starting Frontend Server...
cd frontend
python server.py
goto menu

:backend
echo.
echo Starting Backend Server...
cd backend
if not exist venv (
    echo Creating virtual environment...
    python -m venv venv
)
call venv\Scripts\activate
pip install -r requirements.txt > nul 2>&1
echo.
echo Backend starting at http://localhost:8000
echo API Docs: http://localhost:8000/docs
echo.
uvicorn main:app --reload --port 8000
goto menu

:docker_up
echo.
echo Starting Docker services...
docker-compose up -d
docker-compose ps
goto menu

:docker_down
echo.
echo Stopping Docker services...
docker-compose down
echo Done.
goto menu

:docker_logs
echo.
echo Docker Logs (press Ctrl+C to stop)
docker-compose logs -f
goto menu

:reset_db
echo.
echo WARNING: This will delete all data in the database!
set /p confirm="Continue? (yes/no): "
if /i "%confirm%"=="yes" (
    echo Resetting database...
    docker-compose down -v
    docker-compose up -d
    echo Database reset complete.
) else (
    echo Cancelled.
)
goto menu

:mysql_client
echo.
echo Connecting to MySQL...
docker-compose exec mysql mysql -uroot -pvsp2026 vsp_portal
goto menu

:end
echo.
echo Goodbye!
exit /b 0
