# Quick Fix Deployment - Includes Templates Folder
Write-Host "🔧 Quick Fix Deployment - Including Templates" -ForegroundColor Yellow
Write-Host "==============================================" -ForegroundColor Yellow

# Create a proper deployment package
Write-Host "📦 Creating proper deployment package..." -ForegroundColor Green

# Remove old zip if exists
if (Test-Path "fix-deployment.zip") { Remove-Item "fix-deployment.zip" }

# Create zip with all necessary files including templates
$compress = @{
    Path = "app.py", "requirements.txt", "Procfile", "templates"
    CompressionLevel = "Optimal"
    DestinationPath = "fix-deployment.zip"
}
Compress-Archive @compress

# Deploy the corrected version
Write-Host "🚀 Deploying corrected version..." -ForegroundColor Green
az webapp deployment source config-zip `
    --name "pythonASBEHapp" `
    --resource-group "pythonASBEHappRG" `
    --src "fix-deployment.zip"

# Clean up
Remove-Item "fix-deployment.zip"

Write-Host "✅ Fixed deployment complete!" -ForegroundColor Green
Write-Host "Your app should work now at: https://pythonASBEHapp.azurewebsites.net" -ForegroundColor Cyan
Write-Host "Wait 1-2 minutes for the deployment to complete." -ForegroundColor Yellow