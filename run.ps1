# Run script for Flask Azure Service Bus App

Write-Host "🐍 Starting Flask Azure Service Bus Application" -ForegroundColor Green
Write-Host "===============================================" -ForegroundColor Green

# Navigate to project directory
$projectPath = "c:\samples\pythonASBEventHubappservice"
Set-Location $projectPath

# Check if virtual environment exists
if (Test-Path ".\venv\Scripts\python.exe") {
    Write-Host "✅ Virtual environment found" -ForegroundColor Green
    
    # Run the Flask app
    Write-Host "🚀 Starting Flask application..." -ForegroundColor Yellow
    Write-Host "📍 Application will be available at: http://localhost:5000" -ForegroundColor Cyan
    Write-Host "🛑 Press Ctrl+C to stop the application" -ForegroundColor Yellow
    Write-Host "===============================================" -ForegroundColor Green
    
    & .\venv\Scripts\python.exe app.py
} else {
    Write-Host "❌ Virtual environment not found!" -ForegroundColor Red
    Write-Host "Please run setup.ps1 first to create the virtual environment" -ForegroundColor Yellow
    Write-Host "Command: .\setup.ps1" -ForegroundColor White
}