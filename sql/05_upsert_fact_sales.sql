

INSERT INTO dw.fact_sales
    (order_id, product_id,
     customer_key, product_key, employee_key, shipper_key,
     order_date_key, required_date_key, shipped_date_key,
     quantity, unit_price, discount, gross_amount, net_revenue)
SELECT
    d.orderID,
    d.productID,
    c.customer_key,
    p.product_key,
    e.employee_key,
    s.shipper_key,
    COALESCE(CAST(DATE_FORMAT(o.orderDate,    '%Y%m%d') AS SIGNED), -1),
    COALESCE(CAST(DATE_FORMAT(o.requiredDate, '%Y%m%d') AS SIGNED), -1),
    COALESCE(CAST(DATE_FORMAT(o.shippedDate,  '%Y%m%d') AS SIGNED), -1),
    d.quantity,
    d.unitPrice,
    d.discount,
    d.quantity * d.unitPrice,
    d.quantity * d.unitPrice * (1 - d.discount)
FROM stg.order_details d
JOIN stg.orders        o ON o.orderID     = d.orderID
JOIN dw.dim_customer   c ON c.customer_id = o.customerID
JOIN dw.dim_product    p ON p.product_id  = d.productID
JOIN dw.dim_employee   e ON e.employee_id = o.employeeID
JOIN dw.dim_shipper    s ON s.shipper_id  = o.shipVia
ON DUPLICATE KEY UPDATE
    customer_key      = VALUES(customer_key),
    product_key       = VALUES(product_key),
    employee_key      = VALUES(employee_key),
    shipper_key       = VALUES(shipper_key),
    order_date_key    = VALUES(order_date_key),
    required_date_key = VALUES(required_date_key),
    shipped_date_key  = VALUES(shipped_date_key),
    quantity          = VALUES(quantity),
    unit_price        = VALUES(unit_price),
    discount          = VALUES(discount),
    gross_amount      = VALUES(gross_amount),
    net_revenue       = VALUES(net_revenue);