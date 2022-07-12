--- 1. How many companies have been closed?
SELECT COUNT(id)
FROM company
WHERE STATUS = 'closed';

--- 2. Display the amount of funds raised for US news companies. Use the data from the "company" table. 
---    Order the table by descending values in the funding_total field.
SELECT funding_total
FROM company
WHERE country_code = 'USA' AND category_code = 'news'
ORDER BY funding_total DESC;

--- 3. Find the total amount of purchase transactions ((dollars). 
---    Select transactions that were executed in cash only between 2011 and 2013 inclusively.
SELECT SUM(price_amount)
FROM acquisition
WHERE acquired_at BETWEEN '01-01-2011' AND '31-12-2013' AND term_code = 'cash';

--- 4. Display the name, surname, and account name of people on Twitter whose account name begins with 'Silver'.
SELECT first_name, last_name, twitter_username
FROM people
WHERE twitter_username LIKE 'Silver%';

--- 5. Display all the information about people whose Twitter account name contains a 'money' substring, 
---    and the last name begins with a 'K'.
SELECT *
FROM people
WHERE twitter_username LIKE '%money%' AND last_name LIKE 'K%';

--- 6. For each country, display the total amount of attracted investments received by companies registered 
---    in that country. The country of registration may be defined by country code. 
---    Sort the data by descending amount of investments.
SELECT country_code, SUM(funding_total)
FROM company
GROUP BY country_code
ORDER BY SUM(funding_total) DESC;

--- 7. Create a table that includes the date of the round and the minimum and maximum values for the amount 
---    of investments attracted at that date. Leave only those records where the minimum value of the investment 
---    is not equal to zero and is not equal to the maximum value.
SELECT funded_at, MAX(raised_amount), MIN(raised_amount)
FROM funding_round
GROUP BY funded_at
HAVING MIN(raised_amount) <> 0 AND MAX(raised_amount) != MIN(raised_amount);

--- 8. Create a field with categories:
---    For funds investing in 100 or more companies, assign a 'high_activity' category.
---    For funds that investing in 20 or more companies up to 100, assign a 'middle_activity' category.
---    If the number of companies is less than 20, assign a 'low_activity' category.
---    Display all fields of the 'fund' table and a new field with categories.
SELECT *,
    CASE
    WHEN invested_companies >= 100 THEN 'high_activity'
    WHEN invested_companies BETWEEN 20 AND 99 THEN 'middle_activity'
    WHEN invested_companies < 20 THEN 'low_activity'
    END
    FROM fund;
    
--- 9. For each of the categories assigned in the previous task, count the average number of investment rounds in 
---    which the fund participated, rounded to the nearest whole number. Display the categories and the average number 
---    of investment rounds. Sort the table by the average in ascending order.
SELECT
       CASE
           WHEN invested_companies>=100 THEN 'high_activity'
           WHEN invested_companies>=20 THEN 'middle_activity'
           ELSE 'low_activity'
       END AS activity,
       ROUND(AVG(investment_rounds)) AS average
FROM fund
GROUP BY CASE
           WHEN invested_companies>=100 THEN 'high_activity'
           WHEN invested_companies>=20 THEN 'middle_activity'
           ELSE 'low_activity'
       END
ORDER BY average;

--- 10. Create the table with the ten most active investing countries. Determine the activity of the country by 
---     the average number of companies in which the funds are invested in this country. For each country, calculate 
---     the minimum, maximum and average number of companies to which the funds, founded from 2010 to 2012 inclusive, have invested.
---     Remove from the table countries with funds whose minimum number is zero. Sort the table by the average number of companies in descending order.
SELECT country_code, 
       MIN(invested_companies),
       MAX(invested_companies),
       AVG(invested_companies)
FROM fund
WHERE EXTRACT(YEAR FROM CAST(founded_at AS DATE)) BETWEEN '2010' AND '2012'
GROUP BY country_code
HAVING MIN(invested_companies) != 0
ORDER BY AVG(invested_companies) DESC
LIMIT 10;

--- 11. Display the first and last name of all startup employees. Add a field with the name of the educational institution 
--- the employee graduated from, if known.
SELECT p.first_name, p.last_name, e.instituition
FROM people p
LEFT JOIN education e ON p.id = e.person_id;

--- 12. For each company, find out how many educational institutions its employees have graduated from. Select the name of the 
--- company and the number of unique names of educational institutions. Make up the top 5 companies by this number.
SELECT c.name, COUNT(DISTINCT e.instituition) AS e
FROM company c
INNER JOIN people ON c.id = people.company_id
INNER JOIN education e ON people.id = e.person_id
GROUP BY c.name
ORDER BY e DESC
LIMIT 5;

--- 13. Make a table with unique names of closed companies for which the first round of funding was the last.
SELECT name
FROM company
WHERE status = 'closed' AND
id IN (SELECT company_id
      FROM funding_round
      WHERE is_first_round = is_last_round AND is_first_round = 1);
      
--- 14. Make a list of unique employee numbers that work in companies selected in the previous task.
SELECT id
FROM people 
WHERE company_id IN (SELECT company_id
     FROM funding_round
     WHERE is_first_round = is_last_round
       AND is_first_round = 1)
AND company_id IN (SELECT id FROM company WHERE status = 'closed');

--- 15. Make a table that includes unique pairs: the numbers of employees from the previous task and the 
---     educational institution where they graduated.
SELECT DISTINCT person_id, instituition
FROM education 
WHERE person_id IN (SELECT id
FROM people
WHERE company_id IN
    (SELECT company_id
     FROM funding_round
     WHERE is_first_round = is_last_round
       AND is_first_round = 1)
  AND company_id IN
    (SELECT id
     FROM company
     WHERE status = 'closed'));
     
--- 16. Count the number of educational institutions for each employee from the previous task.
SELECT person_id,
                COUNT(instituition)
FROM education
WHERE person_id IN
    (SELECT id
     FROM people
     WHERE company_id IN
         (SELECT company_id
          FROM funding_round
          WHERE is_first_round = is_last_round
            AND is_first_round = 1)
       AND company_id IN
         (SELECT id
          FROM company
          WHERE status = 'closed'))
GROUP BY person_id;

--- 17. In addition to the previous query select the average number of educational institutions 
---     (not only unique) that have graduated employees of different companies. Only one record is needed. 
SELECT SUM(a.count) / COUNT(a.person_id)
FROM (SELECT person_id,
                COUNT(instituition)
FROM education
WHERE person_id IN
    (SELECT id
     FROM people
     WHERE company_id IN
         (SELECT company_id
          FROM funding_round
          WHERE is_first_round = is_last_round
            AND is_first_round = 1)
       AND company_id IN
         (SELECT id
          FROM company
          WHERE status = 'closed'))
GROUP BY person_id) AS a;

--- 18. Display the average number of educational institutions (not only unique) that Facebook employees have graduated from.
SELECT SUM(a.count) / COUNT(a.person_id)
FROM
  (SELECT person_id,
          COUNT(instituition)
   FROM education
   WHERE person_id IN
       (SELECT id
        FROM people
        WHERE company_id IN
            (SELECT id
             FROM company
             WHERE name = 'Facebook'))
   GROUP BY person_id) AS a;
   
--- 19. Create a table with the following fields: name_of_fund, name_of_company, amount - the amount of investment
---     the company attracted in the round. The table will include information on companies with more than six 
---     milestones and funding rounds from 2012 to 2013 inclusive.
SELECT f.name AS name_of_fund, c.name AS name_of_company, fr.raised_amount AS amount
FROM fund f
LEFT JOIN investment i ON f.id = i.fund_id
LEFT JOIN funding_round fr ON i.funding_round_id = fr.id
LEFT JOIN company c ON fr.company_id = c.id
WHERE c.milestones > 6 AND
      EXTRACT(YEAR FROM CAST (fr.funded_at AS DATE)) BETWEEN '2012' AND '2013';
      
--- 20. Create a table the with the following fields: name of the company-buyer, amount of the transaction, 
---     the name of the bought company, amount of funds invested in the that company,  a percentage that shows how much 
---     the purchase exceeded the investments, rounded to the nearest integer. Ignore transactions that have 
---     a zero purchase amount. If there is no investment in the company, remove the company from the table. 
---     Sort the table by the sum of the transaction in descending order, and then by the name of the company bought alphabetically. 
---     Limit the table to the first ten records.
SELECT c1.name, a.price_amount, c2.name, c2.funding_total, ROUND(a.price_amount / c2.funding_total)
FROM acquisition a
LEFT JOIN company c1 ON a.acquiring_company_id = c1.id
LEFT JOIN company c2 ON a.acquired_company_id = c2.id
WHERE a.price_amount != 0 AND c2.funding_total != 0 
ORDER BY a.price_amount DESC
LIMIT 10;

--- 21. Create the table, which will include the names of the companies in the social category who received funding 
---     from 2010 to 2013 inclusive. Print also the month number of the funding round.
SELECT c.name, EXTRACT(MONTH FROM CAST(fr.funded_at AS DATE))
FROM company c
INNER JOIN funding_round fr ON fr.company_id = c.id
WHERE c.category_code = 'social' AND
      EXTRACT(YEAR FROM CAST(fr.funded_at AS DATE)) BETWEEN '2010' AND '2013';
      
--- 22. Select the data for the months of 2010 to 2013, when the investment rounds occurred. Group the data by month 
---     number and create a table with the fields: the number of the month the rounds were occured, the number of unique 
---     names of funds from the USA that invested this month, number of companies purchased during the month, the total value 
---     of transactions in this month.
WITH b AS (SELECT COUNT(DISTINCT i.fund_id) AS fund, EXTRACT(MONTH FROM CAST(fr.funded_at AS DATE)) AS month
FROM investment i
INNER JOIN funding_round fr ON fr.id = i.funding_round_id
WHERE EXTRACT(YEAR FROM CAST(fr.funded_at AS DATE)) BETWEEN '2010' AND '2013'
AND i.fund_id IN (SELECT id FROM fund WHERE country_code = 'USA')
GROUP BY EXTRACT(MONTH FROM CAST(fr.funded_at AS DATE))),
a AS (SELECT COUNT(acquired_company_id) AS com, EXTRACT(MONTH FROM CAST(acquired_at AS DATE)) AS month
FROM acquisition
WHERE EXTRACT(YEAR FROM CAST(acquired_at AS DATE)) BETWEEN '2010' AND '2013'
GROUP BY EXTRACT(MONTH FROM CAST(acquired_at AS DATE))),
c AS (SELECT SUM(price_amount) AS sum, EXTRACT(MONTH FROM CAST(acquired_at AS DATE)) AS month
FROM acquisition
WHERE EXTRACT(YEAR FROM CAST(acquired_at AS DATE)) BETWEEN '2010' AND '2013'
GROUP BY EXTRACT(MONTH FROM CAST(acquired_at AS DATE)))
SELECT a.month,
       b.fund,
       a.com,
       c.sum
FROM a
INNER JOIN b ON a.month = b.month
INNER JOIN c ON a.month = c.month;

--- 23. Make a pivot table and print the average investment amount for countries with startups registered in 2011, 2012 and 2013. 
--- The annual data should be in a separate field. Sort the table by descending amount of investments.
WITH a AS (SELECT country_code, AVG(funding_total) AS avg_2011
FROM company
WHERE EXTRACT(YEAR FROM CAST(founded_at AS DATE)) = '2011'
GROUP BY country_code),
b AS (SELECT country_code, AVG(funding_total) AS avg_2012
FROM company
WHERE EXTRACT(YEAR FROM CAST(founded_at AS DATE)) = '2012'
GROUP BY country_code),
c AS (SELECT country_code, AVG(funding_total) AS avg_2013
FROM company
WHERE EXTRACT(YEAR FROM CAST(founded_at AS DATE)) = '2013'
GROUP BY country_code)
SELECT a.country_code,
       a.avg_2011,
       b.avg_2012,
       c.avg_2013
FROM a
INNER JOIN b ON a.country_code = b.country_code
INNER JOIN c ON a.country_code = c.country_code
WHERE a.country_code IN (SELECT DISTINCT country_code
FROM company
WHERE EXTRACT(YEAR FROM CAST(founded_at AS DATE)) BETWEEN '2011' AND '2013')
ORDER BY a.avg_2011 DESC;
