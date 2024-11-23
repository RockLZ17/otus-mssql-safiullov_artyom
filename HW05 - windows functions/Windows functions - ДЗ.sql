/*1. Сделать расчет суммы продаж нарастающим итогом по месяцам с 2015 года
(в рамках одного месяца он будет одинаковый, нарастать будет в течение времени выборки).
Нарастающий итог должен быть без оконной функции. */

select 
    t1.[Month],
    t1.[Year],
    t1.Sales_sum,
    (select sum(t2.Sales_sum) 
     from (
         select 
             month(i.OrderDate) as [Month],
             year(i.OrderDate) as [Year],
             sum(il.Quantity * il.UnitPrice) as Sales_sum
         from Sales.Orders as i
         left join Sales.OrderLines as il on i.OrderID = il.OrderID
         where 
			i.OrderDate >= '2015-01-01'
         group by 
			month(i.OrderDate) 
			,year(i.OrderDate)
     ) as t2
     where 
		t2.[Year] <= t1.[Year] 
		and t2.[Month] <= t1.[Month]) as Running_total
from (
	select
		month(i.OrderDate) as [Month]
        ,year(i.OrderDate) as [Year]
        ,sum(il.Quantity * il.UnitPrice) as Sales_sum
    from Sales.Orders as i
    left join Sales.OrderLines as il on i.OrderID = il.OrderID
    where 
		i.OrderDate >= '2015-01-01'
    group by 
		month(i.OrderDate) 
		,year(i.OrderDate)
	) as t1
order by 
	t1.[Year] 
	,t1.[Month]

/* Время работы SQL Server:
   Время ЦП = 1282 мс, затраченное время = 1631 мс. */

/* 2. Сделайте расчет суммы нарастающим итогом в предыдущем запросе с помощью оконной функции.
Сравните производительность запросов 1 и 2 с помощью set statistics time, io on */

select
    [Month],
    [Year],
    Sales_sum,
    sum(Sales_sum) over(order by [Year], [Month]) as RunningTotal
from (
    select 
        month(i.OrderDate) as [Month],
        year(i.OrderDate) as [Year],
        sum(il.Quantity * il.UnitPrice) as Sales_sum
    from Sales.Orders as i
    left join Sales.OrderLines as il on i.OrderID = il.OrderID
    where 
		i.OrderDate >= '2015-01-01'
    group by 
		month(i.OrderDate)
		,year(i.OrderDate)
) as t
order by 
	[Year]
	,[Month]

/* Время работы SQL Server:
   Время ЦП = 31 мс, затраченное время = 35 мс. */

/* 3. Вывести список 2х самых популярных продуктов (по количеству проданных)
в каждом месяце за 2016 год (по 2 самых популярных продукта в каждом месяце). */

with Sales_by_product as (
    select
        month(o.OrderDate) as [Month]
        ,ol.[Description] as Product_name
        ,sum(ol.Quantity) as Quantity
    from Sales.Orders as o
    join Sales.OrderLines as ol ON o.OrderID = ol.OrderID
    where 
		o.OrderDate between '2016-01-01' and '2017-12-31'
    group by 
		month(o.OrderDate)
		,ol.[Description]
),
Ranked_sales_by_product as (
    select 
        [Month]
        ,Product_name
        ,Quantity
        ,rank() over(partition by [Month] order by Quantity desc) as Rn
    from Sales_by_product
)
select 
    [Month]
    ,Product_name
    ,Quantity
from Ranked_sales_by_product
where
	Rn <= 2
order by 
	[Month]
	,Rn


/* 4. Функции одним запросом
Посчитайте по таблице товаров (в вывод также должен попасть ид товара, название, брэнд и цена):

пронумеруйте записи по названию товара, так чтобы при изменении буквы алфавита нумерация начиналась заново
посчитайте общее количество товаров и выведете полем в этом же запросе
посчитайте общее количество товаров в зависимости от первой буквы названия товара
отобразите следующий id товара исходя из того, что порядок отображения товаров по имени
предыдущий ид товара с тем же порядком отображения (по имени)
названия товара 2 строки назад, в случае если предыдущей строки нет нужно вывести "No items"
сформируйте 30 групп товаров по полю вес товара на 1 шт */

select
	StockItemID
	,StockItemName
	,Brand
	,UnitPrice
	,row_number() over (partition by left(StockItemName, 1) order by StockItemName) as Rn
	,count(*) over() as Stock_item_cnt
	,count(*) over(partition by left(StockItemName, 1)) as Stock_item_first_letter_cnt
	,lead(StockItemID) over(order by StockItemName) as next_StockItemID
	,lag(StockItemID) over(order by StockItemName) as prev_StockItemID
	,coalesce(lag(StockItemName, 2) over (order by StockItemName), 'No items') as two_lines_back
from Warehouse.StockItems

/* 5 */

with Latest_sales as (
  select 
    o.SalespersonPersonID,
    c.CustomerID,
    c.CustomerName,
    o.OrderDate,
    ol.Quantity * ol.UnitPrice as Transaction_amount,
    row_number() over(partition by o.SalespersonPersonID order by o.OrderDate desc) as Rn
  from 
    Sales.Orders o
    join Sales.OrderLines ol on o.OrderID = ol.OrderID
    join Sales.Customers c on o.CustomerID = c.CustomerID
)
select
  p.PersonID,
  p.FullName,
  ls.CustomerID,
  ls.CustomerName,
  ls.OrderDate,
  ls.Transaction_amount
from 
  Latest_sales as ls
  join [Application].People p on ls.SalespersonPersonID = p.PersonID
WHERE 
  ls.Rn = 1

/* 6 */

with top_two_items as (
  select 
    c.customerid,
    c.customername,
    si.stockitemid,
    si.unitprice,
    o.orderdate,
    dense_rank() over (partition by c.customerid order by si.unitprice desc) as row_num
  from 
    sales.orders o
    join sales.orderlines ol on o.orderid = ol.orderid
    join sales.customers c on o.customerid = c.customerid
    join warehouse.stockitems si on ol.stockitemid = si.stockitemid
)
select 
  customerid,
  customername,
  stockitemid,
  unitprice,
  orderdate
from 
  top_two_items
where 
  row_num <= 2
