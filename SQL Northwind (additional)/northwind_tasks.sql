-- 1. Display all information from the orders table.
SELECT * 
FROM northwind.orders;

-- 2. Display two fields from the customers table: the name of the ordering company and its city of location.
SELECT company_name, 
       city 
FROM northwind.customers;

-- 3. Display the first five records from the employees table.
SELECT * 
FROM northwind.employees
LIMIT 5;

-- 4. Display the first twenty records from the orders table.
SELECT * 
FROM northwind.orders
LIMIT 20;

-- 5. Display the names and addresses of customer companies located in France.
SELECT company_name, 
       address 
FROM northwind.customers
WHERE UPPER(country) = 'FRANCE';

-- 6. Display the first names and last names of all employees from London.
SELECT first_name, 
       last_name
FROM northwind.employees
WHERE UPPER(city) = 'LONDON';

-- 7. Display the first names and last names of employees from London whose home phone number ends with '8'.
SELECT first_name, 
       last_name
FROM northwind.employees
WHERE UPPER(city) = 'LONDON' AND 
      home_phone LIKE '%8';

-- 8. Display a list of unique city names starting with 'San', where at least one order was placed after July 16, 1996. 
-- Sort the table in lexicographic order, descending.
SELECT DISTINCT cu.city
FROM northwind.customers cu
INNER JOIN northwind.orders ord ON cu.customer_id = ord.customer_id
WHERE ord.order_date > '16-07-1996' AND
      cu.city ILIKE 'San%'
ORDER BY 1 DESC;

-- 9. Display all information about employees, sorting the records in descending order of their birth dates.
SELECT * 
FROM northwind.employees
ORDER BY birth_date DESC;

-- 10. Display all information from the first 100 records of the orders table, sorted by the delivery country in ascending lexicographic order.
SELECT * 
FROM northwind.orders
ORDER BY ship_country
LIMIT 100;

-- 11. Using the orders table, display the number of unique customer IDs (field 'customer_id') that have placed at least one order.
SELECT COUNT(DISTINCT customer_id)
FROM northwind.orders;

-- 12. For all products with a specified supplier, display pairs with the product name and the name of the supplier company for that product.
SELECT pr.product_name, 
       sup.company_name
FROM northwind.products pr
INNER JOIN northwind.suppliers sup ON pr.supplier_id = sup.supplier_id;

-- 13. Display the average price of products in each category from the 'products' table. Round the average to two decimal places.
SELECT category_id, 
       ROUND(AVG(unit_price)::numeric, 2)
FROM northwind.products
GROUP BY category_id;

-- 14. Display unique names of all countries where more than 10 orders have been shipped. Sort the output by country name in descending lexicographic order.
SELECT DISTINCT ship_country
FROM northwind.orders
GROUP BY ship_country
HAVING COUNT(order_id) > 10
ORDER BY 1 DESC;

-- 15. Select countries with more than 30 orders and display the number of orders in these countries. Sort the results by country name in lexicographic order.
SELECT ship_country, 
       COUNT(order_id)
FROM northwind.orders
GROUP BY ship_country
HAVING COUNT(order_id) > 30
ORDER BY 1;

-- 16. Display the names of products with a price higher than the average among all items presented in the table.
SELECT product_name
FROM northwind.products
WHERE unit_price > (SELECT AVG(unit_price) 
                    FROM northwind.products);

-- 17. Display the names of products with a price lower than or equal to the average among all items presented.
SELECT product_name
FROM northwind.products
WHERE unit_price <= (SELECT AVG(unit_price) 
                     FROM northwind.products);

-- 18. Display the order IDs and for each of them - its total cost, considering all the products included in the order and their quantities, 
-- but without considering the discount. Do not round the resulting values.
SELECT order_id, 
       SUM(quantity*unit_price) AS order_total
FROM northwind.order_details
GROUP BY order_id;

-- 19. Display the order IDs and for each of them - the total order cost, considering all ordered products and their quantities, and taking into account the discount. 
-- Round the resulting values to the nearest whole number. Sort the output by ascending order IDs.
SELECT order_id, 
       ROUND(SUM(unit_price*quantity*(1-discount))) AS order_total_with_discount
FROM northwind.order_details
GROUP BY order_id
ORDER BY 1; 

-- 20. Display information about each product:
-- its identifier from the products table;
-- its name from the products table;
-- the name of its category from the categories table;
-- the description of its category from the categories table.
-- Sort the table by ascending product identifiers.
SELECT pr.product_id, 
       pr.product_name,
       cat.category_name, 
       cat.description
FROM northwind.products pr
INNER JOIN northwind.categories cat ON pr.category_id = cat.category_id
ORDER BY 1;

-- 21. For each month of each year, count the unique users who placed at least one order in that month. 
SELECT DATE_TRUNC('MONTH', order_date)::DATE,
       COUNT(DISTINCT customer_id) AS unique_users
FROM northwind.orders
GROUP BY DATE_TRUNC('MONTH', order_date)::DATE;

-- 22. For each year from the orders table, calculate the total sales revenue for that year. Use detailed order information. 
-- Don't forget to consider the discount (field discount) on the product. Sort the results by descending revenue values.
SELECT EXTRACT(YEAR FROM ord.order_date::DATE), 
       SUM(det.unit_price * det.quantity * (1 - det.discount)) AS total_price
FROM northwind.orders ord 
INNER JOIN northwind.order_details det ON ord.order_id = det.order_id
GROUP BY 1
ORDER BY 2 DESC;

-- 23. Display the names of customer companies that made at least two orders in 1996. 
-- Sort the output by the company names field in ascending lexicographic order.
SELECT cus.company_name
FROM northwind.customers cus 
INNER JOIN northwind.orders ord ON cus.customer_id = ord.customer_id
WHERE EXTRACT(YEAR FROM ord.order_date::DATE) = '1996'
GROUP BY 1
HAVING COUNT(cus.company_name) > 1
ORDER BY 1;

-- 24. Display the names of customer companies that made more than five orders in 1997. 
-- Sort the output by the company names field in descending lexicographic order.
SELECT cus.company_name
FROM northwind.customers cus 
INNER JOIN northwind.orders ord ON cus.customer_id = ord.customer_id
WHERE EXTRACT(YEAR FROM ord.order_date::DATE) = '1997'
GROUP BY 1
HAVING COUNT(cus.company_name) > 5
ORDER BY 1 DESC;

-- 25. Display the average number of orders for customer companies for the period from January 1 to July 1, 1998. 
-- Round the average to the nearest whole number. In the calculations, consider only those companies that made more than seven purchases in total, 
-- not just for the specified period.
SELECT ROUND(AVG(cnt))
FROM (SELECT customer_id, COUNT(customer_id) AS cnt
      FROM northwind.orders
      WHERE order_date BETWEEN '1998-01-01' AND '1998-07-02'
      AND customer_id IN (SELECT customer_id
                          FROM northwind.orders
                          GROUP BY 1
                          HAVING COUNT(customer_id) > 7)
      GROUP BY 1) tmp;

-- 26. Display the names of customer companies that placed more than one order per day at least once. 
-- To count orders, use the order_date field. Sort the company names in ascending lexicographic order.
SELECT company_name
FROM northwind.customers
WHERE customer_id IN (SELECT customer_id
                      FROM northwind.orders
                      GROUP BY 1, 
                               DATE_TRUNC('DAY', order_date)::DATE
                      HAVING COUNT(customer_id) > 1)
ORDER BY 1;

-- 27. Display the cities to which orders were shipped at least 10 times. Sort the city names in descending lexicographic order.
SELECT ship_city 
FROM northwind.orders
GROUP BY 1
HAVING COUNT(ship_city) >= 10
ORDER BY 1 DESC;

-- 28. Display the cities to which orders were shipped no more than 12 times. Sort the city names in ascending lexicographic order.
SELECT ship_city
FROM northwind.orders
GROUP BY ship_city
HAVING COUNT(ship_city) <= 12
ORDER BY 1;

-- 29. How did the number of orders at Northwind change monthly by percentage from April 1 to December 1, 1997? 
-- Display a table with the following fields:
-- month number;
-- number of orders per month;
-- percentage showing how much the number of orders changed in the current month compared to the previous one.
-- If the number of orders decreased, the percentage value should be negative; if increased - positive. 
-- Round the percentage value to two decimal places. Sort the table by ascending month value.
SELECT *,
       ROUND((orders_count::NUMERIC / LAG(orders_count) OVER (ORDER BY creation_month) -1) * 100, 2) AS percentage
FROM (SELECT EXTRACT(MONTH FROM order_date) AS creation_month,
             COUNT(order_id) AS orders_count
      FROM northwind.orders
      WHERE order_date BETWEEN '1997-04-01' AND '1997-12-01'
      GROUP BY 1) tmp
ORDER BY creation_month;

-- 30. How did the number of orders at Northwind change annually by percentage from 1996 to 1998? Display a table with the following fields:
-- Year number.
-- Number of orders per year.
-- Percentage, rounded to a whole number, showing how much the number of orders changed in the current year compared to the previous one. 
-- For 1996, display NULL.
SELECT *,
       ROUND((orders_count:: NUMERIC / LAG(orders_count) OVER (ORDER BY creation_year) -1) *100) AS percentage
FROM (SELECT EXTRACT(YEAR FROM order_date) AS creation_year,
             COUNT(order_id) AS orders_count
      FROM northwind.orders
      WHERE order_date BETWEEN '1996-01-01' AND '1998-12-31'
      GROUP BY 1) tmp;

-- 31. Calculate a weekly Retention Rate analog for customer companies. Group companies into cohorts by the week of their first order (order_date field).
-- Determine the return by the presence of an order during the current week.
-- Before extracting the week from the date, convert the values to the timestamp type. Round the Retention Rate value to two decimal places.
WITH profiles AS (SELECT customer_id,
                  DATE_TRUNC('WEEK', MIN(order_date)::TIMESTAMP) AS cohort_dt,
                  COUNT(customer_id) OVER (PARTITION BY DATE_TRUNC('WEEK', MIN(order_date)):: DATE) AS cohort_users_cnt
                  FROM northwind.orders
                  GROUP BY customer_id),
     purchases AS (SELECT DISTINCT customer_id,
                   DATE_TRUNC('WEEK', order_date::TIMESTAMP) AS purchase_date
                   FROM northwind.orders
                   GROUP BY 1, 2)
SELECT cohort_dt, 
       purchase_date, 
       COUNT(p.customer_id) AS users_cnt,
       cohort_users_cnt,
       ROUND(COUNT(p.customer_id) * 100.0 / cohort_users_cnt, 2) AS retention_rate
FROM profiles p
INNER JOIN purchases pur ON p.customer_id = pur.customer_id
GROUP BY 1, 2, 4
ORDER BY cohort_dt, 
         purchase_date;

-- 32. Calculate a monthly Retention Rate analog for customer companies. Group companies into cohorts by the month of their first order (order_date field). 
-- Determine the return by the presence of an order in the current month.
-- Before extracting the week from the date, convert the values to the timestamp type. Round the Retention Rate value to two decimal places.
WITH profiles AS (SELECT customer_id,
						 DATE_TRUNC('MONTH', MIN(order_date)::TIMESTAMP) AS cohort_dt,
						 COUNT(customer_id) OVER (PARTITION BY DATE_TRUNC('MONTH', MIN(order_date)):: DATE) AS cohort_users_cnt
                  FROM northwind.orders
                  GROUP BY customer_id),
	 purchases AS (SELECT DISTINCT customer_id,
								   DATE_TRUNC('MONTH', order_date::TIMESTAMP) AS purchase_date
				   FROM northwind.orders
				   GROUP BY 1, 2)
SELECT cohort_dt, 
	   purchase_date, 
	   COUNT(p.customer_id) AS users_cnt,
	   cohort_users_cnt,
	   ROUND(COUNT(p.customer_id) * 100.0 / cohort_users_cnt, 2) AS retention_rate
FROM profiles p
INNER JOIN purchases pur ON p.customer_id = pur.customer_id
GROUP BY 1, 2, 4
ORDER BY cohort_dt, 
         purchase_date;

-- 33. Calculate a monthly Retention Rate analog for customer companies. Group companies into cohorts by the month of their first order (order_date field). 
-- Determine the return by the presence of an order in the current month.
-- Before extracting the week from the date, convert the values to the timestamp type. Round the Retention Rate value to two decimal places.
WITH profiles AS (SELECT customer_id,
					     DATE_TRUNC('YEAR', MIN(order_date)::TIMESTAMP) AS cohort_dt,
						 COUNT(customer_id) OVER (PARTITION BY DATE_TRUNC('YEAR', MIN(order_date)):: DATE) AS cohort_users_cnt
                  FROM northwind.orders
                  GROUP BY customer_id),
	 purchases AS (SELECT DISTINCT customer_id,
                                   DATE_TRUNC('YEAR', order_date::TIMESTAMP) AS purchase_date
				   FROM northwind.orders
				   GROUP BY 1, 2)
SELECT cohort_dt, 
       purchase_date,
       COUNT(p.customer_id) AS users_cnt,
       cohort_users_cnt,
       ROUND(COUNT(p.customer_id) * 100.0 / cohort_users_cnt, 2) AS retention_rate
FROM profiles p
INNER JOIN purchases pur ON p.customer_id = pur.customer_id
GROUP BY 1, 2, 4
ORDER BY cohort_dt, 
         purchase_date;

-- 34. For each company that has placed at least two orders, display:
-- the date of the second order placement (order_date field), rounded to the month;
-- the identifier of the company that placed the order (customer_id field).
-- Sort the rows by the value in the field with identifiers in lexicographic order in descending order.
SELECT DISTINCT customer_id,
       DATE_TRUNC('MONTH', NTH_VALUE(order_date, 2) OVER(PARTITION BY customer_id 
                                                         ORDER BY order_date ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING))::DATE AS order_date
FROM northwind.orders
WHERE customer_id IN (SELECT customer_id                        
                      FROM northwind.orders
                      GROUP BY 1
                      HAVING COUNT(*) >= 2)
ORDER BY customer_id DESC;

-- 35. For each month from July 1996 to May 1998, calculate the conversion rate in percentages. Find the number of unique customer companies in the current month. 
-- Divide it by the total number of Northwind customer companies that have placed at least one order during all previous time, including the current month. 
-- Uniqueness of the company in this task means the absence of duplicates in the sample.
-- The final table should have the following fields:
-- the date of the first day of the current month;
-- the number of customer companies in the current month;
-- the total number of customer companies for all previous time, including the current month;
-- the ratio of the number of customers for the current month to the total number of customers.
WITH enumerate_users AS (SELECT DATE_TRUNC('month', order_date)::date AS first_purchase,
                                customer_id,
                                ROW_NUMBER() OVER (PARTITION BY customer_id) AS rows_num
                         FROM northwind.orders),
     total_customers AS (SELECT DATE_TRUNC('month', order_date)::date AS month,
                                COUNT(DISTINCT customer_id) AS customers_this_month
                         FROM northwind.orders
                         GROUP BY month
                         ORDER BY month)
SELECT month,
       customers_this_month,
       (SELECT COUNT(DISTINCT customer_id)
        FROM enumerate_users
        WHERE first_purchase <= month) AS total_customers,
       ROUND((customers_this_month::real /
                (SELECT COUNT(DISTINCT customer_id)
                 FROM enumerate_users
                 WHERE first_purchase <= month) * 100)::numeric, 2) AS conversion
FROM total_customers;