-- Dillard's Database Schema
-- Version 1.0

-- Copyright (c) 2006, 2015, Oracle and/or its affiliates.
-- All rights reserved.

-- Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

--  * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
/* Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution. */
/* --  * Neither the name of Oracle nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission. */

/* THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. */

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL';

-- DROP SCHEMA IF EXISTS kcslmubu_sakila2;
CREATE SCHEMA dillards_dim_model_aws;
USE dillards_dim_model_aws;

/* The following actions are performed in lmu.build
Use tableau prep for departments and stores
Use talend for sku_store
USE blihardi_dillards_dim_model_lmu */

/* Use tableau prep for departments and stores*/

CREATE TABLE departments (
	DEPT INT UNIQUE NOT NULL,
    DEPTDESC VARCHAR(255),
    PRIMARY KEY (DEPT)
);

 CREATE TABLE stores (
	STORE INT UNIQUE NOT NULL,
    CITY VARCHAR(255),
    STATE VARCHAR(2),
    ZIP VARCHAR(10),
    PRIMARY KEY (STORE)
);     

/* Use talend for sku_store*/

CREATE TABLE sku_store (
	SKU INT NOT NULL,
	STORE INT NOT NULL,
    COST FLOAT,
    RETAIL FLOAT,
    FOREIGN KEY (SKU)
        REFERENCES skus (SKU),
	FOREIGN KEY (STORE)
        REFERENCES stores (STORE)
);   


/* The rest is performed at AWS
Use Tableau Prep for the following tables: transactions and dim_dates*/

#dim_date data from tableau prep does not work in the pre-existing table
#Select Distinct * does not work in tableau prep as well and "with" does not work with insert into. 

ALTER TABLE dim_dates 
	MODIFY COLUMN SALEDATE DATE UNIQUE NOT NULL,
	MODIFY COLUMN YEAR VARCHAR(4),
    MODIFY COLUMN Quarter INT(1),
    MODIFY COLUMN MONTH INT(2),
    MODIFY COLUMN MONTH_NAME VARCHAR(20),
    MODIFY COLUMN WEEKNUMBER INT(2),
    MODIFY COLUMN DAY INT(2),
    ADD PRIMARY KEY (SALEDATE); 
    
ALTER TABLE dim_date 
	MODIFY COLUMN SALEDATE DATE UNIQUE NOT NULL,
	MODIFY COLUMN YEAR VARCHAR(4),
    MODIFY COLUMN QUARTER INT(1),
    MODIFY COLUMN MONTH INT(2),
    MODIFY COLUMN MONTH_NAME VARCHAR(20),
    MODIFY COLUMN WEEKNUMBER INT(2),
    MODIFY COLUMN DAY_NO INT(2),
    MODIFY COLUMN DAY VARCHAR(20),
    ADD PRIMARY KEY (SALEDATE); 

#table could not be updated. It is potentially due to no data in SKU
ALTER TABLE transactions 
	MODIFY COLUMN SKU INT NOT NULL,
    MODIFY COLUMN STORE INT NOT NULL,
    MODIFY COLUMN REGISTER INT,
    MODIFY COLUMN TRANNUM INT,
    MODIFY COLUMN INTERID INT,
    MODIFY COLUMN SALEDATE DATE,
    MODIFY COLUMN STYPE VARCHAR(20),
    MODIFY COLUMN QUANTITY INT,
    MODIFY COLUMN ORGPRICE FLOAT,
    MODIFY COLUMN SPRICE FLOAT,
    MODIFY COLUMN AMT FLOAT,
    MODIFY COLUMN SEQ INT,
    MODIFY COLUMN MIC INT,
    ADD FOREIGN KEY (SKU)
        REFERENCES skus (SKU),
	ADD FOREIGN KEY (STORE)
        REFERENCES stores (STORE);

/* Use Talend for skus*/

CREATE TABLE skus (
	SKU INT UNIQUE NOT NULL,
    DEPT INT,
    CLASSID VARCHAR(255),
    UPC VARCHAR(255),
    STYLE VARCHAR(255),
    COLOR VARCHAR(255),
    SIZE VARCHAR(255),
    PACKSIZE INT,
    VENDOR VARCHAR(255),
    BRAND VARCHAR(255),
    PRIMARY KEY (SKU),
    FOREIGN KEY (DEPT)
        REFERENCES departments (DEPT)
);

/* Create the following:
dim_store, dim_sku, dim_type & fact_table_purchase, fact_table_return
Talend: dim_sku and fact_table_return
Tableau Prep: dim_store, dim_type, fact_table_purchase */

#Talend: dim_SKU and fact_table_return

CREATE TABLE dim_SKU (
	SKU INT UNIQUE NOT NULL, 
    DEPT INT, 
    DEPTDESC VARCHAR(255),
    BRAND VARCHAR(255)
);

ALTER TABLE dim_SKU
	ADD PRIMARY KEY (SKU);

CREATE TABLE fact_table_return (
	STORE INT, 
    SKU INT,
    STYPE VARCHAR(10),
    SALEDATE DATE,
    DAILY_TOTAL_REVENUE FLOAT, 
    DAILY_PURCHASE_COUNT INT, 
    TRANSACTION_QUANTITY INT);

ALTER TABLE fact_table_return 
	ADD FOREIGN KEY (STORE)
        REFERENCES dim_store (STORE),
	ADD FOREIGN KEY (SKU)
        REFERENCES dim_SKU (SKU),
	ADD FOREIGN KEY (STYPE)
        REFERENCES dim_type (STYPE),
	ADD FOREIGN KEY (SALEDATE)
        REFERENCES dim_date (SALEDATE);
        
#Tableau Prep: dim_store, dim_type, fact_table_purchase

CREATE TABLE dim_store (
	STORE INT UNIQUE NOT NULL, 
    CITY VARCHAR(255), 
    STATE VARCHAR(2),
    ZIP VARCHAR(10),
    PRIMARY KEY (STORE)
);

CREATE TABLE dim_type(
	STYPE VARCHAR(10) UNIQUE NOT NULL, 
    PRIMARY KEY (STYPE)
);

#dropping rev, cost, profit as the original grouping from tableau prep

ALTER TABLE fact_table_purchase 
	MODIFY COLUMN STORE INT, 
    MODIFY COLUMN SKU INT,
    MODIFY COLUMN STYPE VARCHAR(10),
    MODIFY COLUMN SALEDATE DATE,
    MODIFY COLUMN DAILY_TOTAL_QUANTITY INT, 
    MODIFY COLUMN DAILY_AVG_REVENUE FLOAT,
    MODIFY COLUMN DAILY_TOTAL_REVENUE FLOAT,
    MODIFY COLUMN DAILY_PURCHASE_COUNT INT, 
    MODIFY COLUMN DAILY_TOTAL_PROFIT FLOAT, 
    MODIFY COLUMN DAILY_TOTAL_COST FLOAT,
    DROP COLUMN rev,
    DROP COLUMN cost,
    DROP COLUMN profit,
	ADD FOREIGN KEY (STORE)
        REFERENCES dim_store (STORE),
	ADD FOREIGN KEY (SKU)
        REFERENCES dim_SKU (SKU),
	ADD FOREIGN KEY (STYPE)
        REFERENCES dim_type (STYPE),
	ADD FOREIGN KEY (SALEDATE)
        REFERENCES dim_date (SALEDATE);

/*Data Warehouse Purposes
1: Strategic
2: Operation
3: Analytical*/

/*Strategic:
1. Total revenue per month for April, May, and June in 2005. Return the month name and the month's total revenue.
2. Total purchase count per month for April, May, and June in 2005. Return the month name and the month's total purchase count.
3. Total profit per month for April, May, and June in 2005. Return the month name and the month's total profit.*/

#Strategic 1
SELECT 
    dim_date.MONTH_NAME,
    dim_date.YEAR,
    ROUND(SUM(fact_table_purchase.DAILY_TOTAL_REVENUE),
            2) AS 'TOTAL_REVENUE'
FROM
    dim_date
        JOIN
    fact_table_purchase ON dim_date.SALEDATE = fact_table_purchase.SALEDATE
WHERE
    dim_date.MONTH_NAME IN ('April' , 'May', 'June')
        AND dim_date.YEAR = '2005'
GROUP BY dim_date.MONTH_NAME , dim_date.YEAR;

SELECT * FROM fact_table_return
ORDER BY SKU ASC;

#Strategic 2
SELECT 
    dim_date.MONTH_NAME,
    dim_date.YEAR,
    ROUND(SUM(fact_table_purchase.DAILY_PURCHASE_COUNT),
            2) AS 'TOTAL_COUNT'
FROM
    dim_date
        JOIN
    fact_table_purchase ON dim_date.SALEDATE = fact_table_purchase.SALEDATE
WHERE
    dim_date.MONTH_NAME IN ('April' , 'May', 'June')
        AND dim_date.YEAR = '2005'
GROUP BY dim_date.MONTH_NAME , dim_date.YEAR;

#Strategic 3
SELECT 
    dim_date.MONTH_NAME,
    dim_date.YEAR,
    ROUND(SUM(fact_table_purchase.DAILY_TOTAL_PROFIT),
            2) AS 'TOTAL_PROFIT'
FROM
    dim_date
        JOIN
    fact_table_purchase ON dim_date.SALEDATE = fact_table_purchase.SALEDATE
WHERE
    dim_date.MONTH_NAME IN ('April' , 'May', 'June')
        AND dim_date.YEAR = '2005'
GROUP BY dim_date.MONTH_NAME , dim_date.YEAR;

/*Operational:
1. Average revenue per transaction from April 1, 2005 to April 30, 2005 for stores in Texas. Return the date and the average revenue per transaction for the date.
•	To get average revenue per transaction (column names would change based on the schema you created):
SUM(purchase_revenue) / SUM(purchase_transaction_count) AS average_revenue_per_transaction

2. Daily purchase count for a given department from April 7, 2005 to April 14, 2005. Return the date and the date's purchase count.  You can test the query with any of the departments.

3. The 5 lowest performing stores for April 1, 2005 to April 30, 2005 based on purchase revenue. Return the store ID and the store's total revenue for the entire date range.*/


#Operational 1:
SELECT 
    dim_date.SALEDATE,
    ROUND(SUM(fact_table_purchase.DAILY_AVG_REVENUE),
            2) AS 'AVG_REVENUE'
FROM
    dim_date
        JOIN
    fact_table_purchase ON dim_date.SALEDATE = fact_table_purchase.SALEDATE
        JOIN
    dim_store ON fact_table_purchase.STORE = dim_store.STORE
WHERE
    dim_date.MONTH_NAME = 'APRIL'
        AND dim_date.YEAR = '2005'
        AND dim_store.STATE = 'TX'
GROUP BY dim_date.SALEDATE , dim_date.YEAR;

#Operational 2: DEPT 8101 / DEPTDESC ECHO
SELECT 
    dim_date.SALEDATE,
    SUM(fact_table_purchase.DAILY_PURCHASE_COUNT) AS 'TOTAL_COUNT'
FROM
    dim_date
        JOIN
    fact_table_purchase ON dim_date.SALEDATE = fact_table_purchase.SALEDATE
        JOIN
    dim_SKU ON fact_table_purchase.SKU = dim_SKU.SKU
WHERE
    dim_SKU.DEPT = '8101'
        AND dim_date.SALEDATE BETWEEN '2005-04-07' AND '2005-04-14'
GROUP BY dim_date.SALEDATE;

#Operational 3: 
SELECT 
    dim_store.STORE,
    dim_date.SALEDATE,
    ROUND(SUM(fact_table_purchase.DAILY_TOTAL_REVENUE),
            2) AS 'TOTAL_REVENUE'
FROM
    fact_table_purchase
        JOIN
    dim_date ON dim_date.SALEDATE = fact_table_purchase.SALEDATE
        JOIN
    dim_store ON fact_table_purchase.STORE = dim_store.STORE
WHERE
    dim_date.SALEDATE BETWEEN '2005-04-01' AND '2005-04-30'
GROUP BY fact_table_purchase.STORE
ORDER BY TOTAL_REVENUE ASC
LIMIT 5;

/*Analytical:
1. Top 10 SKUs based on quantity sold for May 7, 2005 to May 14, 2005. Return the SKU and the quantity sold for the SKU.

2. Top 3 department and city combinations based on revenue for December 1, 2004 to December 31, 2004. Return the department and city and the revenue for the department and city combination.

3. The number of returned items (STYPE = 'R') for each day of the week for June 2005. Return the day of the week name, i.e. Monday, Thursday, etc. and its returned items total.*/

#Analytical 1
SELECT 
    dim_SKU.SKU,
    SUM(fact_table_purchase.DAILY_TOTAL_QUANTITY) AS 'TOTAL_COUNT'
FROM
    dim_SKU
        JOIN
    fact_table_purchase ON fact_table_purchase.SKU = dim_SKU.SKU
        JOIN
    dim_date ON dim_date.SALEDATE = fact_table_purchase.SALEDATE
WHERE
    dim_date.SALEDATE BETWEEN '2005-05-07' AND '2005-05-14'
GROUP BY dim_SKU.SKU
ORDER BY TOTAL_COUNT DESC
LIMIT 10;

#Analytical 2
SELECT 
    dim_SKU.DEPT,
    dim_store.CITY,
    ROUND(SUM(fact_table_purchase.DAILY_TOTAL_REVENUE),
            2) AS 'TOTAL_REVENUE'
FROM
    dim_SKU
        JOIN
    fact_table_purchase ON fact_table_purchase.SKU = dim_SKU.SKU
        JOIN
    dim_store ON dim_store.STORE = fact_table_purchase.STORE
        JOIN
    dim_date ON dim_date.SALEDATE = fact_table_purchase.SALEDATE
WHERE
    dim_date.SALEDATE BETWEEN '2004-12-01' AND '2004-12-31'
GROUP BY dim_store.CITY, dim_SKU.DEPT
ORDER BY TOTAL_REVENUE DESC
LIMIT 3;

#Analytical 3
SELECT 
    dim_date.SALEDATE,
    dim_date.DAY,
    SUM(fact_table_return.DAILY_PURCHASE_COUNT) AS 'TOTAL_RETURNED_ITEMS'
FROM
    dim_date
        JOIN
    fact_table_return ON fact_table_return.SALEDATE = dim_date.SALEDATE
WHERE
    dim_date.SALEDATE BETWEEN '2005-06-01' AND '2005-06-30'
GROUP BY dim_date.SALEDATE;