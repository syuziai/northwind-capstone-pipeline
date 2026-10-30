import pandas as pd
import requests
from sqlalchemy import text

from src import config
from src.db_connector import get_engine


def download_raw_files():
    config.RAW_DIR.mkdir(parents=True, exist_ok=True)
    items = requests.get(config.GITHUB_API_URL, timeout=30).json()
    for item in items:
        if item["name"].endswith(".csv"):
            response = requests.get(item["download_url"], timeout=30)
            response.raise_for_status()
            (config.RAW_DIR / f"raw_{item['name']}").write_bytes(response.content)
            print("Downloaded", f"raw_{item['name']}")


def load_to_staging(engine):
    for csv_path in sorted(config.RAW_DIR.glob("raw_*.csv")):
        table_name = csv_path.stem.replace("raw_", "")
        df = pd.read_csv(csv_path, dtype=str, keep_default_na=False, na_values=["NULL"])
        with engine.begin() as conn:
            conn.execute(text(f"DELETE FROM stg.{table_name}"))
            df.to_sql(table_name, conn, schema="stg", if_exists="append", index=False)
            in_table = conn.execute(text(f"SELECT COUNT(*) FROM stg.{table_name}")).scalar()
        print(f"{table_name}: CSV {len(df)} rows, table {in_table} rows")


def main():
    if not list(config.RAW_DIR.glob("raw_*.csv")):
        print("No raw files found, downloading them...")
        download_raw_files()
    load_to_staging(get_engine("stg"))
