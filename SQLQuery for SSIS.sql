
--------------to create ETLRun table
use PublisherDW
GO 

CREATE TABLE ETLRun
(
ETLRunKey INT NOT NULL IDENTITY PRIMARY KEY,
TableName varchar(200) NOT NULL,
ETLStatus varchar(25) NULL,
StartTime datetime NULL,
EndTime   datetime NULL,
RecordCount INT NULL
);
GO
-----------------------------------

-----------------------------------to create procedure to log records to ETLRUN table

CREATE PROCEDURE CreateETLLoggingRecord
	@TableName varchar(200),
	@ETLID INT OUTPUT
AS
BEGIN
	--Insert a new record into the ETLRun table and return the ETLID that was generated
    INSERT INTO ETLRun
           (TableName
           ,ETLStatus
           ,StartTime
           ,EndTime
           ,RecordCount)
     VALUES
           (@TableName
           ,'Running'
           ,getdate()
           ,NULL
           ,NULL)

	SET @ETLID = SCOPE_IDENTITY(); -- RETURNS LAST IDENTITY VALUE INSERTED INTO AN IDENTITY COLUMN

END
GO

------------------------------------------------------------------------------------------------


---------------------------------------to create procedure to update records on ETLRUN table
CREATE PROCEDURE UpdateETLLoggingRecord
	@ETLID INT,
	@RecordCount INT
AS
BEGIN
	--Insert a new record into the ETLRun table and return the ETLID that was generated
	update ETLRun 
	set	EndTime = getdate(),
		ETLStatus = 'Success',
		RecordCount = @RecordCount
	where ETLRunKey = @ETLID;

END
GO
-------------------------------------------------------------------------------------

---creating staging table for stg_titles_Dim
CREATE TABLE stg_titles_Dim
(
title_id char (20) PRIMARY KEY,
title varchar (80),
type char (12),
loc_id char (20),
price money,
advance money,
royalty int,
ytd_sales int,
notes varchar(200),
);
GO


---creating staging table for stg_roysched_dim
CREATE TABLE stg_roysched_dim
(
	title_id char(20),
	lorange int,
	hirange int,
	royalty int
	);

---creating staging table for stg_titleauthor_dim
CREATE TABLE stg_titleauthor_dim
(
title_id char(20),
au_ord tinyint,
royaltyper int
);
GO


---creating staging table for author_Fact
CREATE TABLE stg_author_Fact
(
TitleKey INT,
royschedKey INT,
titleauthorKey INT,
au_id char(20),
TID VARCHAR(10),
amountpaid INT
);
GO

select * from author_Fact


---Test: making changes to test price(SCD Type 2) column
---use Publisher DB



update titles
set price=12.95
where title='Fifty Years in Buckingham Palace Kitchens'

update titles
set price=18.99
where title_id='BU1032'

update titles
set price=25.00
where title_id='PC8888'


select * from titles