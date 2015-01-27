
SELECT t.errormsg,t.* FROM transfer_errors t ORDER BY t.errorno DESC;
/*
--shanchu delete
DELETE FROM transfer_errors;
commit;
*/
-- test