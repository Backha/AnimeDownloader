@echo off
:: Create the output directory if it doesn't exist
if not exist output mkdir output

:: Process all MP4 files in the folder
for %%A in (*.mp4) do (
    echo Processing "%%A"...
    "C:\Program Files\MKVToolNix\mkvmerge.exe" -o "output\%%~nA.mp4" "%%A" "%%~nA.ass"
)

pause
