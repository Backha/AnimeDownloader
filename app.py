from flask import Flask, request, render_template
import requests

app = Flask(__name__)

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
            # Log detailed error message for troubleshooting
            return f"Failed to fetch anime information. Error: {str(e)}"

        if response.status_code == 200:
            anime_list = response.json()
            if anime_list:
                # Формируем информацию для каждого аниме
                anime_info_list = []
                for anime in anime_list:
                    english_title = anime.get('name', 'N/A')
                    russian_title = anime.get('russian', 'N/A')
                    japanese_title = ', '.join(anime.get('japanese', [])) if anime.get('japanese') else 'N/A'
                    synonyms = ', '.join(anime.get('synonyms', [])) if anime.get('synonyms') else 'N/A'
                    
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

if __name__ == '__main__':
    app.run(debug=True)
