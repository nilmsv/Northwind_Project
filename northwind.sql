--1) چند سفارش در مجموع ثبت شده است؟

select count(OrderID) as total_order from Orders


--2) درآمد حاصل از این سفارشها چقدر بوده است؟

select sum(od.QUANTITY * p.PRICE) as sum_income from 
OrderDetails od join Products p on p.PRODUCTID = od.PRODUCTID


--3)  5 مشتری برتر را بر اساس مقداری که خرج کردهاند پیدا کنید. 
-- نام و آی دی و مقدار خرج شده هر یک را گزارش کنید

with jn1 as (
select c.CUSTOMERNAME, c.CUSTOMERID, o.ORDERID from
Customers c join Orders o on c.CUSTOMERID = o.CUSTOMERID
)
,
jn2 as (
select j1.CUSTOMERID, j1.CUSTOMERNAME, od.PRODUCTID, od.QUANTITY from
jn1 j1 join OrderDetails od on j1.ORDERID = od.ORDERID
)

select j2.CUSTOMERID, j2.CUSTOMERNAME, sum(p.PRICE * j2.QUANTITY) as total_cost from 
jn2 j2 join Products p on j2.PRODUCTID = p.PRODUCTID
group by j2.CUSTOMERID, j2.CUSTOMERNAME
order by total_cost desc
fetch first 5 rows only

--4)  میانگین هزینه ی سفارشات هر مشتری را به همراه ID و نام او گزارش کنید.
-- به ترتیب نزولی نشان دهید


with jn1 as (
select c.CUSTOMERNAME, c.CUSTOMERID, o.ORDERID from
Customers c join Orders o on c.CUSTOMERID = o.CUSTOMERID
)
,
jn2 as (
select j1.CUSTOMERID, j1.CUSTOMERNAME, j1.ORDERID, od.PRODUCTID, od.QUANTITY from
jn1 j1 join OrderDetails od on j1.ORDERID = od.ORDERID
)

select j2.CUSTOMERNAME, j2.CUSTOMERID, avg(p.PRICE * j2.QUANTITY) as avg_cost from 
jn2 j2 join Products p on j2.PRODUCTID = p.PRODUCTID
group by j2.CUSTOMERID, j2.CUSTOMERNAME
order by avg_cost desc 

--5)  مشتریان را بر اساس مقدار کل هزینه ی سفارشات رتبه بندی کنید،
-- اما فقط مشتریانی را در نظر بگیرید که بیشتر از پنج سفارش داده اند

with jn1 as (
select c.CUSTOMERID, od.ORDERID from
Customers c join Orders od on c.CUSTOMERID = od.CUSTOMERID
)
,
jn2 as (
select j1.CUSTOMERID, j1.ORDERID, ode.PRODUCTID, ode.QUANTITY from 
jn1 j1 join OrderDetails ode on ode.ORDERID = j1.ORDERID
)
,
jn3 as (
select j2.CUSTOMERID, j2.ORDERID, j2.PRODUCTID, j2.QUANTITY, p.PRICE from
jn2 j2 join Products p on j2.PRODUCTID = p.PRODUCTID
)

select j3.CUSTOMERID, sum(j3.PRICE * j3.QUANTITY) as total_cost, count(j3.ORDERID) as total_order from jn3 j3
group by j3.CUSTOMERID
having count(j3.ORDERID) >= 5
order by total_order

--6)  کدام محصول در کل سفارشات ثبت شده بیشترین درآمد را ایجاد کرده است؟
-- به همراه نام و آی دی گزارش کنید

with jn1 as (
select (ode.QUANTITY * p.PRICE) as total_price, p.PRODUCTNAME, p.PRODUCTID from 
OrderDetails ode join Products p on ode.PRODUCTID = p.PRODUCTID
)

select j1.PRODUCTNAME, j1.PRODUCTID, sum(j1.total_price) as total_income from jn1 j1
group by j1.PRODUCTNAME, j1.PRODUCTID
order by total_income desc
fetch first 1 rows only

--7)  هر دسته چند محصول دارد؟
-- به ترتیب نزولی نشان دهید

select p.CATEGORYID, count(p.PRODUCTID) as number_product from Products p
group by p.CATEGORYID
order by number_product desc

--8) محصول پرفروش در هر دسته بر اساس درآمد را تعیین کنید.

with window_function as (
select p.ProductName, p.ProductID, p.CategoryID, (ode.Quantity * p.price) as total_price, max(ode.Quantity * p.price) over (partition by p.CategoryID) as max_income
from Products p join OrderDetails ode on p.PRODUCTID = ode.PRODUCTID
)

select distinct wf.PRODUCTID, wf.CATEGORYID, wf.MAX_INCOME from window_function wf
where wf.total_price = wf.max_income
order by wf.CATEGORYID

--9) 5 کارمند برتر که بالاترین درآمد را ایجاد کردند به همراه ID و نام + ’ ’ + نام خانوادگی گزارش کنید.

with jn1 as (
select e.EmployeeID, e.LastName, e.FirstName, o.ORDERID from
Employees e join Orders o on e.EMPLOYEEID = o.EMPLOYEEID
)
,
jn2 as (
select j1.EMPLOYEEID, j1.FIRSTNAME, j1.LASTNAME, ode.PRODUCTID, ode.QUANTITY from
jn1 j1 join OrderDetails ode on j1.ORDERID = ode.ORDERID
)
,
jn3 as (
select j2.EMPLOYEEID, j2.FIRSTNAME, j2.LASTNAME, j2.PRODUCTID, j2.QUANTITY, p.PRICE from
jn2 j2 join Products p on j2.PRODUCTID = p.PRODUCTID
)

select j3.EMPLOYEEID, j3.FIRSTNAME || ' ' || j3.LASTNAME, sum(j3.PRICE * j3.QUANTITY) as total_income from jn3 j3
group by j3.EMPLOYEEID, j3.FIRSTNAME || ' ' || j3.LASTNAME
order by total_income desc
fetch first 5 rows only


--10)  میانگین درآمد هر کارمند به ازای هر سفارش چقدر بوده است؟ 
-- به ترتیب نزولی نشان دهید

with jn1 as (
select e.EmployeeID, e.LastName, e.FirstName, o.ORDERID from
Employees e join Orders o on e.EMPLOYEEID = o.EMPLOYEEID
)
,
jn2 as (
select j1.EMPLOYEEID, j1.FIRSTNAME, j1.LASTNAME, ode.PRODUCTID, ode.QUANTITY, j1.ORDERID from
jn1 j1 join OrderDetails ode on j1.ORDERID = ode.ORDERID
)
,
jn3 as (
select j2.EMPLOYEEID, j2.FIRSTNAME, j2.LASTNAME, j2.PRODUCTID, j2.QUANTITY, j2.ORDERID ,p.PRICE from
jn2 j2 join Products p on j2.PRODUCTID = p.PRODUCTID
)

select distinct jn3.EMPLOYEEID, jn3.FIRSTNAME, jn3.LASTNAME, jn3.ORDERID, avg(jn3.Quantity * jn3.price) over (partition by jn3.ORDERID) as avg_income from jn3
order by avg_income desc

--11)  کدام کشور بیشترین تعداد سفارشات را ثبت کرده است؟
-- نام کشور را به همراه تعداد سفارشات گزارش کنید

with jn1 as (
select c.COUNTRY, o.ORDERID from
Customers c join Orders o on c.CustomerID = o.CUSTOMERID
)

select j1.COUNTRY, count(j1.ORDERID) as cnt_order from jn1 j1
group by j1.COUNTRY
order by cnt_order desc
fetch first 1 rows only

--12)  مجموع درآمد از سفارشات هر کشور چقدر بوده؟
-- به همراه نام کشور و به ترتیب نزولی نشان دهید

with jn1 as (
select c.COUNTRY, o.ORDERID from
Customers c join Orders o on c.CUSTOMERID = o.CUSTOMERID
)
,
jn2 as (
select j1.COUNTRY, j1.ORDERID, ode.PRODUCTID, ode.QUANTITY from
jn1 j1 join OrderDetails ode on j1.ORDERID = ode.ORDERID
)

select j2.COUNTRY, sum(j2.QUANTITY * p.price) as total_income from jn2 j2 join Products p on j2.PRODUCTID = p.PRODUCTID
group by j2.COUNTRY
order by total_income desc

--13) میانگین قیمت هر دسته چقدر است؟ 
-- به همراه نام دسته و به ترتیب نزولی نشان دهید

with jn1 as (
select p.CATEGORYID, p.PRICE, ode.QUANTITY from
Products p join OrderDetails ode on p.PRODUCTID = ode.PRODUCTID
)

select j1.CATEGORYID, ca.CATEGORYNAME, avg(j1.PRICE * j1.QUANTITY) as avg_price from 
jn1 j1 join Categories ca on j1.CATEGORYID = ca.CATEGORYID
group by j1.CATEGORYID, ca.CATEGORYNAME
order by avg_price desc

--14)  گران ترین دسته بندی کدام است؟
-- به همراه نام دسته نشان دهید

with jn1 as (
select p.CATEGORYID, p.PRICE, ode.QUANTITY from
Products p join OrderDetails ode on p.PRODUCTID = ode.PRODUCTID
)

select j1.CATEGORYID, ca.CATEGORYNAME, sum(j1.PRICE * j1.QUANTITY) as sum_price from 
jn1 j1 join Categories ca on j1.CATEGORYID = ca.CATEGORYID
group by j1.CATEGORYID, ca.CATEGORYNAME
order by sum_price desc
fetch first 1 rows only

--15)  طی سال 1996 هر ماه چند سفارش ثبت شده است؟

with table1 as (
select OrderDate, count(OrderID ) as cnt from Orders
where extract(year from OrderDate) = 1996
group by OrderDate
)

select extract(month from OrderDate) as number_of_month, sum(t1.CNT) as order_count from table1 t1
group by extract(month from OrderDate)
order by number_of_month

 
--16)  میانگین فاصله ی زمانی بین سفارشات هر مشتری چقدر بوده؟
-- به همراه نام مشتری و به ترتیب نزولی نشان دهید


--17) در هر فصل جمع سفارشات چقدر بودهاست؟ 
-- به ترتیب نزولی نشان دهید

with Season as (
SELECT OrderID, OrderDate, 
CASE
    WHEN extract(month from OrderDate) in (1,2,3) and extract(year from OrderDate) = 1996 THEN 'Season1_1996'
    WHEN extract(month from OrderDate) in (4,5,6) and extract(year from OrderDate) = 1996 THEN 'Season2_1996'
    WHEN extract(month from OrderDate) in (7,8,9) and extract(year from OrderDate) = 1996 THEN 'Season3_1996'
    WHEN extract(month from OrderDate) in (10,11,12) and extract(year from OrderDate) = 1996 THEN 'Season4_1996'
    WHEN extract(month from OrderDate) in (1,2,3) and extract(year from OrderDate) = 1997 THEN 'Season1_1997'
    WHEN extract(month from OrderDate) in (4,5,6) and extract(year from OrderDate) = 1997 THEN 'Season2_1997'
    WHEN extract(month from OrderDate) in (7,8,9) and extract(year from OrderDate) = 1997 THEN 'Season3_1997'
    ELSE 'Season4_1997'
END AS Season
FROM Orders
)

select s.SEASON, count(s.ORDERID) as total_order from Season s
group by s.SEASON
order by total_order desc

--18)  کدام تامین کننده بیشترین تعداد کالا را تامین کرده است؟
-- به همراه نام و آی دی گزارش کنید

with jn1 as (
select sp.SUPPLIERNAME, sp.SUPPLIERID, p.PRODUCTID from
Suppliers sp join Products p on sp.SUPPLIERID = p.SUPPLIERID
)

select j1.SUPPLIERID, j1.SUPPLIERNAME, sum(ode.QUANTITY) as total_product from 
jn1 j1 join OrderDetails ode on j1.PRODUCTID = ode.PRODUCTID
group by j1.SUPPLIERID, j1.SUPPLIERNAME
order by total_product desc
fetch first 1 rows only

--19) میانگین قیمت کالای تامین شده توسط هر تامین کننده چقدر بوده؟ 
-- به همراه نام و آی دی و به ترتیب نزولی گزارش کنید

with jn1 as (
select sp.SUPPLIERNAME, sp.SUPPLIERID, p.PRICE, p.PRODUCTID from
Suppliers sp join Products p on sp.SUPPLIERID = p.SUPPLIERID
)

select j1.SUPPLIERID, j1.SUPPLIERNAME, avg(j1.PRICE * ode.Quantity) as avg_price from 
jn1 j1 join OrderDetails ode on j1.PRODUCTID = ode.PRODUCTID
group by j1.SUPPLIERID, j1.SUPPLIERNAME
order by avg_price desc

