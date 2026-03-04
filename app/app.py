"""Flask API for managing items with PostgreSQL database."""
from flask import Flask, request, jsonify
import psycopg2
import os

app = Flask(__name__)

def get_conn():
    return psycopg2.connect(
        host=os.getenv("DB_HOST"),
        port=os.getenv("DB_PORT", "5432"),
        database=os.getenv("DB_NAME"),
        user=os.getenv("DB_USER"),
        password=os.getenv("DB_PASSWORD"),
    )

@app.route("/health")
def health():
    try:
        conn = get_conn()
        conn.close()
        return {"status": "ok"}
    except Exception as e:
        return {"status": "db_down", "error": str(e)}, 500

@app.route("/items", methods=["POST"])
def create_item():
    name = request.json.get("name")
    conn = get_conn()
    cur = conn.cursor()

    cur.execute(
        "INSERT INTO items(name) VALUES(%s) RETURNING id, name;",
        (name,)
    )

    row = cur.fetchone()
    conn.commit()

    cur.close()
    conn.close()

    return jsonify({"id": row[0], "name": row[1]})


@app.route("/items")
def list_items():
    conn = get_conn()
    cur = conn.cursor()

    cur.execute("SELECT id, name FROM items ORDER BY id DESC;")
    rows = cur.fetchall()

    cur.close()
    conn.close()

    return jsonify(rows)


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=3000)