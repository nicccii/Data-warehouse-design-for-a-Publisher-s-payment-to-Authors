USE PublisherDW
GO


CREATE or ALTER PROCEDURE Merge_titles_dim_SCD12
@PackageStartTime datetime,
@RecordCount INT OUTPUT
AS
BEGIN
	
	/*
	title = Type 1
	type = Type 1
	price = Type 2
	advance	= Type 1
	royalty = Type 1
	ytd_sales = Type 1
	*/


		--Type 1 changes
		MERGE INTO titles_dim tgt
		USING stg_titles_dim src ON tgt.title_id = src.title_id
		WHEN MATCHED AND EXISTS 
		(	
			select src.title, src.type, src.advance, src.royalty, src.ytd_sales
			except 
			select tgt.title, tgt.type, tgt.advance, tgt.royalty, tgt.ytd_sales
		)
		THEN UPDATE
		SET
			tgt.title = src.title,
			tgt.type = src.type,
			tgt.advance = src.advance,
			tgt.royalty = src.royalty,
			tgt.ytd_sales = src.ytd_sales

		WHEN NOT MATCHED BY TARGET THEN INSERT
		(
		   title_id
		  ,title
		  ,price
		  ,advance
		  ,royalty
		  ,ytd_sales
		  ,StartDate
		  ,EndDate
		)
		VALUES
		(
			 src.title_id
			,src.title
			,src.price
			,src.advance
			,src.royalty
			,src.ytd_sales
			,@PackageStartTime
			,NULL
		);


	DECLARE @RecCount1 INT
	SET @RecCount1 = @@ROWCOUNT  ---variable to track rows that have been updated for SCD type 1 cols

		
	CREATE TABLE #titles_dim -- Local temporary table
	(
	title_id CHAR(20),
	title VARCHAR(80),
	price money,
	advance money,
	royalty int,
	ytd_sales int,
	StartDate datetime,
	EndDate datetime
	);


	--Type 2 Changes
	INSERT INTO #titles_dim
		   (title_id, title ,price ,advance ,royalty, ytd_sales, StartDate, EndDate)
	SELECT	title_id, title ,price ,advance ,royalty, ytd_sales, StartDate, EndDate	
    From (
		MERGE INTO titles_dim tgt
		USING stg_titles_dim src ON tgt.title_id = src.title_id
		WHEN MATCHED AND tgt.EndDate IS NULL AND EXISTS 
		(	
			select src.price
			except 
			select tgt.price
		)
		THEN UPDATE
		SET 
			tgt.EndDate = @PackageStartTime -- Update End Date of the expired record	

		-- getting values for active records
		Output $ACTION ActionOut, src.title_id, src.title, src.price, src.advance, src.royalty, src.ytd_sales,
			@PackageStartTime as StartDate, NULL as EndDate) AS a
	WHERE  a.ActionOut = 'UPDATE';

/*
The Merge statement can track the data that has changed, and whether it was an insert, update, or delete operation. 
This information can be returned by using the Output clause. 
*/
	insert into titles_dim
	(title_id, title ,price ,advance ,royalty, ytd_sales, StartDate, EndDate)
	select title_id, title ,price ,advance ,royalty, ytd_sales, StartDate, EndDate
	from #titles_dim;    


		--Save the number of records touched by the MERGE statement and send the results back to SSIS
		--@RecCount2 contains number of updates for type 2 cols

		DECLARE @RecCount2 INT
		SET @RecCount2 = @@ROWCOUNT
		SET @RecordCount = @RecCount1 + 2*@RecCount2; ---2*@RecCount2 to account for every inserted and updated rows in SCD type2 col
		SELECT @RecordCount;
	
END
GO
