CREATE TABLE IF NOT EXISTS dw.dim_customer (
    customer_key   INT          NOT NULL AUTO_INCREMENT,
    customer_id    VARCHAR(10)  NOT NULL,
    company_name   VARCHAR(100) NOT NULL,
    contact_name   VARCHAR(100) NULL,
    contact_title  VARCHAR(100) NULL,
    address        VARCHAR(150) NULL,
    city           VARCHAR(60)  NULL,
    region         VARCHAR(60)  NULL,
    postal_code    VARCHAR(20)  NULL,
    country        VARCHAR(60)  NULL,
    phone          VARCHAR(30)  NULL,
    PRIMARY KEY (customer_key),
    UNIQUE KEY uq_dim_customer_id (customer_id)
);

CREATE TABLE IF NOT EXISTS dw.dim_product (
    product_key          INT           NOT NULL AUTO_INCREMENT,
    product_id           INT           NOT NULL,
    product_name         VARCHAR(100)  NOT NULL,
    quantity_per_unit    VARCHAR(60)   NULL,
    list_price           DECIMAL(10,2) NULL,
    is_discontinued      TINYINT(1)    NULL,
    category_id          INT           NULL,
    category_name        VARCHAR(60)   NULL,
    category_description VARCHAR(255)  NULL,
    supplier_id          INT           NULL,
    supplier_name        VARCHAR(100)  NULL,
    supplier_city        VARCHAR(60)   NULL,
    supplier_country     VARCHAR(60)   NULL,
    PRIMARY KEY (product_key),
    UNIQUE KEY uq_dim_product_id (product_id)
);

CREATE TABLE IF NOT EXISTS dw.dim_employee (
    employee_key          INT          NOT NULL AUTO_INCREMENT,
    employee_id           INT          NOT NULL,
    last_name             VARCHAR(60)  NOT NULL,
    first_name            VARCHAR(60)  NULL,
    full_name             VARCHAR(130) NOT NULL,
    title                 VARCHAR(100) NULL,
    hire_date             DATE         NULL,
    city                  VARCHAR(60)  NULL,
    country               VARCHAR(60)  NULL,
    reports_to_employee_id INT         NULL,
    PRIMARY KEY (employee_key),
    UNIQUE KEY uq_dim_employee_id (employee_id)
);

CREATE TABLE IF NOT EXISTS dw.dim_shipper (
    shipper_key   INT          NOT NULL AUTO_INCREMENT,
    shipper_id    INT          NOT NULL,
    company_name  VARCHAR(100) NOT NULL,
    phone         VARCHAR(30)  NULL,
    PRIMARY KEY (shipper_key),
    UNIQUE KEY uq_dim_shipper_id (shipper_id)
);

-- Date dimension. date_key is the date written as a number (19960704).
CREATE TABLE IF NOT EXISTS dw.dim_date (
    date_key          INT          NOT NULL,
    full_date         DATE         NULL,
    year_number       SMALLINT     NULL,
    quarter_number    TINYINT      NULL,
    month_number      TINYINT      NULL,
    month_name        VARCHAR(20)  NOT NULL,
    year_month_label  VARCHAR(10)  NOT NULL,
    iso_week_number   TINYINT      NULL,
    day_of_month      TINYINT      NULL,
    day_of_year       SMALLINT     NULL,
    day_of_week       TINYINT      NULL,   -- 1 = Monday ... 7 = Sunday
    day_name          VARCHAR(20)  NOT NULL,
    is_weekend        TINYINT(1)   NULL,
    fiscal_year       SMALLINT     NULL,
    fiscal_quarter    TINYINT      NULL,
    fiscal_month      TINYINT      NULL,
    PRIMARY KEY (date_key),
    UNIQUE KEY uq_dim_date_full_date (full_date)
);


CREATE TABLE IF NOT EXISTS dw.fact_sales (
    sales_key          BIGINT        NOT NULL AUTO_INCREMENT,
    order_id           INT           NOT NULL,
    product_id         INT           NOT NULL,
    customer_key       INT           NOT NULL,
    product_key        INT           NOT NULL,
    employee_key       INT           NOT NULL,
    shipper_key        INT           NOT NULL,
    order_date_key     INT           NOT NULL,
    required_date_key  INT           NOT NULL,
    shipped_date_key   INT           NOT NULL,
    quantity           INT           NOT NULL,
    unit_price         DECIMAL(10,2) NOT NULL,
    discount           DECIMAL(4,2)  NOT NULL,
    gross_amount       DECIMAL(12,2) NOT NULL,   -- quantity * unit_price
    net_revenue        DECIMAL(14,4) NOT NULL,   -- quantity * unit_price * (1 - discount)
    PRIMARY KEY (sales_key),
    UNIQUE KEY uq_fact_sales_order_line (order_id, product_id),
    CONSTRAINT fk_fact_customer FOREIGN KEY (customer_key)      REFERENCES dw.dim_customer (customer_key),
    CONSTRAINT fk_fact_product  FOREIGN KEY (product_key)       REFERENCES dw.dim_product (product_key),
    CONSTRAINT fk_fact_employee FOREIGN KEY (employee_key)      REFERENCES dw.dim_employee (employee_key),
    CONSTRAINT fk_fact_shipper  FOREIGN KEY (shipper_key)       REFERENCES dw.dim_shipper (shipper_key),
    CONSTRAINT fk_fact_order_dt FOREIGN KEY (order_date_key)    REFERENCES dw.dim_date (date_key),
    CONSTRAINT fk_fact_req_dt   FOREIGN KEY (required_date_key) REFERENCES dw.dim_date (date_key),
    CONSTRAINT fk_fact_ship_dt  FOREIGN KEY (shipped_date_key)  REFERENCES dw.dim_date (date_key)
);



INSERT INTO dw.dim_date (date_key, month_name, year_month_label, day_name)
VALUES (-1, 'Unknown', 'Unknown', 'Unknown')
ON DUPLICATE KEY UPDATE date_key = date_key;




SET @fiscal_start_month = 1;  

INSERT INTO dw.dim_date (
    date_key, full_date, year_number, quarter_number, month_number,
    month_name, year_month_label, iso_week_number, day_of_month, day_of_year,
    day_of_week, day_name, is_weekend, fiscal_year, fiscal_quarter, fiscal_month
)
WITH digits AS (
    SELECT 0 AS d UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4
    UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9
),
millions AS (
    SELECT 0 AS d UNION ALL SELECT 1 UNION ALL SELECT 2
),
numbers AS (
    SELECT a.d + 10 * b.d + 100 * c.d + 1000 * e.d + 10000 * f.d + 100000 * g.d + 1000000 * h.d AS n
    FROM digits a, digits b, digits c, digits e, digits f, digits g, millions h
),
calendar AS (
    SELECT DATE_ADD('1990-01-01', INTERVAL n DAY) AS cal_date
    FROM numbers
    WHERE n <= DATEDIFF('9999-12-31', '1990-01-01')
)
SELECT
    CAST(DATE_FORMAT(cal_date, '%Y%m%d') AS UNSIGNED),
    cal_date,
    YEAR(cal_date),
    QUARTER(cal_date),
    MONTH(cal_date),
    MONTHNAME(cal_date),
    DATE_FORMAT(cal_date, '%Y-%m'),
    WEEK(cal_date, 3),
    DAY(cal_date),
    DAYOFYEAR(cal_date),
    WEEKDAY(cal_date) + 1,
    DAYNAME(cal_date),
    IF(WEEKDAY(cal_date) >= 5, 1, 0),
    YEAR(cal_date) + IF(@fiscal_start_month > 1 AND MONTH(cal_date) >= @fiscal_start_month, 1, 0),
    (MOD(MONTH(cal_date) - @fiscal_start_month + 12, 12) DIV 3) + 1,
    MOD(MONTH(cal_date) - @fiscal_start_month + 12, 12) + 1
FROM calendar
WHERE NOT EXISTS (SELECT 1 FROM dw.dim_date WHERE full_date = '1990-01-01');