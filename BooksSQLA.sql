use BookAnalysis
go


Create Table Books_SQLA(
    ID FLOAT not null,
	Book_Title nvarchar(max) not null,
	Amazon_Price float not null,
	Price_Category varchar(100) not null,
	Price_Rating_Value float not null,
	Authors_Name varchar(max) not null,
	Published_Date nvarchar(max) not null,
	Published_Year int not null,
	Publisher varchar(100) not null,
    Publisher_Popularity varchar(100) not null,
	Binding_Info varchar(100) not null,
	Books_Age int not null, 
	Age_Category varchar(100) not null,
	No_of_Pages int not null,
	Amazon_Sales_Rank bigint not null,
	Amazon_Count bigint not null,
	B_Description varchar(max) not null,
	B_Categories varchar(max) not null,
	Category_Count int not null,
	Aggregate_Rating float not null,
	Rating_Count int not null,
	Rating_Category varchar(max) not null, 
	Readers_Sentiment varchar(max) not null
); 



select * from Books_SQLA
--drop table Books_SQLA

--Checking unique values
select distinct Price_Category from Books_SQLA -- 3 distinct values
select distinct Authors_Name from Books_SQLA -- 1200+ distinct authors 
select distinct Book_Title from Books_SQLA -- 2100+ distinct book title
select distinct Publisher from Books_SQLA -- 522 distinct Publishers
select distinct Published_year from Books_SQLA -- 66 total disti
select distinct Publisher_Popularity from Books_SQLA -- 4 distinct values
select distinct Binding_Info from Books_SQLA -- 21 distinct values
select distinct Age_Category from Books_SQLA -- 4 distinct values
select distinct B_Categories from Books_SQLA -- 776 distinct values
select distinct Rating_Category from Books_SQLA -- 3 distinct values
select distinct Readers_Sentiment from Books_SQLA -- 3 distinct values

-- Select books with Amazon Price with conditions < or >
SELECT * FROM Books_SQLA WHERE Amazon_Price > 10;

-- Select books published after whichever year and sort by Amazon Sales Rank
SELECT * FROM Books_SQLA WHERE Published_Year > 2022 ORDER BY Amazon_Sales_Rank;

-- Count the number of books in each Price Category
SELECT Price_Category, COUNT(*) AS Count FROM Books_SQLA GROUP BY Price_Category;

-- Calculate average Aggregate Rating
SELECT AVG(Aggregate_Rating) as Overall_Average_Rating FROM Books_SQLA;

-- Calculate the average Amazon Price for each Price Category
SELECT Price_Category, AVG(Amazon_Price) AS Avg_Price FROM Books_SQLA GROUP BY Price_Category;

-- Find books with higher than average Amazon Price
SELECT Book_Title FROM Books_SQLA WHERE Amazon_Price > (SELECT AVG(Amazon_Price) FROM Books_SQLA);

-- Count the number of books in each Age Category
SELECT Age_Category, COUNT(*) AS Count
FROM Books_SQLA
WHERE Age_Category LIKE '%Old%'
   OR Age_Category LIKE '%Moderate Age%'
   OR Age_Category LIKE '%Recent%'
   OR Age_Category LIKE '%New Release%'
GROUP BY Age_Category;

-- Convert Amazon Price to a different currency (hypothetical conversion factor)
SELECT ID, Book_Title, Amazon_Price * 1.2 AS Price_Euro FROM Books_SQLA;

-- Calculate rank based on Amazon Sales Rank within each Price Category
SELECT *, RANK() OVER(PARTITION BY Price_Category ORDER BY Amazon_Sales_Rank) AS Rank FROM Books_SQLA;

-- Calculate average Price Rating Value using CTE
WITH AvgPriceRating AS (
    SELECT AVG(Price_Rating_Value) AS Avg_Price_Rating FROM Books_SQLA
)
SELECT * FROM AvgPriceRating;

--common Age Category for each Price Category
SELECT Price_Category, Age_Category, COUNT(*) AS Common_Count
FROM Books_SQLA
GROUP BY Price_Category, Age_Category
ORDER BY Price_Category, Common_Count DESC;

--Rank books by Amazon Price within each Age Category:
SELECT ID, Book_Title, Age_Category, Amazon_Price, 
    RANK() OVER (PARTITION BY Age_Category ORDER BY Amazon_Price DESC) AS PriceRank
FROM Books_SQLA;

--Rank books by Amazon Price within each Age Category and calculate the percentile rank:
SELECT ID, Book_Title, Age_Category, Amazon_Price,
       RANK() OVER (PARTITION BY Age_Category ORDER BY Amazon_Price DESC) AS Price_Rank,
       PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY Amazon_Price) OVER (PARTITION BY Age_Category) AS Median_Price
FROM Books_SQLA;

--Count the occurrences of specific keywords in book descriptions:
SELECT 'All the Books' AS Keyword, COUNT(*) AS Count
FROM Books_SQLA
WHERE B_Description LIKE '%AI%'
UNION
SELECT 'Life' AS Keyword, COUNT(*) AS Count
FROM Books_SQLA
WHERE B_Description LIKE '%Life%';


--Time Series

SELECT 
    YEAR(CAST(Published_Date AS DATE)) AS Pub_Year,
    MONTH(CAST(Published_Date AS DATE)) AS Pub_Month,
    AVG(Amazon_Price) AS Avg_Price,
    AVG(AVG(Amazon_Price)) OVER (ORDER BY YEAR(CAST(Published_Date AS DATE)), MONTH(CAST(Published_Date AS DATE)) 
                                ROWS BETWEEN 2 PRECEDING AND 2 FOLLOWING) AS Moving_Avg_Price
FROM Books_SQLA
WHERE ISDATE(Published_Date) = 1
GROUP BY YEAR(CAST(Published_Date AS DATE)), MONTH(CAST(Published_Date AS DATE))
ORDER BY Pub_Year, Pub_Month;

--calculate the total sales count for each year based on the Amazon sales rank and aggregate rating of books:
SELECT 
    YEAR(CAST(Published_Date AS DATE)) AS Pub_Year,
    SUM(Amazon_Sales_Rank * Aggregate_Rating) AS Total_Sales
FROM Books_SQLA
WHERE ISDATE(Published_Date) = 1
GROUP BY YEAR(CAST(Published_Date AS DATE))
ORDER BY Pub_Year;

--analyze the trend in the number of books published over the years
SELECT 
    Published_Year,
    COUNT(*) AS Num_Books_Published
FROM Books_SQLA
WHERE ISNUMERIC(Published_Year) = 1
GROUP BY Published_Year
ORDER BY Published_Year;

--finds top author and their books average price
WITH TopAuthors AS (
    SELECT Authors_Name as Top_Authors, AVG(Amazon_Price) AS Avg_Price
    FROM Books_SQLA
    GROUP BY Authors_Name
)
SELECT Top_Authors, Avg_Price
FROM TopAuthors
WHERE Avg_Price > (SELECT AVG(Avg_Price) FROM TopAuthors);













