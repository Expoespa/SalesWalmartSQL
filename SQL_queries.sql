-- Create Database
   CREATE DATABASE IF NOT EXISTS salesDataWalmart;
   
    
-- Create Table
	CREATE TABLE IF NOT EXISTS sales(
	invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
    branch VARCHAR(5) NOT NULL,
    city VARCHAR(30) NOT NULL,
    customer_type VARCHAR(30) NOT NULL,
    gender VARCHAR(30) NOT NULL,
    product_line VARCHAR(100) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    quantity INT NOT NULL,
    tax_pct FLOAT(6,4) NOT NULL,
    total DECIMAL(12, 4) NOT NULL,
    date DATETIME NOT NULL,
    time TIME NOT NULL,
    payment VARCHAR(15) NOT NULL,
    cogs DECIMAL(10,2) NOT NULL,
    gross_margin_pct FLOAT(11,9),
    gross_income DECIMAL(12, 4),
    rating FLOAT(2, 1)
);

-- ------------------------------------------------------------------------------
-- ------------------------------Feature Engineering ----------------------------
-- ------------------------------------------------------------------------------

-- time_of_day

-- ALTER TABLE sales ADD COLUMN  time_of_day VARCHAR(20);

UPDATE sales
SET time_of_day = (
	CASE
		WHEN HOUR(time) >= 6 AND HOUR(time) < 13 THEN 'Mañana'
		WHEN HOUR(time) >= 13 AND HOUR(time) < 18 THEN 'Tarde'
		ELSE 'Noche'
	END
);

-- day_name

-- ALTER TABLE sales ADD COLUMN  day_time VARCHAR(20);
UPDATE sales
SET day_time = (
	DAYNAME(date)
);


-- month_name

-- ALTER TABLE sales ADD COLUMN month_name VARCHAR(20);

UPDATE sales
SET month_name = (
	monthname(DATE)
);

-- ------------------------------------------------------------------------------
-- ------------------------Business Questions------------------------------------
-- ------------------------------------------------------------------------------

-- 1. Unique Cities

SELECT DISTINCT city
FROM sales;

-- 2. In which city is each branch?alter
SELECT DISTINCT branch,city
FROM sales;

-- ------------------------------------------------------------------------------
-- ------------------------Product Questions-------------------------------------
-- ------------------------------------------------------------------------------

-- 1.How many unique product lines does the data have?

SELECT DISTINCT COUNT(product_line) AS NumberOfProductLines 
FROM sales;

-- 2.What is the most common payment method?

SELECT payment, COUNT(payment) as Number
FROM sales
GROUP BY payment
ORDER BY 2 DESC
LIMIT 1;

-- 3.What is the most selling product line?

SELECT product_line, COUNT(product_line) as Number
FROM sales
group by 1
ORDER by 2 desc
LIMIT 1;

-- 4.What is the total revenue by month?

SELECT month_name as month,
		SUM(total) as TotalRevenue
FROM sales
GROUP BY month;

-- 5.What month had the largest COGS?
SELECT month_name as Month, SUM(cogs)
FROM sales
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;

-- 6.What product line had the largest revenue?

SELECT product_line as ProductLine, SUM(total) AS Revenue
FROM sales
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;

-- 7.What is the city with the largest revenue?
SELECT city, SUM(total) AS Revenue
FROM sales
GROUP BY 1
ORDER BY 2
LIMIT 1;

-- 8.What product line had the largest VAT?
SELECT product_line, SUM(tax_pct) AS VAT
FROM sales
GROUP BY 1
ORDER BY 2
LIMIT 1;

-- 9.Fetch each product line and add a column to those product line showing "Good", "Bad". Good if its greater than average sales

SELECT avg(quantity)
FROM sales;

SELECT product_line,
		CASE
			WHEN avg(quantity) < 5.4995 THEN 'Bad'
			ELSE 'Good'
		END AS Remark
FROM sales
GROUP BY 1;

-- 10.Which branch sold more products than average product sold?
SELECT branch, SUM(quantity) AS sum_quantity
FROM SALES
GROUP BY 1
HAVING 2 < (SELECT  AVG(quantity) FROM sales)
ORDER BY 2 DESC
LIMIT 1;

-- 11.What is the most common product line by gender?

SELECT gender,product_line, COUNT(gender) AS NumberOfGender
FROM sales
GROUP BY 1,2
ORDER BY 3 DESC;

-- 12.What is the average rating of each product line

SELECT product_line, ROUND(AVG(rating),2) AS AverageRating
FROM sales
GROUP BY 1;

-- ------------------------------------------------------------------------------
-- ------------------------Customers Questions-----------------------------------
-- ------------------------------------------------------------------------------

-- 1.How many unique customer types does the data have?


SELECT COUNT(DISTINCT customer_type) AS NumberOfCustomerTypes
FROM sales;

-- 2.How many unique payment methods does the data have?

SELECT COUNT(DISTINCT payment) as NumberOfPayments
FROM sales;

-- 3.What is the most common customer type?

SELECT customer_type, COUNT(customer_type) AS NumberOfCustomerType
FROM sales
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;

-- 4.Which customer type buys the most?

SELECT customer_type, COUNT(quantity) AS NumberOfBuys
FROM sales
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;

-- 5.What is the gender of most of the customers?

SELECT gender, COUNT(gender)
FROM sales
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;

-- 6.What is the gender distribution per branch?

SELECT
    branch,
    SUM(CASE WHEN gender = 'Male' THEN 1 ELSE 0 END) AS Male,
    SUM(CASE WHEN gender = 'Female' THEN 1 ELSE 0 END) AS Female
FROM sales
GROUP BY branch;

-- 7.Which time of the day do customers give most ratings?


SELECT  time_of_day, AVG(rating)
FROM sales
group by time_of_day
ORDER BY 2 DESC
LIMIT 1;


-- 8.Which time of the day do customers give the most ratings per branch?S

SELECT  branch,time_of_day,avg_rating
	FROM (
		SELECT
			branch,
			time_of_day,
            AVG(rating) as avg_rating,
            ROW_NUMBER() OVER (PARTITION BY branch ORDER BY AVG(rating) DESC) as row_num
		FROM
			sales
		GROUP BY
			1,2
		) AS per_branch
WHERE row_num = 1;


-- 9.Which day fo the week has the best avg ratings?

SELECT  day_time, AVG(rating)
FROM sales
group by day_time
ORDER BY 2 DESC
LIMIT 1;

-- 10.Which day of theS week has the best average ratings per branch

SELECT
    branch,
    day_time,
    avg_rating
FROM (
    SELECT
        branch,
        day_time,
        AVG(rating) AS avg_rating,
        ROW_NUMBER() OVER (PARTITION BY branch ORDER BY AVG(rating) DESC) AS row_num
    FROM
        sales
    GROUP BY
        branch,
        day_time
) AS ranked
WHERE
    row_num = 1;





