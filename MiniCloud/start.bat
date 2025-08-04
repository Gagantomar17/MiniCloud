@echo off
echo =====================================================
echo Starting MiniCloud Project
echo =====================================================
echo.

echo Checking if Java is installed...
java -version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Java is not installed or not in PATH
    echo Please install Java 22 and add it to your PATH
    pause
    exit /b 1
)
echo ✓ Java is installed
echo.

echo Creating uploads directory...
if not exist "uploads" mkdir uploads
echo ✓ Uploads directory ready
echo.

echo Building and starting the project...
echo This may take a few minutes on first run...
echo.

call gradlew.bat bootRun

echo.
echo =====================================================
echo MiniCloud application has stopped
echo =====================================================
pause 