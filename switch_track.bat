@echo off
setlocal enabledelayedexpansion

:: Укажите базовый путь, где искать папки с "AniLibria"
set "base_folder=F:\Anime"
set "log_file=F:\Anime\process_log.txt"

:: Очищаем или создаем файл логов
echo Script started on %date% at %time% > "%log_file%"

:: Флаг для остановки после первого файла
set "stop_after_first=true"

:: Проверка: существует ли базовая папка
if not exist "%base_folder%" (
    echo Base folder not found: %base_folder%
    echo Base folder not found: %base_folder% >> "%log_file%"
    pause
    exit /b
)

:: Рекурсивно обходим папки с названием, содержащим "AniLibria"
for /d %%D in ("%base_folder%\*AniLibria*") do (
    echo Checking folder: %%D
    echo Checking folder: %%D >> "%log_file%"
    if not exist "%%D\*.mkv" (
        echo No MKV files in folder %%D
        echo No MKV files in folder %%D >> "%log_file%"
        goto :continue
    )
    for %%A in ("%%D\*.mkv") do (
        echo Processing file: %%A
        echo Processing file: %%A >> "%log_file%"
        
        :: Извлекаем метаданные дорожек
        echo Extracting track info for %%A...
        "C:\Program Files\MKVToolNix\mkvinfo.exe" "%%A" > track_info.txt
        if errorlevel 1 (
            echo Failed to extract track info for %%A
            echo Failed to extract track info for %%A >> "%log_file%"
            goto :continue
        )

        :: Проверяем содержимое track_info.txt для отладки
        echo ======= TRACK INFO FOR %%A ======= >> "%log_file%"
        type track_info.txt >> "%log_file%"
        echo ================================== >> "%log_file%"

        :: Пример обработки: Меняем дефолтные дорожки
        echo Updating default tracks for %%A...
        "C:\Program Files\MKVToolNix\mkvmerge.exe" -o "%%A" "%%A" ^
        --default-track 1:yes --default-track 3:yes >> "%log_file%" 2>&1

        if errorlevel 1 (
            echo Failed to update default tracks for %%A
            echo Failed to update default tracks for %%A >> "%log_file%"
        ) else (
            echo File processed successfully: %%A
            echo File processed successfully: %%A >> "%log_file%"
        )

        if "!stop_after_first!" == "true" goto :end
    )
    :continue
)

:end
echo Script finished on %date% at %time% >> "%log_file%"
pause
