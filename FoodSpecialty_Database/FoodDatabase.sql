USE blihardi_specialty_food_database

/* 
Count the number of records in the order table. 
*/

SELECT 
    COUNT(*) AS 'Records'
FROM
    Orders;

/*
The warehouse manager wants to know all of the products the company carries. 
Generate a list of all the products with all of the columns. 
*/

SELECT 
    *
FROM
    Products
GROUP BY ProductName;

/*
19.	The marketing department wants to run a direct mail marketing campaign to its American, Canadian, and Mexican customers. 
Write a query to gather the data needed for a mailing label. 
*/

SELECT 
    *
FROM
    Customers
WHERE
    Country = 'USA' OR Country = 'Canada'
        OR Country = 'Mexico';

/*
HR wants to celebrate hire date anniversaries for the sales representatives in the USA office. 
Develop a query that would give HR the information they need to coordinate hire date anniversary gifts. 
Sort the data as you see best fit. 
*/

SELECT 
    *
FROM
    Employees
WHERE
    Country = 'USA'
        AND Title = 'Sales Representative'
GROUP BY HireDate
ORDER BY HireDate;

/*
Customer service noticed an increase in shipping errors for orders handled by the employee, Janet Leverling. 
Return the OrderIDs handled by Janet so that the orders can be inspected for other errors. (2 points)
*/

SELECT 
    Orders.OrderID,
    CONCAT(Employees.FirstName,
            ' ',
            Employees.LastName) AS 'FullName'
FROM
    Orders
        JOIN
    Employees ON Orders.EmployeeID = Employees.EmployeeID
HAVING FullName = 'Janet Leverling'
ORDER BY OrderID;

/*
22.	The sales team wants to develop stronger supply chain relationships with its suppliers by reaching out to the managers 
who have the decision making power to create a just-in-time inventory arrangement. Display the supplier's company name, contact name, title, 
and phone number for suppliers who have manager or mgr in their title. 
*/

SELECT 
    CompanyName, ContactName, ContactTitle, Phone
FROM
    Suppliers
WHERE
    ContactTitle LIKE '%Manager%'
        OR ContactTitle LIKE '%Mgr%'
ORDER BY CompanyName;

/*
The warehouse packers want to label breakable products with a fragile sticker. 
Identify the products with glasses, jars, or bottles and are not discontinued (0 = not discontinued). 
*/

SELECT 
    ProductName, QuantityPerUnit, Discontinued
FROM
    Products
WHERE
    QuantityPerUnit LIKE '%glass%'
        OR QuantityPerUnit LIKE '%jar%'
        OR QuantityPerUnit LIKE '%bottle%'
        AND Discontinued = 0
ORDER BY ProductName;

/*
How many customers are from Brazil and have a role in sales? Your query should only return 1 row. 
*/

SELECT 
    COUNT(*) AS 'TotalCustomers'
FROM
    Customers
WHERE
    Country = 'Brazil'
        AND ContactTitle LIKE '%sales%';

/*
Who is the oldest employee in terms of age? Your query should only return 1 row. 
*/

SELECT 
    CONCAT(FirstName, ' ', LastName) AS 'FullName',
    2021 - YEAR(BirthDate) AS 'Age'
FROM
    Employees
ORDER BY BirthDate ASC
LIMIT 1;

/*
Calculate the total order price per order and product before and after the discount. 
The products listed should only be for those where a discount was applied. 
Alias the before discount and after discount expressions. 
*/

SELECT 
    *,
    UnitPrice * Quantity AS 'BeforeDiscount',
    (UnitPrice * Quantity) - ROUND(((UnitPrice * Quantity) * Discount), 2) AS 'AfterDiscount'
FROM
    OrderDetails
WHERE
    Discount != 0;


/*
To assist in determining the company's assets, find the total dollar value for all products in stock. 
*/

SELECT 
    SUM(UnitPrice * UnitsInStock) AS 'total_dollar_value'
FROM
    Products
WHERE
    UnitsInStock != 0;

/*
Supplier deliveries are confirmed via email and fax. Create a list of suppliers with a missing fax number 
to help the warehouse receiving team identify who to contact to fill in the missing information. 
*/

SELECT 
    *
FROM
    Suppliers
WHERE
    Fax IS NULL;

/*
The PR team wants to promote the company's global presence on the website. 
Identify a unique and sorted list of countries where the company has customers. 
*/

SELECT DISTINCT
    Country,
    GROUP_CONCAT(ContactName
        SEPARATOR ', ') AS 'list_of_contact'
FROM
    Customers
GROUP BY Country
ORDER BY Country;

/*
You're the newest hire. INSERT yourself as an employee. 
You can arbitrarily set the column values as long as they are related to the column. 
*/

INSERT INTO Employees (EmployeeID, LastName, FirstName, Title, TitleOfCourtesy, 
						BirthDate, HireDate, Address, City, Region, PostalCode, 
                        Country, HomePhone, Extension, Notes, ReportsTo, PhotoPath)
VALUES ('', 'Roscoe', 'Joe', 'Sales Manager', 'Mr.', '1982-02-02 00:00:00', '2015-12-12 00:00:00', '770 Broadway', 'New York City',
		'NY', '10001', 'USA', '(917) 123-1234', '1212', 'Education includes BA in sociology', '2', 'http://accweb/employees/etc.bmp');

/*
The supplier, Bigfoot Breweries, recently launched their website. 
UPDATE their website to bigfootbreweries.com. 
*/

UPDATE Suppliers 
SET 
    HomePage = 'bigfootbreweries.com'
WHERE
    CompanyName = 'Bigfoot Breweries';

/*
The images on the employee profiles are broken. 
The link to the employee headshot is missing the .com domain extension. 
Fix the PhotoPath link so that the domain properly resolves. 
Broken link example: http://accweb/emmployees/buchanan.bmp (2 points)
*/

UPDATE Employees 
SET 
    PhotoPath = REPLACE(PhotoPath,
        'accweb/',
        'accweb.com/');

/*
Create a table each to identify the Low, Medium and High group companies based on their total order amount.  
Each table should contain the company name, the total order quantity and the group description that it belongs to.  
*/


CREATE VIEW company_asset AS
    SELECT 
        Customers.CompanyName,
        Products.Unitprice * Products.UnitsInStock AS 'total'
    FROM
        Customers
            JOIN
        Orders ON Customers.CustomerID = Orders.CustomerID
            JOIN
        OrderDetails ON Orders.OrderID = OrderDetails.OrderID
            JOIN
        Products ON OrderDetails.ProductID = Products.ProductID
    GROUP BY Customers.CompanyName;

SELECT 
    *,
    CASE
        WHEN total BETWEEN 0 AND 1000.00 THEN 'Low'
        WHEN total BETWEEN 1000.00 AND 5000.00 THEN 'Medium'
        WHEN total BETWEEN 5000.00 AND 10000.00 THEN 'High'
        WHEN total BETWEEN 10000.00 AND 922337203685 THEN 'Very High'
    END AS group_name
FROM
    company_asset
ORDER BY total;

/*
Custom Data Request. For each request:
*/

/*
Request 1: What are the top and the bottom 10 of purchased products by total sales including the discontinued item throughout the record?

It is important for a manager to analyze the the most and the least profitable products so companies can allocate their money and resources to focus on the most profitable goods. 
*/

CREATE VIEW TOP10 AS
    SELECT 
        Products.ProductName,
        SUM(OrderDetails.UnitPrice * OrderDetails.Quantity) AS 'TotalSales',
        Products.Discontinued,
        'TOP 10' AS Rank
    FROM
        Products
            JOIN
        OrderDetails ON Products.ProductID = OrderDetails.ProductID
    GROUP BY ProductName
    ORDER BY TotalSales DESC
    LIMIT 10;

CREATE VIEW BOTTOM10 AS
    SELECT 
        Products.ProductName,
        SUM(OrderDetails.UnitPrice * OrderDetails.Quantity) AS 'TotalSales',
        Products.Discontinued,
        'Bottom 10' AS Rank
    FROM
        Products
            JOIN
        OrderDetails ON Products.ProductID = OrderDetails.ProductID
    GROUP BY ProductName
    ORDER BY TotalSales ASC
    LIMIT 10;

SELECT 
    *
FROM
    TOP10 
UNION SELECT 
    *
FROM
    BOTTOM10
ORDER BY TotalSales DESC;

/*
Aside the new hire, a manager wants to give bonus to the highest performing employee who processed the most order in 2015. 
At the same time, a manager also needs to know the most underperforming employee so he/she can reanalyze the strength and weakness of that particular employee. 
The manager needs the first and last name as well as his/her titles
Side note: we are assuming that the data request was placed in 2016 during the end of Q4 2015. 

It is important for a manager to acknowledge the amount of work that employees do to get the business operation running. 
Happy employees are the most productive employees. 
*/

CREATE VIEW totalorder AS
    SELECT 
        EmployeeID,
        COUNT(*) AS 'totalorder',
        YEAR(OrderDate) AS 'YEAR'
    FROM
        Orders
    WHERE
        YEAR(OrderDate) = 2015
    GROUP BY EmployeeID
    ORDER BY totalorder DESC;

SELECT 
    totalorder.EmployeeID,
    CONCAT(Employees.FirstName,
            ' ',
            Employees.LastName) AS 'FullName',
    Employees.Title,
    totalorder.totalorder AS 'Total order',
    totalorder.YEAR
FROM
    Employees
        JOIN
    totalorder ON Employees.EmployeeID = totalorder.EmployeeID
ORDER BY totalorder.totalorder DESC;


/*
Are there any changes in UnitPrice for all the product? If so, how much does the price increase/decrease in % or ratio?

A manager needs to know when supplier made a change to the price and devises a new strategy to re-negotiate the price if needed. 
*/

CREATE VIEW max_min AS
    SELECT 
        ProductID,
        MIN(UnitPrice) AS 'Min_Price',
        MAX(UnitPrice) AS 'Max_Price'
    FROM
        OrderDetails
    GROUP BY ProductID
    ORDER BY ProductID;

SELECT 
    max_min.ProductID,
    Products.ProductName,
    max_min.Min_Price,
    max_min.Max_Price,
    max_min.Max_Price - max_min.Min_Price AS 'price differences',
    ((max_min.Max_Price - max_min.Min_Price) / max_min.Min_Price) AS 'ratio'
FROM
    max_min
        JOIN
    Products ON max_min.ProductID = Products.ProductID
ORDER BY ratio DESC;

/*
Check the difference between units in stock and units on order and analyze if the number of the units on order may cause backorder.

It is important to check the status of all inventories to ensure that there is enough stock for other customers to make a purchase. 
*/

CREATE OR REPLACE VIEW backorder AS
    SELECT 
        ProductName,
        UnitsInStock,
        UnitsOnOrder,
        UnitsInStock - UnitsOnOrder AS 'BackOrder'
    FROM
        Products
    WHERE
        UnitsOnOrder != 0 AND Discontinued = 0;

SELECT 
    *, IF(BackOrder < 0, 'Yes', 'No') AS 'Backorder?'
FROM
    backorder
ORDER BY `Backorder?` DESC;

/*
Sometimes, customers want to check the price of one item (not one unit) so they can compare price of the same product with other companies. 
Side note: One item refers to one single item per unit. If a unit has 12 items, we want to know how much one single item cost?

Many customers are always searching for the best price especially when they buy in bulk. 
Comparing the price of one single item is important to stay competitive in the market.  
*/

CREATE VIEW UnitPrice AS
    SELECT 
        ProductName,
        QuantityPerUnit,
        SUBSTRING_INDEX(QuantityPerUnit, ' ', 1) AS 'Quantity per Unit',
        UnitPrice
    FROM
        Products;

SELECT 
    *,
    ROUND((UnitPrice / `Quantity Per Unit`), 2) AS 'one_unit_price'
FROM
    UnitPrice
ORDER BY ProductName;

