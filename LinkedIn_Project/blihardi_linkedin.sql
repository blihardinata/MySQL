/* Linkedin Project */

USE blihardi_linkedin

CREATE TABLE UserInfo (
    UserID INT NOT NULL,
    MembershipType VARCHAR(255) NOT NULL,
    Start_Date DATE,
    End_Date DATE,
    FOREIGN KEY (UserID)
        REFERENCES Profile (UserID),
    FOREIGN KEY (MembershipType)
        REFERENCES Membership (MembershipType)
);

CREATE TABLE Billing (
    Receipt INT AUTO_INCREMENT,
    UserID INT NOT NULL,
    MembershipType VARCHAR(255) NOT NULL,
    PaymentDate DATE,
    CreditCard INT NOT NULL UNIQUE,
    ExpirationDate DATE NOT NULL,
    Cardholder_Name VARCHAR(255) NOT NULL,
    Billing_Address VARCHAR(255),
    AmountPaid VARCHAR(255),
    PRIMARY KEY (Receipt),
    FOREIGN KEY (MembershipType)
        REFERENCES Membership (MembershipType)
);

CREATE TABLE Membership (
    MembershipType VARCHAR(255) NOT NULL UNIQUE,
    FeeAmount VARCHAR(255) NOT NULL,
    PRIMARY KEY (MembershipType)
);

CREATE TABLE Profile (
    UserID INT AUTO_INCREMENT,
    FirstName VARCHAR(255) NOT NULL,
    LastName VARCHAR(255) NOT NULL,
    Country VARCHAR(255) NOT NULL,
    Zip VARCHAR(255) NOT NULL,
    URL VARCHAR(255),
    Password VARCHAR(255) NOT NULL,
    Membership_since DATE,
    Email VARCHAR(255) NOT NULL,
    PRIMARY KEY (UserID)
);

CREATE TABLE Connection (
    UserID INT(25) NOT NULL,
    Type VARCHAR(255) NOT NULL,
    Connection_UserID INT NOT NULL,
    FOREIGN KEY (UserID)
        REFERENCES PROFILE (UserID),
    FOREIGN KEY (Connection_UserID)
        REFERENCES PROFILE (UserID)
);

CREATE TABLE Education (
    SchoolID VARCHAR(255) NOT NULL UNIQUE,
    Education VARCHAR(255) NOT NULL,
    Country VARCHAR(255) NOT NULL,
    City VARCHAR(255) NOT NULL,
    State VARCHAR(255) NOT NULL,
    Zip VARCHAR(255) NOT NULL,
    PRIMARY KEY (SchoolID)
);

CREATE TABLE Company (
    CompanyID VARCHAR(255) NOT NULL UNIQUE,
    Company VARCHAR(255) NOT NULL,
    City VARCHAR(255) NOT NULL,
    State VARCHAR(255) NOT NULL,
    Zip VARCHAR(255) NOT NULL,
    Country VARCHAR(255) NOT NULL,
    PRIMARY KEY (CompanyID)
);

CREATE TABLE JobExperience (
    UserID INT(25) NOT NULL,
    CompanyID VARCHAR(255) NOT NULL,
    StartDate DATE,
    EndDate DATE,
    Position VARCHAR(255),
    Description VARCHAR(255),
    FOREIGN KEY (UserID)
        REFERENCES Profile (UserID),
    FOREIGN KEY (CompanyID)
        REFERENCES Company (CompanyID)
);

CREATE TABLE EducationalExp (
    UserID INT(25) NOT NULL,
    SchoolID VARCHAR(255) NOT NULL,
    Degree VARCHAR(255),
    GraduationYear DATE,
    Major VARCHAR(255),
    FOREIGN KEY (UserID)
        REFERENCES Profile (UserID),
    FOREIGN KEY (SchoolID)
        REFERENCES Education (SchoolID)
);

/*
For every user, list his/her name and e-mail address along with the names and e-mail addresses of their 1st level connections.  
*/

CREATE VIEW User_Con AS
    SELECT 
        Profile.UserID,
        CONCAT(Profile.FirstName, ' ', Profile.LastName) AS 'User FullName',
        Profile.Email,
        Connection2.Connection_UserID
    FROM
        Profile
            JOIN
        Connection ON Profile.UserID = Connection.UserID
            JOIN
        Connection AS Connection2 ON Profile.UserID = Connection2.UserID;

SELECT 
    User_Con.UserID,
    User_Con.`User Fullname`,
    User_Con.Email,
    User_Con.Connection_UserID,
    CONCAT(Profile.FirstName, ' ', Profile.LastName) AS 'Connection FullName',
    Profile.Email
FROM
    User_Con
        JOIN
    Profile ON User_Con.Connection_UserID = Profile.UserID;


/*
How many free members does the company have? How long have they been a free member in term of days from the end of 2020?

A manager needs to implement a way to convert free customers into profitable customers. However, the manager needs to find out first who these customers are
*/

CREATE VIEW User_last AS
    SELECT 
        *, STR_TO_DATE('2020-12-31', '%Y-%m-%d') AS 'LastDate'
    FROM
        UserInfo;

SELECT 
    CONCAT(Profile.FirstName, ' ', Profile.LastName) AS 'FullName',
    User_last.Start_Date,
    CEILING(DATEDIFF(User_last.LastDate, User_last.Start_Date)) AS 'Days_since_membership'
FROM
    User_last
        JOIN
    Profile ON User_last.UserID = Profile.UserID
WHERE
    User_last.MembershipType = 'Free';


/*
The company wants to know what states the users graduated from

It is important for the company to know where the majority of their users goes to school especially when the company wants to build educational activities together. 
*/ 

SELECT 
    SchoolID, State, COUNT(*)
FROM
    Education
GROUP BY State;

#We found that most of the schools are around California

SELECT 
    EducationalExp.UserID,
    CONCAT(Profile.FirstName, ' ', Profile.LastName) AS 'FullName',
    Education.SchoolID,
    Education.Education,
    Education.State
FROM
    Profile
        JOIN
    EducationalExp ON Profile.UserID = EducationalExp.UserID
        JOIN
    Education ON EducationalExp.SchoolID = Education.SchoolID
WHERE
    Education.State = 'CA';

/*
Create a query that would show the total due for each user for 2020.  
*/

CREATE OR REPLACE VIEW BillingCycle AS
    SELECT 
        *, STR_TO_DATE('2020-12-31', '%Y-%m-%d') AS 'LastDate'
    FROM
        Billing
    WHERE
        MembershipType = "Premium";

SELECT 
    Cardholder_Name,
    CEILING(DATEDIFF(LastDate, PaymentDate) / 30) * PaymentDate AS 'totaldue'
FROM
    BillingCycle;

    

