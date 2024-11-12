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
                # Get the titles of the animes found
                titles = [anime['name'] for anime in anime_list]
                return f"You entered: {anime_name}. Possible titles: {', '.join(titles)}"
            else:
                return "No anime found for your search. Please try another name."
        else:
            return f"Failed to fetch anime information. Status Code: {response.status_code}"

    return render_template('home.html')

if __name__ == '__main__':
    app.run(debug=True)
