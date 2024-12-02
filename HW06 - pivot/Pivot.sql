/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "05 - Операторы CROSS APPLY, PIVOT, UNPIVOT".

Задания выполняются с использованием базы данных WideWorldImporters.

Бэкап БД можно скачать отсюда:
https://github.com/Microsoft/sql-server-samples/releases/tag/wide-world-importers-v1.0
Нужен WideWorldImporters-Full.bak

Описание WideWorldImporters от Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

-- ---------------------------------------------------------------------------
-- Задание - написать выборки для получения указанных ниже данных.
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*
1. Требуется написать запрос, который в результате своего выполнения 
формирует сводку по количеству покупок в разрезе клиентов и месяцев.
В строках должны быть месяцы (дата начала месяца), в столбцах - клиенты.

Клиентов взять с ID 2-6, это все подразделение Tailspin Toys.
Имя клиента нужно поменять так чтобы осталось только уточнение.
Например, исходное значение "Tailspin Toys (Gasport, NY)" - вы выводите только "Gasport, NY".
Дата должна иметь формат dd.mm.yyyy, например, 25.12.2019.

Пример, как должны выглядеть результаты:
-------------+--------------------+--------------------+-------------+--------------+------------
InvoiceMonth | Peeples Valley, AZ | Medicine Lodge, KS | Gasport, NY | Sylvanite, MT | Jessie, ND
-------------+--------------------+--------------------+-------------+--------------+------------
01.01.2013   |      3             |        1           |      4      |      2        |     2
01.02.2013   |      7             |        3           |      4      |      2        |     1
-------------+--------------------+--------------------+-------------+--------------+------------
*/

select
	Order_date
	,[Peeples Valley, AZ]
	,[Medicine Lodge, KS]
	,[Gasport, NY]
	,[Sylvanite, MT]
	,[Jessie, ND]
from
(
select
	format(datefromparts(year(o.OrderDate), month(o.OrderDate), 1), 'dd.MM.yyyy') as Order_date
	,replace(replace(c.CustomerName, 'Tailspin Toys (', ''), ')', '') as Customer_name
	,count(1) as Purchases_cnt
from Sales.Orders as o
join Sales.Customers as c on o.CustomerID = c.CustomerID
where
	c.CustomerName like 'Tailspin Toys%'
	and o.CustomerID in (2, 3, 4, 5, 6)
group by
	format(datefromparts(year(o.OrderDate), month(o.OrderDate), 1), 'dd.MM.yyyy')
	,replace(replace(c.CustomerName, 'Tailspin Toys (', ''), ')', '')
) as Source
pivot
(
sum(Purchases_cnt)
for Customer_name in ([Peeples Valley, AZ], [Medicine Lodge, KS], [Gasport, NY], [Sylvanite, MT], [Jessie, ND])
) as Pivot_table

/*
2. Для всех клиентов с именем, в котором есть "Tailspin Toys"
вывести все адреса, которые есть в таблице, в одной колонке.

Пример результата:
----------------------------+--------------------
CustomerName                | AddressLine
----------------------------+--------------------
Tailspin Toys (Head Office) | Shop 38
Tailspin Toys (Head Office) | 1877 Mittal Road
Tailspin Toys (Head Office) | PO Box 8975
Tailspin Toys (Head Office) | Ribeiroville
----------------------------+--------------------
*/

select
	CustomerName
	,Address_line
from
(
select 
	CustomerName
	,deliveryaddressline1
	,deliveryaddressline2
	,PostalAddressLine1
	,PostalAddressLine2
from Sales.Customers 
where
	CustomerName like 'Tailspin Toys%'
) as t1
unpivot
(
Address_line for AddressType in (deliveryaddressline1
	,deliveryaddressline2
	,PostalAddressLine1
	,PostalAddressLine2)
) as Unpivot_table


/*
3. В таблице стран (Application.Countries) есть поля с цифровым кодом страны и с буквенным.
Сделайте выборку ИД страны, названия и ее кода так, 
чтобы в поле с кодом был либо цифровой либо буквенный код.

Пример результата:
--------------------------------
CountryId | CountryName | Code
----------+-------------+-------
1         | Afghanistan | AFG
1         | Afghanistan | 4
3         | Albania     | ALB
3         | Albania     | 8
----------+-------------+-------
*/

select 
	Country_id
	,Country_name
	,[Code]
from
(
select 
	CountryId as Country_id
	,CountryName as Country_name
	,IsoAlpha3Code as Alpha_code
	,cast(IsoNumericCode as nvarchar(3)) as Numeric_code
from [Application].Countries
) as t1
unpivot
(
[Code] for Code_type in (Alpha_code, Numeric_code)
) as Unpivot_table

/*
4. Выберите по каждому клиенту два самых дорогих товара, которые он покупал.
В результатах должно быть ид клиета, его название, ид товара, цена, дата покупки.
*/

select
  c.CustomerID
  ,c.CustomerName
  ,x.StockItemID
  ,x.UnitPrice
  ,x.OrderDate
from
  Sales.Customers c
  cross apply (
    select
      oi.StockItemID
      ,oi.UnitPrice
      ,so.OrderDate
      ,dense_rank() over(partition by so.CustomerID order by oi.UnitPrice desc) as PriceRank
    from
      Sales.Orders so
      join Sales.OrderLines oi on so.OrderID = oi.OrderID
    where 
      so.CustomerID = c.CustomerID
  ) x
where 
  x.PriceRank <= 2




