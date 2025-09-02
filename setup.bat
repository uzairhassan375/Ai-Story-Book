@echo off
echo 🚀 Setting up AI Storybook App...
echo ==================================

REM Check if Python is installed
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Python is not installed. Please install Python 3.8+ first.
    echo Visit: https://www.python.org/downloads/
    pause
    exit /b 1
)

REM Check if Flutter is installed
flutter --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Flutter is not installed. Please install Flutter SDK first.
    echo Visit: https://flutter.dev/docs/get-started/install
    pause
    exit /b 1
)

echo ✅ Python and Flutter are installed

echo Installing Python backend dependencies...
cd /d "%~dp0backend"
pip install -r requirements.txt

if %errorlevel% equ 0 (
    echo ✅ Backend dependencies installed successfully
) else (
    echo ❌ Failed to install backend dependencies
    pause
    exit /b 1
)

cd /d "%~dp0"

echo Installing Flutter frontend dependencies...
cd /d "%~dp0frontend"
flutter pub get

if %errorlevel% equ 0 (
    echo ✅ Frontend dependencies installed successfully
) else (
    echo ❌ Failed to install frontend dependencies
    pause
    exit /b 1
)

cd /d "%~dp0"

echo.
echo 🎉 Setup completed successfully!
echo.
echo Next steps:
echo 1. Configure your API keys in environment variables
echo 2. Set up Firebase project and add configuration files
echo 3. Start the backend: cd backend ^&^& python app.py
echo 4. Start the frontend: cd frontend ^&^& flutter run -d windows
echo.
echo For detailed instructions, see README.md
pause
