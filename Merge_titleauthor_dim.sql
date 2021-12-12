----create SCD Type 1 procedure
USE PublisherDW
GO

CREATE or ALTER PROCEDURE Merge_titleauthor_dim
@RecordCount INT OUTPUT
AS
BEGIN

		--Merge from the staging table into the final dimension table
		MERGE INTO titleauthor_dim tgt
		USING stg_titleauthor_dim src ON tgt.title_id = src.title_id
		WHEN MATCHED AND EXISTS 
                (
			select src.au_ord, src.royaltyper
			except 
			select tgt.au_ord, tgt.royaltyper
		)
		THEN UPDATE
		SET 
			tgt.au_ord = src.au_ord,
			tgt.royaltyper = src.royaltyper

		WHEN NOT MATCHED BY TARGET THEN INSERT
		(
		   title_id
		  ,au_ord
		  ,royaltyper

		)
		VALUES
		(
			 src.title_id
			,src.au_ord
			,src.royaltyper
		);

		--Save the number of records touched by the MERGE statement and send the results back to SSIS
		SET @RecordCount = @@ROWCOUNT;
		SELECT @RecordCount;
	
END
GO