-- 1. Output all information about the products in the general-purpose product line (T).
SELECT * 
FROM adventure.product
WHERE product_line = 'T';

-- 2. Output all information about the products in the general-purpose product line (S).
SELECT * 
FROM adventure.product
WHERE product_line = 'S';

-- 3. Output a list of unique job titles in the Adventure Works Cycle company. Sort the list in lexicographic order in ascending order.
SELECT DISTINCT job_title
FROM adventure.employee
ORDER BY 1;

-- 4. Output a list of unique cities from the address table. Sort the list in lexicographic order in descending order.
SELECT DISTINCT city
FROM adventure.address
ORDER BY 1 DESC;

-- 5. Output the number of products for each style (W - women's, M - men's, U - unisex). Exclude records where the style is not specified, i.e., where the value is NULL. 
-- Sort the output in descending order by the number of products.
SELECT style, 
	   COUNT(*)
FROM adventure.product
WHERE style = style
GROUP BY 1
ORDER BY 2 DESC;

-- 6. Output the average cost of goods for each class (L - economy, M - standard, H - premium). Round the cost value to one decimal place. 
-- Exclude rows where the product class is not specified, i.e., where the value is NULL. 
-- Sort the output in ascending order by the average cost.
SELECT class, 
	   ROUND(AVG(standard_cost), 1) AS avg_cost
FROM adventure.product
WHERE class = class
GROUP BY 1
ORDER BY 2;

-- 7. Select the items that are silver and started selling from 2011 onwards. Output their IDs and the start dates of sales in the timestamp format.
SELECT product_id, 
	   sell_start_date
FROM adventure.product
WHERE color = 'Silver' AND 
	  sell_start_date > '2011-01-01';

-- 8. Select the items that are red and started selling from 2012 onwards. Output their IDs and the start dates of sales in the timestamp format.
SELECT product_id, 
	   sell_start_date
FROM adventure.product
WHERE color = 'Red' AND 
	  sell_start_date > '2012-01-01';

-- 9. Output the company name and city for each supplier. Sort the table in lexicographic order by company name in ascending order.
SELECT name, 
	   city
FROM adventure.vendor
INNER JOIN adventure.vendor_address ON vendor.vendor_id = vendor_address.vendor_id
INNER JOIN adventure.address ON vendor_address.address_id = address.address_id
ORDER BY 1;

-- 10. Output all information about orders from the purchase_order_header table placed between 2012 and 2013 (in the order_date field). 
-- Sort the output in ascending order by order ID.
SELECT *
FROM adventure.purchase_order_header
WHERE order_date BETWEEN '2012-01-01' AND '2013-12-31'
ORDER BY purchase_order_id;

-- 11. Output the average number of available vacation hours for employees in different marital statuses. Round the average to two decimal places. 
-- Sort the table in ascending order by the calculated average values.
SELECT marital_status, 
	   ROUND(AVG(vacation_hours), 2) AS avg_vacation_hours
FROM adventure.employee
GROUP BY 1
ORDER BY 2;

-- 12. For each month from May to August 2012, find the number of orders placed. Output the first day of each month and the number of orders placed in that month. 
-- Sort the results in ascending order by the date.
SELECT DATE_TRUNC('MONTH', order_date)::DATE, 
	   COUNT(purchase_order_id) AS total 
FROM adventure.purchase_order_header
WHERE order_date BETWEEN '2012-05-01' AND '2012-09-01'
GROUP BY 1
ORDER BY 1;

-- 13. From the purchase_order_header table, output the order ID and shipping date for the orders with the lowest shipping cost (in the ship_base field).
-- Sort the results in ascending order by the shipping date. Use subqueries.
SELECT purchase_order_id, ship_date
FROM adventure.purchase_order_header pr
INNER JOIN adventure.ship_method s ON pr.ship_method_id = s.ship_method_id
WHERE ship_base = (SELECT MIN(ship_base) FROM adventure.ship_method)
ORDER BY ship_date;

-- 14. Select the orders whose shipping cost (in the ship_base field) was not the lowest or the highest.
--  Output the order ID and shipping date for the selected orders from the purchase_order_header table.
--  Sort the results in ascending order by the shipping date. Use subqueries.
SELECT purchase_order_id, 
	   ship_date
FROM adventure.purchase_order_header pr
INNER JOIN adventure.ship_method s ON pr.ship_method_id = s.ship_method_id
WHERE ship_base != (SELECT MIN(ship_base) 
					FROM adventure.ship_method) AND 
	  ship_base != (SELECT MAX(ship_base) 
	  				FROM adventure.ship_method)
ORDER BY ship_date;

-- 15. Output the order IDs from the purchase_order_header table with the maximum interval in days between the order date and the shipping date.
SELECT purchase_order_id
FROM adventure.purchase_order_header
GROUP BY 1
HAVING (ship_date - order_date) = (SELECT MAX(ship_date - order_date) 
								   FROM adventure.purchase_order_header);

-- 16. Select the rejected orders from the purchase_order_header table and calculate the total cost of each of them. To find the order total, use the unit price of the item (in the unit_price field) and the quantity of items in the order (in the order_qty field).
--  Use the INNER JOIN operator to join the table. Round the total values to two decimal places. 
-- Sort the results in ascending order by order total. Orders with the same total should be sorted in ascending order by order ID.
SELECT od.purchase_order_id,
       ROUND(SUM(od.unit_price * order_qty), 2) AS total
FROM adventure.purchase_order_header oh
INNER JOIN adventure.purchase_order_detail od ON oh.purchase_order_id = od.purchase_order_id
WHERE status = 3
GROUP BY od.purchase_order_id
ORDER BY total;

-- 17. Output the names of the supplier companies and the full addresses of their websites if the website ends with .com/. Companies with other addresses should not appear in the results.
-- Sort the resulting table by supplier name in lexicographic order in ascending order.
SELECT name, 
	   purchasing_web_service_url
FROM adventure.vendor
WHERE purchasing_web_service_url LIKE '%.com/'
ORDER BY 1;

-- 18. Output the names of the supplier companies and the cities where each company is located. Display information about companies with website addresses that end in .com/. 
-- Sort the resulting table by supplier name in lexicographic order in descending order.
SELECT name, 
	   city
FROM adventure.vendor
INNER JOIN adventure.vendor_address ON vendor.vendor_id = vendor_address.vendor_id
INNER JOIN adventure.address ON vendor_address.address_id = address.address_id
WHERE purchasing_web_service_url LIKE '%.com/'
ORDER BY 1 DESC;

-- 19. Select the suppliers with a credit rating above 3 who are still in use. Output the company name and the street (in the addressline1 field) on which the company is located. 
-- Sort the results in alphabetical order by company name in ascending order.
SELECT name, 
	   addressline1
FROM adventure.vendor
INNER JOIN adventure.vendor_address ON vendor.vendor_id = vendor_address.vendor_id
INNER JOIN adventure.address ON vendor_address.address_id = address.address_id
WHERE vendor.credit_rating > 3 AND 
	  vendor.is_active = True
ORDER BY 1;

-- 20. From the purchase_order_header table, output several fields:
-- the order ID;
-- the ID of the employee who placed the order;
-- the order date (in the order_date field).
-- Add a field with the date of the previous order that was placed by the same employee. If there is no previous order, use the value NULL.
SELECT purchase_order_id,
       employee_id,
       order_date,
       LAG(order_date) OVER(PARTITION BY employee_id ORDER BY order_date) AS previous_order
FROM adventure.purchase_order_header;

-- 21. From the purchase_order_header table, output the order IDs with the maximum interval between the current and the previous orders that were placed by the same employee.
WITH temp AS (SELECT purchase_order_id,
          			 employee_id,
          			 order_date - LAG(order_date, 1) OVER (PARTITION BY employee_id ORDER BY order_date) AS previous_order
   			  FROM adventure.purchase_order_header)
SELECT purchase_order_id
FROM temp
WHERE previous_order = (SELECT MAX(previous_order)
     					FROM temp);

-- 22. Write a query that outputs the order IDs and dates (in the order_date field) from the purchase_order_header table. 
-- Add a separate field that displays the total cost of orders for the current month. You can take the order cost from the subtotal field.
SELECT purchase_order_id,
       order_date,
       SUM(subtotal) OVER (PARTITION BY DATE_TRUNC('MONTH', order_date)) AS total
FROM adventure.purchase_order_header;

-- 23. From the purchase_order_header table, output several fields:
-- employee ID;
-- the ID of the tenth order that the employee placed;
-- the order date of the tenth order that the employee placed (in the order_date field).
-- Sort the table in ascending order by employee IDs.
SELECT DISTINCT employee_id,
       NTH_VALUE(purchase_order_id, 10) OVER (PARTITION BY employee_id ORDER BY order_date ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS purchase_order_id,
       NTH_VALUE(order_date, 10) OVER (PARTITION BY employee_id ORDER BY order_date ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS order_date
FROM adventure.purchase_order_header
ORDER BY 1;

-- 24. From the purchase_order_header table, output several fields:
-- employee ID;
-- the ID of the second order that the employee placed;
-- the order date of the second order that the employee placed (in the order_date field).
-- Sort the table in ascending order by employee IDs.
SELECT DISTINCT employee_id,
       NTH_VALUE(purchase_order_id, 2) OVER (PARTITION BY employee_id ORDER BY order_date ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS purchase_order_id,
       NTH_VALUE(order_date, 2) OVER (PARTITION BY employee_id ORDER BY order_date ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS order_date
FROM adventure.purchase_order_header
ORDER BY 1;

-- 25. Using the purchase_order_header table, output several fields:
-- the employee ID employee_id;
-- the order date order_date;
-- the order total subtotal;
-- the order total with accumulation for each employee, sorted in ascending order by the order date.
-- Round the last two fields to two decimal places.
SELECT employee_id,
       order_date,
       ROUND(subtotal, 2),
       ROUND(SUM(subtotal) OVER (PARTITION BY employee_id ORDER BY order_date), 2) AS order_date
FROM adventure.purchase_order_header
ORDER BY 1;

-- 26. Using the purchase_order_header table, output several fields:
-- the order date (in the order_date field), truncated to the first day of the month and converted to the date type;
-- the total order amount subtotal;
-- the order amount with accumulation by months, sorted in ascending order by the month of the order date.
-- Do not round the values.
SELECT DATE_TRUNC('MONTH', order_date)::DATE AS month_date,
       subtotal,
       SUM(subtotal) OVER (ORDER BY DATE_TRUNC('MONTH', order_date)::DATE) AS cum_sum
FROM adventure.purchase_order_header;

-- 27. Using the purchase_order_header table, output the fields with the order ID, order total (in the subtotal field), 
-- and the minimum value of the subtotal among the current and the following twenty records. Round the last two fields to one decimal place.
SELECT purchase_order_id,
       ROUND(subtotal, 1),
       ROUND(MIN(subtotal) OVER (ORDER BY purchase_order_id ROWS BETWEEN CURRENT ROW AND 20 FOLLOWING), 1) AS min_subtotal
FROM adventure.purchase_order_header;

-- 28. Using the purchase_order_header table, output the fields with the order ID, order total (in the subtotal field),
--  and the maximum value of the subtotal among the current and the previous five records. Do not round the values.
SELECT purchase_order_id,
       subtotal,
       MAX(subtotal) OVER (ORDER BY purchase_order_id ROWS BETWEEN 5 PRECEDING AND CURRENT ROW) AS max_subtotal
FROM adventure.purchase_order_header;

-- 29. Output the identifiers and names of products that are silver in color and belong to the category of mountain bikes. 
-- Sort the output in ascending order by product identifiers.
SELECT product_id, 
	   name
FROM adventure.product
WHERE UPPER(color) = 'SILVER' AND 
	  name LIKE 'Mountain%'
ORDER BY 1;

-- 30. Output the identifiers and names of products that are red in color and belong to the category of road bikes. 
-- Sort the output in ascending order by product identifiers.
SELECT product_id, 
	   name
FROM adventure.product
WHERE UPPER(color) = 'RED' AND 
	  name LIKE 'Road%'
ORDER BY 1;

-- 31. Using the purchase_order_header table, calculate how much customers spent on orders in each month of 2012. 
-- The resulting table should include two fields: the name of the month (in uppercase) and the total spending for the month, rounded to two decimal places. 
-- Sort the results in descending order by spending.
SELECT 
  CASE 
    WHEN EXTRACT(MONTH FROM ORDER_DATE) = 1 THEN 'JANUARY'
    WHEN EXTRACT(MONTH FROM ORDER_DATE) = 2 THEN 'FEBRUARY'
    WHEN EXTRACT(MONTH FROM ORDER_DATE) = 3 THEN 'MARCH'
    WHEN EXTRACT(MONTH FROM ORDER_DATE) = 4 THEN 'APRIL'
    WHEN EXTRACT(MONTH FROM ORDER_DATE) = 5 THEN 'MAY'
    WHEN EXTRACT(MONTH FROM ORDER_DATE) = 6 THEN 'JUNE'
    WHEN EXTRACT(MONTH FROM ORDER_DATE) = 7 THEN 'JULY'
    WHEN EXTRACT(MONTH FROM ORDER_DATE) = 8 THEN 'AUGUST'
    WHEN EXTRACT(MONTH FROM ORDER_DATE) = 9 THEN 'SEPTEMBER'
    WHEN EXTRACT(MONTH FROM ORDER_DATE) = 10 THEN 'OCTOBER'
    WHEN EXTRACT(MONTH FROM ORDER_DATE) = 11 THEN 'NOVEMBER'
    WHEN EXTRACT(MONTH FROM ORDER_DATE) = 12 THEN 'DECEMBER'
  END mnth, 
  ROUND(SUM(subtotal), 2)
FROM adventure.purchase_order_header
WHERE EXTRACT(YEAR FROM order_date) = 2012
GROUP BY 1
ORDER BY 2 DESC;

-- 32. Using the purchase_order_header table, calculate how much customers spent (in the subtotal field) on orders in each quarter of 2012. 
-- The resulting table should include two fields: the name of the quarter (e.g. "first quarter," "second quarter," etc.) and the total spending for the quarter, rounded to two decimal places.
-- Sort the results in ascending order by spending. 
WITH tmp AS (SELECT EXTRACT ('QUARTER' FROM order_date) AS quarter,
			 	    ROUND(SUM(subtotal), 2) AS total
			 FROM adventure.purchase_order_header
			 WHERE order_date BETWEEN '2012-01-01' AND '2012-12-31'
			 GROUP BY 1
			 ORDER BY 2)
SELECT total,
	   CASE WHEN quarter = 1 THEN 'first quarter'
			WHEN quarter = 2 THEN 'second quarter'
			WHEN quarter = 3 THEN 'third quarter'
			WHEN quarter = 4 THEN 'fourth quarter'
	   END
FROM tmp;

-- 33. Using the purchase_order_header table, display three fields:
-- Quarter number (1, 2, 3, 4) of 2012.
-- Total spending for the current quarter.
-- A real number (positive or negative) that indicates the percentage change in spending in the current quarter compared to the previous one. For calculations, use the subtotal field.
-- Round the values of the last two fields to two decimal places.
WITH temp AS (SELECT EXTRACT ('QUARTER' FROM order_date) AS quarter,
					 ROUND(SUM(subtotal), 2) AS total
			  FROM adventure.purchase_order_header
			  WHERE order_date BETWEEN '2012-01-01' AND '2012-12-31'
			  GROUP BY 1
			  ORDER BY 1)
SELECT *,
       ROUND(((total::numeric / LAG(total) OVER ()) - 1) * 100, 2)
FROM temp;

-- 34. Using the purchase_order_detail table and a ranking window function, count the orders that had 3 or more items. Do not use the GROUP BY operator.
SELECT COUNT (*) 
FROM (SELECT RANK() OVER (PARTITION BY purchase_order_id ORDER BY purchase_order_detail_id) AS rnk
	  FROM adventure.purchase_order_detail) tmp
WHERE rnk = 3;

-- 35. Using the purchase_order_detail table and a ranking window function, count the orders that had 20 or more items priced at 37 dollars per unit (the unit_price field) or more expensive. 
-- Do not use the GROUP BY operator.
SELECT COUNT (*) 
FROM (SELECT unit_price, 
			 RANK() OVER (PARTITION BY purchase_order_id ORDER BY purchase_order_detail_id) AS rnk
	  FROM adventure.purchase_order_detail) tmp
WHERE rnk = 20 AND 
	  unit_price > 37;

-- 36. Using the purchase_order_header table, calculate how much money customers spent on orders each year, as well as the difference in spending between the following and current years. 
-- The difference should show how much the spending of the following year differs from the current one. If there is no data for the following year, use NULL.
-- Extract the following fields:
-- Order year (the order_date field), converted to date type;
-- Expenses for the current year (using the subtotal field);
-- The difference in spending between the following and current years.
WITH tmp AS (SELECT DATE_TRUNC ('YEAR', order_date):: DATE as yr,
					SUM(subtotal) AS year_expenditure
			 FROM adventure.purchase_order_header
			 GROUP BY 1
			 ORDER BY 1)
SELECT *,
       LEAD(year_expenditure) OVER () - year_expenditure AS diff
       FROM tmp;

-- 37. Select products that were last supplied in 2013 or later. Display the names of these products and the dates of their last deliveries. 
-- Sort the output in ascending order of dates.
SELECT last_receipt_date, 
	   name
FROM adventure.product_vendor
INNER JOIN adventure.product ON product_vendor.product_id = product.product_id
WHERE last_receipt_date >= '2013-01-01'
ORDER BY 1;

-- 38. Select products that were last supplied in 2012 or later. For the selected products, display:
-- Product name.
-- The total amount spent on ordering this product for all the time represented in the data. 
-- To calculate the expenses, use the unit_price and order_qty fields from the purchase_order_detail table.
-- Sort the results in ascending order of the total amount spent.
SELECT name, 
	   SUM(unit_price*order_qty) AS total
FROM adventure.product_vendor
INNER JOIN adventure.product ON product_vendor.product_id = product.product_id
INNER JOIN adventure.purchase_order_detail ON product_vendor.product_id = purchase_order_detail.product_id
WHERE last_receipt_date >= '2012-01-01'
GROUP BY 1
ORDER BY 2;
