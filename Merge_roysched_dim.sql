USE PublisherDW
GO

CREATE or ALTER PROCEDURE Merge_roysched_dim
@RecordCount INT OUTPUT
AS
BEGIN

		--Merge from the staging table into the final dimension table
		MERGE INTO roysched_dim tgt
		USING stg_roysched_dim src ON tgt.title_id = src.title_id
		WHEN MATCHED AND EXISTS 
                (
			select src.lorange, src.hirange, src.royalty
			except 
			select tgt.lorange, tgt.hirange, tgt.royalty
		)
		THEN UPDATE
		SET 
			tgt.lorange = src.lorange,
			tgt.hirange = src.hirange,
			tgt.royalty = src.royalty

		WHEN NOT MATCHED BY TARGET THEN INSERT
		(
		   title_id
		  ,lorange
		  ,hirange
		  ,royalty

		)
		VALUES
		(
			 src.title_id
			,src.lorange
			,src.hirange
			,src.royalty
		);

		--Save the number of records touched by the MERGE statement and send the results back to SSIS
		SET @RecordCount = @@ROWCOUNT;
		SELECT @RecordCount;
	
END
GO