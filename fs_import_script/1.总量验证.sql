-- ��֤��ַ����
SELECT COUNT(*) FROM fsboss_places t;
SELECT COUNT(*) FROM addressen t;


SELECT * from servicesegmenten;

-- ����ͼ����
SELECT COUNT(*) FROM fsboss_manageaddresses_fs;
SELECT COUNT(*) FROM murotoen m WHERE m.isenable = 1;

-- ��֤��Դ����
SELECT COUNT(*) FROM fsboss_phyresource t;
SELECT COUNT(*) FROM phyresourceen t;

-- ��֤�ͻ�����
SELECT COUNT(*) FROM fsboss_customer t;
SELECT COUNT(*) FROM customeren t;

-- ��֤�û�����
SELECT COUNT(*) FROM fsboss_subscriber t;
SELECT COUNT(*) FROM subscriberen t;

-- ��֤�����Ʒʵ������
SELECT COUNT(*) FROM fsboss_phy_instance;
SELECT COUNT(*) FROM instanceen i WHERE i.productchildtypeid = 1;

-- ��֤�����Ʒʵ������
SELECT COUNT(*) FROM fsboss_ser_instance;
SELECT COUNT(*) FROM instanceen i WHERE i.productchildtypeid = 2;

SELECT COUNT(*)
  FROM subscriberen        s, -- �û���
       customeren          c, --�ͻ���
       fsboss_ser_instance fsi -- �����Ʒʵ����ʱ��
 WHERE s.businessid = 2
   AND c.customerid_pk = s.customerid_pk
   AND fsi.terminalid = s.addinfostr3;

SELECT c.code, pi.*
  FROM fsboss_phy_instance pi, fsboss_customer c
 WHERE NOT EXISTS
 (SELECT '*' FROM subscriberen s WHERE s.addinfostr4 = pi.terminalid)
   AND c.id = pi.customerid;
