SELECT * from addressen a WHERE a.addresscodestr = '00246';
UPDATE servicesegmenten t
   SET t.detailsegmentcodestr =
       SUBSTR(t.detailsegmentcodestr,1,9) || t.segmentcodestr
 WHERE t.segmenttype = 1;
SELECT * from servicesegment_addressen t WHERE t.addressid_pk = 156191;
UPDATE servicesegmenten s SET s.segmentcodestr = SUBSTR(s.segmentnamestr,0,INSTR(s.segmentnamestr,'_')-1)
WHERE s.segmenttype = 1;


SELECT SUBSTR(s.segmentnamestr,0,INSTR(s.segmentnamestr,'_')-1) from servicesegmenten s WHERE s.segmenttype = 1;

SELECT COUNT(*)
  FROM fsboss.areas a, fsboss.areamanagesections am
 WHERE a.endlifecycle =
       to_date('9999/12/31 23:59:59', 'yyyy/MM/dd hh24:mi:ss')
   AND am.areaid = a.id;

SELECT *
  FROM fsboss.areas a
 WHERE a.endlifecycle =
       to_date('9999/12/31 23:59:59', 'yyyy/MM/dd hh24:mi:ss');

SELECT *
  FROM fsboss.areamanagesections t, fsboss.places p
 WHERE t.areaid IN (9223372029566190100, 9223372030202129657)
   AND t.managesectionid = p.id
   AND p.endlifecycle =
       to_date('9999/12/31 23:59:59', 'yyyy/MM/dd hh24:mi:ss');

SELECT a.name, a.endlifecycle, o.name, p.fullname, p.id
  FROM fsboss.areamanagesections t,
       fsboss.places             p,
       fsboss.areas              a,
       fsboss.operationroles     o
 WHERE a.endlifecycle <>
       to_date('9999/12/31 23:59:59', 'yyyy/MM/dd hh24:mi:ss')
   AND t.managesectionid = p.id
   AND p.endlifecycle =
       to_date('9999/12/31 23:59:59', 'yyyy/MM/dd hh24:mi:ss')
   AND t.areaid = a.id
   AND o.id = a.operationroleid;

SELECT t.*, ROWID FROM servicesegmenten t WHERE t.segmentid_pk = -1;

SELECT a.operationroleid FROM fsboss.areas a GROUP BY a.operationroleid;

SELECT a.operationroleid, o.name
  FROM fsboss.areas a, fsboss.operationroles o
 WHERE a.operationroleid = o.id
   AND a.endlifecycle =
       to_date('9999/12/31 23:59:59', 'yyyy/MM/dd hh24:mi:ss')
 GROUP BY a.operationroleid, o.name;

SELECT a.name || '_' || a.description,
       a.id,
       s.segmentid_pk,
       s.detailsegmentcodestr,
       s.detailsegmentnamestr
  FROM fsboss.areas a, servicesegmenten s
 WHERE a.endlifecycle =
       to_date('9999/12/31 23:59:59', 'yyyy/MM/dd hh24:mi:ss')
   AND s.segmentnamestr = '数字片区'
   AND s.mem = a.operationroleid;



SELECT s.servicestr from instanceen t,subscriberen s WHERE t.productchildtypeid = 2 
AND NOT EXISTS (SELECT '*' from priceinstanceen i WHERE i.instanceid_pk = t.instanceid_pk)
AND s.subscriberid_pk = t.subscriberid_pk;

SELECT t.*,ROWID from fsboss_products t;
DELETE FROM fsboss_products t;
SELECT * from producten p,fsboss_products fp WHERE p.productchildtypeid = 2
AND fp.name = p.productnamestr;

SELECT * from priceplanen t WHERE t.priceplannamestr = '集团临时价格计划-24';

SELECT '90009'|| from dicten t WHERE t.dicttypeidl_pk = 1202;

SELECT p.productid_pk,fp.id,p.productid_pk,fp.name,'服务产品PK' from producten p,fsboss_products fp WHERE p.productchildtypeid = 2
AND fp.name = p.productnamestr;

SELECT t.serviceproduct_id from fsboss_ser_instance t GROUP BY t.serviceproduct_id;

SELECT * from fsboss_products;

SELECT s.authenticationtypeid_pk from subscriberen s WHERE s.businessid = 3 AND s.servicestr  = '308193'

SELECT t.keeperid,t.id from fsboss_phyresource t
WHERE NOT EXISTS(SELECT 'x' from basedata_transfer b WHERE to_char(t.keeperid) = b.oldid);


SELECT o.name 区域公司, ma.name 门址名称, ma.fullname 地址全称, s.name
  FROM fsboss.manageaddresses_fs ma,
       fsboss.places             p,
       fsboss.operationroles     o,
       fsboss.simpletypes        s
 WHERE ma.managesectionid = p.id
   AND p.operationroleid = o.id
   AND NOT EXISTS (SELECT 'x' FROM temp_table t WHERE t.id = ma.id)
   AND s.id = ma.statusid
 ORDER BY o.name;

SELECT o.name 区域公司, ma.name 门址名称, ma.fullname 地址全称, s.name
  FROM (SELECT t.id, t.name, t.fullname, t.statusid, t.managesectionid
          FROM fsboss_manageaddresses_fs t
         WHERE t.isformated = 1;

drop TABLE temp_places1;
drop TABLE temp_places2;
drop TABLE temp_building_parameters;
drop TABLE temp_manageaddresses_fs;

SELECT *
  FROM fsboss.manageaddresses_fs t
 WHERE regexp_like(t.name, '^[0-9]-[0-9]{4}$');
SELECT *
  FROM fsboss.manageaddresses_fs t
 WHERE regexp_like(t.name, '^[0-9]{2}-[0-9]{3}$');
SELECT *
  FROM fsboss.manageaddresses_fs t
 WHERE regexp_like(t.name, '^[0-9]{2}-[0-9]{4}$');

SELECT u.*, ROWID FROM uniten u;
SELECT m.*, ROWID FROM murotoen m;
SELECT f.*, ROWID FROM flooren f;

SELECT * FROM addressen a WHERE a.addressid_pk = 129763;

SELECT m.murotonamestr, u.unitnum, f.floornum
  FROM murotoen m, uniten u, flooren f
 WHERE m.unitid = u.unitid_pk
   AND m.floorid = f.floorid_pk;

SELECT t.*, ROWID FROM operareaen t;

SELECT c.operareaid FROM customeren c;

SELECT COUNT(*) FROM uniten u;
SELECT COUNT(*) FROM murotoen m WHERE m.isenable = 1;
SELECT COUNT(*) FROM flooren f;

SELECT SUM(COUNT(DISTINCT t.name))
  FROM fsboss_manageaddresses_fs t
 WHERE t.isformated = 1
 GROUP BY t.managesectionid;
SELECT COUNT(*) FROM fsboss_manageaddresses_fs t WHERE t.isformated = 0;
-- 385030  372207 46671
SELECT CASE
         WHEN COUNT(*) > 0 THEN
          1
         ELSE
          0
       END,
       COUNT(*)
  FROM fsboss_manageaddresses_fs fma
 WHERE fma.connectioncode = '5-2-1'
   AND fma.managesectionid = 9223372029888519075;

SELECT *
  FROM temp_building_parameters t
 WHERE t.managesectionid = 9223372030202780914;
SELECT DISTINCT t.name
  FROM fsboss_manageaddresses_fs t
 WHERE t.managesectionid = 9223372030202780914;
SELECT COUNT(*)
  FROM fsboss_manageaddresses_fs t
 WHERE t.isformated = 0
  SELECT * FROM addressen a WHERE a.mem = '9223372030202774335';


SELECT *
  FROM fsboss.places t, temp_building_parameters tt
 WHERE t.id = tt.managesectionid
   AND tt.id_in_starboss IS NULL;
SELECT * FROM addressen a WHERE a.addressid_pk = 129230;

SELECT COUNT(*) FROM fsboss_customer;

SELECT ma.managesectionid, ma.name
  FROM fsboss_customer c, fsboss_manageaddresses_fs ma
 WHERE c.defaultinstalladdressid = ma.id
 GROUP BY ma.managesectionid, ma.name
HAVING COUNT(*) > 2;

SELECT c.*, ma.*
  FROM fsboss_manageaddresses_fs ma, fsboss_customer c
 WHERE ma.managesectionid = 9223372030202773461
   AND ma.name = '4-402'
   AND c.defaultinstalladdressid = ma.id;

SELECT COUNT(*) FROM fsboss_customer c WHERE c.murotoid IS NULL;
SELECT * FROM muroto_custen;
SELECT c.*
  FROM fsboss_manageaddresses_fs t, fsboss_customer c
 WHERE t.managesectionid = 9223372029399200214
   AND c.defaultinstalladdressid = t.id;

SELECT * FROM temp_building_parameters t ORDER BY t.managesectionid;

SELECT COUNT(*) FROM temp_building_parameters;

SELECT ma.*
  FROM fsboss_customer t, fsboss_manageaddresses_fs ma
 WHERE t.id = 9223372029399200214
   AND ma.id = t.defaultinstalladdressid;
SELECT *
  FROM fsboss_manageaddresses_fs t
 WHERE t.managesectionid = 9223372030202773683;
SELECT *
  FROM temp_building_parameters t
 WHERE t.unitnum = 1
   AND t.floornum = 1
   AND t.murotonum = 1
   AND t.attachementnum <> 0;

SELECT * FROM addressen a WHERE a.detailaddressstr = '010205014022107575';
SELECT t.name
  FROM fsboss_manageaddresses_fs t
 WHERE t.managesectionid = 9223372030202781350;
SELECT DISTINCT t.name
  FROM fsboss_manageaddresses_fs t
 WHERE t.managesectionid = 9223372030202781350
   AND t.statusid = 3701;
SELECT DISTINCT t.name
  FROM fsboss_manageaddresses_fs t
 WHERE t.managesectionid = 9223372030202781350
   AND t.statusid = 3702;
SELECT DISTINCT t.name
  FROM fsboss_manageaddresses_fs t
 WHERE t.managesectionid = 9223372030202781350
   AND t.statusid = 3703;
SELECT DISTINCT t.statusid FROM fsboss_manageaddresses_fs t;
SELECT * FROM fsboss.simpletypes t WHERE t.id IN (3701, 3703, 3702);

SELECT t.*, ROWID FROM fsboss_products t WHERE t.name LIKE '%eoc%';

DELETE FROM depositrecorden;
DELETE FROM paymenten;
SELECT to_char(trunc(SYSDATE) - (1 / 86400), 'yyyyMMddhh24miss') FROM dual;

SELECT c.operareaid from customeren c;
SELECT * from producten p WHERE p.productchildtypeid = 1;
SELECT * FROM fsboss_products;
CREATE TABLE temp_temp_temp AS
SELECT pp.productid_pk,p.id,pp.productnamestr,p.name from fsboss_products p , producten pp
WHERE p.name = pp.productnamestr
/*
3701  未安装
3702  已安装
3703  已开通
*/

/*CREATE TABLE temp_table AS
   SELECT t.id
  FROM fsboss.manageaddresses_fs t
 WHERE regexp_like(t.name, '^[0-9]-[0-9]{3}$')

UNION

SELECT t.id
  FROM fsboss.manageaddresses_fs t
 WHERE regexp_like(t.name, '^[0-9]-[0-9]{4}$')

UNION

SELECT t.id
  FROM fsboss.manageaddresses_fs t
 WHERE regexp_like(t.name, '^[0-9]{2}-[0-9]{3}$')

UNION

SELECT t.id
  FROM fsboss.manageaddresses_fs t
 WHERE regexp_like(t.name, '^[0-9]{2}-[0-9]{4}$')

UNION

SELECT t.id
  FROM fsboss.manageaddresses_fs t
 WHERE regexp_like(t.name, '.*\D[0-9]-[0-9]{3}$')
   AND regexp_count(t.name, '[0-9]-[0-9]{3}') = 1
   AND regexp_count(t.name, '[0-9]-[0-9]{4}') = 0
   AND regexp_count(t.name, '[0-9]{2}-[0-9]{3}') = 0
   AND regexp_count(t.name, '[0-9]{2}-[0-9]{4}') = 0

UNION

SELECT t.id
  FROM fsboss.manageaddresses_fs t
 WHERE regexp_like(t.name, '^[0-9]-[0-9]{3}\D.*')
   AND regexp_count(t.name, '[0-9]-[0-9]{3}') = 1
   AND regexp_count(t.name, '[0-9]-[0-9]{4}') = 0
   AND regexp_count(t.name, '[0-9]{2}-[0-9]{3}') = 0
   AND regexp_count(t.name, '[0-9]{2}-[0-9]{4}') = 0*/
