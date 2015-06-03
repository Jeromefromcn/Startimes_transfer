
/*--��ѯ���boss�е��ն˺�
SELECT tf.serialnumber, t.name
  FROM hugeboss.terminals_fs tf, hugeboss.terminalspecifications t
 WHERE tf.terminalspecificationid = t.id;*/
 
 
--�����û����ϼ��û�;���ϵͳ����û�����¼���ϵ��
UPDATE subscriberen s
   SET s.parentid_fk =
       (SELECT st.subscriberid_pk
          FROM subscriberen st
         WHERE st.customerid_pk = s.customerid_pk
           AND st.subscriberseqstr = 1)
 WHERE s.subscriberseqstr > 1
   AND s.businessid = 2;
--���Ƕ����˸��徫ѡ��(productpk:1039)���û���Ϊ���ֵ��Ӹ����û�(dictidl_pk 1075) �������Ϊ(1076)
--����ʱĬ�϶�Ϊ�����ֵ���-���塱
/*SELECT * FROM dicten d WHERE d.dictstr LIKE '%����%';
SELECT * FROM producten p WHERE p.productnamestr LIKE '%����%';

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

