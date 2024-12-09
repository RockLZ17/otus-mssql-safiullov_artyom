/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "10 - Операторы изменения данных".

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
1. Довставлять в базу пять записей используя insert в таблицу Customers или Suppliers 
*/

insert into Sales.Customers
	(
	CustomerID
	,CustomerName
	,BillToCustomerID
	,CustomerCategoryID
	,PrimaryContactPersonID
	,DeliveryMethodID
	,DeliveryCityID
	,PostalCityID
	,AccountOpenedDate
	,StandardDiscountPercentage
	,IsStatementSent
	,IsOnCreditHold
	,PaymentDays
	,PhoneNumber
	,FaxNumber
	,WebsiteURL
	,DeliveryAddressLine1
	,DeliveryPostalCode
	,PostalAddressLine1
	,PostalPostalCode
	,LastEditedBy
	)
values
	(
	next value for sequences.CustomerID
	,'Test_CustomerName_1'
	,1
	,1
	,1
	,1
	,1
	,1
	,getdate()
	,0.000
	,0
	,0
	,0
	,'Test_PhoneNumber_1'
	,'Test_FaxNumber_1'
	,'Test_WebsiteURL_1'
	,'Test_DeliveryAddressLine1_1'
	,'12345'
	,'Test_PostalAddressLine1_1'
	,'12345'
	,1
	),
	(
	next value for sequences.CustomerID
	,'Test_CustomerName_2'
	,1
	,1
	,1
	,1
	,1
	,1
	,getdate()
	,0.000
	,0
	,0
	,0
	,'Test_PhoneNumber_1'
	,'Test_FaxNumber_1'
	,'Test_WebsiteURL_1'
	,'Test_DeliveryAddressLine1_1'
	,'12345'
	,'Test_PostalAddressLine1_1'
	,'12345'
	,1
	),
	(
	next value for sequences.CustomerID
	,'Test_CustomerName_3'
	,1
	,1
	,1
	,1
	,1
	,1
	,getdate()
	,0.000
	,0
	,0
	,0
	,'Test_PhoneNumber_1'
	,'Test_FaxNumber_1'
	,'Test_WebsiteURL_1'
	,'Test_DeliveryAddressLine1_1'
	,'12345'
	,'Test_PostalAddressLine1_1'
	,'12345'
	,1
	),
	(
	next value for sequences.CustomerID
	,'Test_CustomerName_4'
	,1
	,1
	,1
	,1
	,1
	,1
	,getdate()
	,0.000
	,0
	,0
	,0
	,'Test_PhoneNumber_1'
	,'Test_FaxNumber_1'
	,'Test_WebsiteURL_1'
	,'Test_DeliveryAddressLine1_1'
	,'12345'
	,'Test_PostalAddressLine1_1'
	,'12345'
	,1
	),
	(
	next value for sequences.CustomerID
	,'Test_CustomerName_5'
	,1
	,1
	,1
	,1
	,1
	,1
	,getdate()
	,0.000
	,0
	,0
	,0
	,'Test_PhoneNumber_1'
	,'Test_FaxNumber_1'
	,'Test_WebsiteURL_1'
	,'Test_DeliveryAddressLine1_1'
	,'12345'
	,'Test_PostalAddressLine1_1'
	,'12345'
	,1
	)

/*
2. Удалите одну запись из Customers, которая была вами добавлена
*/

delete Sales.Customers
where CustomerID = 1071

/*
3. Изменить одну запись, из добавленных через UPDATE
*/

update Sales.Customers
set CustomerName = 'Test_CustomerName_4_Update'
where CustomerID = 1070

/*
4. Написать MERGE, который вставит вставит запись в клиенты, если ее там нет, и изменит если она уже есть
*/

select *
into Sales.Customers_Copy
from Sales.Customers

update sales.Customers_Copy
set BillToCustomerID = 2
where CustomerID = 1070

insert into Sales.Customers_Copy
	(
	CustomerID
	,CustomerName
	,BillToCustomerID
	,CustomerCategoryID
	,PrimaryContactPersonID
	,DeliveryMethodID
	,DeliveryCityID
	,PostalCityID
	,AccountOpenedDate
	,StandardDiscountPercentage
	,IsStatementSent
	,IsOnCreditHold
	,PaymentDays
	,PhoneNumber
	,FaxNumber
	,WebsiteURL
	,DeliveryAddressLine1
	,DeliveryPostalCode
	,PostalAddressLine1
	,PostalPostalCode
	,LastEditedBy
	,ValidTo
	,ValidFrom
	)
values
	(
	next value for sequences.CustomerID
	,'Test_CustomerName_Merge'
	,1
	,1
	,1
	,1
	,1
	,1
	,getdate()
	,0.000
	,0
	,0
	,0
	,'Test_PhoneNumber_1'
	,'Test_FaxNumber_1'
	,'Test_WebsiteURL_1'
	,'Test_DeliveryAddressLine1_1'
	,'12345'
	,'Test_PostalAddressLine1_1'
	,'12345'
	,1
	,'9999-12-31 23:59:59.9999999'
	,getdate()
	)



merge Sales.Customers as target 
using Sales.Customers_Copy as source
on target.customerid = source.customerid
when matched
then target.billtocustomerid = source.billtocustomerid
when not matched
    then insert Sales.Customers values (...)
WHEN NOT MATCHED BY SOURCE
    THEN DELETE;


/*
5. Напишите запрос, который выгрузит данные через bcp out и загрузить через bulk insert
*/
