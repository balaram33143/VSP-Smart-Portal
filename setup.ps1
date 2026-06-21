# VSP Smart Portal - One-Click Setup Script
# Run with: powershell -ExecutionPolicy Bypass -File setup.ps1

param(
    [string]$Action = "all"  # Options: all, backend, database, test, clean
)

function Write-Header {
    param([string]$Text)
    Write-Host ""
    Write-Host "=" * 70 -ForegroundColor Cyan
    Write-Host $Text -ForegroundColor Cyan
    Write-Host "=" * 70 -ForegroundColor Cyan
    Write-Host ""
}

function Write-Status {
    param([string]$Text, [string]$Type = "info")
    switch ($Type) {
        "success" { Write-Host "✅ $Text" -ForegroundColor Green }
        "error"   { Write-Host "❌ $Text" -ForegroundColor Red }
        "warning" { Write-Host "⚠️  $Text" -ForegroundColor Yellow }
        default   { Write-Host "ℹ️  $Text" -ForegroundColor Cyan }
    }
}

function Setup-Backend {
    Write-Header "Setting Up Backend"
    
    # Check Python
    Write-Status "Checking Python installation..."
    try {
        $pythonVersion = & py -3.13 --version 2>&1
        Write-Status "Found: $pythonVersion" "success"
    } catch {
        Write-Status "Python 3.13 not found. Install from https://www.python.org/" "error"
        return $false
    }
    
    # Install dependencies
    Write-Status "Installing Python dependencies..."
    cd backend
    & py -3.13 -m pip install -r requirements.txt -q
    if ($?) {
        Write-Status "Dependencies installed successfully" "success"
    } else {
        Write-Status "Failed to install dependencies" "error"
        return $false
    }
    cd ..
    
    return $true
}

function Setup-Database {
    Write-Header "Setting Up Database"
    
    # Check Docker
    $hasDocker = $null -ne (Get-Command docker -ErrorAction SilentlyContinue)
    $hasMySQL = $null -ne (Get-Command mysql -ErrorAction SilentlyContinue)
    
    if (-not $hasDocker -and -not $hasMySQL) {
        Write-Status "No MySQL or Docker found. Install one of:" "error"
        Write-Host "  1. MySQL: https://dev.mysql.com/downloads/mysql/" -ForegroundColor Yellow
        Write-Host "  2. Docker: https://www.docker.com/products/docker-desktop" -ForegroundColor Yellow
        return $false
    }
    
    # Use Docker if available, otherwise use local MySQL
    if ($hasDocker) {
        Write-Status "Using Docker for MySQL..."
        
        # Stop existing container if running
        $existing = docker ps -a --format "{{.Names}}" 2>$null | Select-String "vsp-mysql"
        if ($existing) {
            Write-Status "Stopping existing vsp-mysql container..."
            docker stop vsp-mysql 2>$null
            docker rm vsp-mysql 2>$null
        }
        
        Write-Status "Starting MySQL container..."
        docker run --name vsp-mysql `
            -e MYSQL_ROOT_PASSWORD=vsp2026 `
            -e MYSQL_DATABASE=vsp_portal `
            -p 3306:3306 -d mysql:8.0 2>$null
        
        if ($?) {
            Write-Status "MySQL container started" "success"
            Write-Status "Waiting for MySQL to be ready (30 seconds)..."
            Start-Sleep -Seconds 30
        } else {
            Write-Status "Failed to start MySQL container" "error"
            return $false
        }
    }
    
    # Initialize database
    Write-Status "Initializing database..."
    if ($hasDocker -and $existing) {
        docker exec vsp-mysql mysql -u root -pvsp2026 vsp_portal < database/init.sql 2>$null
    } else {
        mysql -u root -pvsp2026 vsp_portal < database/init.sql 2>$null
    }
    
    if ($?) {
        Write-Status "Database initialized successfully" "success"
        return $true
    } else {
        Write-Status "Failed to initialize database" "error"
        return $false
    }
}

function Start-Backend {
    Write-Header "Starting Backend Server"
    
    Write-Status "Backend starting on http://localhost:8000"
    Write-Status "API Docs: http://localhost:8000/docs"
    Write-Status "Press Ctrl+C to stop"
    Write-Host ""
    
    cd backend
    & py -3.13 main.py
}

function Test-API {
    Write-Header "Testing API Endpoints"
    
    $endpoints = @(
        @{ url = "http://localhost:8000/api/health"; name = "Health" },
        @{ url = "http://localhost:8000/api/dashboard"; name = "Dashboard" },
        @{ url = "http://localhost:8000/api/locations"; name = "Locations" },
        @{ url = "http://localhost:8000/api/machines"; name = "Machines" },
        @{ url = "http://localhost:8000/api/accidents"; name = "Accidents" },
        @{ url = "http://localhost:8000/api/lostfound"; name = "Lost & Found" }
    )
    
    $passed = 0
    $failed = 0
    
    foreach ($endpoint in $endpoints) {
        try {
            $response = Invoke-WebRequest -Uri $endpoint.url -TimeoutSec 5 -ErrorAction Stop
            if ($response.StatusCode -eq 200 -or $response.StatusCode -eq 500) {
                Write-Status "$($endpoint.name): $($response.StatusCode)" "success"
                $passed++
            } else {
                Write-Status "$($endpoint.name): $($response.StatusCode)" "error"
                $failed++
            }
        } catch {
            Write-Status "$($endpoint.name): Connection failed" "error"
            $failed++
        }
    }
    
    Write-Host ""
    Write-Status "Results: $passed passed, $failed failed"
    Write-Host ""
}

function Clean-Environment {
    Write-Header "Cleaning Environment"
    
    Write-Status "Stopping Docker containers..."
    docker stop vsp-mysql 2>$null
    
    Write-Status "Clearing Python cache..."
    Remove-Item -Recurse -Force backend/__pycache__ -ErrorAction SilentlyContinue
    Remove-Item -Recurse -Force backend/.pytest_cache -ErrorAction SilentlyContinue
    
    Write-Status "Clean complete" "success"
}

# Main execution
switch ($Action) {
    "all" {
        if ((Setup-Backend) -and (Setup-Database)) {
            Write-Status "Setup complete! Starting backend..." "success"
            Start-Backend
        }
    }
    "backend" {
        Setup-Backend
    }
    "database" {
        Setup-Database
    }
    "test" {
        Test-API
    }
    "clean" {
        Clean-Environment
    }
    default {
        Write-Host "Usage: powershell -ExecutionPolicy Bypass -File setup.ps1 [action]"
        Write-Host ""
        Write-Host "Actions:"
        Write-Host "  all       - Full setup (backend + database + start)" -ForegroundColor Cyan
        Write-Host "  backend   - Setup backend only" -ForegroundColor Cyan
        Write-Host "  database  - Setup database only" -ForegroundColor Cyan
        Write-Host "  test      - Test API endpoints" -ForegroundColor Cyan
        Write-Host "  clean     - Clean environment" -ForegroundColor Cyan
    }
}

Write-Host ""
