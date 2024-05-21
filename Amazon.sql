CREATE DATABASE IF NOT EXISTS amazon ;
USE amazon;

CREATE TABLE amazon(
invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
branch VARCHAR(5) NOT NULL,
city VARCHAR(30) NOT NULL,
customer_type VARCHAR(30) NOT NULL,
gender VARCHAR(10) NOT NULL,
product_line VARCHAR(100) NOT NULL,
unit_price DECIMAL(10,2) NOT NULL,
quantity INT(20) NOT NULL,
vat FLOAT(6,4) NOT NULL,
total DECIMAL(12, 4) NOT NULL,
date DATETIME NOT NULL,
time TIME NOT NULL,
payment VARCHAR(15) NOT NULL,
cogs DECIMAL(10,2) NOT NULL,
gross_margin_pct FLOAT(11,9),
gross_income DECIMAL(12, 4),
rating FLOAT(2, 1)
);

select * from amazon;
describe amazon;

SELECT * FROM amazon;

# Checking if there are any null values in columns
SELECT * FROM amazon 
WHERE
Invoice_ID IS NULL OR
branch IS NULL OR
CITY IS NULL OR
customer_type IS NULL OR
Gender IS NULL OR
product_line IS NULL OR
unit_price IS NULL OR
quantity IS NULL OR
VAT IS NULL ;


#FEATURE ENGINEERING
#Add a new column named timeofday to give insight of sales in the Morning, Afternoon and Evening. 
# This will help answer the question on which part of the day most sales are made.

ALTER TABLE amazon ADD COLUMN time_of_day VARCHAR(20);
UPDATE amazon
SET time_of_day = (CASE
 WHEN `time` BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
 WHEN `time` BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
 ELSE "Evening"
 END);
 SELECT * FROM amazon;
 
 #Add a new column named dayname that contains the extracted days of the week on which the given transaction took place (Mon, Tue, Wed, Thur, Fri). 
 #This will help answer the question on which week of the day each branch is busiest
ALTER TABLE amazon ADD COLUMN day_name VARCHAR(10);
UPDATE amazon
SET day_name = DAYNAME(Date);

# Add a new column named monthname that contains the extracted months of the year on which the given transaction took place (Jan, Feb, Mar).
# Help determine which month of the year has the most sales and profit.
ALTER TABLE amazon ADD COLUMN Month_Name VARCHAR(20);
UPDATE amazon
SET Month_Name = MONTHNAME(Date);

SELECT * FROM amazon;


-- Business Questions To Answer:
#What is the count of distinct cities in the dataset?
SELECT COUNT(DISTINCT(City)) AS City_count FROM amazon;
-- There are 3 unique Cities in the dataset

#For each branch, what is the corresponding city?
SELECT DISTINCT(branch),City FROM amazon;
-- For branch A - Yangon, branch B - Mandalay, branch C - Naypyitaw

#What is the count of distinct product lines in the dataset?
SELECT COUNT(DISTINCT(product_line)) AS Product_Count FROM amazon;
-- There are 6 distinct product lines in the dataset

#Which payment_method method occurs most frequently?
SELECT payment,COUNT(payment)AS payment_count FROM amazon
GROUP BY 1
ORDER BY 2 DESC;
-- Cash payment method is most frequently used

#Which product line has the highest sales?
SELECT SUM(quantity) as QTY,
product_line 
FROM amazon
GROUP BY 2
ORDER BY 1 DESC;
-- Electronic accessories has the highest sales, whereas Health and Beauty section needs to be improved

#How much revenue is generated each month?
SELECT Month_Name,SUM(total) as Revenue
FROM amazon
GROUP BY Month_Name
ORDER BY 2 DESC;
-- Maximum revenue is earned in January followed by March. February has the lowest compared to January and March 

#In which month did the cost of goods sold reach its peak?
SELECT Month_Name AS Month,SUM(cogs) AS Cost_of_Goods
FROM amazon
GROUP BY 1 
ORDER BY 2 DESC;
-- Cost of Goods reached its peak in January

#Which product line generated the highest revenue?
SELECT product_line,SUM(total) as total_Revenue
FROM amazon
GROUP BY 1
ORDER BY 2 DESC;
-- Food and beverages has the highest revenue

#In which city was the highest revenue recorded?
SELECT City,SUM(total)as total_Revenue
FROM amazon
GROUP BY 1
ORDER BY 2 DESC;
-- Naypyitaw has the highest revenue recorded

#Which product line incurred the highest Value Added Tax?
SELECT product_line,SUM(VAT) as Value_Added_Tax 
FROM amazon
GROUP BY 1
ORDER BY 2 DESC;
-- Food and beverages incurred highest Value Added Tax

#For each product line, add a column indicating "Good" if its sales are above average, otherwise "Bad."
SELECT AVG(total) from amazon;

SELECT product_line,ROUND(avg(total),2) AS Average_Revenue,
CASE WHEN AVG(total)>(SELECT AVG(total)FROM amazon) THEN 'Good'
	ELSE 'Bad'
	END AS Review
FROM amazon
GROUP BY 1;

#Identify the branch that exceeded the average number of products sold.
SELECT branch,SUM(quantity)as qty
FROM amazon 
GROUP BY 1
HAVING SUM(quantity)>(SELECT AVG(quantity)FROM amazon)
ORDER BY 2 DESC; 
-- branch A exceeded the average number of product sold

#Which product line is most frequently associated with each gender?
SELECT product_line,Gender,COUNT(Gender) as Gender_Count
FROM amazon
GROUP BY 1,2
ORDER BY 3 DESC;
-- Fashion Accessories is associated with Female with the highest count of 96, Health and beauty products are used by male the most with atleast 88 males using them.

#Calculate the average rating for each product line.
SELECT product_line,ROUND(AVG(rating),2) as Average_rating
FROM amazon
GROUP BY 1
ORDER BY 2 DESC;
-- Food and beverages tops the Average rating of 7.11 , whearas Home and lifestyle ranks the lowest at 6.84 

#Count the sales occurrences for each time of day on every weekday.
SELECT * FROM amazon;

##This will show for all the weekdays 
SELECT day_name,time_of_day,COUNT(*) AS Num_of_Sales
FROM amazon
GROUP BY 1,2
ORDER BY 3 DESC;
-- This shows that Saturday Evening has the highest sales

## this will show for a weekday as mentioned in the code
SELECT time_of_day,COUNT(*)AS Num_of_Sales
FROM amazon
WHERE day_name ='SUNDAY'
GROUP BY 1
ORDER BY 2 DESC;
-- On Sunday Evenings Sales are highest

#Identify the customer type contributing the highest revenue.
SELECT customer_type,SUM(total)
FROM amazon
GROUP BY 1
ORDER BY 2 DESC;
--  Normal Customers contribute highest revenue

#Determine the city with the highest VAT percentage.
SELECT City,ROUND(AVG(VAT),2)AS Avg_Tax_Prcnt
FROM amazon
GROUP BY 1
ORDER BY 2 DESC;
-- Naypyitaw City generates the highest VAT percentage

#Identify the customer type with the highest VAT payment_methods.
SELECT customer_type,ROUND(AVG(VAT),2)as total_tax
FROM amazon
GROUP BY 1
ORDER BY 2 DESC;
-- Customer Type 'Member' has the highest VAT payment_methods

#What is the count of distinct customer types in the dataset?
SELECT COUNT(DISTINCT(customer_type)) as Distinct_Customer_Type
FROM amazon;
-- There are 2 distinct customer types

#What is the count of distinct payment_method methods in the dataset?
SELECT COUNT(DISTINCT(payment_method)) as Distinct_payment_method
FROM amazon;
-- There are 3 distinct payment_method methods

#Which customer type occurs most frequently?
SELECT customer_type,COUNT(customer_type)AS Count_Customer_type FROM amazon
GROUP BY 1
ORDER BY 2 DESC;
-- Member customer type occurs more frequently

#Identify the customer type with the highest purchase frequency.
SELECT customer_type,
SUM(quantity) AS total_quantity_ordered
FROM amazon
GROUP BY 1
ORDER BY 2 DESC;
-- Customers who are members buys the most

#Determine the predominant gender among customers.
SELECT Gender,COUNT(Gender)AS count
FROM amazon
GROUP BY 1
ORDER BY 2 DESC;
-- There are not much difference male and female genders

#Examine the distribution of genders within each branch.
SELECT branch,Gender,COUNT(Gender)as gender_count
FROM amazon
GROUP BY 1,2
ORDER BY 1;

#Identify the time of day when customers provide the most ratings.
SELECT time_of_day,COUNT(rating) AS count
FROM amazon
GROUP BY 1
ORDER BY 2 DESC;
-- Most ratings are given in the evenings. The reason may be due to fact that most customers visit during evening

#Determine the time of day with the highest customer ratings for each branch.
select * from amazon;
SELECT time_of_day,branch,COUNT(rating) AS rating_Count
FROM amazon
GROUP BY 1,2
ORDER BY 3 DESC;
-- Most of the ratings are provided in the evening in branch B, followed by branch C. ratings are quite less in the morning across all the branches

#Identify the day of the week with the highest average ratings.
SELECT day_name,ROUND(AVG(rating),2)AS Avg_rating
FROM amazon
GROUP BY 1
ORDER BY 2 DESC;
-- Monday,Friday,Sunday has the best average ratings

#Determine the day of the week with the highest average ratings for each branch.
SELECT day_name,branch,ROUND(AVG(rating),2)AS ratings
FROM amazon
GROUP BY 1,2
ORDER BY 3 DESC;
-- Monday has the highest rating in branch B, followed by Friday in branch A & C	



































