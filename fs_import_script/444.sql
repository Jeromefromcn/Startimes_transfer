SELECT --'drop table ' || t.table_name || ';' ||
 'create table ' ||
       t.table_name || ' as select * from ' || t.table_name || '@fsboss;'
  FROM user_tables t
 WHERE t.table_name IN ('EMPLOYEE_ORGANIZATIONUNIT');
select * from EMPLOYEE_ORGANIZATIONUNIT
