/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "03 - Подзапросы, CTE, временные таблицы".

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
-- Для всех заданий, где возможно, сделайте два варианта запросов:
--  1) через вложенный запрос
--  2) через WITH (для производных таблиц)
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*
1. Выберите сотрудников (Application.People), которые являются продажниками (IsSalesPerson), 
и не сделали ни одной продажи 04 июля 2015 года. 
Вывести ИД сотрудника и его полное имя. 
Продажи смотреть в таблице Sales.Invoices.
*/

/* Вложенный запрос */

select 
	PersonID
	,FullName
from [Application].People
where
	issalesperson = 1
	and PersonID not in (select ContactPersonID from Sales.Invoices where InvoiceDate = '2015-07-04')

/* CTE */

;with q as
	(
	select
		ContactPersonID
	from Sales.Invoices
	where 
		InvoiceDate = '2015-07-04'
	)
select 
	PersonID
	,FullName
from [Application].People
where
	issalesperson = 1
	and PersonID not in (select ContactPersonID from q)

/*
2. Выберите товары с минимальной ценой (подзапросом). Сделайте два варианта подзапроса. 
Вывести: ИД товара, наименование товара, цена.
*/

/* Вложенный запрос */

select distinct
	il.StockItemID
	,il.[Description]
	,(select min(UnitPrice) from Sales.InvoiceLines as il1) as Min_price
from Sales.InvoiceLines as il

/* CTE */

;with q as 
	(
    select 
        min(UnitPrice) as Min_price
    from Sales.InvoiceLines
	)
select distinct
    il.StockItemID,
    il.[Description],
    (select * from q)
from 
    Sales.InvoiceLines il

/*
3. Выберите информацию по клиентам, которые перевели компании пять максимальных платежей 
из Sales.CustomerTransactions. 
Представьте несколько способов (в том числе с CTE). 
*/

/* Вложенный запрос */

select *
from Sales.Customers
where CustomerID in (select top 5 CustomerID from Sales.CustomerTransactions order by TransactionAmount desc)

/* CTE */

;with q as
	(
	select top 5
		CustomerID
	from Sales.CustomerTransactions
	order by 
		TransactionAmount desc
	)
select *
from Sales.Customers
where
	CustomerID in (select CustomerID from q)

/*
4. Выберите города (ид и название), в которые были доставлены товары, 
входящие в тройку самых дорогих товаров, а также имя сотрудника, 
который осуществлял упаковку заказов (PackedByPersonID).
*/

/* Вложенный запрос */

select 
	city.CityID
	,city.CityName
	,p.FullName
from Sales.Invoices as i
left join Sales.Customers as c on i.CustomerID = c.CustomerID
left join [Application].Cities as city on c.DeliveryCityID = city.CityID
left join [Application].People as p on i.PackedByPersonID = p.personid
where 
	i.InvoiceID in (select top 3 InvoiceID from Sales.InvoiceLines order by UnitPrice desc)

/* CTE */

;with q as
	(
	select top 3
		InvoiceID
	from Sales.InvoiceLines
	order by
		UnitPrice desc
	)
select
	city.CityID
	,city.CityName
	,p.FullName
from Sales.Invoices as i
left join Sales.Customers as c on i.CustomerID = c.CustomerID
left join [Application].Cities as city on c.DeliveryCityID = city.CityID
left join [Application].People as p on i.PackedByPersonID = p.personid
where 
	i.InvoiceID in (select InvoiceID from q)

-- ---------------------------------------------------------------------------
-- Опциональное задание
-- ---------------------------------------------------------------------------
-- Можно двигаться как в сторону улучшения читабельности запроса, 
-- так и в сторону упрощения плана\ускорения. 
-- Сравнить производительность запросов можно через SET STATISTICS IO, TIME ON. 
-- Если знакомы с планами запросов, то используйте их (тогда к решению также приложите планы). 
-- Напишите ваши рассуждения по поводу оптимизации. 

-- 5. Объясните, что делает и оптимизируйте запрос

SELECT 
	Invoices.InvoiceID, 
	Invoices.InvoiceDate,
	(SELECT People.FullName
		FROM Application.People
		WHERE People.PersonID = Invoices.SalespersonPersonID
	) AS SalesPersonName,
	SalesTotals.TotalSumm AS TotalSummByInvoice, 
	(SELECT SUM(OrderLines.PickedQuantity*OrderLines.UnitPrice)
		FROM Sales.OrderLines
		WHERE OrderLines.OrderId = (SELECT Orders.OrderId 
			FROM Sales.Orders
			WHERE Orders.PickingCompletedWhen IS NOT NULL	
				AND Orders.OrderId = Invoices.OrderId)	
	) AS TotalSummForPickedItems
FROM Sales.Invoices 
	JOIN
	(SELECT InvoiceId, SUM(Quantity*UnitPrice) AS TotalSumm
	FROM Sales.InvoiceLines
	GROUP BY InvoiceId
	HAVING SUM(Quantity*UnitPrice) > 27000) AS SalesTotals
		ON Invoices.InvoiceID = SalesTotals.InvoiceID
ORDER BY TotalSumm DESC

-- --

TODO: напишите здесь свое решение
