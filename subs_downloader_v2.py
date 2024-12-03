import os
import subprocess
from subliminal import download_best_subtitles, save_subtitles, scan_video
from babelfish import Language

# Папка с аниме
anime_folder = 'F:\\Anime'

# Лимит загрузок (для режима разработки)
download_limit = 100
downloads = 0

# Рекурсивное сканирование папок
for root, dirs, files in os.walk(anime_folder):
    for file in files:
        if file.endswith(('.mkv', '.mp4', '.avi')):
            filepath = os.path.join(root, file)
            print(f"Обработка файла: {filepath}")

            # Проверка наличия английских субтитров
            video = scan_video(filepath)
            if not any(s.language == Language('en') for s in video.subtitle_languages):
                if downloads >= download_limit:
                    print("Достигнут лимит загрузок субтитров на сегодня.")
                    break

                print(f"Скачиваю английские субтитры для {filepath}")
                subtitles = download_best_subtitles([video], {Language('en')})
                save_subtitles(video, subtitles[video])
                downloads += 1

                # Получение пути к загруженным субтитрам
                eng_sub = filepath.replace(os.path.splitext(filepath)[1], '.en.srt')
                if os.path.exists(eng_sub):
                    print(f"Встраиваю субтитры: {eng_sub}")
                    output_file = filepath.replace(os.path.splitext(filepath)[1], '_with_subs.mkv')
                    subprocess.run([
                        'mkvmerge', '-o', output_file, filepath,
                        '--language', '0:eng', '--default-track', '0:yes', eng_sub
                    ])
                    os.remove(eng_sub)  # Удаляем временные субтитры
                    os.rename(output_file, filepath)  # Заменяем оригинальный файл
                else:
                    print(f"Не удалось найти скачанные субтитры для {filepath}")
            else:
                print(f"Субтитры уже есть для {filepath}")
