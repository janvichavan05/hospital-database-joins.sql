CREATE TABLE sales (
    sale_id INT PRIMARY KEY,
    customer_id INT,
    product VARCHAR(50),
    category VARCHAR(50),
    amount DECIMAL(10,2),
    sale_date DATE,
    region VARCHAR(50)
);
INSERT INTO sales VALUES
(1, 101, 'Laptop', 'Electronics', 50000, '2024-01-05', 'West'),
(2, 102, 'Phone', 'Electronics', 20000, '2024-01-06', 'East'),
(3, 101, 'Shoes', 'Fashion', 3000, '2024-01-07', 'West'),
(4, 103, 'Watch', 'Fashion', 7000, '2024-02-02', 'North'),
(5, 104, 'Tablet', 'Electronics', 25000, '2024-02-10', 'South'),
(6, 102, 'Bag', 'Fashion', 1500, '2024-02-12', 'East'),
(7, 105, 'Laptop', 'Electronics', 52000, '2024-03-01', 'West'),
(8, 101, 'Phone', 'Electronics', 18000, '2024-03-03', 'North');
WITH 

-- 1. MONTHLY SALES CTE
MonthlySales AS (
    SELECT 
        YEAR(sale_date) AS yr,
        MONTH(sale_date) AS mn,
        SUM(amount) AS total_month_sales
    FROM sales
    GROUP BY YEAR(sale_date), MONTH(sale_date)
),

-- 2. CUSTOMER SPENDING CTE
CustomerSpending AS (
    SELECT 
        customer_id,
        SUM(amount) AS total_spent
    FROM sales
    GROUP BY customer_id
),

-- 3. CATEGORY SALES BY REGION CTE
CategoryRegionSales AS (
    SELECT 
        region,
        category,
        SUM(amount) AS total_category_sales
    FROM sales
    GROUP BY region, category
),

-- 4. DAILY SALES CTE
DailySales AS (
    SELECT 
        sale_date,
        SUM(amount) AS daily_sales
    FROM sales
    GROUP BY sale_date
),

-- 5. PRODUCT TOTALS
ProductTotals AS (
    SELECT 
        product,
        SUM(amount) AS prod_total
    FROM sales
    GROUP BY product
),

-- 6. AVERAGE PRODUCT SALES
AvgProductSales AS (
    SELECT AVG(prod_total) AS avg_prod_sales
    FROM ProductTotals
)

SELECT 
    s.sale_id,
    s.customer_id,
    s.product,
    s.category,
    s.amount,
    s.sale_date,
    s.region,

    -- Rank customers by spending
    RANK() OVER (ORDER BY cs.total_spent DESC) AS customer_rank,

    -- Running total of sales by date
    SUM(ds.daily_sales) OVER (ORDER BY ds.sale_date) AS running_total_sales,

    -- 3-Day Moving Average
    AVG(ds.daily_sales) OVER (
        ORDER BY ds.sale_date
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS moving_avg_3_days,

    -- Rank category inside each region
    DENSE_RANK() OVER (
        PARTITION BY crs.region
        ORDER BY crs.total_category_sales DESC
    ) AS category_rank_in_region,

    -- Product performance check
    CASE 
        WHEN pt.prod_total > aps.avg_prod_sales
        THEN 'Above Average'
        ELSE 'Below Average'
    END AS product_performance,

    -- Monthly sales
    ms.total_month_sales

FROM sales s

LEFT JOIN CustomerSpending cs
    ON s.customer_id = cs.customer_id

LEFT JOIN CategoryRegionSales crs
    ON s.region = crs.region 
   AND s.category = crs.category

LEFT JOIN DailySales ds
    ON s.sale_date = ds.sale_date

LEFT JOIN MonthlySales ms
    ON YEAR(s.sale_date) = ms.yr
   AND MONTH(s.sale_date) = ms.mn

LEFT JOIN ProductTotals pt
    ON s.product = pt.product

CROSS JOIN AvgProductSales aps

ORDER BY s.sale_date;
