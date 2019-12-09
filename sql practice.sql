
-- subquery visualization https://dataschool.com/learn/how-sql-subqueries-work

-- vim mode, control + C, then press 'i' to go into insert mode 
-- annoying this is what causes problems. 

/*
As VS Code remembers the last session when opened, you can:

open New Window (Ctrl+Shift+N) - this will open new VS Code with no project folders opened,
close the old window (with opened project folder),
close the new one.
Next time you run VS Code, it should look like the last window you closed and thus without any folders opened.

Note that this process closes ALL opened folders.
*/



-- w3resource SQL JOIN PRACTICE 
-- https://www.w3resource.com/sql-exercises/sql-joins-exercises.php

/* 1. Write a SQL statement to prepare a list wtih salesman name, customer name, 
and their cities for the salesmen and customer who belongs to the same city. */

-- explicit join
SELECT salesman.name as salesmen, customer.cust_name, customer.city  
FROM  salesman INNER JOIN 
    customer ON salesman.city = customer.city  
ORDER BY salesman.city DESC; 

-- implicit join 
SELECT salesman.name AS "Salesman",
customer.cust_name, customer.city 
FROM salesman, customer 
WHERE salesman.city=customer.city;

/*  2. Write a SQL statement to make a list with order no, purchase amount,
customer name, and their cities for those orders which order amount between
500 and 2000 */ 

-- explicit join 
SELECT orders.ord_no, orders.purch_amt, customer.cust_name, cutomer.city
FROM orders INNER JOIN customer
    ON orders.customer_id = customer.customer_id 
WHERE orders.purch_amt BETWEEN 500 AND 2000 ;

-- implicit join 
SELECT a.ord_no, a.purch_amt, b.cust_name, b.city
FROM orders as a, customer as b 
WHERE a.customer_id = b.customer_id AND a.purch_amt BETWEEN 500 AND 2000;  

/* 3. Write a SQL statement to know which salesman are working for which customer. 
*/ 

SELECT customer.cust_name, salesman.name 
FROM customer 
    INNER JOIN salesman 
    ON customer.salesman_id = salesman.salesman_id 
ORDER BY salesman.salesman_id DESC

/* 4. Write a SQL statement to find the list of customers who appointed a salesman
 for their jobs who gets a commission from the company is more than 12% 






/* w3resource Subquery on HR Practice  */\
-- https://www.w3resource.com/sql-exercises/sql-subqueries-exercises.php

 /* 1. Write a query to display the name (first name and last name) for those employees who gets more salary than the employee whose ID is 163 */ 

 SELECT CONCAT (first_name, ' ', last_name) as name
 FROM employees e 
 WHERE salary >  (
     SELECT salary 
     FROM employees e
     WHERE e.employee_id = 163
 );

 /* 3. Write a query to display the name (first name and last name), salary, department id for those employees who earn such amount of salary which is the smallest salary of any of the departments  */ 

 SELECT first_name, last_name, salary, dapartment_id 
 FROM employees 
 WHERE salary in 
 (
    SELECT min(salary)
    FROM employees
    GROUP BY department_id 
 ); 
 
 -- First make the subquery. It will be grouped by department ID, so multiple minimum salary values will exist. The outer query will select a salary within this list of value. Because remember a subquery is interpreted as a list, not a table, by the outer query!  
 

 /* 4. Write a query to display the employee id, employee name (first name and last name) for all employees who earn more than the average salary. */ 

 SELECT employee_id, first_name, last_name
 FROM employees 
 WHERE salary > (
     SELECT avg(salary)  
     FROM employees 
 );


 /* 5. Write a query to display the employee name, employee id, and salary of all employees who report to Payam */ 

 SELECT first_name, last_name, employee_id, salary 
 FROM employees
 WHERE manager_id IN (
     SELECT employee_id 
     FROM employees
     WHERE first_name = 'Payam'
 )

 /*6 