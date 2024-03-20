use orders;

/*Q1. Write a query to display customer_id, customer full name with their title (Mr/Ms), 
 both first name and last name are in upper case, customer_email,  customer_creation_year 
 and display customer’s category after applying below categorization rules:
 i. if CUSTOMER_CREATION_DATE year <2005 then category A
 ii. if CUSTOMER_CREATION_DATE year >=2005 and <2011 then category B 
 iii. if CUSTOMER_CREATION_DATE year>= 2011 then category C
 Expected 52 rows in final output.
 [Note: TABLE to be used - ONLINE_CUSTOMER TABLE] 
Hint:Use CASE statement. create customer_creation_year column with the help of customer_creation_date,
 no permanent change in the table is required. (Here don’t UPDATE or DELETE the columns in the table nor CREATE new tables
 for your representation. A new column name can be used as an alias for your manipulation in case if you are going to use a CASE statement.) 
*/

## Answer 1.
SELECT customer_id, 
	   concat(IF(customer_gender='M', 'Mr', 'Ms'), ' ', upper(customer_fname), ' ' ,upper(customer_lname)) as full_name, 
       customer_email, 
       year(customer_creation_date) as customer_creation_year,
		CASE
			WHEN YEAR(customer_creation_date) < 2005 THEN 'A'
			WHEN YEAR(customer_creation_date) >= 2005 AND YEAR(customer_creation_date) < 2011 THEN 'B'
			ELSE 'C'
		END AS category
FROM online_customer;

/* Q2. Write a query to display the following information for the products which
 have not been sold: product_id, product_desc, product_quantity_avail, product_price,
 inventory values (product_quantity_avail * product_price), New_Price after applying discount
 as per below criteria. Sort the output with respect to decreasing value of Inventory_Value. 
i) If Product Price > 20,000 then apply 20% discount 
ii) If Product Price > 10,000 then apply 15% discount 
iii) if Product Price =< 10,000 then apply 10% discount 
Expected 13 rows in final output.
[NOTE: TABLES to be used - PRODUCT, ORDER_ITEMS TABLE]
Hint: Use CASE statement, no permanent change in table required. 
(Here don’t UPDATE or DELETE the columns in the table nor CREATE new tables for your representation.
 A new column name can be used as an alias for your manipulation in case if you are going to use a CASE statement.)
*/
## Answer 2.
SELECT *, ROUND((product_price-discount),2) AS new_price FROM
(SELECT product_id, 
		product_desc, 
        product_quantity_avail, 
        product_price, 
        product_quantity_avail*product_price as inventory_values,
        CASE
        WHEN product_price>20000 THEN product_price*20/100
        WHEN product_price>10000 AND product_price<=20000 THEN product_price*15/100
        ELSE product_price*10/100
        END as discount
FROM product
WHERE product_id NOT IN (SELECT distinct product_id FROM order_items))t;

/*Q3. Write a query to display Product_class_code, Product_class_desc, Count of Product type in each product class, 
Inventory Value (p.product_quantity_avail*p.product_price). Information should be displayed for only those
 product_class_code which have more than 1,00,000 Inventory Value. Sort the output with respect to decreasing value of Inventory_Value. 
Expected 9 rows in final output.
[NOTE: TABLES to be used - PRODUCT, PRODUCT_CLASS]
Hint: 'count of product type in each product class' is the count of product_id based on product_class_code.
*/

## Answer 3.
SELECT pc.product_class_code,
	   pc.product_class_desc,
       count(p.product_id) AS count_of_products,
       SUM(p.product_quantity_avail*p.product_price) AS inventory_value
FROM product_class pc
LEFT JOIN product p
ON p.product_class_code = pc.product_class_code
GROUP BY 1,2
HAVING inventory_value>100000
ORDER BY inventory_value desc;


/* Q4. Write a query to display customer_id, full name, customer_email, customer_phone and
 country of customers who have cancelled all the orders placed by them.
Expected 1 row in the final output
[NOTE: TABLES to be used - ONLINE_CUSTOMER, ADDRESSS, OREDER_HEADER]
Hint: USE SUBQUERY
*/
 
## Answer 4.
SELECT oc.customer_id,
	   CONCAT(oc.customer_fname,' ',oc.customer_lname) AS full_name,
       oc.customer_email,
       oc.customer_phone,
       ad.country
FROM online_customer oc
JOIN address ad
ON oc.address_id = ad.address_id
LEFT JOIN ORDER_HEADER oh 
ON oc.customer_id = oh.customer_id
WHERE oh.order_status ='Cancelled'
GROUP BY 1,2,3,4,5
HAVING COUNT(oh.order_id) = (SELECT COUNT(*) 
							FROM ORDER_HEADER 
							WHERE customer_id = oc.customer_id) OR COUNT(oh.order_id) IS NULL;


/*Q5. Write a query to display Shipper name, City to which it is catering, num of customer catered by the shipper in the city ,
 number of consignment delivered to that city for Shipper DHL 
Expected 9 rows in the final output
[NOTE: TABLES to be used - SHIPPER, ONLINE_CUSTOMER, ADDRESSS, ORDER_HEADER]
Hint: The answer should only be based on Shipper_Name -- DHL. The main intent is to find the number
 of customers and the consignments catered by DHL in each city.
 */

## Answer 5.  
SELECT s.shipper_name, 
	   a.city, 
       count(oc.customer_id) customers_catered,
       count(oh.order_id) consignments_delivered 
FROM shipper s
	JOIN order_header oh
ON s.shipper_id = oh.shipper_id
	JOIN online_customer oc
ON oc.customer_id = oh.customer_id
	JOIN address a
ON a.address_id = oc.address_id
WHERE s.shipper_name = 'DHL'
GROUP BY 2;


/*Q6. Write a query to display product_id, product_desc, product_quantity_avail, quantity sold and 
show inventory Status of products as per below condition: 

a. For Electronics and Computer categories, 
if sales till date is Zero then show  'No Sales in past, give discount to reduce inventory', 
if inventory quantity is less than 10% of quantity sold, show 'Low inventory, need to add inventory', 
if inventory quantity is less than 50% of quantity sold, show 'Medium inventory, need to add some inventory',
if inventory quantity is more or equal to 50% of quantity sold, show 'Sufficient inventory' 

b. For Mobiles and Watches categories, 
if sales till date is Zero then show 'No Sales in past, give discount to reduce inventory', 
if inventory quantity is less than 20% of quantity sold, show 'Low inventory, need to add inventory', 
if inventory quantity is less than 60% of quantity sold, show 'Medium inventory, need to add some inventory', 
if inventory quantity is more or equal to 60% of quantity sold, show 'Sufficient inventory' 

c. Rest of the categories, 
if sales till date is Zero then show 'No Sales in past, give discount to reduce inventory', 
if inventory quantity is less than 30% of quantity sold, show 'Low inventory, need to add inventory', 
if inventory quantity is less than 70% of quantity sold, show 'Medium inventory, need to add some inventory',
if inventory quantity is more or equal to 70% of quantity sold, show 'Sufficient inventory'
Expected 60 rows in final output
[NOTE: (USE CASE statement) ; TABLES to be used - PRODUCT, PRODUCT_CLASS, ORDER_ITEMS]
Hint:  quantity sold here is product_quantity in order_items table. 
You may use multiple case statements to show inventory status (Low stock, In stock, and Enough stock)
 that meets both the conditions i.e. on products as well as on quantity.
The meaning of the rest of the categories, means products apart from electronics, computers, mobiles, and watches.
*/

## Answer 6.
SELECT  p.product_id, 
        p.product_desc, 
        p.product_quantity_avail, 
        SUM(o.product_quantity) AS quantity_sold,
        CASE 
			WHEN pc.product_class_desc IN ('Electronics','Computer') THEN
                CASE 
                  WHEN SUM(o.product_quantity) = 0 THEN 'No Sales in past, give discount to reduce inventory'
                  WHEN p.product_quantity_avail < (SUM(o.product_quantity)*0.1) THEN 'Low inventory, need to add inventory'
                  WHEN p.product_quantity_avail < (SUM(o.product_quantity) * 0.5) THEN 'Medium inventory, need to add some inventory'
				  ELSE 'Sufficient inventory'
				END
			WHEN pc.product_class_desc IN ('Mobiles', 'Watches') THEN
               CASE
                   WHEN SUM(o.product_quantity) = 0 THEN 'No Sales in past, give discount to reduce inventory'
                   WHEN p.product_quantity_avail < (SUM(o.product_quantity) * 0.2) THEN 'Low inventory, need to add inventory'
                   WHEN p.product_quantity_avail < (SUM(o.product_quantity) * 0.6) THEN 'Medium inventory, need to add some inventory'
                   ELSE 'Sufficient inventory'
               END
			ELSE
				CASE
                   WHEN SUM(o.product_quantity) = 0 THEN 'No Sales in past, give discount to reduce inventory'
                   WHEN p.product_quantity_avail < (SUM(o.product_quantity) * 0.3) THEN 'Low inventory, need to add inventory'
                   WHEN p.product_quantity_avail < (SUM(o.product_quantity) * 0.7) THEN 'Medium inventory, need to add some inventory'
                   ELSE 'Sufficient inventory'
               END
       END AS inventory_status
FROM product p
JOIN product_class as pc
ON p.product_class_code = pc.product_class_code
LEFT JOIN order_items o
ON o.product_id = p.product_id
GROUP BY p.product_id, p.product_desc, p.product_quantity_avail, pc.product_class_desc;




/* Q7. Write a query to display order_id and volume of the biggest order (in terms of volume) that can fit in carton id 10 .
Expected 1 row in final output
[NOTE: TABLES to be used - CARTON, ORDER_ITEMS, PRODUCT]
Hint: First find the volume of carton id 10 and then find the order id with products having total volume less than the volume of carton id 10
 */

## Answer 7.
SELECT o.order_id,
	  sum(p.len*p.width*p.height) as volume_of_order
FROM order_items o 
JOIN product p 
ON o.product_id = p.product_id
group by o.order_id
having volume_of_order < (SELECT len*width*height as volume_of_carton_10
							FROM carton
							WHERE carton_id=10)
order by volume_of_order desc
limit 1;


/*Q8. Write a query to display customer id, customer full name, total quantity and total value (quantity*price) 
shipped where mode of payment is Cash and customer last name starts with 'G'
Expected 2 rows in final output
[NOTE: TABLES to be used - ONLINE_CUSTOMER, ORDER_ITEMS, PRODUCT, ORDER_HEADER]
*/

## Answer 8.
SELECT oc.customer_id,
       concat(oc.customer_fname,' ',oc.customer_lname) as full_name,
       sum(oi.product_quantity),
       sum(oi.product_quantity*p.product_price) as total_value
from online_customer oc
join order_header as oh
on oc.customer_id = oh.customer_id
join order_items oi
on oi.order_id = oh.order_id
join product p
on p.product_id
WHERE oh.payment_mode = 'Cash' and oc.customer_lname like 'G%'
group by 1;
       


/*Q9. Write a query to display product_id, product_desc and total quantity of products which are sold together 
with product id 201 and are not shipped to city Bangalore and New Delhi. 
Expected 5 rows in final output
[NOTE: TABLES to be used - ORDER_ITEMS, PRODUCT, ORDER_HEADER, ONLINE_CUSTOMER, ADDRESS]
Hint: Display the output in descending order with respect to the sum of product_quantity. 
(USE SUB-QUERY) In final output show only those products , 
 product_id’s which are sold with 201 product_id (201 should not be there in output) and are shipped except Bangalore and New Delhi
 */

## Answer 9.
SELECT oi.product_id,
       p.product_desc,
       SUM(oi.product_quantity) AS total_quantity_sold
FROM ORDER_ITEMS oi
INNER JOIN ORDER_HEADER oh ON oi.order_id = oh.order_id
INNER JOIN PRODUCT p ON oi.product_id = p.product_id
INNER JOIN ONLINE_CUSTOMER oc ON oh.customer_id = oc.customer_id
INNER JOIN ADDRESS a ON oc.address_id = a.address_id
WHERE oi.product_id <> 201  
  AND a.city NOT IN ('Bangalore', 'New Delhi')  
GROUP BY oi.product_id, p.product_desc
HAVING oi.product_id IN (  
    SELECT DISTINCT product_id
    FROM ORDER_ITEMS
    WHERE order_id IN (
        SELECT order_id
        FROM ORDER_ITEMS
        WHERE product_id = 201  
    )
    AND product_id <> 201  
)
ORDER BY total_quantity_sold DESC;

/* Q10. Write a query to display the order_id, customer_id and customer fullname, 
total quantity of products shipped for order ids which are even and shipped to address where pincode is not starting with "5" 
Expected 15 rows in final output
[NOTE: TABLES to be used - ONLINE_CUSTOMER, ORDER_HEADER, ORDER_ITEMS, ADDRESS]	
 */

## Answer 10.
SELECT oi.order_id,
       oc.customer_id,
       concat(oc.customer_fname,' ',oc.customer_lname) as full_name,
       sum(oi.product_quantity) total_quantity_of_products
FROM online_customer oc
JOIN address a 
ON a.address_id = oc.address_id
join order_header oh
on oc.customer_id = oh.customer_id
join order_items oi
on oh.order_id=oi.order_id 
WHERE oh.order_id % 2 = 0 AND a.pincode NOT LIKE '5%'
GROUP BY 1
LIMIT 15;

