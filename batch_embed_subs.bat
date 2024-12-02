@echo off
setlocal enabledelayedexpansion

:: Запрашиваем у пользователя язык субтитров
set /p subtitle_lang=Введите язык субтитров (en/ru): 

:: Проверяем ввод пользователя
if not "!subtitle_lang!"=="en" if not "!subtitle_lang!"=="ru" (
    echo Неверный ввод. Используйте "en" или "ru".
    pause
    exit /b
)

:: Указываем путь к MKVToolNix
set "mkvmerge_path=C:\Program Files\MKVToolNix\mkvmerge.exe"

:: Создаём лог-файл
set "log_file=process_log.txt"
echo Старт обработки: %date% %time% > "%log_file%"

:: Переходим в папку с видеофайлами
cd /d "%~dp0"

:: Обрабатываем каждый MKV-файл в папке
for %%A in (*.mkv) do (
    :: Определяем имя файла без расширения
    set "filename=%%~nA"
    set "subtitle_file=!filename!.!subtitle_lang!.ass"

    :: Проверяем наличие субтитров
    if exist "!subtitle_file!" (
        echo Обработка файла: %%A с субтитрами: !subtitle_file! >> "%log_file%"
        echo Обработка файла: %%A с субтитрами: !subtitle_file!

        :: Создаём новый файл с добавленными субтитрами
        "%mkvmerge_path%" -o "!filename!_with_subs.mkv" "%%A" "!subtitle_file!" >> "%log_file%" 2>&1

        :: Проверяем успешность операции
        if !errorlevel! equ 0 (
            echo Успешно: %%A >> "%log_file%"
            echo Успешно: %%A

            :: Удаляем оригинальный файл
            del "%%A"

            :: Переименовываем новый файл в оригинальное имя
            ren "!filename!_with_subs.mkv" "%%~nA%%~xA"

            :: Удаляем файл субтитров
            del "!subtitle_file!"
        ) else (
            echo Ошибка при обработке: %%A >> "%log_file%"
            echo Ошибка при обработке: %%A
        )
    ) else (
        echo Субтитры не найдены для: %%A >> "%log_file%"
        echo Субтитры не найдены для: %%A
    )
)

echo Завершение обработки: %date% %time% >> "%log_file%"
echo Завершение обработки: %date% %time%

endlocal
pause
