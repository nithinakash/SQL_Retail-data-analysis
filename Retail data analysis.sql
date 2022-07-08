--**********************************--
-->Data Preparation & Understanding<--
--**********************************--

--> 1. What is the total number of rows in eachof the 3 tables in the database ?
Select CONVERT(Varchar, COUNT(*)) + ' -> Count_transaction' as Count_of_rows from Transactions
Union All
Select CONVERT(Varchar, COUNT(*)) + ' -> Count_prod_cat_info' as Count_prod_cat_info from prod_cat_info
Union all	
Select CONVERT(Varchar, COUNT(*)) + ' -> Count_Customer' as Count_Customer from Customer;

-------------------------------------------------------------------------------------------------------------------------------------

--> 2. What is the total number of transactions that have a return ?
select COUNT(transaction_id) as Count_returns from Transactions
where Qty <= 0

-------------------------------------------------------------------------------------------------------------------------------------

--> 3. As you would have noticed, the dates provided across the datasets are not in a correct format. As first steps, 
-->	pls convert the date variables into valid date formats before proceeding ahead.
select CAST(C.DOB as date) DOB_formated , CAST(T.tran_date as date) Tran_date_formated from Transactions T
Inner join Customer C on C.customer_Id = T.cust_id;

-------------------------------------------------------------------------------------------------------------------------------------

--> 4. What is the time range of the transaction data available for analysis? Show the output in number of days, months and years 
-->	simultaneously in different columns.
select Top 1 DATEDIFF(DAY,(select MIN(tran_date) from Transactions),(select MAX(tran_date) from Transactions)) No_of_days,
DATEDIFF(MONTH,(select MIN(tran_date) from Transactions),(select MAX(tran_date) from Transactions)) No_of_months,
DATEDIFF(YEAR,(select MIN(tran_date) from Transactions),(select MAX(tran_date) from Transactions)) No_of_years
from Transactions;

-------------------------------------------------------------------------------------------------------------------------------------
--> 5. Which product category does the sub-category “DIY” belong to? 
select prod_cat,prod_subcat from prod_cat_info
where prod_subcat ='DIY'

-------------------------------------------------------------------------------------------------------------------------------------
--***************--
-->DATA ANALYSIS<--
--***************--

--> 1. Which channel is most frequently used for transactions? 
select Top 1 Store_type, COUNT(transaction_id) Most_Frequent from Transactions
group by Store_type
order by Most_Frequent desc

-------------------------------------------------------------------------------------------------------------------------------------
--> 2.  What is the count of Male and Female customers in the database? 
select Gender, COUNT(customer_Id) Cust_count from Customer
group by Gender
order by Cust_count desc

-------------------------------------------------------------------------------------------------------------------------------------
--> 3. From which city do we have the maximum number of customers and how many?
select top 1 city_code,COUNT(customer_Id) Cust_count from Customer
group by city_code
order by Cust_count desc

-------------------------------------------------------------------------------------------------------------------------------------
--> 4. How many sub-categories are there under the Books category?
select prod_cat, COUNT(prod_sub_cat_code) subcat_count from prod_cat_info
where prod_cat = 'Books'
group by prod_cat

-------------------------------------------------------------------------------------------------------------------------------------
--> 5. What is the maximum quantity of products ever ordered?
select P.prod_cat, MAX(T.Qty) Max_Qty from Transactions T
inner join prod_cat_info P on P.prod_cat_code = T.prod_cat_code
group by P.prod_cat

-------------------------------------------------------------------------------------------------------------------------------------
--> 6. What is the net total revenue generated in categories Electronics and Books?
select P.prod_cat,SUM(T.total_amt) Total_Revenue from Transactions T
inner join prod_cat_info P on P.prod_cat_code = T.prod_cat_code
where P.prod_cat in ('Electronics','Books')
group by P.prod_cat

-------------------------------------------------------------------------------------------------------------------------------------
--> 7. How many customers have >10 transactions with us, excluding returns? 
select T.cust_id, COUNT(T.cust_id) tran_count from Transactions T
inner join Customer C on C.customer_Id = T.cust_id
where T.Qty>0
group by T.cust_id
having COUNT(T.cust_id)>10

-------------------------------------------------------------------------------------------------------------------------------------
--> 8. What is the combined revenue earned from the “Electronics” & “Clothing” 
--> categories, from “Flagship stores”? 
select ROUND(SUM(T.total_amt),2) combined_revenue from Transactions T
inner join prod_cat_info P on P.prod_cat_code = T.prod_cat_code
where T.Store_type = 'Flagship store' and P.prod_cat in ('Electronics','Clothing')

-------------------------------------------------------------------------------------------------------------------------------------
--> 9. What is the total revenue generated from “Male” customers in “Electronics” 
--> category? Output should display total revenue by prod sub-cat.
select P.prod_subcat, ROUND(SUM(T.total_amt),2) Total_revenue from prod_cat_info P
left join Transactions T on T.prod_subcat_code = P.prod_sub_cat_code
left join Customer C on C.customer_Id = T.cust_id
where C.Gender = 'M' and P.prod_cat = 'Electronics'
group by P.prod_subcat

-------------------------------------------------------------------------------------------------------------------------------------
--> 10.What is percentage of sales and returns by product sub category; display only top 
--> 5 sub categories in terms of sales? 
select top 5 prod_subcat ,
ROUND((Select (SUM(case when total_amt > 0 then total_amt else 0 end)/(select Sum(total_amt) from Transactions where total_amt > 0)))*100,2) [Sale %],
ROUND((Select (SUM(case when total_amt < 0 then total_amt else 0 end)/(select Sum(total_amt) from Transactions where total_amt > 0)))*100,2) [Return %]
from Transactions T
inner join prod_cat_info P on P.prod_sub_cat_code = T.prod_subcat_code
group by prod_subcat
order by [Sale %] Desc

-------------------------------------------------------------------------------------------------------------------------------------
--> 11. For all customers aged between 25 to 35 years find what is the net total revenue 
--> generated by these consumers in last 30 days of transactions from max transaction 
--> date available in the data? 
select C.customer_Id,DATEDIFF(YEAR,DOB,(select MAX(tran_date) from Transactions)) [age],
ROUND(SUM(T.total_amt),2) Total_Revenue from Transactions T
inner join Customer C on C.customer_Id = T.cust_id
where DATEDIFF(YEAR,C.DOB,T.tran_date) between 25 and 35
group by C.customer_Id,DOB,T.tran_date
having DATEDIFF(day,tran_date,(select MAX(tran_date) from Transactions)) < = 30

-------------------------------------------------------------------------------------------------------------------------------------
--> 12.Which product category has seen the max value of returns in the last 3 months of 
-->	transactions? 
select Top 1 P.prod_cat,ROUND((select SUM(case when T.total_amt < 0 then T.total_amt else 0 end)),2) [Returns]from Transactions T
inner join prod_cat_info P on P.prod_cat_code = T.prod_cat_code
Where DATEDIFF(DAY,T.tran_date,(select MAX(tran_date) from Transactions)) <= 90
group by P.prod_cat
order by Returns

-------------------------------------------------------------------------------------------------------------------------------------
--> 13.Which store-type sells the maximum products; by value of sales amount and by 
-->	quantity sold? 
select TOP 1 Store_type,ROUND(SUM(total_amt),2)[Sales_amt],SUM(Qty)[QTY] from Transactions
group by Store_type
order by Sales_amt Desc,QTY Desc

-------------------------------------------------------------------------------------------------------------------------------------
--> 14.What are the categories for which average revenue is above the overall average. 
select P.prod_cat, ROUND(AVG(total_amt),2)[> Overall_avg] from Transactions T
inner join prod_cat_info P on P.prod_cat_code = T.prod_cat_code
group by P.prod_cat
having AVG(total_amt) > (Select AVG(total_amt) from Transactions)

-------------------------------------------------------------------------------------------------------------------------------------
--> 15. Find the average and total revenue by each subcategory for the categories which 
--> are among top 5 categories in terms of quantity sold. 
select P.prod_cat,P.prod_subcat,ROUND(AVG(total_amt),2)[avg],ROUND(SUM(total_amt),2)[total] from Transactions T
inner join prod_cat_info P on P.prod_sub_cat_code = T.prod_subcat_code
where P.prod_cat_code in (select prod_cat_code from 
(select Top 5 prod_cat_code, SUM(Qty) [QTY]from Transactions group by prod_cat_code order by Qty Desc) as T1)
group by P.prod_cat,P.prod_subcat
order by P.prod_cat

-------------------------------------------------------------------------------------------------------------------------------------