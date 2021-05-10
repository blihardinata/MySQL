-- Dataco Supply Chain's Database Schema
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
CREATE SCHEMA dataco_aws;
USE dataco_aws;

ALTER TABLE dim_rfm
	MODIFY COLUMN rfm_score FLOAT UNIQUE NOT NULL,
    MODIFY COLUMN customer_segments VARCHAR(100),
    ADD PRIMARY KEY (rfm_score); 
    
ALTER TABLE dim_customer 
	MODIFY COLUMN Customer_Id INT UNIQUE NOT NULL,
	MODIFY COLUMN Name VARCHAR(255),
    MODIFY COLUMN Address VARCHAR(255),
    MODIFY COLUMN State VARCHAR(255),
    MODIFY COLUMN City VARCHAR(255),
    MODIFY COLUMN Country VARCHAR(255),
    MODIFY COLUMN Zip VARCHAR(20),
    MODIFY COLUMN Latitude FLOAT,
    MODIFY COLUMN Longitude FLOAT,
    MODIFY COLUMN rfm_score FLOAT,
    ADD PRIMARY KEY (Customer_Id),
    ADD FOREIGN KEY (rfm_score)
        REFERENCES dim_rfm (rfm_score); 
        
ALTER TABLE dim_dept
	MODIFY COLUMN Dept_ID INT UNIQUE NOT NULL,
    MODIFY COLUMN Dept_Name VARCHAR(100),
    ADD PRIMARY KEY (Dept_ID);

ALTER TABLE dim_status
	MODIFY COLUMN Order_Status VARCHAR(255) UNIQUE NOT NULL,
    ADD PRIMARY KEY (Order_Status); 

ALTER TABLE dim_product
	MODIFY COLUMN Category_Id INT UNIQUE NOT NULL,
    MODIFY COLUMN Category_Name VARCHAR(100),
    ADD PRIMARY KEY (Category_Id);
    
ALTER TABLE dim_date 
	MODIFY COLUMN Date DATE UNIQUE NOT NULL,
	MODIFY COLUMN Year VARCHAR(4),
    MODIFY COLUMN Quarter INT(1),
    MODIFY COLUMN Month INT(2),
    MODIFY COLUMN Month_name VARCHAR(20),
    MODIFY COLUMN Week_no INT(2),
    MODIFY COLUMN Weekday INT,
    MODIFY COLUMN Day_no INT(2),
    MODIFY COLUMN Day VARCHAR(20),
    ADD PRIMARY KEY (DATE); 

ALTER TABLE dim_order
	MODIFY COLUMN Order_Id INT UNIQUE NOT NULL,
	MODIFY COLUMN Order_Country VARCHAR(255),
    MODIFY COLUMN Order_Zip VARCHAR(255),
    MODIFY COLUMN Order_Region VARCHAR(255),
    MODIFY COLUMN Delivery_Status VARCHAR(255),
    MODIFY COLUMN Shipping_Mode VARCHAR(255),
    MODIFY COLUMN Order_State VARCHAR(255),
    MODIFY COLUMN Market VARCHAR(20),
    MODIFY COLUMN Order_City VARCHAR(20),
    ADD PRIMARY KEY (Order_Id);
    
ALTER TABLE fact_table_gains
	MODIFY COLUMN Order_Id INT, 
    MODIFY COLUMN Date DATE,
    MODIFY COLUMN Category_Id INT,
    MODIFY COLUMN Order_Status VARCHAR(255),
    MODIFY COLUMN Dept_ID INT,
    MODIFY COLUMN Customer_Id INT,
    MODIFY COLUMN Daily_Purchase_Count FLOAT, 
    MODIFY COLUMN Average_Daily_Revenue FLOAT,
    MODIFY COLUMN Daily_Total_Revenue FLOAT,
    MODIFY COLUMN Average_Daily_Profit FLOAT, 
    MODIFY COLUMN Daily_Total_Profit FLOAT, 
	ADD FOREIGN KEY (Order_Id)
        REFERENCES dim_order (Order_Id),
	ADD FOREIGN KEY (Category_Id)
        REFERENCES dim_product (Category_Id),
	ADD FOREIGN KEY (Date)
        REFERENCES Date (dim_date),
	ADD FOREIGN KEY (Order_Status)
        REFERENCES dim_status (Order_Status),
	ADD FOREIGN KEY (Dept_ID)
        REFERENCES dim_dept (Dept_ID),
	ADD FOREIGN KEY (Customer_Id)
        REFERENCES dim_customer (Customer_Id);

ALTER TABLE fact_table_loss
	MODIFY COLUMN Order_Id INT, 
    MODIFY COLUMN Date DATE,
    MODIFY COLUMN Category_Id INT,
    MODIFY COLUMN Order_Status VARCHAR(255),
    MODIFY COLUMN Dept_ID INT,
    MODIFY COLUMN Customer_Id INT,
    MODIFY COLUMN Daily_Purchase_Count FLOAT, 
    MODIFY COLUMN Average_Daily_Revenue FLOAT,
    MODIFY COLUMN Daily_Total_Revenue FLOAT,
    MODIFY COLUMN Average_Daily_loss FLOAT, 
    MODIFY COLUMN Daily_Total_loss FLOAT, 
	ADD FOREIGN KEY (Order_Id)
        REFERENCES dim_order (Order_Id),
	ADD FOREIGN KEY (Category_Id)
        REFERENCES dim_product (Category_Id),
	ADD FOREIGN KEY (Order_Status)
        REFERENCES dim_status (Order_Status),
	ADD FOREIGN KEY (Dept_ID)
        REFERENCES dim_dept (Dept_ID),
	ADD FOREIGN KEY (Customer_Id)
        REFERENCES dim_customer (Customer_Id);
