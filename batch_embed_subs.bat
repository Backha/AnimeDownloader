@echo off
setlocal enabledelayedexpansion

REM Запросить у пользователя язык субтитров
echo Введите язык субтитров (например, en или ru):
set /p lang=

REM Путь к директории с видео и субтитрами - текущая директория
set "video_dir=%cd%"

REM Перейти в текущую папку с видеофайлами и субтитрами
cd /d "%video_dir%"

REM Ищем все файлы MKV в директории
for %%f in (*.mkv) do (
    REM Ищем соответствующий файл субтитров
    set "subtitle_file=%%~nf.%lang%.srt"
    if not exist "!subtitle_file!" set "subtitle_file=%%~nf.%lang%.ass"
    if exist "!subtitle_file!" (
        REM Создаем имя для временного выходного файла
        set "output_file=%%~nf_with_subs.mkv"
        
        REM Встраиваем субтитры в видео с помощью FFmpeg
        ffmpeg -i "%%f" -i "!subtitle_file!" -c:v copy -c:a copy -c:s mov_text "!output_file!"
        
        REM Проверяем успешность встраивания
        if exist "!output_file!" (
            REM Удаляем старый файл и переименовываем новый файл в старый
            del "%%f"
            ren "!output_file!" "%%~nxf"
            
            REM Удаляем файл субтитров после успешного встраивания
            del "!subtitle_file!"
            
            echo Субтитры успешно встроены в %%f
        ) else (
            echo Ошибка при встраивании субтитров в %%f
        )
    ) else (
        echo Субтитры для %%f не найдены, пропускаем.
    )
)

endlocal
pause
