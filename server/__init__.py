from flask import Flask
import os

app = Flask(__name__)
app.config.update(os.environ)
if os.path.isfile("server/config.json"):
    app.config.from_json("config.json")

from server import routes
