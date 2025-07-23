# PowerShell script for Django Vue Starter project management

param(
    [Parameter(Position=0)]
    [string]$Command
)

# Load environment variables from .env file
function Load-EnvironmentVariables {
    if (Test-Path ".env") {
        Get-Content ".env" | ForEach-Object {
            if ($_ -and $_ -notmatch "^#") {
                $name, $value = $_ -split "=", 2
                if ($name -and $value) {
                    [Environment]::SetEnvironmentVariable($name.Trim(), $value.Trim(), "Process")
                }
            }
        }
    }
}

# Load environment variables
Load-EnvironmentVariables

# Default ports from environment or fallback
$DJANGO_PORT = if ($env:DJANGO_PORT) { $env:DJANGO_PORT } else { "8000" }
$VUE_PORT = if ($env:VUE_PORT) { $env:VUE_PORT } else { "9000" }

# Function to display usage information
function Show-Usage {
    Write-Host "Usage: .\run.ps1 [command]"
    Write-Host "Available commands:"
    Write-Host "  backend        - Start Django development server"
    Write-Host "  frontend       - Start Vue/Quasar development server"
    Write-Host "  dev            - Start both backend and frontend in parallel"
    Write-Host "  dev-process    - Start both services using separate processes (alternative for Ctrl+C issues)"
    Write-Host "  setup          - Install dependencies and setup project"
    Write-Host "  migrate        - Run Django migrations"
    Write-Host "  createsuperuser - Create Django superuser"
    Write-Host "  install-backend - Install Python dependencies"
    Write-Host "  install-frontend - Install Node.js dependencies"
    Write-Host "  build-frontend - Build frontend for production"
    Write-Host "  test           - Run tests"
    Write-Host "  clean          - Clean generated files"
    Write-Host "  help           - Show this help message"
}

# Function to check if command exists
function Test-CommandExists {
    param([string]$CommandName)
    $null = Get-Command $CommandName -ErrorAction SilentlyContinue
    return $?
}

# Function to check dependencies
function Test-Dependencies {
    Write-Host "Checking dependencies..."

    if (-not (Test-CommandExists "python")) {
        Write-Host "Error: Python is required but not installed." -ForegroundColor Red
        exit 1
    }

    if (-not (Test-CommandExists "node")) {
        Write-Host "Error: Node.js is required but not installed." -ForegroundColor Red
        exit 1
    }

    if (-not (Test-CommandExists "npm")) {
        Write-Host "Error: npm is required but not installed." -ForegroundColor Red
        exit 1
    }

    Write-Host "All dependencies found." -ForegroundColor Green
}

# Function to install backend dependencies
function Install-Backend {
    Write-Host "Installing Python dependencies..."
    Set-Location "backend"

    if (-not (Test-Path ".venv")) {
        Write-Host "Creating virtual environment..."
        python -m venv .venv
    }

    # Activate virtual environment
    & ".venv\Scripts\Activate.ps1"

    python -m pip install --upgrade pip
    pip install -r requirements.txt

    Write-Host "Backend dependencies installed." -ForegroundColor Green
    Set-Location ".."
}

# Function to install frontend dependencies
function Install-Frontend {
    Write-Host "Installing Node.js dependencies..."
    Set-Location "frontend"
    npm install
    Write-Host "Frontend dependencies installed." -ForegroundColor Green
    Set-Location ".."
}

# Function to run Django migrations
function Invoke-Migrations {
    Write-Host "Running Django migrations..."
    Set-Location "backend"

    # Activate virtual environment
    & ".venv\Scripts\Activate.ps1"

    python manage.py makemigrations
    python manage.py migrate

    Write-Host "Migrations completed." -ForegroundColor Green
    Set-Location ".."
}

# Function to create superuser
function New-Superuser {
    Write-Host "Creating Django superuser..."
    Set-Location "backend"

    # Activate virtual environment
    & ".venv\Scripts\Activate.ps1"

    python manage.py createsuperuser
    Set-Location ".."
}

# Function to start Django backend
function Start-Backend {
    Write-Host "Starting Django development server on port $DJANGO_PORT..."
    Set-Location "backend"

    # Activate virtual environment
    & ".venv\Scripts\Activate.ps1"

    python manage.py runserver "0.0.0.0:$DJANGO_PORT"
}

# Function to start Vue frontend
function Start-Frontend {
    Write-Host "Starting Vue/Quasar development server on port $VUE_PORT..."
    Set-Location "frontend"
    npm run dev
}

# Function to start both services
function Start-Dev {
    Write-Host "Starting both backend and frontend..."

    # Register cleanup handler for Ctrl+C
    $script:BackendJob = $null
    $script:FrontendJob = $null

    Register-EngineEvent -SourceIdentifier PowerShell.Exiting -Action {
        Write-Host "`nShutting down services..." -ForegroundColor Yellow
        if ($script:BackendJob) {
            $script:BackendJob | Stop-Job -PassThru | Remove-Job -Force
        }
        if ($script:FrontendJob) {
            $script:FrontendJob | Stop-Job -PassThru | Remove-Job -Force
        }
    }

    # Start backend in background
    $script:BackendJob = Start-Job -ScriptBlock {
        Set-Location $using:PWD
        Set-Location "backend"
        & ".venv\Scripts\Activate.ps1"
        python manage.py runserver "0.0.0.0:$using:DJANGO_PORT"
    }

    # Wait a moment for backend to start
    Start-Sleep -Seconds 3

    # Start frontend in background
    $script:FrontendJob = Start-Job -ScriptBlock {
        Set-Location $using:PWD
        Set-Location "frontend"
        npm run dev
    }

    Write-Host "Backend Job ID: $($script:BackendJob.Id)"
    Write-Host "Frontend Job ID: $($script:FrontendJob.Id)"
    Write-Host "Press Ctrl+C to stop both services"

    try {
        # Wait for either job to finish and receive their output
        while ($script:BackendJob.State -eq "Running" -or $script:FrontendJob.State -eq "Running") {
            # Check for Ctrl+C using console key available
            if ([Console]::KeyAvailable) {
                $key = [Console]::ReadKey($true)
                if ($key.Modifiers -eq [ConsoleModifiers]::Control -and $key.Key -eq [ConsoleKey]::C) {
                    Write-Host "`nCtrl+C detected. Stopping services..." -ForegroundColor Yellow
                    break
                }
            }

            $script:BackendJob | Receive-Job
            $script:FrontendJob | Receive-Job
            Start-Sleep -Seconds 1
        }
    }
    catch [System.Management.Automation.PipelineStoppedException] {
        Write-Host "`nInterrupted. Stopping services..." -ForegroundColor Yellow
    }
    finally {
        # Clean up jobs
        Write-Host "Cleaning up background jobs..." -ForegroundColor Yellow
        if ($script:BackendJob) {
            $script:BackendJob | Stop-Job -PassThru | Remove-Job -Force
        }
        if ($script:FrontendJob) {
            $script:FrontendJob | Stop-Job -PassThru | Remove-Job -Force
        }

        # Unregister the event handler
        Get-EventSubscriber -SourceIdentifier PowerShell.Exiting -ErrorAction SilentlyContinue | Unregister-Event

        Write-Host "All services stopped." -ForegroundColor Green
    }
}

# Alternative function using Start-Process (often more reliable for Ctrl+C)
function Start-DevProcess {
    Write-Host "Starting both backend and frontend with Start-Process..."

    $script:BackendProcess = $null
    $script:FrontendProcess = $null

    try {
        # Start backend process
        Write-Host "Starting Django development server on port $DJANGO_PORT..."
        $BackendArgs = @(
            "-Command"
            "Set-Location 'backend'; & '.venv\Scripts\Activate.ps1'; python manage.py runserver 0.0.0.0:$DJANGO_PORT"
        )
        $script:BackendProcess = Start-Process -FilePath "powershell.exe" -ArgumentList $BackendArgs -PassThru -WindowStyle Normal

        # Wait a moment for backend to start
        Start-Sleep -Seconds 3

        # Start frontend process
        Write-Host "Starting Vue/Quasar development server on port $VUE_PORT..."
        $FrontendArgs = @(
            "-Command"
            "Set-Location 'frontend'; npm run dev"
        )
        $script:FrontendProcess = Start-Process -FilePath "powershell.exe" -ArgumentList $FrontendArgs -PassThru -WindowStyle Normal

        Write-Host "Backend Process ID: $($script:BackendProcess.Id)"
        Write-Host "Frontend Process ID: $($script:FrontendProcess.Id)"
        Write-Host "Press Ctrl+C to stop both services, or close the terminal windows"

        # Wait for user to press Ctrl+C
        Write-Host "Services are running. Press any key to stop..."
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    }
    finally {
        # Clean up processes
        Write-Host "`nStopping services..." -ForegroundColor Yellow

        if ($script:BackendProcess -and -not $script:BackendProcess.HasExited) {
            Write-Host "Stopping backend process..."
            $script:BackendProcess.Kill()
            $script:BackendProcess.WaitForExit(5000)
        }

        if ($script:FrontendProcess -and -not $script:FrontendProcess.HasExited) {
            Write-Host "Stopping frontend process..."
            $script:FrontendProcess.Kill()
            $script:FrontendProcess.WaitForExit(5000)
        }

        Write-Host "All services stopped." -ForegroundColor Green
    }
}

# Function to build frontend for production
function Build-Frontend {
    Write-Host "Building frontend for production..."
    Set-Location "frontend"
    npm run build
    Write-Host "Frontend build completed." -ForegroundColor Green
    Set-Location ".."
}

# Function to run tests
function Invoke-Tests {
    Write-Host "Running tests..."

    Write-Host "Running Django tests..."
    Set-Location "backend"
    & ".venv\Scripts\Activate.ps1"
    python manage.py test
    Set-Location ".."

    Write-Host "Running frontend tests..."
    Set-Location "frontend"
    npm run test
    Set-Location ".."
}

# Function to clean generated files
function Clear-GeneratedFiles {
    Write-Host "Cleaning generated files..."

    # Clean Python cache
    Get-ChildItem -Path . -Recurse -Directory -Name "__pycache__" | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
    Get-ChildItem -Path . -Recurse -File -Name "*.pyc" | Remove-Item -Force -ErrorAction SilentlyContinue

    # Clean frontend build
    if (Test-Path "frontend\dist") {
        Remove-Item "frontend\dist" -Recurse -Force
    }
    if (Test-Path "frontend\node_modules\.cache") {
        Remove-Item "frontend\node_modules\.cache" -Recurse -Force
    }

    Write-Host "Cleanup completed." -ForegroundColor Green
}

# Function to setup project
function Initialize-Project {
    Write-Host "Setting up Django Vue Starter project..."
    Test-Dependencies
    Install-Backend
    Install-Frontend
    Invoke-Migrations
    Write-Host "Setup completed! Run '.\run.ps1 dev' to start development servers." -ForegroundColor Green
}

# Check if a command was provided
if (-not $Command) {
    Show-Usage
    exit 1
}

# Run the requested command
switch ($Command.ToLower()) {
    "backend" {
        Start-Backend
    }
    "frontend" {
        Start-Frontend
    }
    "dev" {
        Start-Dev
    }
    "dev-process" {
        Start-DevProcess
    }
    "setup" {
        Initialize-Project
    }
    "migrate" {
        Invoke-Migrations
    }
    "createsuperuser" {
        New-Superuser
    }
    "install-backend" {
        Install-Backend
    }
    "install-frontend" {
        Install-Frontend
    }
    "build-frontend" {
        Build-Frontend
    }
    "test" {
        Invoke-Tests
    }
    "clean" {
        Clear-GeneratedFiles
    }
    "help" {
        Show-Usage
    }
    default {
        Write-Host "Unknown command: $Command" -ForegroundColor Red
        Show-Usage
        exit 1
    }
}
