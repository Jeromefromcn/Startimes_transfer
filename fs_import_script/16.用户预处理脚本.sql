-- ����p1�� 
DROP TABLE temp_places1;
CREATE TABLE temp_places1 AS
SELECT fsboss.get_strarraystrofindex(sys_connect_by_path(p.id, '>'), '>', 1) cid,
       p.id,
       p.operationroleid,
       p.endlifecycle
  FROM fsboss.places p
 START WITH p.parentid IS NOT NULL
CONNECT BY PRIOR p.parentid = p.id;
-- ��������
CREATE INDEX index_places1_1 ON temp_places1(ID);
CREATE INDEX index_places1_2 ON temp_places1(operationroleid);
CREATE INDEX index_places1_3 ON temp_places1(cid);
-- ����p2��
DROP TABLE temp_places2;
CREATE TABLE temp_places2 AS
SELECT pa1.operationroleid, pa2.id, pa2.code, pa2.endlifecycle, pa2.name
  FROM fsboss.places pa1, fsboss.places pa2
 WHERE pa1.parentid IS NULL
   AND pa2.parentid = pa1.id;
-- ��������
CREATE INDEX index_places2_1 ON temp_places2(ID);
CREATE INDEX index_places2_2 ON temp_places2(operationroleid);
-- ��ȡ�����û���Ϣ
DROP TABLE fsboss_subscriber;
CREATE TABLE fsboss_subscriber AS
-- ������롢ҵ�����͡��û����͡��ϴ�ͣ��ʱ�䡢�ն˺š����ն˱�ʶ���û�״̬
-- �����ܿ��� 299932 ���53�����л����������ܿ�
SELECT pd.*,
       sc.code servicestr, -- �û��������
       2 type_of_service, -- ҵ������
       t.masterid masterid, -- ���ն˱�ʶ
       t.terminalspecificationid terminalspecificationid, -- �ն����ͱ�ʶ���Ƿ����ն�
       decode(t.terminalspecificationid,
              9223372032954843176,
              1,
              t.serialnumber + 2) seqstr, -- �ն˺�
       1 accesspointid, -- �����id
       eu.organizationunit_id organizationunit_id, -- ��������id
       '��˳����-�����û�' mem,
       transfer_dvb_utils_pkg.fun_get_stb_type(pd.id) subscriber_tpye, -- �����û�����
       2 authenticationtypeid, -- CA��֤��ʽ
       202 equiptypeid -- �豸����
  FROM temp_places1                       p1,
       temp_places2                       p2,
       fsboss.manageaddresses_fs          m,
       fsboss.customers_fs                c,
       fsboss.products_fs                 pd,
       fsboss.productofferingattributes   poa,
       fsboss.simpletypes                 pos,
       fsboss.terminals_fs                t,
       fsboss.terminalspecifications      ts,
       fsboss.smartcards_fs               sc,
       fsboss.productphysicalresources_fs ppr,
       fsboss.products_fs                 scpd,
       fsboss.employee_organizationunit   eu
 WHERE p1.operationroleid = p2.operationroleid
   AND p1.id = p2.id
   AND m.managesectionid = p1.cid
   AND c.defaultinstalladdressid = m.id
   AND pd.customerid = c.id
   AND poa.productofferingid = pd.productofferingid
   AND pos.id = poa.domainobjectattributeid
   AND pos.code = 'Po_DigitalBase'
   AND t.id = pd.terminalid
   AND ts.id = t.terminalspecificationid
   AND pd.statusid IN (3602, 3604, 3609, 3612) -- ״̬Ϊ�������ͻ���ͣ��������ͣ��������ͣ
   AND scpd.id = ppr.productid
   AND ppr.physicalresourceid = sc.id
   AND scpd.terminalid = t.id
   AND eu.employee_id = pd.salesmanid
UNION

-- ��ȡģ���û���Ϣ

SELECT pd.*,
       nvl(c.optionalcode, c.code) servicestr, -- ������룺����ȡSMS�ͻ����룬û�е�ȡ�ͻ�����
       1 type_of_service, -- ҵ������
       t.masterid masterid, -- ���ն˱�ʶ
       t.terminalspecificationid terminalspecificationid, -- �ն����ͱ�ʶ���Ƿ����ն�
       decode(t.terminalspecificationid,
              9223372032954843176,
              1,
              t.serialnumber + 2) seqstr, -- �ն˺�
       NULL accesspointid, -- �����id
       eu.organizationunit_id organizationunit_id, -- ��������id
       '��˳����-ģ���û�' mem,
       1045 subscriber_tpye, -- ģ����ͨ�û�����
       1 authenticationtypeid, -- ģ����֤��ʽ
       NULL equiptypeid -- �豸����
  FROM fsboss.products_fs               pd, -- ���ϵͳ��Ʒ������
       fsboss.productofferings          po,
       fsboss.productofferingattributes poatt,
       fsboss.simpletypes               poatts,
       fsboss.customers_fs              c, --���ϵͳ�ͻ���
       fsboss.terminals_fs              t,
       fsboss.employee_organizationunit eu -- �����˼�¼
 WHERE pd.customerid = c.id
   AND c.defaultinstalladdressid IS NOT NULL --û����ַ�Ŀͻ�������
   AND pd.productofferingid = po.id
   AND po.id = poatt.productofferingid
   AND poatt.domainobjectattributeid = poatts.id
   AND pd.terminalid = t.id
   AND poatts.code = 'Po_Analog'
   AND eu.employee_id = pd.salesmanid
   AND pd.statusid IN (3601, 3602, 3604, 3605, 3612)

UNION

-- ��ȡ����û���Ϣ 

SELECT pd.*,
       TRIM(users.code) servicestr, -- ������루�ص㣩
       3 type_of_service, -- ҵ������
       t.masterid masterid, -- ���ն˱�ʶ
       t.terminalspecificationid terminalspecificationid, -- �ն����ͱ�ʶ���Ƿ����ն�
       decode(t.terminalspecificationid,
              9223372032954843176,
              1,
              t.serialnumber + 2) seqstr, -- �ն˺�
       NULL accesspointid, -- �����id
       eu.organizationunit_id organizationunit_id, -- ��������id
       '��˳����-����û�' mem,
       30451 subscriber_tpye, -- IP����
       3 authenticationtypeid, -- �����֤��ʽ
       NULL equiptypeid -- �豸����
  FROM fsboss.customers_fs              c, --���ϵͳ�ͻ���
       fsboss.products_fs               pd, --���ϵͳ��Ʒ������
       fsboss.productofferings          po, --���ϵͳ��Ʒ��
       fsboss.productofferingattributes poatt, --���ϵͳ��Ʒ���ͱ�
       fsboss.simpletypes               poatts, --���ϵͳ��Ʒ���ͱ�2
       fsboss.productservices_fs        pf, --���ϵͳ��Ʒ�����
       fsboss.userservices_fs           uf, --���ϵͳ�û����������
       fsboss.users_fs                  users, --���ϵͳ�û�����¼�û�����˺�
       fsboss.employee_organizationunit eu, -- �����˼�¼
       fsboss.terminals_fs              t
 WHERE pd.statusid IN (3601, 3602, 3604, 3605, 3612)
   AND pd.productofferingid = po.id
   AND po.id = poatt.productofferingid
   AND poatt.domainobjectattributeid = poatts.id
   AND poatts.code = 'Po_Broadband'
   AND pf.productid = pd.id
   AND pd.salesmanid = eu.employee_id(+)
   AND pf.serviceid = uf.serviceid
   AND t.id = pd.terminalid
   AND uf.userid = users.id
   AND c.id = pd.customerid
   AND c.defaultinstalladdressid IS NOT NULL
UNION

-- ��ȡ���ר���û���Ϣ 
SELECT pd.*,
       to_char(pd.id) servicestr, -- ������루�ص㣩
       3 type_of_service, -- ҵ������
       t.masterid masterid, -- ���ն˱�ʶ
       t.terminalspecificationid terminalspecificationid, -- �ն����ͱ�ʶ���Ƿ����ն�
       decode(t.terminalspecificationid,
              9223372032954843176,
              1,
              t.serialnumber + 2) seqstr, -- �ն˺�
       NULL accesspointid, -- �����id
       eu.organizationunit_id organizationunit_id, -- ��������id  
       '��˳����-���ר��' mem,
       30452 subscriber_tpye, -- ר������
       3 authenticationtypeid, -- �����֤��ʽ
       NULL equiptypeid -- �豸����
  FROM fsboss.customers_fs              c, --���ϵͳ�ͻ���
       fsboss.products_fs               pd, --���ϵͳ��Ʒ������
       fsboss.productofferings          po, --���ϵͳ��Ʒ��
       fsboss.productofferingattributes poatt, --���ϵͳ��Ʒ���ͱ�
       fsboss.simpletypes               poatts,
       fsboss.employee_organizationunit eu, --������
       fsboss.terminals_fs              t
 WHERE pd.statusid IN (3601, 3602, 3604, 3605, 3612)
   AND pd.productofferingid = po.id
   AND po.id = poatt.productofferingid
   AND poatt.domainobjectattributeid = poatts.id
   AND poatts.code = 'Po_Broadband'
   AND pd.salesmanid = eu.employee_id(+)
   AND c.id = pd.customerid
   AND pd.terminalid = t.id
   AND c.defaultinstalladdressid IS NOT NULL
   AND NOT EXISTS (SELECT 'x'
          FROM fsboss.productservices_fs pf
         WHERE pf.productid = pd.id);
         
-- ��������
CREATE INDEX index_subscriber_1 ON fsboss_subscriber(ID);
CREATE INDEX index_subscriber_2 ON fsboss_subscriber(customerid);


--ɾ���ظ�terminalid�У�statusΪ3612���û�
DELETE fsboss_subscriber dfs
 WHERE dfs.terminalid IN
       (SELECT fs.terminalid
          FROM fsboss_subscriber fs
         WHERE EXISTS (SELECT *
                  FROM fsboss_subscriber fd
                 WHERE fd.terminalid = fs.terminalid
                   AND fd.servicestr <> fs.servicestr))
   AND dfs.statusid = 3612;






COMMIT;





