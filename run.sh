#!/usr/bin/env bash

# Load environment variables
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
fi

# Default ports from environment or fallback
DJANGO_PORT=${DJANGO_PORT:-8000}
VUE_PORT=${VUE_PORT:-9000}

# Function to display usage information
show_usage() {
    echo "Usage: $0 [command]"
    echo "Available commands:"
    echo "  backend        - Start Django development server"
    echo "  frontend       - Start Vue/Quasar development server"
    echo "  dev            - Start both backend and frontend in parallel"
    echo "  setup          - Install dependencies and setup project"
    echo "  migrate        - Run Django migrations"
    echo "  createsuperuser - Create Django superuser"
    echo "  install-backend - Install Python dependencies"
    echo "  install-frontend - Install Node.js dependencies"
    echo "  build-frontend - Build frontend for production"
    echo "  test           - Run tests"
    echo "  clean          - Clean generated files"
    echo "  help           - Show this help message"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check dependencies
check_dependencies() {
    echo "Checking dependencies..."

    if ! command_exists python3; then
        echo "Error: Python 3 is required but not installed."
        exit 1
    fi

    if ! command_exists node; then
        echo "Error: Node.js is required but not installed."
        exit 1
    fi

    if ! command_exists npm; then
        echo "Error: npm is required but not installed."
        exit 1
    fi

    echo "All dependencies found."
}

# Function to install backend dependencies
install_backend() {
    echo "Installing Python dependencies..."
    cd backend

    if [ ! -d ".venv" ]; then
        echo "Creating virtual environment..."
        python3 -m venv .venv
    fi

    # Activate virtual environment
    if [[ "$SHELL" == "cmd" ]] || [[ "$SHELL" == "powershell" ]]; then
        .venv/Scripts/activate
    else
        .venv/bin/activate
    fi

    pip install --upgrade pip
    pip install -r requirements.txt

    echo "Backend dependencies installed."
    cd ..
}

# Function to install frontend dependencies
install_frontend() {
    echo "Installing Node.js dependencies..."
    cd frontend
    npm install
    echo "Frontend dependencies installed."
    cd ..
}

# Function to run Django migrations
run_migrations() {
    echo "Running Django migrations..."
    cd backend

    # Activate virtual environment

    if [[ "$SHELL" == "cmd" ]] || [[ "$SHELL" == "powershell" ]]; then
        source .venv/Scripts/activate
    else
        source .venv/bin/activate
    fi

    python manage.py makemigrations
    python manage.py migrate

    echo "Migrations completed."
    cd ..
}

# Function to create superuser
create_superuser() {
    echo "Creating Django superuser..."
    cd backend

    # Activate virtual environment
    if [[ "$SHELL" == "cmd" ]] || [[ "$SHELL" == "powershell" ]]; then
        source .venv/Scripts/activate
    else
        source .venv/bin/activate
    fi

    python manage.py createsuperuser
    cd ..
}

# Function to start Django backend
start_backend() {
    echo "Starting Django development server on port $DJANGO_PORT..."
    cd backend

    # Activate virtual environment
    if [[ "$SHELL" == "cmd" ]] || [[ "$SHELL" == "powershell" ]]; then
        source .venv/Scripts/activate
    else
        source .venv/bin/activate
    fi

    python manage.py runserver 0.0.0.0:$DJANGO_PORT
}

# Function to start Vue frontend
start_frontend() {
    echo "Starting Vue/Quasar development server on port $VUE_PORT..."
    cd frontend
    npm run dev
}

# Function to start both services
start_dev() {
    echo "Starting both backend and frontend..."

    # Start backend in background
    (start_backend) &
    BACKEND_PID=$!

    # Wait a moment for backend to start
    sleep 3

    # Start frontend in background
    (start_frontend) &
    FRONTEND_PID=$!

    echo "Backend PID: $BACKEND_PID"
    echo "Frontend PID: $FRONTEND_PID"
    echo "Press Ctrl+C to stop both services"

    # Wait for either process to finish
    wait $BACKEND_PID $FRONTEND_PID
}

# Function to build frontend for production
build_frontend() {
    echo "Building frontend for production..."
    cd frontend
    npm run build
    echo "Frontend build completed."
    cd ..
}

# Function to run tests
run_tests() {
    echo "Running tests..."

    echo "Running Django tests..."
    cd backend
    if [[ "$SHELL" == "cmd" ]] || [[ "$SHELL" == "powershell" ]]; then
        source .venv/Scripts/activate
    else
        source .venv/bin/activate
    fi
    python manage.py test
    cd ..

    echo "Running frontend tests..."
    cd frontend
    npm run test
    cd ..
}

# Function to clean generated files
clean() {
    echo "Cleaning generated files..."

    # Clean Python cache
    find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null
    find . -name "*.pyc" -delete 2>/dev/null

    # Clean frontend build
    rm -rf frontend/dist
    rm -rf frontend/node_modules/.cache

    echo "Cleanup completed."
}

# Function to setup project
setup_project() {
    echo "Setting up Django Vue Starter project..."
    check_dependencies
    install_backend
    install_frontend
    run_migrations
    echo "Setup completed! Run './run.sh dev' to start development servers."
}

# Check if a command was provided
if [ $# -eq 0 ]; then
    show_usage
    exit 1
fi

# Run the requested command
case "$1" in
    backend)
        start_backend
        ;;
    frontend)
        start_frontend
        ;;
    dev)
        start_dev
        ;;
    setup)
        setup_project
        ;;
    migrate)
        run_migrations
        ;;
    createsuperuser)
        create_superuser
        ;;
    install-backend)
        install_backend
        ;;
    install-frontend)
        install_frontend
        ;;
    build-frontend)
        build_frontend
        ;;
    test)
        run_tests
        ;;
    clean)
        clean
        ;;
    help)
        show_usage
        ;;
    *)
        echo "Unknown command: $1"
        show_usage
        exit 1
        ;;
esac
