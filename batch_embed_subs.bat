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

:: Specify the path to MKVToolNix (change if needed)
set "mkvmerge_path=C:\Program Files\MKVToolNix\mkvmerge.exe"

:: Create a log file
set "log_file=process_log.txt"
echo Script started on %date% at %time% > "%log_file%"

:: Change to the folder with video files
cd /d "%~dp0"
echo Current folder: %cd% >> "%log_file%"

:: Process each MP4 file in the folder
for %%A in (*.mp4) do (
    :: Get the file name without extension
    set "filename=%%~nA"

    :: Find the first matching subtitle file
    set "subtitle_file="
    for %%S in ("!filename!.*.ass") do (
        set "subtitle_file=%%S"
        goto FoundSubtitle
    )

    :: No subtitle file found
    echo No subtitles found for: %%A >> "%log_file%"
    echo No subtitles found for: %%A
    goto SkipFile

:FoundSubtitle
    echo Processing file: %%A with subtitles: !subtitle_file! >> "%log_file%"
    echo Processing file: %%A with subtitles: !subtitle_file!

    :: Create a new file with embedded subtitles and set track name
    "%mkvmerge_path%" -o "!filename!_with_subs.mkv" "%%A" --track-name 0:"!track_name!" "!subtitle_file!" >> "%log_file%" 2>&1

    :: Check if the operation was successful
    if !errorlevel! equ 0 (
        echo Success: %%A >> "%log_file%"
        echo Success: %%A

        :: Delete the original file
        echo Deleting original file: %%A >> "%log_file%"
        del "%%A"

        :: Rename the new file to the original name
        echo Renaming file: "!filename!_with_subs.mkv" to "%%~nA%%~xA" >> "%log_file%"
        ren "!filename!_with_subs.mkv" "%%~nA%%~xA"

        :: Delete the subtitle file
        echo Deleting subtitle file: !subtitle_file! >> "%log_file%"
        del "!subtitle_file!"
    ) else (
        echo Error processing file: %%A >> "%log_file%"
        echo Error processing file: %%A
    )

:SkipFile
)

echo Script finished on %date% at %time% >> "%log_file%"
echo Script finished on %date% at %time%

endlocal
pause
