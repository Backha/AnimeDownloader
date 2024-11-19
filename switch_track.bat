@echo off
setlocal enabledelayedexpansion

:: Укажите базовый путь, где искать папки с "AniLibria"
set "base_folder=F:\Anime"
set "log_file=F:\Anime\process_log.txt"

:: Очищаем или создаем файл логов
echo Script started on %date% at %time% > "%log_file%"

:: Флаг для остановки после первого файла
set "stop_after_first=true"

:: Рекурсивно обходим папки с названием, содержащим "AniLibria"
for /d %%D in ("%base_folder%\*AniLibria*") do (
    echo Checking folder: %%D >> "%log_file%"
    for %%A in ("%%D\*.mkv") do (
        echo Processing file: %%A >> "%log_file%"
        
        :: Проверяем, установлена ли вторая дорожка как дефолтная
        "C:\Program Files\MKVToolNix\mkvinfo.exe" "%%A" | findstr /C:"Track number: 2" /C:"default_track: 1" > nul
        if !errorlevel! equ 0 (
            echo File "%%A" already has default tracks set, skipping. >> "%log_file%"
            echo Skipping file: %%A
            if "!stop_after_first!" == "true" goto :end
            goto :continue
        )
        
        :: Меняем дефолтные дорожки
        "C:\Program Files\MKVToolNix\mkvmerge.exe" -o "%%A" "%%A" ^
        --default-track 1:yes --default-track 3:yes >> "%log_file%" 2>&1

        echo File processed successfully: %%A >> "%log_file%"
        echo File processed: %%A
        if "!stop_after_first!" == "true" goto :end
        :continue
    )
)

:end
echo Script finished on %date% at %time% >> "%log_file%"
pause
