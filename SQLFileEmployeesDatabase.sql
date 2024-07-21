# Below are notes regarding the employees database utilized for the subsequent queries:

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


# Specify the database to be used:

USE employees;


# SAMPLE QUERIES


# 1) Obtain a table containing the average salary, rounded to 2 decimal places, of employees by gender in each department.
#    Order the results by department number in ascending order.
#    The field list should contain:
#    - Department Number
#    - Department Name
#    - Gender
#    - Average Salary

SELECT
	d.dept_no AS department_number,
	d.dept_name AS department_name,
	e.gender,
	ROUND(AVG(s.salary), 2) AS average_salary
FROM departments d
# Inner join to join the departments table with the department employees (dept_emp) table, which contains employee number
INNER JOIN dept_emp de ON d.dept_no = de.dept_no
# Inner join to join prior tables with the employees table, which contains employee number and gender
INNER JOIN employees e ON de.emp_no = e.emp_no
# Inner join to join prior tables with the salaries table, which contains employee number and salaries
INNER JOIN salaries s ON e.emp_no = s.emp_no
# Group the table by department number, then group by gender within each department
GROUP BY d.dept_no, e.gender
# The ORDER BY clause is defaulted to ascending
ORDER BY d.dept_no;

# 2) Obtain a table containing all employees that have been hired in 2000. 
#    The field list should contain:
#    - Employee Number
#    - First Name
#    - Last Name
#    - Hire Date

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
#    The field list should contain:
#    - Employee Number
#    - First Name
#    - Last Name
#    - Highest Salary
 
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
#     - Employee Number
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
#	 - Employee Number
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
#	 Note that the number of contracts represent the total number of rows within the salaries table, as each row represents a new salary per employee.
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

# Append both prior tables

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
#    along with the total number of contracts. These totals will be the two fields of the resulting table.

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
# Filter for the male gender
WHERE e.gender = 'M';


# 9) Obtain a table containing the employee number, first name, last name, hire date, and the number of days between the employee's hire date and the current date.
#    Filter for employees whose number of days between the current date and their hire date is less than 30 days. 
#    Order the table by hire date, then employee number, both in ascending order.

SELECT
	emp_no,
    	first_name,
    	last_name,
	hire_date,
    	# Use TIMESTAMPDIFF function to calculate the number of days between two dates
    	TIMESTAMPDIFF(day, hire_date, current_date) AS date_difference
FROM employees
# Specify the condition for the number of days in between
WHERE TIMESTAMPDIFF(day, hire_date, current_date) < 30
ORDER BY hire_date, emp_no ASC;


# 10) Obtain a table containing the employee number, first_name, last_name, 
#     the 5 most recent dates that an employee's salary as changed, 
#     and the rolling average for those 5 most recent salary changes.
#     Write two queries: one using a subquery, and another using a CTE (common table expression).


# Subquery Solution
SELECT
	emp_no,
    	first_name,
    	last_name,
	salary,
	from_date,
    	# Calculate the rolling average salaries by employee
	AVG(salary) OVER(PARTITION BY emp_no ORDER BY from_date ASC) AS rolling_average_salary
FROM
	(SELECT
		e.emp_no,
        	e.first_name,
        	e.last_name,
		s.salary,
		s.from_date,
        	# Create a row number column in salary change date descending order
		ROW_NUMBER() OVER(PARTITION BY e.emp_no ORDER BY s.from_date DESC) AS date_row_number
	 FROM employees e
	 INNER JOIN salaries s on e.emp_no = s.emp_no) a
# Specify the 5 most recent salary change dates     
WHERE date_row_number <= 5
ORDER BY emp_no, from_date ASC;


# CTE Solution
WITH cte AS
	(SELECT
		e.emp_no,
        	e.first_name,
        	e.last_name,
		s.salary,
		s.from_date,
        	# Create a row number column in salary change date descending order
		ROW_NUMBER() OVER(PARTITION BY e.emp_no ORDER BY s.from_date DESC) AS date_row_number
	 FROM employees e
	 INNER JOIN salaries s on e.emp_no = s.emp_no)
	
SELECT
	emp_no,
    	first_name,
    	last_name,
	salary,
	from_date,
    	# Calculate the rolling average salaries by employee
	AVG(salary) OVER(PARTITION BY emp_no ORDER BY from_date ASC) AS rolling_average_salary
FROM cte
# Specify the 5 most recent salary change dates
WHERE date_row_number <= 5
ORDER BY emp_no, from_date ASC;


# 11) Create both a view and temporary table of employees whose last name falls between the letter 'A' and letter 'J' (inclusive)
#	  along with the number of unique titles that the employee has held, given the condition that the employee has held more than one title.
#	  The field list should contain:
#	  - Full Name (this should be formatted as "Last Name, First Name")
#	  - Tile Count


# View Solution

# Create and name the View (or replace it if it exists)
CREATE OR REPLACE VIEW Number_of_Titles_View AS

# Create a CTE for the formatted employee names
WITH cte AS 
(SELECT 
	e.emp_no, 
	CONCAT(e.last_name, ', ', e.first_name) AS full_name
FROM employees e)

# Select the appropriate fields from the CTE joined on the titles table
SELECT
	c.emp_no,
	c.full_name,
    	# Count of the unique titles
	COUNT(DISTINCT t.title) AS title_count
FROM cte c
# Inner join the cte on the titles table based on employee number 
INNER JOIN titles t ON c.emp_no = t.emp_no
# Add condition for full name, specifically that falls within A and J (inclusive)
WHERE full_name REGEXP '^[a-j]'
GROUP BY c.emp_no
HAVING title_count > 1
ORDER BY full_name;

# Select from the View
SELECT 
	* 
FROM Number_Of_Titles_View;


# Temporary Table Solution

# Create and name the Temporary Table
CREATE TEMPORARY TABLE Number_Of_Titles_Temp_Table

# Create a CTE for the formatted employee names
WITH cte AS 
(SELECT 
	e.emp_no, 
	CONCAT(e.last_name, ', ', e.first_name) AS full_name
FROM employees e)

# Select the appropriate fields from the CTE joined on the titles table
SELECT
	c.emp_no,
	c.full_name,
	COUNT(DISTINCT t.title) AS title_count
FROM cte c
# Inner join the cte on the titles table based on employee number 
INNER JOIN titles t ON c.emp_no = t.emp_no
# Add condition for full name, specifically that falls within A and J (inclusive)
WHERE full_name REGEXP '^[a-j]'
GROUP BY c.emp_no
HAVING title_count > 1
ORDER BY full_name;

# Select from the Temporary Table
SELECT 
	* 
FROM Number_Of_Titles_Temp_Table;


# 12) Create both a stored procedure and a user-defined function that calculates
#	  an employee's average salary, given their employee number. The output should be rounded to 2 decimal places.


# Stored Procedure Solution

# Specifiy a new delimiter
DELIMITER $$

# Specify database
USE employees $$

# Create procedure with employee number as IN parameter and average salary as OUT parameter
CREATE PROCEDURE emp_avg_salary_out(IN p_emp_no INTEGER, OUT p_avg_salary DECIMAL(10, 2))

# Create query
BEGIN
	SELECT
		# Specify the average salary as the output
		AVG(s.salary) INTO p_avg_salary 
    	FROM employees e
    	# Join salaries table to employees table on employee ID
    	JOIN salaries s ON e.emp_no = s.emp_no
	# Specify the employee number as the IN parameter
    	WHERE e.emp_no = p_emp_no;
END$$

# Return the delimiter to ";"
DELIMITER ;

# Call the procedure with parameters
CALL emp_avg_salary_out(11300, @p_avg_salary);

SELECT @p_avg_salary;


# User-Defined Function Solution

# Specify a new delimiter
DELIMITER $$

# Create function with employee number as the input parameter and returns the employee's average salary
CREATE FUNCTION f_emp_avg_salary (p_emp_no INTEGER) RETURNS DECIMAL(10, 2)

# Specify the function as deterministic
DETERMINISTIC

# Create query
BEGIN

# Declare the average salary variable
DECLARE v_avg_salary DECIMAL(10, 2);

	SELECT
		# Specify the average salary as the output
		AVG(s.salary) INTO v_avg_salary
	FROM employees e
    	# Join salaries table to employees table on employee ID
	JOIN salaries s ON e.emp_no = s.emp_no
    	# Specify the employee number as the IN parameter
   	 WHERE e.emp_no = p_emp_no;
    	# Specify the return value
	RETURN v_avg_salary;

END $$

# Return the delimiter to ";"
DELIMITER ;

# Call the function with parameter
SELECT f_emp_avg_salary(11300) AS average_salary;
