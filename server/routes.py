from server import app
from flask import render_template
from server.database import get_connection
import json

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/api/reset/<name>', methods=['POST'])
def reset(name):
    print('in reset!')
    with get_connection() as conn:
        conn.reset(name)
    return {
            'name': name,
            'count': 0,
            }

@app.route('/api/increment/<name>', methods=['POST'])
def increment(name):
    with get_connection() as conn:
        new = conn.increment(name)
    return {
            'name': name,
            'count': new,
            }

@app.route('/api/get/<name>')
def get(name):
    with get_connection() as conn:
        value = conn.get(name)
        return {
                'name': name,
                'count': value,
                }

@app.route('/api/all')
def get_all():
    with get_connection() as conn:
        print(json.dumps(conn.get_all()))
        return json.dumps(conn.get_all())
