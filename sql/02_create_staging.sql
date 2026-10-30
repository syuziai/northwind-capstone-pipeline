DROP TABLE IF EXISTS stg.categories;
CREATE TABLE stg.categories (
    categoryID    INT,
    categoryName  VARCHAR(255),
    description   TEXT,
    picture       LONGTEXT
);

DROP TABLE IF EXISTS stg.customers;
CREATE TABLE stg.customers (
    customerID    VARCHAR(10),
    companyName   VARCHAR(255),
    contactName   VARCHAR(255),
    contactTitle  VARCHAR(255),
    address       VARCHAR(255),
    city          VARCHAR(255),
    region        VARCHAR(255),
    postalCode    VARCHAR(50),
    country       VARCHAR(255),
    phone         VARCHAR(50),
    fax           VARCHAR(50)
);

DROP TABLE IF EXISTS stg.employees;
CREATE TABLE stg.employees (
    employeeID       INT,
    lastName         VARCHAR(255),
    firstName        VARCHAR(255),
    title            VARCHAR(255),
    titleOfCourtesy  VARCHAR(50),
    birthDate        DATETIME,
    hireDate         DATETIME,
    address          VARCHAR(255),
    city             VARCHAR(255),
    region           VARCHAR(255),
    postalCode       VARCHAR(50),
    country          VARCHAR(255),
    homePhone        VARCHAR(50),
    extension        VARCHAR(20),
    photo            LONGTEXT,
    notes            TEXT,
    reportsTo        INT,
    photoPath        VARCHAR(255)
);

DROP TABLE IF EXISTS stg.employee_territories;
CREATE TABLE stg.employee_territories (
    employeeID    INT,
    territoryID   VARCHAR(20)
);

DROP TABLE IF EXISTS stg.order_details;
CREATE TABLE stg.order_details (
    orderID    INT,
    productID  INT,
    unitPrice  DECIMAL(10,2),
    quantity   INT,
    discount   DECIMAL(4,2)
);

DROP TABLE IF EXISTS stg.orders;
CREATE TABLE stg.orders (
    orderID         INT,
    customerID      VARCHAR(10),
    employeeID      INT,
    orderDate       DATETIME,
    requiredDate    DATETIME,
    shippedDate     DATETIME,
    shipVia         INT,
    freight         DECIMAL(10,2),
    shipName        VARCHAR(255),
    shipAddress     VARCHAR(255),
    shipCity        VARCHAR(255),
    shipRegion      VARCHAR(255),
    shipPostalCode  VARCHAR(50),
    shipCountry     VARCHAR(255)
);

DROP TABLE IF EXISTS stg.products;
CREATE TABLE stg.products (
    productID        INT,
    productName      VARCHAR(255),
    supplierID       INT,
    categoryID       INT,
    quantityPerUnit  VARCHAR(255),
    unitPrice        DECIMAL(10,2),
    unitsInStock     INT,
    unitsOnOrder     INT,
    reorderLevel     INT,
    discontinued     INT
);

DROP TABLE IF EXISTS stg.regions;
CREATE TABLE stg.regions (
    regionID           INT,
    regionDescription  VARCHAR(255)
);

DROP TABLE IF EXISTS stg.shippers;
CREATE TABLE stg.shippers (
    shipperID    INT,
    companyName  VARCHAR(255),
    phone        VARCHAR(50)
);

DROP TABLE IF EXISTS stg.suppliers;
CREATE TABLE stg.suppliers (
    supplierID    INT,
    companyName   VARCHAR(255),
    contactName   VARCHAR(255),
    contactTitle  VARCHAR(255),
    address       VARCHAR(255),
    city          VARCHAR(255),
    region        VARCHAR(255),
    postalCode    VARCHAR(50),
    country       VARCHAR(255),
    phone         VARCHAR(50),
    fax           VARCHAR(50),
    homePage      TEXT
);

DROP TABLE IF EXISTS stg.territories;
CREATE TABLE stg.territories (
    territoryID           VARCHAR(20),
    territoryDescription  VARCHAR(255),
    regionID              INT
);