# Simple Azure App Service Deployment
# Easy 3-step deployment to Azure

Write-Host "🚀 Easy Azure App Service Deployment" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Green

# Step 1: Login to Azure (if needed)
Write-Host "🔑 Step 1: Checking Azure login..." -ForegroundColor Yellow
try {
    $account = az account show --output json | ConvertFrom-Json
    Write-Host "✅ Already logged in as: $($account.user.name)" -ForegroundColor Green
} catch {
    Write-Host "Please login to Azure..." -ForegroundColor Yellow
    az login
}

# Step 2: Set subscription
Write-Host "🎯 Step 2: Setting subscription..." -ForegroundColor Yellow
az account set --subscription "ME-MngEnvMCAP560609-ragangul-1"
Write-Host "✅ Subscription set" -ForegroundColor Green

# Step 3: Create or get App Service (if it doesn't exist)
Write-Host "🌐 Step 3: Creating App Service (if needed)..." -ForegroundColor Yellow

# Create resource group if it doesn't exist
az group create --name "pythonASBEHappRG" --location "East US" --output none
Write-Host "✅ Resource group ready" -ForegroundColor Green

# Create App Service Plan if it doesn't exist
az appservice plan create `
    --name "pythonASBEHappPlan" `
    --resource-group "pythonASBEHappRG" `
    --sku FREE `
    --is-linux `
    --output none
Write-Host "✅ App Service Plan ready" -ForegroundColor Green

# Create Web App if it doesn't exist
az webapp create `
    --name "pythonASBEHapp" `
    --resource-group "pythonASBEHappRG" `
    --plan "pythonASBEHappPlan" `
    --runtime "PYTHON:3.11" `
    --output none
Write-Host "✅ Web App ready" -ForegroundColor Green

# Step 4: Configure App Settings
Write-Host "⚙️ Step 4: Setting up configuration..." -ForegroundColor Yellow
az webapp config appsettings set `
    --name "pythonASBEHapp" `
    --resource-group "pythonASBEHappRG" `
    --settings `
        SERVICE_BUS_CONNECTION_STRING="your-azure-service-bus-connection-string" `
        QUEUE_NAME="asbqueue" `
        SCM_DO_BUILD_DURING_DEPLOYMENT="true" `
    --output none
Write-Host "✅ Configuration set" -ForegroundColor Green

# Step 5: Deploy the code
Write-Host "📦 Step 5: Deploying your Flask app..." -ForegroundColor Yellow

# Create deployment zip (excluding unnecessary files)
if (Test-Path "deployment.zip") { Remove-Item "deployment.zip" }

$filesToZip = @(
    "app.py",
    "requirements.txt", 
    "templates/*",
    "Procfile"
)

# Create a simple zip with just the necessary files
Compress-Archive -Path $filesToZip -DestinationPath "deployment.zip" -Force

# Deploy to Azure
az webapp deployment source config-zip `
    --name "pythonASBEHapp" `
    --resource-group "pythonASBEHappRG" `
    --src "deployment.zip" `
    --output none

# Clean up
Remove-Item "deployment.zip"

Write-Host "🎉 Deployment Complete!" -ForegroundColor Green
Write-Host "========================" -ForegroundColor Green
Write-Host "Your app is deployed at: https://pythonASBEHapp.azurewebsites.net" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Wait 2-3 minutes for the app to start" -ForegroundColor White
Write-Host "2. Visit the URL above to test your app" -ForegroundColor White
Write-Host "3. Check logs in Azure Portal if needed" -ForegroundColor White