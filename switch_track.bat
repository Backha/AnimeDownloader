@echo off
setlocal enabledelayedexpansion

:: Укажите базовый путь, где искать папки с "AniLibria"
set "base_folder=F:\Anime"
set "log_file=F:\Anime\process_log.txt"

:: Очищаем или создаем файл логов
echo Script started on %date% at %time% > "%log_file%"

:: Рекурсивно обходим папки с названием, содержащим "AniLibria"
for /d %%D in ("%base_folder%\*AniLibria*") do (
    echo Checking folder: %%D
    echo Checking folder: %%D >> "%log_file%"
    for %%A in ("%%D\*.mkv") do (
        echo Processing file: %%A
        echo Processing file: %%A >> "%log_file%"
        
        :: Меняем дефолтные дорожки
        "C:\Program Files\MKVToolNix\mkvmerge.exe" -o "%%A.temp" "%%A" ^
        --default-track 1:no --default-track 2:yes ^
        --default-track 3:no --default-track 4:yes >> "%log_file%" 2>&1

        if errorlevel 1 (
            echo Failed to update default tracks for %%A
            echo Failed to update default tracks for %%A >> "%log_file%"
            del "%%A.temp" >nul 2>&1
        ) else (
            :: Проверяем результат
            "C:\Program Files\MKVToolNix\mkvinfo.exe" "%%A.temp" | findstr "default_track" >> "%log_file%"
            
            if not exist "%%A.temp" (
                echo File processing failed unexpectedly for %%A
                echo File processing failed unexpectedly for %%A >> "%log_file%"
            ) else (
                del "%%A"
                move "%%A.temp" "%%A"
                echo File processed successfully: %%A
                echo File processed successfully: %%A >> "%log_file%"
            )
        )
    )
)

echo Script finished on %date% at %time% >> "%log_file%"
pause
