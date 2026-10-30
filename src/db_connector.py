import re

from sqlalchemy import create_engine, text
from sqlalchemy.engine import URL

from src import config


def get_engine(database=None):
    url = URL.create(
        "mysql+pymysql",
        username=config.DB_USER,
        password=config.DB_PASSWORD,
        host=config.DB_HOST,
        port=config.DB_PORT,
        database=database,
        query={"charset": "utf8mb4"},
    )
    return create_engine(url)


def split_sql(sql_text):
    sql_text = re.sub(r"--[^\n]*", "", sql_text)
    parts = [part.strip() for part in sql_text.split(";")]
    return [part for part in parts if part]


def run_sql_file(engine, file_path):
    statements = split_sql(file_path.read_text(encoding="utf-8-sig"))
    with engine.begin() as conn:
        for statement in statements:
            conn.execute(text(statement))
    print(f"{file_path.name}: {len(statements)} statements executed")
