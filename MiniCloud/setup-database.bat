@echo off
echo =====================================================
echo MiniCloud Database Setup Script
echo =====================================================

echo.
echo This script will help you set up the database for MiniCloud.
echo.

REM Check if MySQL is installed
mysql --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: MySQL is not installed or not in PATH
    echo Please install MySQL and add it to your PATH
    pause
    exit /b 1
)

echo MySQL is installed. Proceeding with database setup...
echo.

REM Create development database
echo Creating development database...
mysql -u root -p -e "CREATE DATABASE IF NOT EXISTS minicloud_dev;"
if %errorlevel% neq 0 (
    echo ERROR: Failed to create development database
    echo Please check your MySQL credentials
    pause
    exit /b 1
)

REM Create production database
echo Creating production database...
mysql -u root -p -e "CREATE DATABASE IF NOT EXISTS minicloud;"
if %errorlevel% neq 0 (
    echo ERROR: Failed to create production database
    echo Please check your MySQL credentials
    pause
    exit /b 1
)

echo.
echo Databases created successfully!
echo.

REM Ask user which schema to use
echo Choose database schema:
echo 1. Simple schema (recommended for development)
echo 2. Production schema (advanced features)
echo.
set /p choice="Enter your choice (1 or 2): "

if "%choice%"=="1" (
    echo.
    echo Setting up simple schema...
    mysql -u root -p minicloud_dev < database\minicloud_simple.sql
    if %errorlevel% neq 0 (
        echo ERROR: Failed to set up simple schema
        pause
        exit /b 1
    )
    echo Simple schema set up successfully!
) else if "%choice%"=="2" (
    echo.
    echo Setting up production schema...
    mysql -u root -p minicloud < database\minicloud_production.sql
    if %errorlevel% neq 0 (
        echo ERROR: Failed to set up production schema
        pause
        exit /b 1
    )
    echo Production schema set up successfully!
) else (
    echo Invalid choice. Please run the script again.
    pause
    exit /b 1
)

echo.
echo =====================================================
echo Database setup completed successfully!
echo =====================================================
echo.
echo Next steps:
echo 1. Update your application.properties with correct database credentials
echo 2. Run the application with: .\gradlew.bat bootRun
echo 3. Access the application at: http://localhost:8080/api/v1
echo.
pause 