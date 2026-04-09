-- Business question: Calculate salary increase from first to second contract since 1998, 
-- Compare with the average increase, excluding employees with only one contract since 1998, ordered by employee number ascending
-- Then classify as 'Lower_than_AVG' or 'Higher_Than_AVG' compared to the average increase

-- Step 1: Rank contracts per employee since 1998
CREATE VIEW v_salary_difference AS WITH cte_a AS
  (SELECT emp_no,
          salary,
          from_date,
          ROW_NUMBER() OVER (PARTITION BY emp_no
                             ORDER BY from_date ASC) AS contract_numb
   FROM salaries
   WHERE YEAR(from_date) >= 1998), 

-- Step 2: Select first and second contract salaries per employee
cte_b AS
  (SELECT c1.emp_no,
          c1.salary AS Salary_1,
          c2.salary AS Salary_2
   FROM cte_a c1
   LEFT JOIN cte_a c2 ON c1.emp_no = c2.emp_no
   AND c2.contract_numb = 2
   WHERE c1.contract_numb = 1), 

-- Step 3: Calculate salary difference between first and second contract
cte_c AS
  (SELECT emp_no,
          Salary_1,
          Salary_2,
          Salary_2 - Salary_1 AS Salary_Difference
   FROM cte_b) 
   
-- Final step: Salary difference per employee categorized against average
SELECT cte_c.emp_no,
       cte_c.Salary_Difference,
       CASE
           WHEN cte_c.Salary_Difference >
                  (SELECT AVG(Salary_Difference) AS AVG_Salary_Difference
                   FROM cte_c) THEN "Higher_Than_AVG"
           ELSE "Lower_than_AVG"
       END AS "Higher_Or_Lower_Than_AVG"
FROM cte_c
WHERE Salary_Difference IS NOT NULL
ORDER BY cte_c.emp_no ASC;






 