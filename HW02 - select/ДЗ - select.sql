/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.
Занятие "02 - Оператор SELECT и простые фильтры, JOIN".

Задания выполняются с использованием базы данных WideWorldImporters.

Бэкап БД WideWorldImporters можно скачать отсюда:
https://github.com/Microsoft/sql-server-samples/releases/download/wide-world-importers-v1.0/WideWorldImporters-Full.bak

Описание WideWorldImporters от Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

-- ---------------------------------------------------------------------------
-- Задание - написать выборки для получения указанных ниже данных.
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*
1. Все товары, в названии которых есть "urgent" или название начинается с "Animal".
Вывести: ИД товара (StockItemID), наименование товара (StockItemName).
Таблицы: Warehouse.StockItems.
*/

select 
	StockItemID
	,StockItemName
from Warehouse.StockItems
where
	StockItemName like '%urgent%'
	or StockItemName like 'Animal%'

/*
2. Поставщиков (Suppliers), у которых не было сделано ни одного заказа (PurchaseOrders).
Сделать через JOIN, с подзапросом задание принято не будет.
Вывести: ИД поставщика (SupplierID), наименование поставщика (SupplierName).
Таблицы: Purchasing.Suppliers, Purchasing.PurchaseOrders.
По каким колонкам делать JOIN подумайте самостоятельно.
*/

select
	s.SupplierID
	,s.SupplierName
from Purchasing.Suppliers as s
left join Purchasing.PurchaseOrders as po on s.SupplierID = po.SupplierID
where
	po.SupplierID is null

/*
3. Заказы (Orders) с ценой товара (UnitPrice) более 100$ 
либо количеством единиц (Quantity) товара более 20 штук
и присутствующей датой комплектации всего заказа (PickingCompletedWhen).
Вывести:
* OrderID
* дату заказа (OrderDate) в формате ДД.ММ.ГГГГ
* название месяца, в котором был сделан заказ
* номер квартала, в котором был сделан заказ
* треть года, к которой относится дата заказа (каждая треть по 4 месяца)
* имя заказчика (Customer)
Добавьте вариант этого запроса с постраничной выборкой,
пропустив первую 1000 и отобразив следующие 100 записей.

Сортировка должна быть по номеру квартала, трети года, дате заказа (везде по возрастанию).

Таблицы: Sales.Orders, Sales.OrderLines, Sales.Customers.
*/

select distinct
	o.OrderID
	,format(o.OrderDate, 'dd.MM.yyyy') as order_date
	,datename(month, o.OrderDate) as month_name
	,datepart(quarter, o.OrderDate) as order_quarter
	,case
		when month(o.OrderDate) between 1 and 4 then 1
        when month(o.OrderDate) between 5 and 8 then 2
        else 3
    end as third_of_year
	,c.CustomerName
from Sales.Orders as o
join Sales.OrderLines as ol on o.OrderID = ol.OrderID
join Sales.Customers as c on o.CustomerID = c.CustomerID
where
	(ol.UnitPrice > 100
	or ol.Quantity > 20)
	and ol.PickingCompletedWhen is not null
order by
	order_quarter
	,third_of_year
	,order_date
offset 1000 rows fetch next 200 rows only

/*
4. Заказы поставщикам (Purchasing.Suppliers),
которые должны быть исполнены (ExpectedDeliveryDate) в январе 2013 года
с доставкой "Air Freight" или "Refrigerated Air Freight" (DeliveryMethodName)
и которые исполнены (IsOrderFinalized).
Вывести:
* способ доставки (DeliveryMethodName)
* дата доставки (ExpectedDeliveryDate)
* имя поставщика
* имя контактного лица принимавшего заказ (ContactPerson)

Таблицы: Purchasing.Suppliers, Purchasing.PurchaseOrders, Application.DeliveryMethods, Application.People.
*/

select
	dm.DeliveryMethodName
	,po.ExpectedDeliveryDate
	,s.SupplierName
	,p.FullName as ContactPerson
from Purchasing.PurchaseOrders as po
left join [Application].DeliveryMethods as dm on po.DeliveryMethodID = dm.DeliveryMethodID
left join Purchasing.Suppliers as s on po.SupplierID = s.SupplierID
left join [Application].People as p on po.ContactPersonID = p.PersonID
where
	po.ExpectedDeliveryDate between '2013-01-01' and '2013-01-31'
	and (dm.DeliveryMethodName = 'Air Freight' or dm.DeliveryMethodName = 'Refrigerated Air Freight')
	and po.IsOrderFinalized = 1

/*
5. Десять последних продаж (по дате продажи) с именем клиента и именем сотрудника,
который оформил заказ (SalespersonPerson).
Сделать без подзапросов.
*/

/* Непонятно какие столбцы вывести из таблицы продаж, поэтому вывел всё плюс требуемые столбцы из справочников.
Так как в условии не сказано о каких конктретно последних 10 продаж идёт речь, вывел просто 10 последних строк по дате продажи. */

select top 10
	o.*
	,c.CustomerName
	,p.FullName
from Sales.Orders as o
left join Sales.Customers as c on o.CustomerID = c.CustomerID
left join [Application].People as p on o.SalespersonPersonID = p.PersonID
order by
	o.OrderDate desc

/*
6. Все ид и имена клиентов и их контактные телефоны,
которые покупали товар "Chocolate frogs 250g".
Имя товара смотреть в таблице Warehouse.StockItems.
*/

/* Непонятно что подразумаеватся под "Все ид", поэтому были выведены все ID из таблиц, участвуюзих в запросе.*/

select distinct
	o.OrderID as Orders_OrderID
	,o.CustomerID
	,o.SalespersonPersonID
	,o.PickedByPersonID
	,o.ContactPersonID
	,o.BackorderOrderID
	,ol.OrderLineID
	,ol.OrderID as OrderLines_OrderID
	,ol.StockItemID as OrderLines_StockItemID
	,ol.PackageTypeID
	,c.CustomerID
	,c.BillToCustomerID
	,c.CustomerCategoryID
	,c.BuyingGroupID
	,c.PrimaryContactPersonID
	,c.AlternateContactPersonID
	,c.DeliveryMethodID
	,c.DeliveryCityID
	,c.PostalCityID
	,si.StockItemID as StockItems_StockItemID
	,si.SupplierID
	,si.ColorID
	,si.UnitPackageID
	,si.OuterPackageID
	,c.CustomerName
	,c.PhoneNumber
from Sales.Orders as o
left join Sales.OrderLines as ol on o.OrderID = ol.OrderID
left join Sales.Customers as c on o.CustomerID = c.CustomerID
left join Warehouse.StockItems as si on ol.StockItemID = si.StockItemID
where
	ol.[Description] = 'Chocolate frogs 250g'

