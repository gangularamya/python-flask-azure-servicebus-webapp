# Azure Web App Deployment Script
# This script helps deploy the Flask app to Azure App Service

param(
    [Parameter(Mandatory=$true)]
    [string]$ResourceGroupName,
    
    [Parameter(Mandatory=$true)]
    [string]$WebAppName,
    
    [Parameter(Mandatory=$true)]
    [string]$ServiceBusConnectionString,
    
    [string]$Location = "East US",
    [string]$AppServicePlan = "ASP-$WebAppName"
)

Write-Host "🚀 Azure Web App Deployment Script" -ForegroundColor Green
Write-Host "===================================" -ForegroundColor Green

# Check if Azure CLI is installed
try {
    az --version | Out-Null
    Write-Host "✅ Azure CLI found" -ForegroundColor Green
} catch {
    Write-Host "❌ Azure CLI not found. Please install Azure CLI first." -ForegroundColor Red
    Write-Host "Download from: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli" -ForegroundColor Yellow
    exit 1
}

# Login to Azure (if not already logged in)
Write-Host "🔑 Checking Azure login status..." -ForegroundColor Yellow
$loginCheck = az account show 2>$null
if (-not $loginCheck) {
    Write-Host "Please login to Azure..." -ForegroundColor Yellow
    az login
}

# Create Resource Group
Write-Host "📁 Creating Resource Group: $ResourceGroupName" -ForegroundColor Yellow
az group create --name $ResourceGroupName --location $Location

# Create App Service Plan (Linux, Python 3.13)
Write-Host "📋 Creating App Service Plan: $AppServicePlan" -ForegroundColor Yellow
az appservice plan create `
    --name $AppServicePlan `
    --resource-group $ResourceGroupName `
    --sku B1 `
    --is-linux

# Create Web App
Write-Host "🌐 Creating Web App: $WebAppName" -ForegroundColor Yellow
az webapp create `
    --resource-group $ResourceGroupName `
    --plan $AppServicePlan `
    --name $WebAppName `
    --runtime "PYTHON:3.13" `
    --startup-file "gunicorn --bind=0.0.0.0 --timeout 600 app:app"

# Configure App Settings
Write-Host "⚙️ Configuring App Settings..." -ForegroundColor Yellow
az webapp config appsettings set `
    --resource-group $ResourceGroupName `
    --name $WebAppName `
    --settings `
        SERVICE_BUS_CONNECTION_STRING="$ServiceBusConnectionString" `
        QUEUE_NAME="asbqueue" `
        SCM_DO_BUILD_DURING_DEPLOYMENT="true"

# Deploy code
Write-Host "📦 Deploying code to Web App..." -ForegroundColor Yellow
# First, create a zip file of the project (excluding venv and other unnecessary files)
$excludeFiles = @('venv', '.git', '__pycache__', '*.pyc', '.env')
$zipPath = "deployment.zip"

# Remove existing zip if it exists
if (Test-Path $zipPath) {
    Remove-Item $zipPath
}

# Create zip file
Add-Type -AssemblyName System.IO.Compression.FileSystem
$compressionLevel = [System.IO.Compression.CompressionLevel]::Optimal
$zip = [System.IO.Compression.ZipFile]::Open($zipPath, 'Create')

Get-ChildItem -Path . -Recurse | Where-Object {
    $item = $_
    $exclude = $false
    foreach ($pattern in $excludeFiles) {
        if ($item.FullName -like "*$pattern*") {
            $exclude = $true
            break
        }
    }
    return -not $exclude -and -not $item.PSIsContainer
} | ForEach-Object {
    $relativePath = $_.FullName.Substring((Get-Location).Path.Length + 1)
    [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($zip, $_.FullName, $relativePath, $compressionLevel)
}

$zip.Dispose()

# Deploy the zip file
az webapp deployment source config-zip `
    --resource-group $ResourceGroupName `
    --name $WebAppName `
    --src $zipPath

# Clean up zip file
Remove-Item $zipPath

# Get the Web App URL
$webAppUrl = az webapp show --resource-group $ResourceGroupName --name $WebAppName --query "defaultHostName" --output tsv
$fullUrl = "https://$webAppUrl"

Write-Host "🎉 Deployment completed!" -ForegroundColor Green
Write-Host "===================================" -ForegroundColor Green
Write-Host "Web App URL: $fullUrl" -ForegroundColor Cyan
Write-Host "Resource Group: $ResourceGroupName" -ForegroundColor White
Write-Host "App Service Plan: $AppServicePlan" -ForegroundColor White
Write-Host "===================================" -ForegroundColor Green
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Wait 2-3 minutes for the deployment to complete" -ForegroundColor White
Write-Host "2. Visit the URL above to test your application" -ForegroundColor White
Write-Host "3. Check Azure Portal for logs if needed" -ForegroundColor White