-- ============================================================
-- ZEPTO PRODUCT DATA ANALYSIS
-- ============================================================
-- Objective:
-- Analyze product pricing, discounts, availability,
-- inventory, product categories, and value-for-money metrics.
--
-- Dataset: Zepto product data
-- Database: PostgreSQL
-- ============================================================


-- ============================================================
-- 1. DATA EXPLORATION
-- ============================================================

-- 1.1 Count the total number of records
SELECT COUNT(*)
FROM zepto_v2;

-- 1.2 Preview sample records
SELECT *
FROM zepto_v2
LIMIT 10;

-- 1.3 Check for NULL values in important columns
SELECT *
FROM zepto_v2
WHERE name IS NULL
   OR category IS NULL
   OR mrp IS NULL
   OR discountPercent IS NULL
   OR discountedSellingPrice IS NULL
   OR weightInGms IS NULL
   OR availableQuantity IS NULL
   OR outOfStock IS NULL
   OR quantity IS NULL;

-- 1.4 Identify unique product categories
SELECT DISTINCT category
FROM zepto_v2
ORDER BY category;

-- 1.5 Compare products by stock availability
SELECT
    outOfStock,
    COUNT(sku_id) AS no_of_products
FROM zepto_v2
GROUP BY outOfStock;

-- 1.6 Identify products with multiple SKUs
SELECT
    name,
    COUNT(sku_id) AS number_of_skus
FROM zepto_v2
GROUP BY name
HAVING COUNT(sku_id) > 1
ORDER BY number_of_skus DESC;


-- ============================================================
-- 2. DATA CLEANING
-- ============================================================

-- 2.1 Check for products with zero MRP or selling price
SELECT *
FROM zepto_v2
WHERE mrp = 0
   OR discountedSellingPrice = 0;

-- 2.2 Convert prices from paise to rupees
UPDATE zepto_v2
SET mrp = mrp / 100.0,
    discountedSellingPrice = discountedSellingPrice / 100.0;

-- 2.3 Verify the converted prices
SELECT
    mrp,
    discountedSellingPrice
FROM zepto_v2;


-- ============================================================
-- 3. PRODUCT & DISCOUNT ANALYSIS
-- ============================================================

-- 3.1 Identify the top 10 products by discount percentage
SELECT DISTINCT
    name,
    discountPercent
FROM zepto_v2
ORDER BY discountPercent DESC
LIMIT 10;

-- 3.2 Find high-priced products that are out of stock
SELECT DISTINCT
    name,
    mrp
FROM zepto_v2
WHERE outOfStock = 'TRUE'
  AND mrp > 300
ORDER BY mrp DESC;

-- 3.3 Estimate inventory value by category
-- Note: This represents estimated inventory value,
-- not actual realized sales revenue.
SELECT
    category,
    SUM(discountedSellingPrice * availableQuantity) AS estimated_inventory_value
FROM zepto_v2
GROUP BY category
ORDER BY estimated_inventory_value DESC;

-- 3.4 Find expensive products with low discounts
SELECT DISTINCT
    name,
    mrp,
    discountPercent
FROM zepto_v2
WHERE mrp > 500
  AND discountPercent < 10
ORDER BY mrp DESC,
         discountPercent DESC;

-- 3.5 Identify categories with the highest average discount
SELECT
    category,
    ROUND(AVG(discountPercent), 2) AS avg_discount
FROM zepto_v2
GROUP BY category
ORDER BY avg_discount DESC
LIMIT 5;


-- ============================================================
-- 4. PRODUCT VALUE & INVENTORY ANALYSIS
-- ============================================================

-- 4.1 Calculate price per gram for products weighing 100g or more
SELECT DISTINCT
    name,
    weightInGms,
    discountedSellingPrice,
    ROUND(discountedSellingPrice / weightInGms, 2) AS price_per_gram
FROM zepto_v2
WHERE weightInGms >= 100
ORDER BY price_per_gram;

-- 4.2 Classify products based on weight
SELECT DISTINCT
    name,
    weightInGms,
    CASE
        WHEN weightInGms < 1000 THEN 'LOW'
        WHEN weightInGms < 5000 THEN 'MEDIUM'
        ELSE 'BULK'
    END AS weight_category
FROM zepto_v2;

-- 4.3 Calculate total inventory weight by category
SELECT
    category,
    SUM(weightInGms * availableQuantity) AS total_inventory_weight
FROM zepto_v2
GROUP BY category
ORDER BY total_inventory_weight DESC;