import os
from pathlib import Path

from dotenv import load_dotenv

BASE_DIR = Path(__file__).resolve().parent.parent
load_dotenv(BASE_DIR / ".env")

DB_USER = os.getenv("MYSQL_USER", "root")
DB_PASSWORD = os.getenv("MYSQL_PASSWORD")
DB_HOST = os.getenv("MYSQL_HOST", "localhost")
DB_PORT = int(os.getenv("MYSQL_PORT", "3306"))

RAW_DIR = BASE_DIR / "data" / "raw"
SQL_DIR = BASE_DIR / "sql"

GITHUB_API_URL = (
    "https://api.github.com/repos/graphql-compose/graphql-compose-examples/"
    "contents/examples/northwind/data/csv"
)

if DB_PASSWORD is None:
    raise RuntimeError("MYSQL_PASSWORD not found. Create a .env file in the project folder.")
