from sqlalchemy import text

from src import config
from src.db_connector import get_engine, run_sql_file


def print_summary(engine):
    queries = {
        "dim_customer": "SELECT COUNT(*) FROM dw.dim_customer",
        "dim_product": "SELECT COUNT(*) FROM dw.dim_product",
        "dim_employee": "SELECT COUNT(*) FROM dw.dim_employee",
        "dim_shipper": "SELECT COUNT(*) FROM dw.dim_shipper",
        "dim_date": "SELECT COUNT(*) FROM dw.dim_date",
        "fact_sales rows": "SELECT COUNT(*) FROM dw.fact_sales",
        "total net revenue": "SELECT ROUND(SUM(net_revenue), 2) FROM dw.fact_sales",
    }
    print("Warehouse summary:")
    with engine.connect() as conn:
        for label, query in queries.items():
            print(f"  {label}: {conn.execute(text(query)).scalar()}")


def main():
    engine = get_engine()
    run_sql_file(engine, config.SQL_DIR / "04_upsert_dimensions.sql")
    run_sql_file(engine, config.SQL_DIR / "05_upsert_fact_sales.sql")
    print_summary(engine)
