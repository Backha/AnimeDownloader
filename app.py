from flask import Flask, request, render_template
import requests
import qbittorrentapi

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

    return render_template('home.html')

# New route to search and download anime
@app.route('/download', methods=['POST'])
def download():
    anime_name = request.form['anime_name']
    # Поиск торрентов на nyaa.si
    nyaa_url = f"https://nyaa.si/?f=0&c=0_0&q={anime_name}&s=seeders&o=desc"
    try:
        response = requests.get(nyaa_url)
        response.raise_for_status()  # This will raise an HTTPError for bad responses
    except requests.exceptions.RequestException as e:
        return f"Failed to fetch torrent information. Error: {str(e)}"

    # Находим магнет-ссылку (в реальном проекте лучше использовать HTML-парсер)
    if 'magnet:' in response.text:
        magnet_link = response.text.split('magnet:')[1].split('"')[0]
        magnet_link = 'magnet:' + magnet_link

        # Добавляем торрент в qBittorrent
        try:
            qb.torrents_add(urls=magnet_link)
            return f"Torrent for {anime_name} has been added successfully!"
        except qbittorrentapi.APIError as e:
            return f"Failed to add torrent. Error: {str(e)}"
    else:
        return "No torrent found for your search."

if __name__ == '__main__':
    app.run(debug=True)
