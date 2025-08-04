@echo off
echo =====================================================
echo Stopping MiniCloud Project
echo =====================================================
echo.

echo Stopping application on port 8080...
netstat -ano | findstr :8080 >nul 2>&1
if %errorlevel% equ 0 (
    for /f "tokens=5" %%a in ('netstat -ano ^| findstr :8080') do (
        echo Found process with PID: %%a
        taskkill /PID %%a /F >nul 2>&1
        echo ✓ Application stopped
    )
) else (
    echo No application found running on port 8080
)
echo.

echo Stopping Gradle daemon...
call gradlew.bat --stop >nul 2>&1
echo ✓ Gradle daemon stopped
echo.

echo =====================================================
echo MiniCloud Project Stopped
echo =====================================================
echo.
echo To start the application again, run: start.bat
echo.
pause
