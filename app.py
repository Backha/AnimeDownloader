from flask import Flask, request, render_template

app = Flask(__name__)

# Home page with a form to enter anime title
@app.route('/', methods=['GET', 'POST'])
def home():
    if request.method == 'POST':
        anime_name = request.form['anime_name']
        # Logic for searching anime and adding to download queue will go here
        return f"You entered: {anime_name}"
    return render_template('home.html')

if __name__ == '__main__':
    app.run(debug=True)
