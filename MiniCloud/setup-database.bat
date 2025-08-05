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

REM Create database
echo Creating database...
mysql -u root -p -e "CREATE DATABASE IF NOT EXISTS minicloud;"
if %errorlevel% neq 0 (
    echo ERROR: Failed to create database
    echo Please check your MySQL credentials
    pause
    exit /b 1
)



echo.
echo Databases created successfully!
echo.

echo Setting up schema...
mysql -u root -p minicloud < database\minicloud.sql
if %errorlevel% neq 0 (
    echo ERROR: Failed to set up schema
    pause
    exit /b 1
)
echo Schema set up successfully!

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