
/*--查询汇巨boss中的终端号
SELECT tf.serialnumber, t.name
  FROM hugeboss.terminals_fs tf, hugeboss.terminalspecifications t
 WHERE tf.terminalspecificationid = t.id;*/
 
 
--更新用户的上级用户;汇巨系统本身没有上下级关系；
UPDATE subscriberen s
   SET s.parentid_fk =
       (SELECT st.subscriberid_pk
          FROM subscriberen st
         WHERE st.customerid_pk = s.customerid_pk
           AND st.subscriberseqstr = 1)
 WHERE s.subscriberseqstr > 1
   AND s.businessid = 2;
--凡是订购了高清精选包(productpk:1039)的用户则为数字电视高清用户(dictidl_pk 1075) 否则标清为(1076)
--倒库时默认都为“数字电视-高清”
/*SELECT * FROM dicten d WHERE d.dictstr LIKE '%标清%';
SELECT * FROM producten p WHERE p.productnamestr LIKE '%高清%';

SELECT s.subscribertypeid, d.dictstr, COUNT(*)
  FROM subscriberen s, dicten d
 WHERE d.dictidl_pk = s.subscribertypeid
 GROUP BY s.subscribertypeid, d.dictstr;*/

UPDATE subscriberen s
   SET s.subscribertypeid = 1076
 WHERE s.businessid = 2
   AND NOT EXISTS (SELECT 'x'
          FROM instanceen i
         WHERE i.subscriberid_pk = s.subscriberid_pk
           AND i.productchildtypeid = 2
           AND i.productid = 1039);

