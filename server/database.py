import plyvel

def get_connection():
    from server import app
    return Database(app.config["LEVELDB_NAME"])

class Database():
    def __init__(self, name):
        self.db = plyvel.DB(name, create_if_missing=True)

    def __enter__(self):
        return self

    def __exit__(self, exc_type, exc_value, traceback):
        self.db.close()
