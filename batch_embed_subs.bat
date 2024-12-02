@echo off
for %%A in (*.mp4) do (
    if not "%%~nA"=="The_Idolmaster_-_01" if not "%%~nA"=="The_Idolmaster_-_25" (
        echo Processing "%%A"...
        "C:\Program Files\MKVToolNix\mkvmerge.exe" -o "output\%%~nA_with_subs.mkv" "%%A" "%%~nA.ass"
    )
)
pause
