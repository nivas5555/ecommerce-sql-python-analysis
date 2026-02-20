-- BASIC PROBLEMS
-- 1: List all unique cities where customers are located
SELECT DISTINCT
    customer_city
FROM customers
ORDER BY customer_city;

-- 2: Count number of orders placed in 2017
SELECT 
    COUNT(DISTINCT order_id) AS total_orders_2017
FROM orders
WHERE YEAR(order_purchase_timestamp) = 2017;

-- 3: Total sales per product category
SELECT
    p.product_category,
    ROUND(SUM(oi.price), 2) AS total_sales
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
GROUP BY p.product_category
ORDER BY total_sales DESC;

-- Checking total sales
SELECT
    ROUND(SUM(price), 2) AS overall_revenue
FROM order_items;

-- 4: Percentage of orders paid in installments
SELECT
    ROUND(
        (
            SELECT COUNT(DISTINCT order_id)
            FROM payments
            WHERE payment_installments > 1
        )
        /
        (
            SELECT COUNT(DISTINCT order_id)
            FROM orders
        ) * 100,
        2
    ) AS installment_percentage;
    
    
-- 5: Count number of unique customers from each state
SELECT
    customer_state,
    COUNT(DISTINCT customer_unique_id) AS total_customers
FROM customers
GROUP BY customer_state
ORDER BY total_customers DESC;



-- INTERMEDIATE PROBLEMS
-- 1: Number of orders per month in 2018
SELECT
    MONTH(order_purchase_timestamp) AS order_month,
    COUNT(DISTINCT order_id) AS total_orders
FROM orders
WHERE YEAR(order_purchase_timestamp) = 2018
GROUP BY order_month
ORDER BY order_month;

-- Verifying Months
SELECT 
    MIN(order_purchase_timestamp) AS earliest_2018,
    MAX(order_purchase_timestamp) AS latest_2018
FROM orders
WHERE YEAR(order_purchase_timestamp) = 2018;


-- 2: Average number of products per order grouped by customer city

SELECT
    customer_city,
    ROUND(AVG(order_item_count), 2) AS avg_products_per_order
FROM (
    SELECT
        o.order_id,
        c.customer_city,
        COUNT(oi.order_item_id) AS order_item_count
    FROM orders o
    JOIN order_items oi
        ON o.order_id = oi.order_id
    JOIN customers c
        ON o.customer_id = c.customer_id
    GROUP BY o.order_id, c.customer_city
) t
GROUP BY customer_city
ORDER BY avg_products_per_order DESC;


-- 3: Percentage contribution of total revenue by product category

SELECT
    p.product_category,
    ROUND(SUM(oi.price), 2) AS category_revenue,
    ROUND(
        SUM(oi.price) /
        (SELECT SUM(price) FROM order_items) * 100,
        2
    ) AS revenue_percentage
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
GROUP BY p.product_category
ORDER BY revenue_percentage DESC;


-- 4: Prepare product-level dataset for correlation analysis

SELECT
    oi.product_id,
    COUNT(oi.order_item_id) AS times_purchased,
    ROUND(AVG(oi.price), 2) AS avg_price
FROM order_items oi
GROUP BY oi.product_id;

SELECT
    oi.product_id,
    p.product_category,
    COUNT(oi.order_item_id) AS times_purchased,
    ROUND(AVG(oi.price), 2) AS avg_price
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
GROUP BY oi.product_id, p.product_category;



-- 5: Total revenue per seller + ranking

SELECT
    seller_id,
    total_revenue,
    RANK() OVER (ORDER BY total_revenue DESC) AS revenue_rank
FROM (
    SELECT
        oi.seller_id,
        ROUND(SUM(oi.price + oi.freight_value), 2) AS total_revenue
    FROM order_items oi
    GROUP BY oi.seller_id
) seller_revenue
ORDER BY revenue_rank;


-- ADVANCED PROBLEMS
-- 1: Moving average of order value per customer

SELECT
    customer_id,
    order_id,
    order_purchase_timestamp,
    order_value,
    ROUND(
        AVG(order_value) OVER (
            PARTITION BY customer_id
            ORDER BY order_purchase_timestamp
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ),
        2
    ) AS moving_avg_order_value
FROM (
    SELECT
        o.order_id,
        o.customer_id,
        o.order_purchase_timestamp,
        SUM(oi.price + oi.freight_value) AS order_value
    FROM orders o
    JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY
        o.order_id,
        o.customer_id,
        o.order_purchase_timestamp
) order_values
ORDER BY customer_id, order_purchase_timestamp;


-- 2. Cumulative monthly sales per year

SELECT
    sales_year,
    sales_month,
    monthly_sales,
    ROUND(
        SUM(monthly_sales) OVER (
            PARTITION BY sales_year
            ORDER BY sales_month
        ),
        2
    ) AS cumulative_sales
FROM (
    SELECT
        YEAR(o.order_purchase_timestamp) AS sales_year,
        MONTH(o.order_purchase_timestamp) AS sales_month,
        ROUND(SUM(oi.price + oi.freight_value), 2) AS monthly_sales
    FROM orders o
    JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY
        sales_year,
        sales_month
) monthly_data
ORDER BY sales_year, sales_month;


-- 3: Year-over-Year (YoY) Growth Rate

SELECT
    sales_year,
    total_sales,
    ROUND(
        (
            total_sales - LAG(total_sales) OVER (ORDER BY sales_year)
        )
        / LAG(total_sales) OVER (ORDER BY sales_year) * 100,
        2
    ) AS yoy_growth_percentage
FROM (
    SELECT
        YEAR(o.order_purchase_timestamp) AS sales_year,
        ROUND(SUM(oi.price + oi.freight_value), 2) AS total_sales
    FROM orders o
    JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY sales_year
) yearly_sales
ORDER BY sales_year;


-- 4: Customer Retention Rate (6 months)

SELECT
    ROUND(
        (retained_customers / total_customers) * 100,
        2
    ) AS retention_rate_percentage
FROM (
    SELECT
        (SELECT COUNT(DISTINCT customer_id) FROM orders) AS total_customers,
        (
            SELECT COUNT(DISTINCT o.customer_id)
            FROM orders o
            JOIN (
                SELECT
                    customer_id,
                    MIN(order_purchase_timestamp) AS first_purchase_date
                FROM orders
                GROUP BY customer_id
            ) fp
            ON o.customer_id = fp.customer_id
            WHERE o.order_purchase_timestamp > fp.first_purchase_date
              AND o.order_purchase_timestamp <= DATE_ADD(fp.first_purchase_date, INTERVAL 6 MONTH)
        ) AS retained_customers
) t;



-- 5: Top 3 Customers per Year (by Spending)

SELECT
    sales_year,
    customer_id,
    total_spent,
    spend_rank
FROM (
    SELECT
        YEAR(o.order_purchase_timestamp) AS sales_year,
        o.customer_id,
        ROUND(SUM(oi.price + oi.freight_value), 2) AS total_spent,
        RANK() OVER (
            PARTITION BY YEAR(o.order_purchase_timestamp)
            ORDER BY SUM(oi.price + oi.freight_value) DESC
        ) AS spend_rank
    FROM orders o
    JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY sales_year, o.customer_id
) ranked_customers
WHERE spend_rank <= 3
ORDER BY sales_year, spend_rank;

-- END