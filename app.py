from flask import Flask, request, render_template

app = Flask(__name__)

@app.route('/', methods=['GET', 'POST'])
def home():
    if request.method == 'POST':
        anime_name = request.form['anime_name']
        return f"Вы ввели: {anime_name}"
    return render_template('home.html')

if __name__ == '__main__':
    app.run(debug=True)
