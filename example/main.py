import edgedb
import json
from http import HTTPStatus

from flask import Flask

app = Flask(__name__)


@app.get("/")
def health_check() -> tuple[dict, int]:
    client = edgedb.create_client()
    version = client.query_json("select sys::get_version()")
    client.close()
    return {"status": "Ok", "version": json.loads(version) }, HTTPStatus.OK

