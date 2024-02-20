# Below are notes regarding the employees database utilized for these queries.

--  Sample employee database 
--  See changelog table for details
--  Copyright (C) 2007,2008, MySQL AB
--  
--  Original data created by Fusheng Wang and Carlo Zaniolo
--  http://www.cs.aau.dk/TimeCenter/software.htm
--  http://www.cs.aau.dk/TimeCenter/Data/employeeTemporalDataSet.zip
-- 
--  Current schema by Giuseppe Maxia 
--  Data conversion from XML to relational by Patrick Crews
-- 
--  This work is licensed under the 
--  Creative Commons Attribution-Share Alike 3.0 Unported License. 
--  To view a copy of this license, visit 
--  http://creativecommons.org/licenses/by-sa/3.0/ or send a letter to 
--  Creative Commons, 171 Second Street, Suite 300, San Francisco, 
--  California, 94105, USA.
-- 
--  DISCLAIMER
--  To the best of our knowledge, this data is fabricated, and
--  it does not correspond to real people. 
--  Any similarity to existing people is purely coincidental.


# Specify the database

USE employees;


# SAMPLE QUERIES


# 1) Obtain a table containing the average salary of employees by gender in each department.
#	 Order the results by department number in ascending order.
#	 The field list should contain:
#	 - Department Number
#	 - Department Name
#	 - Gender
#	 - Average Salary

SELECT
	d.dept_no AS department_number,
	d.dept_name AS department_name,
	e.gender,
	AVG(s.salary) AS average_salary
FROM departments d
# Inner join to join the departments table with the department employees (dept_emp) table on the department number table, which contains employee number
INNER JOIN dept_emp dm ON d.dept_no = dm.dept_no
# Inner join to join prior tables with the employees table, which contains employee number and gender
INNER JOIN employees e ON dm.emp_no = e.emp_no
# Inner join to join prior tables with the salaries table, which contains employee number and salaries
INNER JOIN salaries s ON e.emp_no = s.emp_no
# Group the table by department number, then group by gender within each department
GROUP BY d.dept_no, e.gender
# The ORDER BY clause is defaulted to ascending
ORDER BY d.dept_no;

# 2) Obtain a table containing all employees that have been hired in 2000. 
#	 The field list should contain:
#	 - Employee Number
#	 - First Name
#	 - Last Name
#	 - Hire Date

SELECT
	emp_no AS employee_number,
	first_name,
	last_name,
	hire_date
FROM employees
WHERE YEAR(hire_date) = 2000;


# 3) Obtain a table of employees with their highest salaries. 
#    Filter only for employees with a max salary greater than $80,000.
#    Order the results by salary in descending order.
#	 The field list should contain:
#	 - Employee Number
#	 - First Name
#	 - Last Name
#	 - Highest Salary
 
SELECT
	e.emp_no AS employee_number,
    e.first_name,
    e.last_name,
    MAX(s.salary) AS highest_salary
FROM employees e
INNER JOIN salaries s ON e.emp_no = s.emp_no
GROUP BY emp_no
HAVING highest_salary > 80000
ORDER BY highest_salary DESC;

#  4) Obtain a table containing the following three fields for all individuals whose employee number is not greater than 10040:
#  	  - Employee Number
#     - The lowest department number among the departments where the employee has worked in
#     - Assign '110022' as 'manager' to all individuals whose employee number is lower than or equal to 10020, and '110039' to those whose number is between 10021 and 10040 inclusive

SELECT
	emp_no AS employee_number,
	# Use a subquery to find the lowest department number an employee has worked in
    (SELECT
		MIN(dept_no)
    # The dept_emp table contains both department number and employee number    
	FROM dept_emp de
	WHERE e.emp_no = de.emp_no) AS department_number,
	CASE WHEN emp_no <= 10020 THEN '110022' ELSE '110039' END AS manager
FROM employees e
WHERE emp_no <= 10040;


# 5) Obtain a table containing a list of all employees with "Engineer" in their title.
#	 The field list should contain:
#	 - First Name
#	 - Last Name
#	 - Hire Date
#	 - Title
#	 - Position Start Date
#	 - Position End Date

SELECT 
	e.emp_no AS employee_number,
    e.first_name,
	e.last_name,
	e.hire_date,
	t.title,
    t.from_date AS position_start_date,
    t.to_date AS position_end_date
FROM employees e
# Inner join to join employees table with titles table, which contains employee number, titles, position start date, and position end date
INNER JOIN titles t ON e.emp_no = t.emp_no
# Search for the string "Engineer" within the title field
WHERE title LIKE ('%Engineer%');


# 6) Obtain a table with the number of distinct employee numbers and the total number of employee numbers.
# 	 The field list should contain:
# 	 - Distinct Number of Employees
# 	 - Total Number of Employees
# 	 Then, obtain a table of distinct employee numbers and the total number of contracts based on the salaries table.
# 	 The field list should contain:
# 	 - Distinct Number of Employees
# 	 - Total Number of Contracts
# 	 Lastly, append the results of both tables to create one table.
# 	 The field list should contain:
# 	 - Distinct Numbers
# 	 - Total Numbers

# Distinct Number of Employees and Total Number of Employees
SELECT
	COUNT(DISTINCT emp_no) AS distinct_number_of_employees,
	COUNT(emp_no) AS total_number_of_employees
FROM employees;

# Distinct Number of Employees and Total Number of Contracts
SELECT
	COUNT(DISTINCT emp_no) AS distinct_number_of_employees,
	COUNT(emp_no) AS total_number_of_contracts
FROM salaries;

# Both prior tables appended

SELECT
	COUNT(DISTINCT emp_no) AS distinct_numbers,
	COUNT(emp_no) AS total_numbers
FROM employees

UNION ALL

SELECT
	COUNT(DISTINCT emp_no) AS distinct_numbers,
	COUNT(emp_no) AS total_numbers
FROM salaries;
 
 
# 7) Obtain a table of departments and the department managers associated with them.
# 	 Provide the salaries of the department managers, with the date range of the salary, and the date range at which the manager oversaw the department.
# 	 Provide a rank number for the salaries in descending order within each department.
# 	 The field list should contain:
# 	 - Department Number
#	 - Department Name
#	 - Manager Number
#	 - Manager Name
#	 - Manager Last Name
#	 - Department Salary Ranking
#	 - Salary
#	 - Salary Start Date
#	 - Salary End Date
#	 - Start Date for Manager within Department
#	 - End Date for Manager within Department
 
SELECT
	d.dept_no AS department_number,
	d.dept_name AS department_name,
	dm.emp_no AS employee_number,
    e.first_name AS manager_first_name,
    e.last_name AS manager_last_name,
    # RANK window function for department salary (specified at end of query)
	RANK() OVER w AS department_salary_ranking,
	s.salary,
	s.from_date AS salary_start_date,
	s.to_date AS salary_end_date,
	dm.from_date AS dept_manager_start_date,
	dm.to_date AS dept_manager_end_date
# Inner join to join employees, department manager, salaries, and departments together and retrive relevant fields
FROM employees e
INNER JOIN dept_manager dm ON e.emp_no = dm.emp_no
INNER JOIN salaries s ON dm.emp_no = s.emp_no
		   # Add conditions for salary start and end dates to be within start and end dates manager oversees the department
		   AND s.from_date BETWEEN dm.from_date AND dm.to_date
		   AND s.to_date BETWEEN dm.from_date AND dm.to_date
INNER JOIN departments d ON dm.dept_no = d.dept_no
# Specify the partition and the order
WINDOW w AS (PARTITION BY dm.dept_no ORDER BY s.salary DESC);


# 8) Obtain a table of the total number of male employees whose highest salaries are lower than the average salary of the total number of contracts,
#	 along with the total number of contracts. These totals will be the two fields of the resulting table.

# Create CTEs (Common Table Expressions) for the employees' highest salaries and the average salary of the entire employee population
WITH
 
cte_highest_salary AS
(SELECT
	s.emp_no,
	MAX(s.salary) AS highest_salary
 FROM employees e
 INNER JOIN salaries s ON e.emp_no = s.emp_no
 GROUP BY e.emp_no),
 
cte_avg_salary AS
(SELECT
	AVG(salary) AS avg_salary
 FROM salaries)
 
SELECT
	# Create a CASE statement to SUM the number of instances that meet the criteria of the highest salary falling below the average
	SUM(CASE WHEN c1.highest_salary < c2.avg_salary THEN 1 ELSE 0 END) AS m_highest_salary_below_average,
	COUNT(e.emp_no) AS total_number_contracts
FROM employees e
# Inner join to join the employees table with the CTE highest salary table
INNER JOIN cte_highest_salary c1 ON e.emp_no = c1.emp_no
# Cross join to join the CTE average salary table with all rows of the prior joined tables
CROSS JOIN cte_avg_salary c2
# Specify for male gender
WHERE e.gender = 'M';