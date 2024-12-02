@echo off
:: Create the output directory if it doesn't exist
if not exist output mkdir output

:: Process all video files in the folder
for %%A in (*.mp4) do (
    echo Processing "%%A"...
    "C:\Program Files\MKVToolNix\mkvmerge.exe" -o "output\%%~nA.mkv" "%%A" "%%~nA.ass"
)

pause
