--- Get the top 3 product types that have proven most profitable
SELECT prod.product_line, sum(oi.quantity_ordered * oi.price_each) profit
FROM products prod
LEFT JOIN order_items oi
ON oi.product_code = prod.product_code
GROUP BY prod.product_line
ORDER BY profit desc
LIMIT 3;

--- Get the top 3 products by most items sold
SELECT prod.product_code, sum(coalesce(oi.quantity_ordered,0)) total
FROM products prod
LEFT JOIN order_items oi
ON oi.product_code = prod.product_code
GROUP BY prod.product_code
ORDER BY total desc
LIMIT 3;

--- Get the top 3 products by items sold per country of customer for: USA, Spain, Belgium
SELECT * FROM (
SELECT a.*, RANK() OVER (PARTITION BY COUNTRY ORDER BY total DESC) as rk 
from (
SELECT c.country, prod.product_code, sum(coalesce(oi.quantity_ordered,0)) total
FROM products prod
LEFT JOIN order_items oi
ON oi.product_code = prod.product_code
LEFT JOIN customers c
ON c.customer_number = oi.customer_number
GROUP BY c.country, prod.product_code
ORDER BY country, total desc) as a ) as b
WHERE b.rk <= 3
AND b.country in ('USA','Spain','Belgium');

--I know there's a way to do this without two subqueries but I need to move onto the spark stuff.  Also, historically, I'd avoid doing stuff like this
-- because I felt it was pretty unreadable compared to just loading it into R and (dynamically) filtering there.  But I get that it's not feasible with bigger datasets.
	
--- Get the most profitable day of the week
SELECT extract(dow from TO_DATE(o.order_date,'YYYY-MM-DD')) as d_o_w, sum(oi.quantity_ordered * oi.price_each) profit
FROM order_items oi
LEFT JOIN orders o
ON oi.order_number = o.order_number
GROUP BY d_o_w
ORDER BY profit desc
LIMIT 1;

--- Get the top 3 city-quarters with the highest average profit margin in their sales
SELECT e.city, extract(quarter from TO_DATE(o.order_date,'YYYY-MM-DD')) as quarter, avg(oi.quantity_ordered * oi.price_each) profit
FROM order_items oi
LEFT JOIN orders o
ON oi.order_number = o.order_number
LEFT JOIN employees e
on oi.sales_rep_employee_number = e.employee_number
GROUP BY city, quarter
ORDER BY profit desc
LIMIT 3;
											
-- you'd probably want to put year and quarter in columns if you're going to want to look at quarterly data (Q1 2017 =/= Q1 2018, etc.)

-- List the employees who have sold more goods (in $ amount) than the average employee.

	
SELECT a.employee_number, a.profit FROM (
SELECT e.employee_number, sum(oi.quantity_ordered * oi.price_each) profit
FROM employees e
RIGHT JOIN order_items oi
ON e.employee_number = oi.sales_rep_employee_number
GROUP BY e.employee_number) as a
WHERE a.profit > (
											
SELECT avg(b.profit) from (
SELECT e.employee_number, sum(oi.quantity_ordered * oi.price_each) profit
FROM employees e
RIGHT JOIN order_items oi
ON e.employee_number = oi.sales_rep_employee_number
GROUP BY e.employee_number) as b);

-- List all the orders where the sales amount in the order is in the top 10% of all order sales amounts (BONUS: Add the employee number)

SELECT a.order_number, a.total FROM (
SELECT o.order_number, sum(oi.quantity_ordered * oi.price_each) total
from orders o
LEFT JOIN order_items oi
on o.order_number = oi.order_number
GROUP BY o.order_number ) a
WHERE a.total > (

SELECT percentile_cont(.1) within group (order by total desc) as pct_10 from (
SELECT o.order_number, sum(oi.quantity_ordered * oi.price_each) total
from orders o
LEFT JOIN order_items oi
on o.order_number = oi.order_number
GROUP BY o.order_number) as b);

											
								  
								  
								  
								  
								  