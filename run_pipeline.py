from src import config, stage_raw_data, transform_warehouse
from src.db_connector import get_engine, run_sql_file


def main():
    engine = get_engine()

    print("1/4 Creating schemas and staging tables")
    run_sql_file(engine, config.SQL_DIR / "01_create_db_and_schemas.sql")
    run_sql_file(engine, config.SQL_DIR / "02_create_staging.sql")

    print("2/4 Loading raw data into staging")
    stage_raw_data.main()

    print("3/4 Creating warehouse tables and date dimension")
    run_sql_file(engine, config.SQL_DIR / "03_create_warehouse.sql")

    print("4/4 Loading the warehouse")
    transform_warehouse.main()

    print("Pipeline finished.")


if __name__ == "__main__":
    main()
