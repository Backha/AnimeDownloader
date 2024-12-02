import os
import subprocess
import glob
import hashlib

# Путь к директории с видеофайлами
video_dir = r"F:\Anime\ACCA 13-ku Kansatsu-ka (2017)"

# Сначала скачиваем субтитры с помощью Subliminal
def download_subtitles(video_dir):
    command = [
        "subliminal", "download", "-l", "en", "-d", video_dir, video_dir
    ]
    subprocess.run(command, check=True)

# Встраиваем субтитры в видео с помощью FFmpeg
def embed_subtitles_ffmpeg(video_path, subtitle_path):
    temp_output_path = os.path.splitext(video_path)[0] + "_with_subs_temp.mkv"
    command = [
        "ffmpeg", "-i", video_path, "-i", subtitle_path,
        "-c:v", "copy", "-c:a", "copy", "-c:s", "srt", temp_output_path
    ]
    subprocess.run(command, check=True)
    return temp_output_path

# Удаляем файл субтитров после успешного встраивания
def remove_file(file_path):
    if os.path.exists(file_path):
        os.remove(file_path)

# Проверка уникальности субтитров (по хэшу)
def is_unique_subtitle(subtitle_path, existing_subtitles_hashes):
    with open(subtitle_path, 'rb') as f:
        file_hash = hashlib.md5(f.read()).hexdigest()
    return file_hash not in existing_subtitles_hashes

# Основная функция для обработки всех видео в папке
def process_videos(video_dir):
    # Сначала скачиваем субтитры для всех файлов в директории
    download_subtitles(video_dir)

    # Ищем все файлы MKV в директории
    video_files = glob.glob(os.path.join(video_dir, "*.mkv"))
    existing_subtitles_hashes = set()

    for video_path in video_files:
        # Ищем соответствующий файл субтитров (.en.srt)
        subtitle_path = os.path.splitext(video_path)[0] + ".en.srt"
        if os.path.exists(subtitle_path):
            # Проверяем, является ли файл субтитров уникальным
            if is_unique_subtitle(subtitle_path, existing_subtitles_hashes):
                # Добавляем хэш субтитров в набор существующих хэшей
                with open(subtitle_path, 'rb') as f:
                    existing_subtitles_hashes.add(hashlib.md5(f.read()).hexdigest())
                # Встраиваем субтитры в видео
                try:
                    temp_output_path = embed_subtitles_ffmpeg(video_path, subtitle_path)
                    # Удаляем субтитры после успешного встраивания
                    remove_file(subtitle_path)
                except subprocess.CalledProcessError as e:
                    print(f"Ошибка при встраивании субтитров в {video_path}: {e}")
            else:
                print(f"Субтитры для {video_path} уже существуют и совпадают с другими эпизодами, пропускаем.")

# Запуск процесса
if __name__ == "__main__":
    process_videos(video_dir)
