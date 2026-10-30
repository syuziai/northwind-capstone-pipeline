-- 04_upsert_dimensions.sql

INSERT INTO dw.dim_customer
    (customer_id, company_name, contact_name, contact_title,
     address, city, region, postal_code, country, phone)
SELECT
    customerID, companyName, contactName, contactTitle,
    address, city, COALESCE(region, 'Not specified'), postalCode, country, phone
FROM stg.customers
ON DUPLICATE KEY UPDATE
    company_name  = VALUES(company_name),
    contact_name  = VALUES(contact_name),
    contact_title = VALUES(contact_title),
    address       = VALUES(address),
    city          = VALUES(city),
    region        = VALUES(region),
    postal_code   = VALUES(postal_code),
    country       = VALUES(country),
    phone         = VALUES(phone);


INSERT INTO dw.dim_product
    (product_id, product_name, quantity_per_unit, list_price, is_discontinued,
     category_id, category_name, category_description,
     supplier_id, supplier_name, supplier_city, supplier_country)
SELECT
    p.productID, p.productName, p.quantityPerUnit, p.unitPrice, p.discontinued,
    p.categoryID, c.categoryName, c.description,
    p.supplierID, s.companyName, s.city, s.country
FROM stg.products p
LEFT JOIN stg.categories c ON c.categoryID = p.categoryID
LEFT JOIN stg.suppliers  s ON s.supplierID = p.supplierID
ON DUPLICATE KEY UPDATE
    product_name         = VALUES(product_name),
    quantity_per_unit    = VALUES(quantity_per_unit),
    list_price           = VALUES(list_price),
    is_discontinued      = VALUES(is_discontinued),
    category_id          = VALUES(category_id),
    category_name        = VALUES(category_name),
    category_description = VALUES(category_description),
    supplier_id          = VALUES(supplier_id),
    supplier_name        = VALUES(supplier_name),
    supplier_city        = VALUES(supplier_city),
    supplier_country     = VALUES(supplier_country);


INSERT INTO dw.dim_employee
    (employee_id, last_name, first_name, full_name, title,
     hire_date, city, country, reports_to_employee_id)
SELECT
    employeeID, lastName, firstName, CONCAT(firstName, ' ', lastName), title,
    DATE(hireDate), city, country, reportsTo
FROM stg.employees
ON DUPLICATE KEY UPDATE
    last_name              = VALUES(last_name),
    first_name             = VALUES(first_name),
    full_name              = VALUES(full_name),
    title                  = VALUES(title),
    hire_date              = VALUES(hire_date),
    city                   = VALUES(city),
    country                = VALUES(country),
    reports_to_employee_id = VALUES(reports_to_employee_id);


INSERT INTO dw.dim_shipper (shipper_id, company_name, phone)
SELECT shipperID, companyName, phone
FROM stg.shippers
ON DUPLICATE KEY UPDATE
    company_name = VALUES(company_name),
    phone        = VALUES(phone);