#Test SQL

SELECT
*
FROM
employees e
JOIN
dept_emp de ON e.emp_no = de.emp_no
JOIN
departments d ON de.dept_no = d.dept_no
WHERE dept_name = 'Customer Service';