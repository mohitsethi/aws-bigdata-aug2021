-- Console Queries.

SELECT SUM(WBC.amountissued)
FROM wbc.wbcdata WBC
WHERE WBC.status = 'Activated';

SELECT SUM(WBC.amountissued - WBC.balance)
FROM wbc.wbcdata WBC
WHERE WBC.status = 'Activated';

SELECT SUM(WBC.balance)
FROM wbc.wbcdata WBC 
WHERE WBC.status = 'Activated';

SELECT *
FROM wbc.wbcdata WBC
INNER JOIN wbc.thirdpartydata TP ON TP.cardnumber = WBC.cardnumber LIMIT 10;

SELECT COUNT(*) FROM wbc.wbcdata WBC 
INNER JOIN wbc.thirdpartydata TP ON TP.cardnumber = WBC.cardnumber
WHERE WBC.status = 'Voided';

SELECT * FROM wbc.wbcdata WBC 
INNER JOIN wbc.thirdpartydata TP ON TP.cardnumber = WBC.cardnumber
WHERE WBC.status = 'Voided';

-- SQL Workbench.

SELECT COUNT(*)
FROM wbc.wbcdata WBC
INNER JOIN wbc.thirdpartydata TP ON TP.cardnumber = WBC.cardnumber
WHERE WBC.balance <> TP.balance;

SELECT *
FROM wbc.wbcdata WBC
INNER JOIN wbc.thirdpartydata TP ON TP.cardnumber = WBC.cardnumber
WHERE WBC.balance <> TP.balance;

SELECT WBC.cardnumber, WBC.balance AS wbcbalance, TP.balance AS tpbalance, TP.status, WBC.cardtype
FROM wbc.wbcdata WBC
INNER JOIN wbc.thirdpartydata TP ON TP.cardnumber = WBC.cardnumber
WHERE WBC.balance <> TP.balance;

SELECT WBC.cardnumber, WBC.balance AS wbcbalance, TP.balance AS tpbalance, TP.status, WBC.cardtype
FROM wbc.wbcdata WBC
INNER JOIN wbc.thirdpartydata TP ON TP.cardnumber = WBC.cardnumber
WHERE WBC.balance <> TP.balance
AND (TP.status = 'Activated' OR TP.status = 'Issued');