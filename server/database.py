import pymongo
import json
import os

def get_connection():
    from server import app
    return Database(app.config["MONGO_URL"])

def reset_collection(tally_names, mongo_url):
    with open(config_file, 'r') as f:
        config = json.load(f)
    db = Database(mongo_url)
    db.delete_all()
    for name in tally_names:
        db.reset(name)

class Database():
    def __init__(self, address):
        self.client = pymongo.MongoClient(address)
        self.tallies = self.client.tallies.tallies

    def __enter__(self):
        return self

    def __exit__(self, exc_type, exc_value, traceback):
        self.client.close()

    def increment(self, name):
        new_doc = self.tallies.find_one_and_update({'name': name},
                {'$inc': {'count': 1}},
                return_document=pymongo.ReturnDocument.AFTER)
        return new_doc['count']

    def get(self, name):
        doc = self.tallies.find_one({'name': name})
        return doc['count']

    def reset(self, name):
        self.tallies.update_one({'name': name}, {'$set': {'count': 0}},
                upsert=True)
        return 0

    def get_all(self):
        docs = self.tallies.find()
        return [{'name': doc['name'], 'count': doc['count']} for doc in
                docs]

    def delete_all(self):
        self.tallies.delete_many({})

if __name__ == '__main__':
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument('--reset', action='store_true')
    parser.add_argument('config')
    args = parser.parse_args()
    if args.reset:
        reset_collection(args.config)
