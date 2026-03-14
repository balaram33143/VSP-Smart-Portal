#!/bin/bash
# VSP Smart Portal - Development Quick Start
# Mac/Linux Bash Script

clear

echo ""
echo "======================================"
echo " VSP SMART PORTAL - Development Setup"
echo "======================================"
echo ""

show_menu() {
    echo ""
    echo "Select option:"
    echo ""
    echo "1. Start Frontend Server (http://localhost:3000)"
    echo "2. Start Backend Server (http://localhost:8000)"
    echo "3. Start Everything (Docker)"
    echo "4. Stop Everything (Docker)"
    echo "5. View Docker Logs"
    echo "6. Reset Database"
    echo "7. Open Database Client"
    echo "8. Exit"
    echo ""
}

frontend_server() {
    echo ""
    echo "Starting Frontend Server..."
    cd frontend
    python3 server.py
}

backend_server() {
    echo ""
    echo "Starting Backend Server..."
    cd backend
    if [ ! -d "venv" ]; then
        echo "Creating virtual environment..."
        python3 -m venv venv
    fi
    source venv/bin/activate
    pip install -q -r requirements.txt
    echo ""
    echo "Backend starting at http://localhost:8000"
    echo "API Docs: http://localhost:8000/docs"
    echo ""
    uvicorn main:app --reload --port 8000
}

docker_up() {
    echo ""
    echo "Starting Docker services..."
    docker-compose up -d
    docker-compose ps
}

docker_down() {
    echo ""
    echo "Stopping Docker services..."
    docker-compose down
    echo "Done."
}

docker_logs() {
    echo ""
    echo "Docker Logs (press Ctrl+C to stop)"
    docker-compose logs -f
}

reset_db() {
    echo ""
    echo "WARNING: This will delete all data in the database!"
    read -p "Continue? (yes/no): " confirm
    if [ "$confirm" = "yes" ]; then
        echo "Resetting database..."
        docker-compose down -v
        docker-compose up -d
        echo "Database reset complete."
    else
        echo "Cancelled."
    fi
}

mysql_client() {
    echo ""
    echo "Connecting to MySQL..."
    docker-compose exec mysql mysql -uroot -pvsp2026 vsp_portal
}

while true; do
    show_menu
    read -p "Enter choice (1-8): " choice
    
    case $choice in
        1) frontend_server ;;
        2) backend_server ;;
        3) docker_up ;;
        4) docker_down ;;
        5) docker_logs ;;
        6) reset_db ;;
        7) mysql_client ;;
        8) echo ""; echo "Goodbye!"; exit 0 ;;
        *) echo "Invalid choice. Please try again." ;;
    esac
done
