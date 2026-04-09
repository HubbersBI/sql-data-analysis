-- Business question: Segment customers based on purchase behavior by calculating total orders and total revenue, 
-- Then classify as 'Low Value', 'Mid Value', or 'High Value' value according to order count and total revenue.

-- Step 1: Aggregate total orders and revenue per customer and product to account for different product prices and multiple orders
CREATE VIEW v_customer_value AS WITH cte_a AS
  (SELECT s.customerkey,
          cl.lastname,
          s.productkey,
          SUM(s.orderquantity) AS total_orders_p,
          ROUND(SUM(s.orderquantity *
                      (SELECT productprice
                       FROM product_lookup pl
                       WHERE pl.productkey = s.productkey)), 2) AS total_revenue_p
   FROM sales_data s
   JOIN customer_lookup cl ON cl.customerkey = s.customerkey
   GROUP BY customerkey,
            productkey,
            cl.lastname),
            
-- Step 2: Calculate total quantity purchased per customer
cte_b AS
  (SELECT customerkey,
          SUM(orderquantity) AS total_quantity_purchased
   FROM sales_data s
   GROUP BY customerkey) 
   
-- Final step: Summarize total quantity and revenue per customer, and classify customer value
SELECT cte_a.customerkey,
       cte_a.lastname,
       cte_b.total_quantity_purchased,
       ROUND(SUM(total_revenue_p), 2) AS total_revenue,
       CASE
           WHEN SUM(cte_a.total_revenue_p) < 100
                OR cte_b.total_quantity_purchased < 5 THEN 'Low Value'
           WHEN cte_b.total_quantity_purchased BETWEEN 5 AND 15 THEN 'Mid Value'
           WHEN SUM(cte_a.total_revenue_p) < 6000
                OR cte_b.total_quantity_purchased > 15 THEN 'High Value'
           ELSE 'Value Unknown'
       END AS 'Customer Value'
FROM cte_a
JOIN cte_b ON cte_a.customerkey = cte_b.customerkey
GROUP BY cte_a.customerkey,
         cte_b.total_quantity_purchased,
         cte_a.lastname;