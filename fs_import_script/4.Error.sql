SELECT COUNT(*) FROM transfer_errors;
SELECT * FROM transfer_errors t ORDER BY t.errorno DESC;

/*SELECT * from MUROTOEN;
--问题1；导入方格时，mem字段太短
ALTER TABLE MUROTOEN MODIFY (MEM Varchar2(500));*/

/*
DELETE FROM transfer_errors;
commit;
*/

--SELECT * from fsboss_ser_instance fsi WHERE fsi.terminalid IN (1118999999735760095);



