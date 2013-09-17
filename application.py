from flask import Flask
app = Flask(__name__)

@app.route("/")
def hello():
    with open("templates/map.html", "rb") as f:
        return f.read()

if __name__ == "__main__":
    app.run()
