Gift Card Data Generation Process

Data Generated Using SQL Server 2016

Step 1: Create a database, name does not matter.
Step 2: Run all table creation scripts in any order. (Found in "Table Create" folder)
Step 3: Run all table populate scripts in any order. (Found in "Table Populate" folder)
Step 4: Run "Data Generator Script" to fill WiredBrainCoffeeData and ThirdPartyData tables with data. (Adjust the number of rows to your liking)
Step 5: Export WiredBrainCoffeeData and ThirdPartyData rows to CSV file using SQL Server Import / Export Wizard.
		(Choose to export to flat CSV file)
		(Make sure to not include the column names for the first row)
		(When prompted to select the data to be exported, use the following queries for WiredBrainCoffeeData and ThirdPartyData, respectively)
		
		WiredBrainCoffeeData:
		SELECT StoreID, CardNumber, Status, DateIssued, DateActivated, DateVoided, DateExpires, CardType, AmountIssued, Balance, Notes FROM WiredBrainCoffeeData;
		
		ThirdPartyData:
		SELECT CardNumber, MerchantID, MerchantName, Status, DateIssued, DateActivated, DateVoided, DateExpires, CardType, Balance, PrintLocation, DatePrinted, CardVersion, AuthorizationCode FROM ThirdPartyData;

Caution! Edit these files in programs like Microsoft Excel at your own risk! You have been warned. :)

Feel free to generate as many rows or files as you'd like.