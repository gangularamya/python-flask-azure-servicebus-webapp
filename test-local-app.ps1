# test-local-app.ps1 - Test your local Flask app
Write-Host "🧪 Testing Flask Azure Service Bus App Locally" -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Green

$baseUrl = "http://localhost:5000"

# Test 1: Health Check
Write-Host "🏥 Test 1: Health Check..." -ForegroundColor Yellow
try {
    $health = Invoke-RestMethod -Uri "$baseUrl/health" -Method GET
    Write-Host "✅ Health Check: $($health.status)" -ForegroundColor Green
    Write-Host "   Connection Status: $($health.connection_status)" -ForegroundColor Cyan
    Write-Host "   Queue: $($health.service_bus_queue)" -ForegroundColor Cyan
} catch {
    Write-Host "❌ Health Check Failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 2: Send Message
Write-Host "`n📤 Test 2: Send Message..." -ForegroundColor Yellow
try {
    $messageData = @{
        message = "Hello from PowerShell test - $(Get-Date)"
    } | ConvertTo-Json
    
    $response = Invoke-RestMethod -Uri "$baseUrl/send-message" -Method POST -Body $messageData -ContentType "application/json"
    Write-Host "✅ Message Sent: $($response.message)" -ForegroundColor Green
    Write-Host "   Content: $($response.content)" -ForegroundColor Cyan
} catch {
    Write-Host "❌ Send Message Failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 3: Receive Messages
Write-Host "`n📥 Test 3: Receive Messages..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/receive-messages" -Method GET
    Write-Host "✅ Messages Received: $($response.messages_count)" -ForegroundColor Green
    
    if ($response.messages.Count -gt 0) {
        Write-Host "   Latest Message: $($response.messages[0].body)" -ForegroundColor Cyan
    }
} catch {
    Write-Host "❌ Receive Messages Failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n🎉 Testing Complete!" -ForegroundColor Green
Write-Host "Visit http://localhost:5000 to use the web interface" -ForegroundColor Cyan