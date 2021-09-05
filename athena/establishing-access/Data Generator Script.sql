DECLARE @RowCount INT;
DECLARE @CardNumber BIGINT;
DECLARE @RowString VARCHAR(13);
DECLARE @Random INT;
DECLARE @Random2 INT;
DECLARE @Upper INT;
DECLARE @Lower INT;
DECLARE @InsertDate DATETIME;
DECLARE @MerchantID UNIQUEIDENTIFIER;
DECLARE @Balance MONEY;
DECLARE @NumberOfRowsToGenerate INT;

SET @NumberOfRowsToGenerate = 10000;
SET @Lower = -730;
SET @Upper = -300;
SET @RowCount = 0;
SET @CardNumber = 37482966448;
SET @MerchantID = NEWID();

DELETE FROM ThirdPartyData;
DELETE FROM WiredBrainCoffeeData;

WHILE @RowCount < @NumberOfRowsToGenerate
BEGIN
	SET @RowString = CAST(@CardNumber AS VARCHAR(13));
	SELECT @Random = ROUND(((@Upper - @Lower -1) * RAND() + @Lower), 0);
	SELECT @Random2 = ROUND(((200 - 10 - 1) * RAND() + 1), 0);
	SET @InsertDate = DATEADD(dd, @Random, GETDATE());
	SET @Balance = (SELECT TOP 1 * FROM PossibleBalances ORDER BY NEWID());
	INSERT INTO ThirdPartyData
		(CardNumber
		, MerchantID
		, MerchantName
		, [Status]
		, DateIssued
		, DateActivated
		, DateVoided
		, DateExpires
		, CardType
		, AmountIssued
		, Balance
		, PrintLocation
		, DatePrinted
		, CardVersion
		, AuthorizationCode)
	VALUES
		(REPLICATE('0', 13 - DATALENGTH(@RowString)) + @RowString
		, @MerchantID
		, 'Wired Brain Coffee'
		, (SELECT TOP 1 *
			FROM CardStatuses
			ORDER BY NEWID())
		, @InsertDate
		, DATEADD(dd, @Random2, @InsertDate)
		, NULL
		, NULL
		, (SELECT TOP 1 *
			FROM CardTypes
			ORDER BY NEWID())
		, @Balance
		, @Balance
		, (SELECT TOP 1 *
			FROM PrintLocations
			ORDER BY NEWID())
		, '2015-09-01 04:00:00'
		, 2.4
		, SUBSTRING(CONVERT(varchar(255), NEWID()), 0, 7))
	SET @RowCount = @RowCount + 1;
	SET @CardNumber = @CardNumber + 13;
END

UPDATE ThirdPartyData SET DateActivated = NULL WHERE [Status] = 'Issued';
UPDATE ThirdPartyData SET DateVoided = DATEADD(dd, (ROUND(((200 - 10 - 1) * RAND() + 1), 0)), DateActivated) WHERE [Status] = 'Voided';
UPDATE ThirdPartyData SET DatePrinted = '2014-09-01 04:00:00' WHERE PrintLocation = 'San Francisco';
UPDATE ThirdPartyData SET DatePrinted = '2014-08-12 12:00:00' WHERE PrintLocation = 'New York City';
UPDATE ThirdPartyData SET DatePrinted = '2014-06-01 04:00:00' WHERE PrintLocation = 'Seattle';
UPDATE ThirdPartyData SET DatePrinted = '2014-05-17 18:00:00' WHERE PrintLocation = 'Phoenix';
UPDATE ThirdPartyData SET Balance = 0.00 WHERE [Status] = 'Voided';
WITH SampleData AS (SELECT *, NEWID() AS ID FROM ThirdPartyData)
UPDATE SampleData SET Balance = (SELECT ROUND(CAST(Balance - RAND(CHECKSUM(NEWID())) * Balance AS MONEY),2)) WHERE [Status] = 'Activated' AND (SELECT ABS(CHECKSUM(ID) % 10)) > 1;
WITH SampleData AS (SELECT *, NEWID() AS ID FROM ThirdPartyData)
UPDATE SampleData SET Balance = 0.00 WHERE [Status] = 'Activated' AND (SELECT ABS(CHECKSUM(ID) % 10)) > 5;

INSERT INTO WiredBrainCoffeeData
SELECT NEWID(), 1, TPD.CardNumber, TPD.Status, TPD.DateIssued, TPD.DateActivated, TPD.DateVoided, TPD.DateExpires, TPD.CardType, TPD.AmountIssued, TPD.Balance, '' 
FROM ThirdPartyData TPD;
UPDATE WiredBrainCoffeeData SET StoreID = 2 WHERE (SELECT ABS(CHECKSUM(ID) % 100)) < 20;
UPDATE WiredBrainCoffeeData SET StoreID = 3 WHERE (SELECT ABS(CHECKSUM(ID) % 100)) > 20 AND (SELECT ABS(CHECKSUM(ID) % 100)) < 40;
UPDATE WiredBrainCoffeeData SET StoreID = 4 WHERE (SELECT ABS(CHECKSUM(ID) % 100)) > 40 AND (SELECT ABS(CHECKSUM(ID) % 100)) < 60;
UPDATE WiredBrainCoffeeData SET Notes = 'Mother''s Day Special' WHERE (SELECT ABS(CHECKSUM(ID) % 100)) < 3;
UPDATE WiredBrainCoffeeData SET Notes = 'Birthday Card' WHERE (SELECT ABS(CHECKSUM(ID) % 100)) > 3 AND (SELECT ABS(CHECKSUM(ID) % 100)) < 7;
UPDATE WiredBrainCoffeeData SET Notes = 'Father''s Day Deal' WHERE (SELECT ABS(CHECKSUM(ID) % 100)) > 7 AND (SELECT ABS(CHECKSUM(ID) % 100)) < 11;
UPDATE WiredBrainCoffeeData SET Notes = 'Bought 2 Got 1 Free' WHERE (SELECT ABS(CHECKSUM(ID) % 100)) > 11 AND (SELECT ABS(CHECKSUM(ID) % 100)) < 15;
UPDATE WiredBrainCoffeeData SET Balance = (Balance - 5.00) WHERE Balance > 5.00 AND AmountIssued >= 5.00 AND (SELECT ABS(CHECKSUM(ID) % 100)*2) > 33 AND (SELECT ABS(CHECKSUM(ID) % 100)*2) < 36;
UPDATE WiredBrainCoffeeData SET Balance = (Balance - 20.00) WHERE Balance > 20.00 AND AmountIssued >= 20.00 AND (SELECT ABS(CHECKSUM(ID) % 100)*2) > 36 AND (SELECT ABS(CHECKSUM(ID) % 100)*2) < 40; 
UPDATE WiredBrainCoffeeData SET Balance = (Balance + 10.00) WHERE (Balance + 10.00) < AmountIssued AND (SELECT ABS(CHECKSUM(ID) % 100)*2) > 40 AND (SELECT ABS(CHECKSUM(ID) % 100)*2) < 44; 
UPDATE WiredBrainCoffeeData SET Balance = (Balance + 15.00) WHERE (Balance + 15.00) < AmountIssued AND (SELECT ABS(CHECKSUM(ID) % 100)*2) > 44 AND (SELECT ABS(CHECKSUM(ID) % 100)*2) < 48; 