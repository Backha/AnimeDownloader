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
    set "skip_folder=false"
    
    for %%A in ("%%D\*.mkv") do (
        echo Checking file: %%A >> "%log_file%"
        
        :: Проверяем количество дорожек
        "C:\Program Files\MKVToolNix\mkvinfo.exe" "%%A" | findstr /C:"Track type: audio" /C:"Track type: subtitles" > track_check.txt
        set /a audio_count=0
        set /a subs_count=0
        for /f "tokens=*" %%B in (track_check.txt) do (
            echo %%B | findstr /C:"Track type: audio" >nul && set /a audio_count+=1
            echo %%B | findstr /C:"Track type: subtitles" >nul && set /a subs_count+=1
        )
        
        if !audio_count! lss 2 (
            echo Not enough audio tracks in %%A >> "%log_file%"
            set "skip_folder=true"
            goto :skip
        )
        
        if !subs_count! lss 2 (
            echo Not enough subtitle tracks in %%A >> "%log_file%"
            set "skip_folder=true"
            goto :skip
        )
        
        :: Генерация временного имени
        set "temp_file=%%~dpAtmp_%%~nA.mkv"
        
        :: Меняем дефолтные дорожки
        echo Updating default tracks for %%A >> "%log_file%"
        "C:\Program Files\MKVToolNix\mkvmerge.exe" -o "!temp_file!" "%%A" ^
        --default-track 2:no --default-track 3:yes ^
        --default-track 4:no --default-track 5:yes >> "%log_file%" 2>&1

        if errorlevel 1 (
            echo Failed to process %%A >> "%log_file%"
            del "!temp_file!" >nul 2>&1
        ) else (
            del "%%A"
            move "!temp_file!" "%%A"
            echo File processed successfully: %%A >> "%log_file%"
        )
    )
    :skip
    if "!skip_folder!" == "true" (
        echo Skipping folder: %%D due to missing tracks >> "%log_file%"
        goto :next_folder
    )
    :next_folder
)
echo Script finished on %date% at %time% >> "%log_file%"
pause
