# =====================================================
# MiniCloud Database Setup Script (PowerShell)
# =====================================================

Write-Host "=====================================================" -ForegroundColor Green
Write-Host "MiniCloud Database Setup Script" -ForegroundColor Green
Write-Host "=====================================================" -ForegroundColor Green

Write-Host ""
Write-Host "This script will help you set up the database for MiniCloud." -ForegroundColor Yellow
Write-Host ""

# Check if MySQL is installed
try {
    $mysqlVersion = mysql --version 2>$null
    if ($LASTEXITCODE -ne 0) {
        throw "MySQL not found"
    }
    Write-Host "MySQL is installed: $mysqlVersion" -ForegroundColor Green
} catch {
    Write-Host "ERROR: MySQL is not installed or not in PATH" -ForegroundColor Red
    Write-Host "Please install MySQL and add it to your PATH" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host ""
Write-Host "MySQL is installed. Proceeding with database setup..." -ForegroundColor Green
Write-Host ""

# Get MySQL credentials
$mysqlUser = Read-Host "Enter MySQL username (default: root)"
if ([string]::IsNullOrEmpty($mysqlUser)) {
    $mysqlUser = "root"
}

$mysqlPassword = Read-Host "Enter MySQL password" -AsSecureString
$mysqlPasswordPlain = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($mysqlPassword))

# Create database
Write-Host "Creating database..." -ForegroundColor Yellow
$dbCommand = "CREATE DATABASE IF NOT EXISTS minicloud;"
if ([string]::IsNullOrEmpty($mysqlPasswordPlain)) {
    mysql -u $mysqlUser -e $dbCommand
} else {
    mysql -u $mysqlUser -p$mysqlPasswordPlain -e $dbCommand
}

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Failed to create database" -ForegroundColor Red
    Write-Host "Please check your MySQL credentials" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}



Write-Host ""
Write-Host "Databases created successfully!" -ForegroundColor Green
Write-Host ""

Write-Host "Setting up schema..." -ForegroundColor Yellow
if ([string]::IsNullOrEmpty($mysqlPasswordPlain)) {
    mysql -u $mysqlUser minicloud < database\minicloud.sql
} else {
    mysql -u $mysqlUser -p$mysqlPasswordPlain minicloud < database\minicloud.sql
}

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Failed to set up schema" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}
Write-Host "Schema set up successfully!" -ForegroundColor Green

Write-Host ""
Write-Host "=====================================================" -ForegroundColor Green
Write-Host "Database setup completed successfully!" -ForegroundColor Green
Write-Host "=====================================================" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Update your application.properties with correct database credentials" -ForegroundColor White
Write-Host "2. Run the application with: .\gradlew.bat bootRun" -ForegroundColor White
Write-Host "3. Access the application at: http://localhost:8080/api/v1" -ForegroundColor White
Write-Host ""
Read-Host "Press Enter to exit" 