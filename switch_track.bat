@echo off
setlocal enabledelayedexpansion

:: Путь к MKVToolNix
set "mkvinfo_path=C:\Program Files\MKVToolNix\mkvinfo.exe"
set "mkvpropedit_path=C:\Program Files\MKVToolNix\mkvpropedit.exe"

:: Базовая папка
set "base_folder=F:\Anime"
set "log_file=F:\Anime\process_log.txt"

:: Очищаем лог-файл
echo Script started on %date% at %time% > "%log_file%"
echo Script started on %date% at %time%
pause

:: Проверяем папки
echo Searching for folders containing "AniLibria" >> "%log_file%"
echo Searching for folders containing "AniLibria"
pause
for /d %%D in ("%base_folder%\*AniLibria*") do (
    echo Found folder: %%D >> "%log_file%"
    echo Found folder: %%D
    pause

    for %%F in ("%%D\*.mkv") do (
        echo Processing file: %%F >> "%log_file%"
        echo Processing file: %%F
        pause

        :: Анализируем треки файла
        echo Running mkvinfo for %%F >> "%log_file%"
        "%mkvinfo_path%" "%%F" | findstr /C:"Track type: audio" /C:"Track type: subtitles" >> "%log_file%" 2>&1
        echo Finished mkvinfo for %%F
        pause

        :: Изменяем флаги
        echo Running mkvpropedit for %%F >> "%log_file%"
        "%mkvpropedit_path%" "%%F" --edit track:2 --set flag-default=1 --set flag-forced=0 --edit track:3 --set flag-default=0 --set flag-forced=1 --edit track:4 --set flag-default=1 --set flag-forced=0 --edit track:5 --set flag-default=0 --set flag-forced=1 >> "%log_file%" 2>&1
        echo Finished mkvpropedit for %%F
        pause

        :: Проверка ошибок
        if errorlevel 1 (
            echo Failed to process file: %%F >> "%log_file%"
            echo Failed to process file: %%F
            pause
        ) else (
            echo Successfully processed file: %%F >> "%log_file%"
            echo Successfully processed file: %%F
            pause
        )
    )
)

:: Завершение
echo Script finished on %date% at %time% >> "%log_file%"
echo Script finished on %date% at %time%
pause
