@echo off
cls
setlocal enabledelayedexpansion
title comfyui-rocm Updater

echo ====================================================
echo  comfyui-rocm - Updater
echo ====================================================
echo.

:: Check if git is available
where git >nul 2>&1
if errorlevel 1 (
    echo [!] Git not found. Please install Git from https://git-scm.com/download/win
    pause
    exit /b 1
)

set "REPO_URL=https://github.com/patientx-cfz/comfyui-rocm"
set "INSTALL_DIR=%~dp0"
set "TEMP_DIR=%INSTALL_DIR%_update_temp"

echo [*] Fetching latest source from GitHub...
echo.

:: Clone repo into a temp folder (shallow, just latest commit)
if exist "%TEMP_DIR%" rd /s /q "%TEMP_DIR%"
git clone --depth 1 --quiet "%REPO_URL%" "%TEMP_DIR%"
if errorlevel 1 (
    echo [!] Failed to fetch updates. Check your internet connection.
    if exist "%TEMP_DIR%" rd /s /q "%TEMP_DIR%"
    pause
    exit /b 1
)

echo [*] Applying updates...

:: Copy everything EXCEPT preserved user folders and files
robocopy "%TEMP_DIR%" "%INSTALL_DIR%" /E /XD "%TEMP_DIR%\python_env" "%TEMP_DIR%\models" "%TEMP_DIR%\output" "%TEMP_DIR%\input" "%TEMP_DIR%\user" "%TEMP_DIR%\custom_nodes" /XF "%INSTALL_DIR%comfyui-user.bat" /NFL /NDL /NJH /NJS >nul 2>&1

:: Clean up temp
rd /s /q "%TEMP_DIR%"

echo [*] Checking Python dependencies...
.\python_env\python.exe -m pip install -r requirements.txt --no-warn-script-location --quiet
if errorlevel 1 (
    echo [!] Warning: dependency update had errors, comfyui-rocm may still work.
)

echo.
echo ====================================================
echo  Update complete!
echo  Your models, outputs, and custom_nodes were kept.
echo ====================================================
echo.
pause
