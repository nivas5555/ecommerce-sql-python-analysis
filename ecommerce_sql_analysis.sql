/* =====================================================
   Project: E-Commerce Data Analysis
   Author: Nivas Kumar
   Tool: MySQL Workbench
   Database: ecommerce_analysis
   Purpose: SQL queries used for analysis & validation
   ===================================================== */

/* =====================================================
   SECTION 1: DATA UNDERSTANDING & BASIC CHECKS
   ===================================================== */
-- Purpose:
-- Validate row counts
-- Inspect key tables
-- Check basic distributions

-- Row count check for main tables
SELECT 'customers' AS table_name, COUNT(*) AS row_count FROM customers
UNION ALL
SELECT 'orders', COUNT(*) FROM orders
UNION ALL
SELECT 'order_items', COUNT(*) FROM order_items
UNION ALL
SELECT 'products', COUNT(*) FROM products
UNION ALL
SELECT 'payments', COUNT(*) FROM payments

-- Check primary key uniqueness
SELECT 
    COUNT(*) AS total_rows,
    COUNT(DISTINCT customer_id) AS distinct_customers
FROM customers;

SELECT 
    COUNT(*) AS total_rows,
    COUNT(DISTINCT order_id) AS distinct_orders
FROM orders;

SELECT 
    COUNT(*) AS total_rows,
    COUNT(DISTINCT product_id) AS distinct_products
FROM products;

/* =========================================================
   SECTION 2: BASIC PROBLEMS
   Objective: Extract fundamental insights from the dataset.
   =========================================================
   Purpose:
   - Answer fundamental business questions
   - Match "Basic Problems" from project brief
   ========================================================= */

-- Problem 1: List all unique cities where customers are located
SELECT DISTINCT
    customer_city
FROM customers
ORDER BY customer_city;


-- Problem 2: Count the number of orders placed in 2017
SELECT
    COUNT(*) AS orders_2017
FROM orders
WHERE YEAR(order_purchase_timestamp) = 2017;


-- Problem 3: Find total sales per product category
SELECT
    p.product_category,
    ROUND(SUM(oi.price + oi.freight_value), 2) AS total_sales
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
GROUP BY p.product_category
ORDER BY total_sales DESC;


-- Problem 4: Percentage of orders paid in installments
-- Total number of orders
SELECT
    COUNT(DISTINCT order_id) AS total_orders
FROM payments;

-- Orders paid in installments (more than 1 installment)
SELECT
    COUNT(DISTINCT order_id) AS installment_orders
FROM payments
WHERE payment_installments > 1;

-- Percentage of orders paid in installments
SELECT
    ROUND(
        (installment_orders / total_orders) * 100,
        2
    ) AS installment_order_percentage
FROM
(
    SELECT
        (SELECT COUNT(DISTINCT order_id)
         FROM payments
         WHERE payment_installments > 1) AS installment_orders,

        (SELECT COUNT(DISTINCT order_id)
         FROM orders) AS total_orders
) t;


-- Problem 5: Count the number of customers from each state
SELECT
    customer_state,
    COUNT(DISTINCT customer_id) AS total_customers
FROM customers
GROUP BY customer_state
ORDER BY total_customers DESC;

-- Insight:
-- São Paulo (SP) has the highest number of customers by a large margin,
-- indicating a strong geographic concentration of demand.
-- This suggests opportunities for region-focused marketing, logistics optimization,
-- and faster delivery SLAs in high-density states.


/* =====================================================
   SECTION 3: INTERMEDIATE BUSINESS QUESTIONS
   Objective: Dive Deeper into sales and order trends
   =====================================================
   Purpose:
   - Analyze trends and deeper business patterns
   - Match "Intermediate Problems" from project brief
*/

-- Problem 1: Calculate number of orders per month in 2018
SELECT
    MONTH(order_purchase_timestamp) AS order_month,
    COUNT(order_id) AS total_orders
FROM orders
WHERE YEAR(order_purchase_timestamp) = 2018
GROUP BY order_month
ORDER BY order_month;


-- Problem 2: Find the average number of products per order, grouped by customer city
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

-- Problem 3: Percentage contribution of total revenue by product category
SELECT
    p.product_category,
    ROUND(SUM(oi.price + oi.freight_value), 2) AS category_revenue
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
GROUP BY p.product_category;


SELECT
    p.product_category,
    ROUND(SUM(oi.price + oi.freight_value), 2) AS category_revenue,
    ROUND(
        SUM(oi.price + oi.freight_value)
        / (SELECT SUM(price + freight_value) FROM order_items) * 100,
        2
    ) AS revenue_percentage
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
GROUP BY p.product_category
ORDER BY revenue_percentage DESC;


-- Problem 4: Identify the correlation between product price and the number of times a product has been purchased
SELECT
    oi.product_id,
    COUNT(oi.order_item_id) AS times_purchased,
    ROUND(AVG(oi.price), 2) AS avg_price
FROM order_items oi
GROUP BY oi.product_id;

-- NOTE:
-- SQL is used here to prepare product-level data (avg_price vs times_purchased).
-- Correlation analysis is performed in Python / Excel / BI tools,
-- since MySQL does not support statistical correlation functions natively.


-- Problem 5: Calculate total revenue generated by each seller and rank them by revenue
SELECT
    oi.seller_id,
    ROUND(SUM(oi.price + oi.freight_value), 2) AS total_revenue
FROM order_items oi
GROUP BY oi.seller_id
ORDER BY total_revenue DESC;

-- ranking sellers by total revenure
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
) t;



/* =====================================================
   SECTION 4: ADVANCED ANALYTICS
   Objective: Generate strategic and customer-centric insights.
   =====================================================
   Purpose:
   - Generate strategic and customer-centric insights
   - Match "Advanced Problems" from project brief
*/

-- Problem 1: Moving average of order values per customer over time

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
) t
ORDER BY customer_id, order_purchase_timestamp;

-- Problem 2: Cumulative monthly sales per year
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
) t
ORDER BY sales_year, sales_month;


-- Problem 3: Year-over-Year (YoY) growth rate of total sales
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
) t
ORDER BY sales_year;


-- Problem 4: Customer Retention Rate

-- 1: Identify first purchase date for each customer
SELECT
    customer_id,
    MIN(order_purchase_timestamp) AS first_purchase_date
FROM orders
GROUP BY customer_id;

-- 2: Identify customers with repeat purchase within 6 months of first purchase
SELECT DISTINCT
    o.customer_id
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
  AND o.order_purchase_timestamp <= DATE_ADD(fp.first_purchase_date, INTERVAL 6 MONTH);

-- 3: Calculate customer retention rate (%)
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


-- PRoblem 5: Top 3 Customers (each year as per spending)

-- 1: Calculate yearly spend per customer
SELECT
    YEAR(o.order_purchase_timestamp) AS sales_year,
    o.customer_id,
    ROUND(SUM(oi.price + oi.freight_value), 2) AS total_spent
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY
    sales_year,
    o.customer_id
ORDER BY
    sales_year,
    total_spent DESC;

-- 2: Rank customers by total spend within each year
SELECT
    sales_year,
    customer_id,
    total_spent,
    RANK() OVER (
        PARTITION BY sales_year
        ORDER BY total_spent DESC
    ) AS spend_rank
FROM (
    SELECT
        YEAR(o.order_purchase_timestamp) AS sales_year,
        o.customer_id,
        ROUND(SUM(oi.price + oi.freight_value), 2) AS total_spent
    FROM orders o
    JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY
        sales_year,
        o.customer_id
) t
ORDER BY
    sales_year,
    spend_rank;


-- 3: Top 3 customers by total spend in each year
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
    GROUP BY
        sales_year,
        o.customer_id
) ranked_customers
WHERE spend_rank <= 3
ORDER BY
    sales_year,
    spend_rank;
