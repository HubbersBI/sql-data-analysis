-- Business question: Calculate the percentage (3 decimals) of current employees who are managers

-- Step 1: Identify current managers together with all current employees
WITH cte_a AS
  (SELECT DISTINCT s.emp_no,
                   dm.emp_no AS manager_emp_no
   FROM salaries s
   LEFT JOIN dept_manager dm ON dm.emp_no = s.emp_no
   AND dm.to_date = '9999-01-01'
   WHERE s.to_date = '9999-01-01')
   
-- Final step: Calculate what percentage of table are managers
SELECT ROUND(AVG(CASE
                     WHEN manager_emp_no IS NOT NULL THEN 1
                     ELSE 0
                 END) * 100, 3) AS Percentage_Manager
FROM cte_a;








