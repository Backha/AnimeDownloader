@echo off
setlocal enabledelayedexpansion

:: Укажите базовый путь, где искать папки с "AniLibria"
set "base_folder=F:\Anime"
set "log_file=F:\Anime\process_log.txt"

:: Очищаем или создаем файл логов
echo Script started on %date% at %time% > "%log_file%"
echo Base folder: %base_folder% >> "%log_file%"

:: Проверка существования базовой папки
if not exist "%base_folder%" (
    echo ERROR: Base folder does not exist: %base_folder%
    echo ERROR: Base folder does not exist: %base_folder% >> "%log_file%"
    pause
    exit /b
)

:: Рекурсивно обходим папки с названием, содержащим "AniLibria"
for /d %%D in ("%base_folder%\*AniLibria*") do (
    echo Found folder: %%D
    echo Found folder: %%D >> "%log_file%"

    set "skip_folder=false"

    :: Проверяем все файлы в папке на наличие достаточного количества дорожек
    for %%A in ("%%D\*.mkv") do (
        echo Checking file: %%A >> "%log_file%"

        :: Проверяем количество дорожек
        "C:\Program Files\MKVToolNix\mkvinfo.exe" "%%A" > track_info.txt 2>>"%log_file%"
        if errorlevel 1 (
            echo ERROR: Failed to check tracks for %%A >> "%log_file%"
            set "skip_folder=true"
            goto :check_next_folder
        )

        set /a audio_count=0
        set /a subs_count=0

        for /f "tokens=*" %%B in ('type track_info.txt ^| findstr /C:"Track type: audio" /C:"Track type: subtitles"') do (
            echo %%B | findstr /C:"Track type: audio" >nul && set /a audio_count+=1
            echo %%B | findstr /C:"Track type: subtitles" >nul && set /a subs_count+=1
        )

        echo Audio tracks: !audio_count!, Subtitle tracks: !subs_count! >> "%log_file%"

        if !audio_count! lss 2 (
            echo Not enough audio tracks in %%A >> "%log_file%"
            set "skip_folder=true"
        )

        if !subs_count! lss 2 (
            echo Not enough subtitle tracks in %%A >> "%log_file%"
            set "skip_folder=true"
        )
    )

    :: Если в каком-либо файле недостаточно дорожек, пропускаем папку
    :check_next_folder
    if "!skip_folder!" == "true" (
        echo Skipping folder: %%D due to missing tracks >> "%log_file%"
        echo Skipping folder: %%D due to missing tracks
        goto :next_folder
    )

    :: Обрабатываем файлы в папке
    for %%A in ("%%D\*.mkv") do (
        echo Processing file: %%A >> "%log_file%"

        :: Создание временного файла
        set "temp_file=%%~dpAtmp_%%~nA.mkv"
        echo Creating temporary file: !temp_file! >> "%log_file%"

        "C:\Program Files\MKVToolNix\mkvmerge.exe" -o "!temp_file!" "%%A" ^
        --default-track 2:no --default-track 3:yes ^
        --default-track 4:no --default-track 5:yes >> "%log_file%" 2>&1

        if errorlevel 1 (
            echo ERROR: Failed to process %%A >> "%log_file%"
            del "!temp_file!" >nul 2>&1
        ) else (
            del "%%A"
            move /Y "!temp_file!" "%%A"
            echo File processed successfully: %%A >> "%log_file%"
        )
    )

    :next_folder
)
echo Script finished on %date% at %time% >> "%log_file%"
pause
