# Setup script for Flask Azure Service Bus App
# This script creates a virtual environment and installs required packages

Write-Host "🐍 Setting up Flask Azure Service Bus Application" -ForegroundColor Green
Write-Host "=================================================" -ForegroundColor Green

# Define Python path
$pythonPath = "C:\Users\ragangul\AppData\Local\Programs\Python\Python313\python.exe"

# Check if Python 3.13 exists
if (Test-Path $pythonPath) {
    Write-Host "✅ Found Python 3.13 at: $pythonPath" -ForegroundColor Green
} else {
    Write-Host "❌ Python 3.13 not found at: $pythonPath" -ForegroundColor Red
    Write-Host "Please install Python 3.13 or update the path in this script" -ForegroundColor Yellow
    exit 1
}

# Navigate to project directory
$projectPath = "c:\samples\pythonASBEventHubappservice"
Set-Location $projectPath
Write-Host "📁 Working in directory: $projectPath" -ForegroundColor Cyan

# Create virtual environment
Write-Host "🔄 Creating virtual environment..." -ForegroundColor Yellow
& $pythonPath -m venv venv

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Virtual environment created successfully" -ForegroundColor Green
} else {
    Write-Host "❌ Failed to create virtual environment" -ForegroundColor Red
    exit 1
}

# Activate virtual environment
Write-Host "🔄 Activating virtual environment..." -ForegroundColor Yellow
& .\venv\Scripts\Activate.ps1

# Upgrade pip
Write-Host "🔄 Upgrading pip..." -ForegroundColor Yellow
& .\venv\Scripts\python.exe -m pip install --upgrade pip

# Install requirements
Write-Host "🔄 Installing requirements..." -ForegroundColor Yellow
& .\venv\Scripts\pip.exe install -r requirements.txt

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ All packages installed successfully" -ForegroundColor Green
} else {
    Write-Host "❌ Failed to install packages" -ForegroundColor Red
    exit 1
}

# Display installed packages
Write-Host "📦 Installed packages:" -ForegroundColor Cyan
& .\venv\Scripts\pip.exe list

Write-Host "`n🎉 Setup completed successfully!" -ForegroundColor Green
Write-Host "=================================================" -ForegroundColor Green
Write-Host "To run the application:" -ForegroundColor White
Write-Host "1. Activate virtual environment: .\venv\Scripts\Activate.ps1" -ForegroundColor Yellow
Write-Host "2. Update .env file with your actual Service Bus connection string" -ForegroundColor Yellow
Write-Host "3. Run the app: python app.py" -ForegroundColor Yellow
Write-Host "4. Open browser: http://localhost:5000" -ForegroundColor Yellow
Write-Host "=================================================" -ForegroundColor Green