CREATE DATABASE coffee_shop_sales_db;

USE coffee_shop_sales_db;

SELECT * FROM coffee_shop_sales;
SET SQL_SAFE_UPDATES = 0;
UPDATE coffee_shop_sales
SET transaction_date = str_to_date(transaction_date, '%d-%m-%Y');

ALTER TABLE coffee_shop_sales
MODIFY COLUMN transaction_date DATE;

DESCRIBE coffee_shop_sales;

UPDATE coffee_shop_sales
SET transaction_time = str_to_date(transaction_time, '%H:%i:%s');

ALTER TABLE coffee_shop_sales
MODIFY COLUMN transaction_time TIME;
DESCRIBE coffee_shop_sales;


ALTER TABLE coffee_shop_sales
CHANGE COLUMN ï»¿transaction_id transaction_id INT;
DESCRIBE coffee_shop_sales;

SELECT * FROM coffee_shop_sales;


-- TO CALCULATE THE TOTAL SALES TOTAL SALES= UNIT PRICE* TRANSACTION_QTY

SELECT month(transaction_date), ROUND(sum(unit_price * transaction_qty),2) as Total_sales
FROM coffee_shop_sales
group by month(transaction_date);

SELECT ROUND(sum(unit_price * transaction_qty)) as Total_sales
FROM coffee_shop_sales
WHERE month(transaction_date) = 5;


-- month on month increase or decrease in sales
-- calcualte the difference in sales between the selected month and the previous month.

SELECT
    month(transaction_date) AS month,
    ROUND(SUM(unit_price * transaction_qty)) AS total_sales,
    (SUM(unit_price * transaction_qty) - LAG(SUM(unit_price * transaction_qty),1)
    OVER (ORDER BY MONTH(transaction_date))) / LAG(SUM(unit_price * transaction_qty), 1)
    OVER (ORDER BY MONTH(transaction_date)) * 100 AS mom_increase_percentage
FROM
    coffee_shop_sales
WHERE
    MONTH(transaction_date) IN (4,5)
GROUP BY 
    MONTH(transaction_date)
ORDER BY
    MONTH(transaction_date);
    
-- Total orders
SELECT COUNT(transaction_id) AS Total_Orders
FROM coffee_shop_sales
WHERE
MONTH(transaction_date) = 3;


-- Month on month increase or decrease in orders

SELECT
    MONTH(transaction_date) AS MONTH,
    COUNT(transaction_id) as Total_orders,
    (COUNT(transaction_id)- LAG(COUNT(transaction_id))
    OVER(ORDER BY MONTH(transaction_date))) / LAG(COUNT(transaction_id),1)
    OVER(ORDER BY MONTH(transaction_date)) * 100 AS mom_percentage
FROM 
    coffee_shop_sales
WHERE
    MONTH(transaction_date)  IN (2,3)
GROUP BY 
    MONTH(transaction_date)
ORDER BY 
    MONTH(transaction_date);
    
    
-- Total quantity sold

SELECT SUM(transaction_qty) AS total_quantiy
FROM coffee_shop_sales where month(transaction_date)=6;


-- change in the total quantity 
SELECT
	MONTH(transaction_date) As Month,
	SUM(transaction_qty) as Total_Qunatity,
    (SUM(transaction_qty)- LAG(SUM(transaction_qty),1)
    OVER (ORDER BY MONTH(transaction_date))) / LAG(SUM(transaction_qty),1)
    OVER (ORDER BY MONTH(transaction_date)) * 100 AS mom_percentage_change
FROM
    coffee_shop_sales
WHERE
    Month(transaction_date) IN (3,4)
GROUP BY
    MONTH(transaction_date)
order by
    Month(transaction_date);
    
    
    
-- charts requirements
-- Calendar Heat Map

SELECT 
    CONCAT(ROUND(SUM(unit_price * transaction_qty)/1000,1), 'K') as Total_sales,
    CONCAT(ROUND(SUM(transaction_qty) /1000,1), 'K') AS total_qty_sold,
    CONCAT(ROUND(COUNT(transaction_id)/1000,1), 'K') AS Total_Orders
FROM
    coffee_shop_sales
WHERE
    transaction_date= '2023-03-27';
    

-- by weekdays and weekends sales analysis
SELECT
    CASE WHEN dayofweek(transaction_date) IN (1,7) THEN  'WEEKENDS'
    ELSE 'WEEKDAYS'
    END AS day_type,
    CONCAT(ROUND(SUM(unit_price * transaction_qty)/1000,1),'K') AS total_sales
FROM coffee_shop_sales
where month(transaction_date) =5
group by CASE WHEN dayofweek(transaction_date) IN (1,7) THEN  'WEEKENDS'
    ELSE 'WEEKDAYS'
    END;
    
-- Sales_analysis by location

SELECT
    store_location,
    CONCAT(ROUND(SUM(unit_price * transaction_qty)/1000,1),'K') AS total_sales
FROM coffee_shop_sales
WHERE MONTH(transaction_date) = 5 -- may
GROUP BY store_location
ORDER BY SUM(unit_price * transaction_qty) DESC;

-- Daily sales analysis with average line
SELECT
     date(transaction_date) as daily_sales_date,
     Sum(Unit_price * Transaction_qty) as Total_daily_sales
FROM coffee_shop_sales
WHERE Month(transaction_date)=5
Group by date(transaction_date);


-- To find average sales 

SELECT 
    CONCAT(ROUND(AVG(Total_sales)/1000,1), 'K') AS Avg_Sales
FROM
    (
    SELECT SUM(unit_price * transaction_qty) AS Total_sales
    FROM coffee_shop_sales
    WHERE Month(transaction_date) = 5
    GROUP BY transaction_date
    ) AS internal_query;

SELECT
    DAY(transaction_date) AS day_of_month,
    SUM(unit_price * transaction_qty) AS total_sales
FROM coffee_shop_sales
WHERE Month(transaction_date)=5
GROUP BY DAY(transaction_date)
ORDER BY DAY(transaction_date) ASC;

SELECT
    day_of_month,
	CASE
       WHEN total_sales > avg_sales THEN 'Above_Average'
       WHEN total_sales < avg_sales THEN 'Below_Average'
       ELSE 'Average'
	END AS sales_status,
    total_sales
FROM
    (
     SELECT
          DAY(transaction_date) AS day_of_month,
          SUM(unit_price * transaction_qty) AS total_sales,
          AVG(SUM(unit_price * transaction_qty)) OVER () AS avg_sales
	 FROM
         coffee_shop_sales
	 WHERE
         Month(transaction_date) = 5
	 GROUP BY
         DAY(transaction_date)
 ) AS sales_data
 ORDER BY 
     day_of_month;
     
     
SELECT
    product_category,
    CONCAT(ROUND(SUM(unit_price * transaction_qty)/1000,1), 'K') AS total_sales
FROM coffee_shop_sales
WHERE MONTH(transaction_date) =5
GROUP BY product_category
ORDER BY SUM(unit_price * transaction_qty) DESC;

SELECT * FROM coffee_shop_sales;
-- Top 10 products by sales
SELECT
   product_type,
   SUM(unit_price * transaction_qty ) AS total_sales
FROM 
   coffee_shop_sales
WHERE MONTH(transaction_date) =5 AND product_category = 'Coffee'
GROUP BY product_type
ORDER BY total_sales DESC
LIMIT 10;

-- Sales analysis by days and hours

SELECT
    SUM(unit_price * transaction_qty) AS total_sales,
    SUM(transaction_qty) as total_qty_sold,
    COUNT(*)
FROM coffee_shop_sales
WHERE MONTH(transaction_date) = 5
AND dayofweek(transaction_date) =2
AND HOUR(transaction_time) = 8;

SELECT
    HOUR(transaction_time),
    SUM(unit_price * transaction_qty) AS total_sales
FROM coffee_shop_sales
WHERE MONTH(transaction_date) = 5
GROUP BY HOUR(transaction_time)
ORDER BY HOUR(transaction_time);


SELECT
    CASE
       WHEN DAYOFWEEK(transaction_date) =2 THEN 'Monday'
       WHEN DAYOFWEEK(transaction_date) =3 THEN 'Tuesday'
       WHEN DAYOFWEEK(transaction_date) =4 THEN 'Wednesday'
       WHEN DAYOFWEEK(transaction_date) =5 THEN 'Thursday'
       WHEN DAYOFWEEK(transaction_date) =6 THEN 'Friday'
       WHEN DAYOFWEEK(transaction_date) =7 THEN 'Saturday'
       ELSE 'Sunday'
	END AS Day_of_week,
    ROUND(SUM(unit_price * transaction_qty)) AS total_sales
FROM 
   coffee_shop_sales
WHERE
   Month(transaction_date) =5
GROUP BY 
   CASE
       WHEN DAYOFWEEK(transaction_date) =2 THEN 'Monday'
       WHEN DAYOFWEEK(transaction_date) =3 THEN 'Tuesday'
       WHEN DAYOFWEEK(transaction_date) =4 THEN 'Wednesday'
       WHEN DAYOFWEEK(transaction_date) =5 THEN 'Thursday'
       WHEN DAYOFWEEK(transaction_date) =6 THEN 'Friday'
       WHEN DAYOFWEEK(transaction_date) =7 THEN 'Saturday'
       ELSE 'Sunday'
   END;
    
	