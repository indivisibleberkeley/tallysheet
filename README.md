Tally Sheet by Indivisible Berkeley
===================================

## To run locally

Requirements:
 - python 3.5+
 - access to a mongodb database (could be local)

Steps:
1. Clone the repository and cd into the base repository folder
2. Install dependencies with ``pip install -r requirements.txt``
3. Verify you can access your mongodb database.
3. From a python console, ``import reset_database from server.database``
   and run it with

```
reset_database(["QuantityToTally1", "Quantity2", ...], "mongodb access URL")
```

4. Set up flask with ``export FLASK_APP=server`` then start flask with
   ``flask run``
5. Navigate to ``localhost:5000`` or ``127.0.0.1:5000``

This program uses the "tallies" collection in the "tallies" database,
and will overwrite any existing data stored in that collection.
