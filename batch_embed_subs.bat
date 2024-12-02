@echo off
setlocal enabledelayedexpansion

:: Ask the user for subtitle language
set /p subtitle_lang=Enter subtitle language (en/ru): 

:: Validate user input
if not "!subtitle_lang!"=="en" if not "!subtitle_lang!"=="ru" (
    echo Invalid input. Use "en" or "ru".
    pause
    exit /b
)

:: Set track name based on language
if "!subtitle_lang!"=="en" (
    set "track_name=English"
) else (
    set "track_name=Русский"
)

:: Specify the path to MKVToolNix
set "mkvmerge_path=C:\Program Files\MKVToolNix\mkvmerge.exe"

:: Create a log file
set "log_file=process_log.txt"
echo Script started on %date% at %time% > "%log_file%"

:: Change to the folder with video files
cd /d "%~dp0"
echo Current folder: %cd% >> "%log_file%"

:: Check for MKV files
for %%A in (*.mkv) do (
    echo Found video file: %%A >> "%log_file%"
    echo Found video file: %%A

    :: Check for matching subtitle file
    set "subtitle_file="
    for %%S in ("%%~nA*.ass") do (
        set "subtitle_file=%%S"
        goto ProcessFile
    )

    echo No subtitles found for: %%A >> "%log_file%"
    echo No subtitles found for: %%A
    goto SkipFile

:ProcessFile
    echo Processing file: %%A with subtitles: !subtitle_file! >> "%log_file%"
    echo Processing file: %%A with subtitles: !subtitle_file!

    :: Dummy operation for debugging
    echo mkvmerge would run here on %%A and !subtitle_file! >> "%log_file%"

:SkipFile
)

echo Script finished on %date% at %time% >> "%log_file%"
echo Script finished on %date% at %time%

endlocal
pause
