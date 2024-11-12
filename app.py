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
            "User-Agent": "AnimeDownloaderApp/1.0 (contact@example.com)"  # Замените email на ваш или оставьте так
        }
        response = requests.get(shikimori_url, headers=headers)
        if response.status_code == 200:
            anime_list = response.json()
            # Get the titles of the animes found
            titles = [anime['name'] for anime in anime_list]
            return f"You entered: {anime_name}. Possible titles: {', '.join(titles)}"
        else:
            return "Failed to fetch anime information. Please try again."
    return render_template('home.html')

if __name__ == '__main__':
    app.run(debug=True)
