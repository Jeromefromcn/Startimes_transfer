-- ��ȡ�ͻ���Ϣ 
-- �˻������֡�����˱������֡��ͻ��������ֶγ��ȶ���Ϊ256
ALTER TABLE customeren modify(customernamestr VARCHAR2(256));
ALTER TABLE accounten Modify(accountnamestr Varchar2(255));
ALTER TABLE acctbooken MODIFY (acctbooknamestr VARCHAR2(256));
ALTER TABLE subscriberen ADD(addinfostr4 VARCHAR2(50));
ALTER TABLE customeren MODIFY (LINKMANSTR Varchar2(256));

DROP TABLE fsboss_customer; 
CREATE TABLE fsboss_customer AS
SELECT t.*,
       ma.managesectionid  managesectionid, -- ����������ַ
       cla.customerlevelid customerlevelid -- ��������������
  FROM fsboss.customers_fs               t,
       fsboss.manageaddresses_fs         ma,
       fsboss.customerlevelagreements_fs cla,
       fsboss_places                     p
 WHERE t.defaultinstalladdressid IS NOT NULL
   AND t.defaultinstalladdressid = ma.id
   AND t.id = cla.customerid
   AND ma.managesectionid = p.id;
-- ������������
CREATE INDEX index_customer_id ON fsboss_customer(id);
-- ���ַ�������ֶ���������
CREATE INDEX index_customer_msid ON fsboss_customer(managesectionid);
-- ��������
CREATE INDEX index_fsboss_def_install_add ON fsboss_customer(defaultinstalladdressid);
-- ���ӷ���id�����ɷ���ʱ����
ALTER TABLE fsboss_customer add murotoid NUMBER(19);
-- ��������
CREATE INDEX index_cust_murotoid ON fsboss_customer(murotoid);

COMMIT;
