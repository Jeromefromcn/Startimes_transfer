create table basedata_transfer as select * from  fssms5.basedata_transfer;

create table fsboss_products as select * from fssms5.fsboss_products;

select object_name, machine, s.sid, s.serial#
  from v$locked_object l, dba_objects o, v$session s
 where l.object_id¡¡ = ¡¡o.object_id
   and l.session_id = s.sid;

select spid, osuser, s.program from v$session s,v$process p where s.paddr=p.addr and s.sid=2395 
