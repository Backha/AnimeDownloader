from flask import Flask, request, render_template
import requests
import qbittorrentapi
from bs4 import BeautifulSoup
import time

app = Flask(__name__)

# Подключение к qBittorrent Web UI
qb = qbittorrentapi.Client(
    host='localhost',
    port=8080,
    username='admin',  # Ваш логин
    password='adminadmin'  # Ваш пароль
)

try:
    qb.auth_log_in()
except qbittorrentapi.LoginFailed as e:
    print(f"Failed to connect to qBittorrent: {str(e)}")

# Home page with a form to enter anime title
@app.route('/', methods=['GET', 'POST'])
def home():
    if request.method == 'POST':
        anime_name = request.form['anime_name']
        action = request.form['action']

        if action == "Search":
            # Make a request to Shikimori API to get anime information
            shikimori_url = f"https://shikimori.one/api/animes?search={anime_name}"
            headers = {
                "User-Agent": "AnimeDownloaderApp/1.0 (contact@example.com)"  # Replace email with your actual email if required
            }
            
            try:
                response = requests.get(shikimori_url, headers=headers)
                response.raise_for_status()  # This will raise an HTTPError for bad responses
            except requests.exceptions.RequestException as e:
                return f"Failed to fetch anime information. Error: {str(e)}"

            if response.status_code == 200:
                anime_list = response.json()
                if anime_list:
                    # Формируем информацию для каждого аниме
                    anime_info_list = []
                    for anime in anime_list:
                        anime_id = anime.get('id')
                        english_title = anime.get('name', 'N/A')
                        russian_title = anime.get('russian', 'N/A')

                        # Запрос для получения более детальной информации об аниме по ID
                        detail_url = f"https://shikimori.one/api/animes/{anime_id}"
                        detail_response = requests.get(detail_url, headers=headers)
                        if detail_response.status_code == 200:
                            detail_info = detail_response.json()
                            japanese_title = detail_info.get('japanese', 'N/A')
                            synonyms = ', '.join(detail_info.get('synonyms', [])) if 'synonyms' in detail_info else 'N/A'

                            anime_info = (
                                f"English: {english_title}, "
                                f"Russian: {russian_title}, "
                                f"Japanese: {japanese_title}, "
                                f"Other titles: {synonyms}"
                            )
                            anime_info_list.append(anime_info)

                    return f"You entered: {anime_name}.<br><br>Possible titles:<br>" + "<br>".join(anime_info_list)
                else:
                    return "No anime found for your search. Please try another name."
            else:
                return f"Failed to fetch anime information. Status Code: {response.status_code}"

        elif action == "Download":
            # Поиск торрентов на nyaa.si
            nyaa_url = f"https://nyaa.si/?f=0&c=0_0&q={anime_name}&s=seeders&o=desc"
            headers = {
                "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.3"
            }
            
            # Пауза перед выполнением запроса
            time.sleep(2)
            
            try:
                response = requests.get(nyaa_url, headers=headers)
                response.raise_for_status()  # This will raise an HTTPError for bad responses
            except requests.exceptions.RequestException as e:
                return f"Failed to fetch torrent information. Error: {str(e)}"

            # Парсим HTML и находим магнет-ссылку
            soup = BeautifulSoup(response.text, 'html.parser')
            magnet_link = soup.find('a', href=True, text='Magnet')
            if magnet_link:
                magnet_url = magnet_link['href']
                # Добавляем торрент в qBittorrent
                try:
                    qb.torrents_add(urls=magnet_url)
                    return f"Torrent for {anime_name} has been added successfully!"
                except qbittorrentapi.APIError as e:
                    return f"Failed to add torrent. Error: {str(e)}"
            else:
                return "No torrent found for your search."

    return render_template('home.html')

if __name__ == '__main__':
    app.run(debug=True)
