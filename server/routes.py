from server import app
from flask import render_template
from server.database import get_connection

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/api/reset', methods=['POST'])
def reset():
    print('in reset!')
    with get_connection() as conn:
        conn.db.put(b'tally1', b'\x00')
    return ('', 204)

@app.route('/api/increment', methods=['POST'])
def increment():
    with get_connection() as conn:
        old = conn.db.get(b'tally1')[0]
        conn.db.put(b'tally1', bytes([old+1]))
    return ('', 204)

@app.route('/api/get')
def get():
    with get_connection() as conn:
        print(conn.db.get(b'tally1'))
        return {
                'tally1': conn.db.get(b'tally1')[0],
                }
