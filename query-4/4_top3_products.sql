-- Business question: Identify the top 3 products by revenue within each category to highlight best performers.

-- Step 1: Aggregate total quantity sold per product
CREATE VIEW v_top_products_per_category AS WITH cte_a AS
  (SELECT s.productkey,
          SUM(s.Orderquantity) AS Quantity_Sold
   FROM sales_data s
   GROUP BY s.productkey), 
   
-- Step 2: Calculate total revenue per product and assign product to its category
cte_b AS
  (SELECT pl.productname,
          pcl.categoryname,
          ROUND(cte_a.quantity_sold * pl.ProductPrice, 2) AS Product_Revenue
   FROM product_lookup pl
   JOIN cte_a ON cte_a.productkey = pl.productkey
   JOIN product_subcategories_lookup psl ON psl.ProductSubcategoryKey = pl.ProductSubcategoryKey
   JOIN product_categories_lookup pcl ON pcl.ProductCategoryKey = psl.ProductCategoryKey), 
   
-- Step 3: Rank products within each category based on revenue to identify top performers
cte_c AS
  (SELECT cte_b.productname,
          cte_b.categoryname,
          cte_b.Product_Revenue,
          DENSE_RANK() OVER(PARTITION BY categoryname
                            ORDER BY Product_Revenue DESC) AS Top_3_Products
   FROM cte_b) 
   
-- Final step: Select top 3 products per category
SELECT cte_c.productname,
       cte_c.categoryname,
       cte_c.product_revenue,
       cte_c.Top_3_Products
FROM cte_c
WHERE cte_c.Top_3_Products <= 3;

