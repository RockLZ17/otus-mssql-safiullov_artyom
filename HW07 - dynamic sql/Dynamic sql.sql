/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "07 - Динамический SQL".

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

Это задание из занятия "Операторы CROSS APPLY, PIVOT, UNPIVOT."
Нужно для него написать динамический PIVOT, отображающий результаты по всем клиентам.
Имя клиента указывать полностью из поля CustomerName.

Требуется написать запрос, который в результате своего выполнения 
формирует сводку по количеству покупок в разрезе клиентов и месяцев.
В строках должны быть месяцы (дата начала месяца), в столбцах - клиенты.

Дата должна иметь формат dd.mm.yyyy, например, 25.12.2019.

Пример, как должны выглядеть результаты:
-------------+--------------------+--------------------+----------------+----------------------
InvoiceMonth | Aakriti Byrraju    | Abel Spirlea       | Abel Tatarescu | ... (другие клиенты)
-------------+--------------------+--------------------+----------------+----------------------
01.01.2013   |      3             |        1           |      4         | ...
01.02.2013   |      7             |        3           |      4         | ...
-------------+--------------------+--------------------+----------------+----------------------
*/

declare @sql nvarchar(max) = ''
declare @pivot_list nvarchar(max) = ''

-- Получаем список клиентов -
select 
	@pivot_list += '[' + CustomerName + '],'
from Sales.Customers


-- Удаляем последнюю запятую --
set @pivot_list = left(@pivot_list, len(@pivot_list) - 1)

-- Формируем динамический SQL --
set @sql = '
    select
        Order_date
        ,' + @pivot_list + '
    from
    (
        select top 1000
            format(datefromparts(year(o.OrderDate), month(o.OrderDate), 1), ''d'') as Order_date
            ,c.CustomerName as Customer_name
            ,count(1) as Purchases_cnt
        from Sales.Orders as o
        join Sales.Customers as c on o.CustomerID = c.CustomerID
        group by
            format(datefromparts(year(o.OrderDate), month(o.OrderDate), 1), ''d'')
            ,c.CustomerName
    ) as Source
    pivot
    (
        sum(Purchases_cnt)
        for Customer_name in (' + @pivot_list + ')
    ) as Pivot_table
'

-- Выполняем динамический SQL
exec sp_executesql @sql



