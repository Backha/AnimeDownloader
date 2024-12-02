@echo off
setlocal enabledelayedexpansion

:: Output the script's directory
echo Script is running from: %~dp0

:: Switch to the script's directory
cd /d "%~dp0"

:: Output the current directory after switching
echo Current working directory: %cd%

:: Check for MKV files
for %%A in (*.mkv) do (
    echo Found file: %%A
)

:: Check if no MKV files were found
if not exist *.mkv (
    echo No MKV files found in this directory.
)

pause
