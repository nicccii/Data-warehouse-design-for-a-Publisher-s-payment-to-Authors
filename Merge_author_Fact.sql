
USE PublisherDW
GO

CREATE OR ALTER   PROCEDURE Merge_author_Fact
@RecordCount INT OUTPUT
AS
BEGIN

		MERGE INTO author_Fact tgt
		USING stg_author_Fact src ON tgt.au_id = src.au_id AND tgt.titlekey = src.titlekey
		WHEN MATCHED AND EXISTS 
		(SELECT src.TitleKey,src.royschedKey, src.titleauthorKey, src.au_id, src.amountpaid
		 except
		 SELECT tgt.TitleKey,tgt.royschedKey, tgt.titleauthorKey, tgt.au_id, tgt.amountpaid)
		THEN UPDATE
		SET 
			tgt.TitleKey = src.TitleKey,
			tgt.royschedKey = src.royschedKey,
			tgt.titleauthorKey = src.titleauthorKey,
			tgt.au_id = src.au_id,
			tgt.amountpaid = src.amountpaid

		WHEN NOT MATCHED BY TARGET THEN INSERT
		(
		    TitleKey ,
			royschedKey ,
			titleauthorKey ,
			au_id,
			amountpaid
		)
		VALUES
		(
			src.TitleKey ,
			src.royschedKey ,
			src.titleauthorKey ,
			src.au_id ,
			src.amountpaid
		);

		--Save the number of records touched by the MERGE statement and send the results back to SSIS
		SET @RecordCount = @@ROWCOUNT;
		SELECT @RecordCount;
	
END
GO