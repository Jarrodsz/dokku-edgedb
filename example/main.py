import os
import sys
import gel

from fastapi import FastAPI

app = FastAPI()

@app.get("/")
def read_root():
    """Execute a query on the GEL database."""
    client = gel.create_client()
    result = client.query("SELECT 1 + 1")
    return {"result": result}

