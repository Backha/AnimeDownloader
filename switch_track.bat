@echo off
setlocal enabledelayedexpansion

:: Путь к MKVToolNix
set "mkvpropedit_path=C:\Program Files\MKVToolNix\mkvpropedit.exe"
set "mkvinfo_path=C:\Program Files\MKVToolNix\mkvinfo.exe"

:: Базовая папка с файлами
set "base_folder=F:\Anime"
set "log_file=F:\Anime\process_log.txt"

:: Очищаем/создаём лог-файл
echo Script started on %date% at %time% > "%log_file%"

:: Рекурсивный поиск файлов в папках, содержащих "AniLibria"
for /d %%D in ("%base_folder%\*AniLibria*") do (
    echo Checking folder: %%D >> "%log_file%"
    
    set "audio_count=0"
    set "subtitle_count=0"
    set "skip_folder=no"

    :: Проверяем все файлы в папке
    for %%F in ("%%D\*.mkv") do (
        echo Analyzing file: %%F >> "%log_file%"
        
        "%mkvinfo_path%" "%%F" | findstr /C:"Track type: audio" /C:"Track type: subtitles" > temp_check.txt

        :: Подсчитываем количество треков
        for /f "tokens=*" %%L in (temp_check.txt) do (
            if /i "%%L"=="|  + Track type: audio" set /a audio_count+=1
            if /i "%%L"=="|  + Track type: subtitles" set /a subtitle_count+=1
        )

        :: Проверка условий
        if !audio_count! lss 2 (
            echo Not enough audio tracks in folder %%D. Skipping... >> "%log_file%"
            set "skip_folder=yes"
            goto :skip_folder
        )
        if !subtitle_count! lss 2 (
            echo Not enough subtitle tracks in folder %%D. Skipping... >> "%log_file%"
            set "skip_folder=yes"
            goto :skip_folder
        )
    )

    :skip_folder
    if "!skip_folder!"=="yes" (
        echo Folder skipped: %%D >> "%log_file%"
        del temp_check.txt
        goto :next_folder
    )

    :: Обрабатываем файлы в папке, если все проверки пройдены
    for %%F in ("%%D\*.mkv") do (
        echo Processing file: %%F >> "%log_file%"
        "%mkvpropedit_path%" "%%F" --edit track:2 --set flag-default=1 --set flag-forced=0 --edit track:3 --set flag-default=0 --set flag-forced=1 --edit track:4 --set flag-default=1 --set flag-forced=0 --edit track:5 --set flag-default=0 --set flag-forced=1 >> "%log_file%" 2>&1

        if errorlevel 1 (
            echo Failed to process file: %%F >> "%log_file%"
        ) else (
            echo Successfully processed file: %%F >> "%log_file%"
        )
    )
    :next_folder
)

:: Завершаем скрипт
echo Script finished on %date% at %time% >> "%log_file%"
pause
