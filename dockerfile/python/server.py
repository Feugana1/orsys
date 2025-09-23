from flask import Flask
import os

app = Flask(__name__)

# Get environment variable NAME, default to "World"
name = os.getenv("NAME", "World")

@app.route("/")
def home():
    return f"Hello, {name}! This is your server running on port 8080."

if __name__ == "__main__":
    # Make the server accessible from outside the container
    app.run(host="0.0.0.0", port=8080)
